package controller;

import dao.TaskDAO;
import dao.TaskHistoryDAO;
import model.Task;
import model.TaskHistory;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/user/task/start")
public class UserTaskStartServlet extends HttpServlet {
    private TaskDAO taskDAO;
    private TaskHistoryDAO historyDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        historyDAO = new TaskHistoryDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedInUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
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
            
            if (!"ASSIGNED".equals(task.getStatus()) && !"PENDING".equals(task.getStatus())) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Task cannot be started from its current status.");
                return;
            }
            
            dao.TaskDependencyDAO dependencyDAO = new dao.TaskDependencyDAO();
            java.util.List<model.TaskDependency> deps = dependencyDAO.getDependenciesForTask(id);
            for (model.TaskDependency dep : deps) {
                Task prereq = taskDAO.getTaskById(dep.getPrerequisiteTaskId());
                if (prereq != null && !"COMPLETED".equals(prereq.getStatus())) {
                    String titleEnc = java.net.URLEncoder.encode(prereq.getTitle(), "UTF-8");
                    response.sendRedirect(request.getContextPath() + "/user/task/view?id=" + id + "&error=incomplete_dependency&blockedTitle=" + titleEnc + "&blockedStatus=" + prereq.getStatus());
                    return;
                }
            }
            
            task.setStatus("IN_PROGRESS");
            taskDAO.updateTask(task);
            
            TaskHistory history = new TaskHistory();
            history.setTaskId(task.getId());
            history.setUserId(loggedInUser.getId());
            history.setAction("TASK_STARTED");
            historyDAO.createHistory(history);
            
            response.sendRedirect(request.getContextPath() + "/user/task/view?id=" + id + "&success=started");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Task ID format.");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error starting task.");
        }
    }
}
