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

@WebServlet("/admin/postponement/action")
public class AdminPostponementActionServlet extends HttpServlet {
    private PostponementRequestDAO requestDAO;
    private TaskDAO taskDAO;
    private TaskHistoryDAO historyDAO;

    @Override
    public void init() throws ServletException {
        requestDAO = new PostponementRequestDAO();
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
        
        User admin = (User) session.getAttribute("loggedInUser");
        if (!"ADMIN".equals(admin.getRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String action = request.getParameter("action");
            String adminResponse = request.getParameter("adminResponse");

            PostponementRequest req = requestDAO.getRequestById(id);
            if (req == null || !"PENDING".equals(req.getStatus())) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Request not found or not PENDING.");
                return;
            }

            if ("reject".equalsIgnoreCase(action) && (adminResponse == null || adminResponse.trim().isEmpty())) {
                // optional: no error thrown
            }

            Task task = taskDAO.getTaskById(req.getTaskId());
            if (task == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found.");
                return;
            }

            Timestamp now = new Timestamp(System.currentTimeMillis());
            
            req.setAdminResponse(adminResponse);
            req.setRespondedAt(now);
            req.setRespondedBy(admin.getId());

            TaskHistory history = new TaskHistory();
            history.setTaskId(task.getId());
            history.setUserId(admin.getId());

            if ("approve".equalsIgnoreCase(action)) {
                req.setStatus("APPROVED");
                task.setDeadline(req.getRequestedDeadline());
                taskDAO.updateTask(task);
                history.setAction("POSTPONEMENT_APPROVED");
            } else if ("reject".equalsIgnoreCase(action)) {
                req.setStatus("REJECTED");
                history.setAction("POSTPONEMENT_REJECTED");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action.");
                return;
            }

            requestDAO.updateRequest(req);
            historyDAO.createHistory(history);
            
            try {
                dao.NotificationDAO notificationDAO = new dao.NotificationDAO();
                model.Notification notification = new model.Notification();
                notification.setUserId(req.getUserId());
                notification.setRead(false);
                
                if ("approve".equalsIgnoreCase(action)) {
                    notification.setType("Postponement Approved");
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM d, yyyy HH:mm");
                    String formattedDeadline = sdf.format(req.getRequestedDeadline());
                    notification.setMessage("Your postponement request for '" + task.getTitle() + "' has been approved. New deadline: " + formattedDeadline);
                } else if ("reject".equalsIgnoreCase(action)) {
                    notification.setType("Postponement Rejected");
                    String msg = "Your postponement request for '" + task.getTitle() + "' has been rejected.";
                    if (adminResponse != null && !adminResponse.trim().isEmpty()) {
                        msg += " Reason: " + adminResponse;
                    }
                    notification.setMessage(msg);
                }
                
                notificationDAO.createNotification(notification);
            } catch (Exception notifEx) {
                getServletContext().log("Notification Error", notifEx);
            }

            response.sendRedirect(request.getContextPath() + "/admin/postponement-requests?success=action");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid ID format.");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing action.");
        }
    }
}
