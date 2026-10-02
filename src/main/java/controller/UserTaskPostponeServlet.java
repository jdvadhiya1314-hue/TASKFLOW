package controller;

import dao.PostponementRequestDAO;
import dao.TaskDAO;
import dao.TaskHistoryDAO;
import model.PostponementRequest;
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
import java.sql.Timestamp;
import java.util.List;

@WebServlet("/user/task/postpone")
public class UserTaskPostponeServlet extends HttpServlet {
    private TaskDAO taskDAO;
    private PostponementRequestDAO requestDAO;
    private TaskHistoryDAO historyDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        requestDAO = new PostponementRequestDAO();
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
            String requestedDeadlineStr = request.getParameter("requestedDeadline");
            String reason = request.getParameter("reason");
            
            if (requestedDeadlineStr == null || requestedDeadlineStr.trim().isEmpty() || reason == null || reason.trim().isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Required fields missing.");
                return;
            }

            Task task = taskDAO.getTaskById(id);
            if (task == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
                return;
            }
            
            if (task.getAssignedTo() == null || task.getAssignedTo() != loggedInUser.getId()) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied: You do not own this task.");
                return;
            }
            
            if ("COMPLETED".equals(task.getStatus())) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cannot postpone a completed task.");
                return;
            }
            
            Timestamp requestedDeadline = Timestamp.valueOf(requestedDeadlineStr.replace("T", " ") + ":00");
            if (!requestedDeadline.after(task.getDeadline())) {
                // Must be later than current deadline
                response.sendRedirect(request.getContextPath() + "/user/task/view?id=" + id + "&error=invalid_date");
                return;
            }

            // Check if there is already a PENDING request for this task
            List<PostponementRequest> existingRequests = requestDAO.getRequestsByUserId(loggedInUser.getId());
            for (PostponementRequest req : existingRequests) {
                if (req.getTaskId() == id && "PENDING".equals(req.getStatus())) {
                    response.sendRedirect(request.getContextPath() + "/user/task/view?id=" + id + "&error=pending_exists");
                    return;
                }
            }

            PostponementRequest postReq = new PostponementRequest();
            postReq.setTaskId(id);
            postReq.setUserId(loggedInUser.getId());
            postReq.setCurrentDeadline(task.getDeadline());
            postReq.setRequestedDeadline(requestedDeadline);
            postReq.setReason(reason);
            postReq.setStatus("PENDING");
            
            requestDAO.createRequest(postReq);
            
            TaskHistory history = new TaskHistory();
            history.setTaskId(task.getId());
            history.setUserId(loggedInUser.getId());
            history.setAction("POSTPONEMENT_REQUESTED");
            historyDAO.createHistory(history);
            
            try {
                dao.UserDAO userDAO = new dao.UserDAO();
                dao.NotificationDAO notificationDAO = new dao.NotificationDAO();
                List<User> admins = userDAO.getActiveAdmins();
                for (User adminUser : admins) {
                    model.Notification notification = new model.Notification();
                    notification.setUserId(adminUser.getId());
                    notification.setType("Postponement Request");
                    notification.setMessage(loggedInUser.getName() + " has requested a postponement for task: " + task.getTitle() + " (ID: " + task.getId() + ")");
                    notification.setRead(false);
                    notificationDAO.createNotification(notification);
                }
            } catch (Exception notifEx) {
                getServletContext().log("Failed to create notification", notifEx);
            }
            
            response.sendRedirect(request.getContextPath() + "/user/postponement-requests?success=requested");
        } catch (IllegalArgumentException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid date format.");
        } catch (Exception e) {
            getServletContext().log("Error in UserTaskPostponeServlet", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error requesting postponement.");
        }
    }
}
