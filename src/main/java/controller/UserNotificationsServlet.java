package controller;

import dao.NotificationDAO;
import model.Notification;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/user/notifications")
public class UserNotificationsServlet extends HttpServlet {
    private NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User loggedInUser = (User) session.getAttribute("loggedInUser");
            if (loggedInUser != null) {
                try {
                    List<Notification> notifications = notificationDAO.getNotificationsForUser(loggedInUser.getId());
                    request.setAttribute("notifications", notifications);
                    request.setAttribute("currentRoute", "/user/notifications");
                } catch (Exception e) {
                    getServletContext().log("Error", e);
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load notifications.");
                    return;
                }
            }
        }
        
        request.getRequestDispatcher("/user/notifications.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User loggedInUser = (User) session.getAttribute("loggedInUser");
            if (loggedInUser != null) {
                try {
                    String action = request.getParameter("action");
                    if ("markAllRead".equals(action)) {
                        notificationDAO.markAllAsRead(loggedInUser.getId());
                    } else if ("markRead".equals(action)) {
                        int notificationId = Integer.parseInt(request.getParameter("id"));
                        Notification notification = notificationDAO.getNotificationById(notificationId);
                        if (notification != null && notification.getUserId() == loggedInUser.getId()) {
                            notificationDAO.markAsRead(notificationId);
                        } else {
                            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
                            return;
                        }
                    }
                } catch (Exception e) {
                    getServletContext().log("Error", e);
                }
            }
        }
        response.sendRedirect(request.getContextPath() + "/user/notifications");
    }
}
