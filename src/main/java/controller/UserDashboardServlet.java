package controller;

import dao.TaskDAO;
import model.Task;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/user/dashboard")
public class UserDashboardServlet extends HttpServlet {
    private TaskDAO taskDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User loggedInUser = (User) session.getAttribute("loggedInUser");
            if (loggedInUser != null) {
                try {
                    int total = taskDAO.getTaskCount(loggedInUser.getId());
                    int pending = taskDAO.getTaskCountByStatus(loggedInUser.getId(), "ASSIGNED") + taskDAO.getTaskCountByStatus(loggedInUser.getId(), "PENDING");
                    int inProgress = taskDAO.getTaskCountByStatus(loggedInUser.getId(), "IN_PROGRESS");
                    int completed = taskDAO.getTaskCountByStatus(loggedInUser.getId(), "COMPLETED");
                    int overdue = taskDAO.getOverdueTasksCount(loggedInUser.getId());
                    
                    dao.NotificationDAO notificationDAO = new dao.NotificationDAO();
                    int unreadNotifications = notificationDAO.getUnreadCount(loggedInUser.getId());
                    
                    dao.TaskHistoryDAO historyDAO = new dao.TaskHistoryDAO();
                    java.util.List<model.TaskHistory> recentActivity = historyDAO.getRecentHistory(loggedInUser.getId(), 5);
                    
                    java.util.List<Task> upcomingTasks = taskDAO.getUpcomingTasks(loggedInUser.getId(), 5);
                    java.util.List<Task> overdueTasksList = taskDAO.getOverdueTasks(loggedInUser.getId());
                    
                    dao.UserDAO userDAO = new dao.UserDAO();
                    java.util.Map<Integer, String> userMap = new java.util.HashMap<>();
                    for (User u : userDAO.getAllUsers()) {
                        userMap.put(u.getId(), u.getName());
                    }
                    
                    request.setAttribute("totalTasks", total);
                    request.setAttribute("pendingTasks", pending);
                    request.setAttribute("inProgressTasks", inProgress);
                    request.setAttribute("completedTasks", completed);
                    request.setAttribute("overdueTasks", overdue);
                    request.setAttribute("unreadNotifications", unreadNotifications);
                    request.setAttribute("recentActivity", recentActivity);
                    request.setAttribute("upcomingTasks", upcomingTasks);
                    request.setAttribute("overdueTasksList", overdueTasksList);
                    request.setAttribute("userMap", userMap);
                    request.setAttribute("currentRoute", "/user/dashboard");
                } catch (Exception e) {
                    getServletContext().log("Error", e);
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load dashboard data.");
                    return;
                }
            }
        }
        
        request.getRequestDispatcher("/user/dashboard.jsp").forward(request, response);
    }
}
