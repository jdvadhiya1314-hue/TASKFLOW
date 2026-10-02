package controller;

import dao.TaskDAO;
import dao.TaskCommentDAO;
import dao.TaskHistoryDAO;
import dao.UserDAO;
import model.Task;
import model.TaskComment;
import model.TaskHistory;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/user/task/view")
public class UserTaskViewServlet extends HttpServlet {
    private TaskDAO taskDAO;
    private TaskCommentDAO commentDAO;
    private TaskHistoryDAO historyDAO;
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        commentDAO = new TaskCommentDAO();
        historyDAO = new TaskHistoryDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }
        
        User loggedInUser = (User) session.getAttribute("loggedInUser");
        
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Task task = taskDAO.getTaskById(id);
            
            if (task == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
                return;
            }
            
            if (task.getAssignedTo() == null || task.getAssignedTo() != loggedInUser.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not own this task.");
                return;
            }
            
            List<TaskComment> comments = commentDAO.getCommentsForTask(id);
            List<TaskHistory> historyList = historyDAO.getHistoryForTask(id);
            
            // Map users for comments and history
            java.util.Map<Integer, String> userMap = new java.util.HashMap<>();
            List<User> allUsers = userDAO.getAllUsers();
            for (User u : allUsers) {
                userMap.put(u.getId(), u.getName());
            }
            
            dao.TaskDependencyDAO dependencyDAO = new dao.TaskDependencyDAO();
            List<model.TaskDependency> dependencies = dependencyDAO.getDependenciesForTask(id);
            List<Task> allTasks = taskDAO.getAllTasks();
            java.util.Map<Integer, Task> taskMap = new java.util.HashMap<>();
            for (Task t : allTasks) {
                taskMap.put(t.getId(), t);
            }
            
            request.setAttribute("task", task);
            request.setAttribute("comments", comments);
            request.setAttribute("historyList", historyList);
            request.setAttribute("userMap", userMap);
            request.setAttribute("dependencies", dependencies);
            request.setAttribute("taskMap", taskMap);
            request.setAttribute("currentRoute", "/user/tasks");
            
            request.getRequestDispatcher("/user/task-view.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Task ID format.");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading task.");
        }
    }
}
