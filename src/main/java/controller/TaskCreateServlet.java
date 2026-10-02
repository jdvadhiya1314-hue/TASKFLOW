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

@WebServlet("/admin/task/create")
public class TaskCreateServlet extends HttpServlet {
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
            List<User> activeUsers = userDAO.getActiveUsers();
            request.setAttribute("users", activeUsers);
            request.getRequestDispatcher("/admin/task-create.jsp").forward(request, response);
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not load form.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String title = request.getParameter("title");
            String description = request.getParameter("description");
            String assignedToStr = request.getParameter("assignedTo");
            String startDateStr = request.getParameter("startDate");
            String deadlineStr = request.getParameter("deadline");
            String priority = request.getParameter("priority");

            if (title == null || title.trim().isEmpty()) {
                throw new IllegalArgumentException("Title is required.");
            }
            if (deadlineStr == null || deadlineStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Deadline is required.");
            }
            if (assignedToStr == null || assignedToStr.trim().isEmpty()) {
                throw new IllegalArgumentException("Assigned user is required.");
            }
            if (priority == null || (!priority.equals("LOW") && !priority.equals("MEDIUM") && !priority.equals("HIGH") && !priority.equals("URGENT"))) {
                throw new IllegalArgumentException("Invalid priority.");
            }

            // In a real app we parse actual datetime strings properly to Timestamp.
            // HTML datetime-local uses 'YYYY-MM-DDThh:mm'. We replace 'T' with space.
            Timestamp startDate = null;
            if (startDateStr != null && !startDateStr.isEmpty()) {
                startDate = Timestamp.valueOf(startDateStr.replace("T", " ") + ":00");
            } else {
                startDate = new Timestamp(System.currentTimeMillis());
            }
            Timestamp deadline = Timestamp.valueOf(deadlineStr.replace("T", " ") + ":00");

            if (deadline.before(startDate)) {
                throw new IllegalArgumentException("Deadline cannot be before start date.");
            }

            Task task = new Task();
            task.setTitle(title.trim());
            task.setDescription(description != null ? description.trim() : "");
            task.setAssignedTo(Integer.parseInt(assignedToStr));
            task.setStartDate(startDate);
            task.setDeadline(deadline);
            task.setPriority(priority);
            task.setStatus("ASSIGNED");
            
            User admin = (User) request.getSession().getAttribute("loggedInUser");
            task.setCreatedBy(admin.getId());

            taskDAO.createTask(task);
            
            // Record task creation history
            dao.TaskHistoryDAO historyDAO = new dao.TaskHistoryDAO();
            model.TaskHistory history = new model.TaskHistory();
            history.setTaskId(task.getId());
            history.setUserId(admin.getId());
            history.setAction("TASK_CREATED");
            historyDAO.createHistory(history);
            
            // If assigned to a user initially, record assignment
            if (task.getAssignedTo() != null) {
                model.TaskHistory assignHistory = new model.TaskHistory();
                assignHistory.setTaskId(task.getId());
                assignHistory.setUserId(admin.getId());
                assignHistory.setAction("TASK_ASSIGNED to user " + task.getAssignedTo());
                historyDAO.createHistory(assignHistory);
                
                try {
                    dao.NotificationDAO notificationDAO = new dao.NotificationDAO();
                    model.Notification notification = new model.Notification();
                    notification.setUserId(task.getAssignedTo());
                    notification.setType("New Task Assigned");
                    notification.setMessage("You have been assigned a new task: " + task.getTitle() + " (ID: " + task.getId() + ")");
                    notification.setRead(false);
                    notificationDAO.createNotification(notification);
                } catch (Exception notifEx) {
                    getServletContext().log("Failed to create notification", notifEx);
                }
            }
            
            // Success
            response.sendRedirect(request.getContextPath() + "/admin/tasks?success=created");
        } catch (Exception e) {
            getServletContext().log("Error in TaskCreateServlet", e);
            try {
                request.setAttribute("errorMessage", e.getMessage());
                request.setAttribute("users", userDAO.getActiveUsers());
                request.getRequestDispatcher("/admin/task-create.jsp").forward(request, response);
            } catch (Exception ex) {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "An error occurred.");
            }
        }
    }
}
