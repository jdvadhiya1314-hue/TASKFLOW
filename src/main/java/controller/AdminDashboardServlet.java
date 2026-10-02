package controller;

import dao.TaskDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {
    private TaskDAO taskDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            int totalTasks = taskDAO.getTaskCount();
            int pendingTasks = taskDAO.getTaskCountByStatus("ASSIGNED") + taskDAO.getTaskCountByStatus("PENDING");
            int inProgressTasks = taskDAO.getTaskCountByStatus("IN_PROGRESS");
            int completedTasks = taskDAO.getTaskCountByStatus("COMPLETED");
            int overdueTasks = taskDAO.getOverdueTasksCount();
            
            dao.PostponementRequestDAO requestDAO = new dao.PostponementRequestDAO();
            int postponementRequests = requestDAO.getPendingRequestCount();
            
            dao.TaskHistoryDAO historyDAO = new dao.TaskHistoryDAO();
            java.util.List<model.TaskHistory> recentActivity = historyDAO.getRecentHistory(10);
            
            java.util.List<model.Task> recentTasks = taskDAO.getRecentTasks(5);
            
            dao.UserDAO userDAO = new dao.UserDAO();
            java.util.Map<Integer, String> userMap = new java.util.HashMap<>();
            for (model.User u : userDAO.getAllUsers()) {
                userMap.put(u.getId(), u.getName());
            }

            request.setAttribute("totalTasks", totalTasks);
            request.setAttribute("pendingTasks", pendingTasks);
            request.setAttribute("inProgressTasks", inProgressTasks);
            request.setAttribute("completedTasks", completedTasks);
            request.setAttribute("overdueTasks", overdueTasks);
            request.setAttribute("postponementRequests", postponementRequests);
            request.setAttribute("recentActivity", recentActivity);
            request.setAttribute("recentTasks", recentTasks);
            request.setAttribute("userMap", userMap);

            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Dashboard loading failed.");
        }
    }
}
