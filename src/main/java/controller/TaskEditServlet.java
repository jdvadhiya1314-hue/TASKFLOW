package controller;

import dao.TaskDAO;
import dao.UserDAO;
import model.Task;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/admin/task/edit")
public class TaskEditServlet extends HttpServlet {
    private TaskDAO taskDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Task task = taskDAO.getTaskById(id);
            if (task == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
                return;
            }
            
            List<User> activeUsers = userDAO.getActiveUsers();
            request.setAttribute("task", task);
            request.setAttribute("users", activeUsers);
            request.getRequestDispatcher("/admin/task-edit.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Task ID format.");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading task.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String assignedToStr = request.getParameter("assignedTo");
            String startDateStr = request.getParameter("startDate");
            String deadlineStr = request.getParameter("deadline");
            String priority = request.getParameter("priority");

            if (title == null || title.trim().isEmpty() || startDateStr == null || deadlineStr == null) {
                throw new IllegalArgumentException("Required fields missing.");
            }

            Timestamp startDate = Timestamp.valueOf(startDateStr.replace("T", " ") + ":00");
            Timestamp deadline = Timestamp.valueOf(deadlineStr.replace("T", " ") + ":00");

            if (deadline.before(startDate)) {
                throw new IllegalArgumentException("Deadline cannot be before start date.");
            }

            Task task = taskDAO.getTaskById(id);
            if (task == null) {
                throw new IllegalArgumentException("Task not found.");
            }

            task.setTitle(title);
            task.setDescription(description);
            
            Integer oldAssignedTo = task.getAssignedTo();
            
            if (assignedToStr != null && !assignedToStr.isEmpty()) {
                int newUserId = Integer.parseInt(assignedToStr);
                User assignedUser = userDAO.getUserById(newUserId);
                if (assignedUser == null || !"USER".equals(assignedUser.getRole())) {
                    throw new IllegalArgumentException("Assigned user must exist and have the USER role.");
                }
                task.setAssignedTo(newUserId);
            } else {
                task.setAssignedTo(null);
            }
            
            task.setStartDate(startDate);
            task.setDeadline(deadline);
            task.setPriority(priority);
            // Do NOT update status here. Status is managed by task lifecycle.
            
            taskDAO.updateTask(task);
            
            User admin = (User) request.getSession().getAttribute("loggedInUser");
            dao.TaskHistoryDAO historyDAO = new dao.TaskHistoryDAO();
            
            model.TaskHistory editHistory = new model.TaskHistory();
            editHistory.setTaskId(task.getId());
            editHistory.setUserId(admin.getId());
            editHistory.setAction("TASK_EDITED");
            historyDAO.createHistory(editHistory);
            
            // Record assignment change if any
            if ((oldAssignedTo == null && task.getAssignedTo() != null) ||
                (oldAssignedTo != null && !oldAssignedTo.equals(task.getAssignedTo()))) {
                model.TaskHistory assignHistory = new model.TaskHistory();
                assignHistory.setTaskId(task.getId());
                assignHistory.setUserId(admin.getId());
                assignHistory.setAction(task.getAssignedTo() == null ? "TASK_UNASSIGNED" : "TASK_ASSIGNED to user " + task.getAssignedTo());
                historyDAO.createHistory(assignHistory);
                
                if (task.getAssignedTo() != null) {
                    try {
                        dao.NotificationDAO notificationDAO = new dao.NotificationDAO();
                        model.Notification notification = new model.Notification();
                        notification.setUserId(task.getAssignedTo());
                        notification.setType("New Task Assigned");
                        notification.setMessage("You have been assigned a new task: " + task.getTitle() + " (ID: " + task.getId() + ")");
                        notification.setRead(false);
                        notificationDAO.createNotification(notification);
                    } catch (Exception notifEx) {
                        getServletContext().log("Notification Error", notifEx);
                    }
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/tasks?success=updated");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Task ID format.");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            try {
                // If it fails, reload the edit page
                int id = Integer.parseInt(request.getParameter("id"));
                Task task = taskDAO.getTaskById(id);
                request.setAttribute("task", task);
                request.setAttribute("users", userDAO.getActiveUsers());
                request.setAttribute("errorMessage", e.getMessage());
                request.getRequestDispatcher("/admin/task-edit.jsp").forward(request, response);
            } catch (Exception ex) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred.");
            }
        }
    }
}
