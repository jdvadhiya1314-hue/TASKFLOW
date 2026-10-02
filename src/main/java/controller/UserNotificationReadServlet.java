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

@WebServlet("/user/notifications/read")
public class UserNotificationReadServlet extends HttpServlet {
    private NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        notificationDAO = new NotificationDAO();
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
            int notificationId = Integer.parseInt(request.getParameter("id"));
            Notification notification = notificationDAO.getNotificationById(notificationId);
            
            if (notification == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Notification not found.");
                return;
            }
            
            if (notification.getUserId() != loggedInUser.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not own this notification.");
                return;
            }

            notificationDAO.markAsRead(notificationId);
            
            response.sendRedirect(request.getContextPath() + "/user/notifications");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Notification ID.");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error marking notification as read.");
        }
    }
}
