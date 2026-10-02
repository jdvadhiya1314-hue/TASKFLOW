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

@WebServlet("/admin/task/view")
public class TaskViewServlet extends HttpServlet {
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
            
            if (task.getAssignedTo() != null) {
                User assigned = userDAO.getUserById(task.getAssignedTo());
                request.setAttribute("assignedUser", assigned);
            }
            
            if (task.getCreatedBy() != null) {
                User creator = userDAO.getUserById(task.getCreatedBy());
                request.setAttribute("creator", creator);
            }
            
            dao.TaskCommentDAO commentDAO = new dao.TaskCommentDAO();
            dao.TaskHistoryDAO historyDAO = new dao.TaskHistoryDAO();
            
            java.util.List<model.TaskComment> comments = commentDAO.getCommentsForTask(id);
            java.util.List<model.TaskHistory> historyList = historyDAO.getHistoryForTask(id);
            
            java.util.Map<Integer, String> userMap = new java.util.HashMap<>();
            for (User u : userDAO.getAllUsers()) {
                userMap.put(u.getId(), u.getName());
            }
            
            dao.TaskDependencyDAO dependencyDAO = new dao.TaskDependencyDAO();
            java.util.List<model.TaskDependency> dependencies = dependencyDAO.getDependenciesForTask(id);
            java.util.List<Task> allTasks = taskDAO.getAllTasks();
            java.util.Map<Integer, Task> taskMap = new java.util.HashMap<>();
            for (Task t : allTasks) {
                taskMap.put(t.getId(), t);
            }
            
            request.setAttribute("comments", comments);
            request.setAttribute("historyList", historyList);
            request.setAttribute("userMap", userMap);
            request.setAttribute("dependencies", dependencies);
            request.setAttribute("allTasks", allTasks);
            request.setAttribute("taskMap", taskMap);
            
            request.setAttribute("task", task);
            request.getRequestDispatcher("/admin/task-view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Task ID format.");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading task.");
        }
    }
}
