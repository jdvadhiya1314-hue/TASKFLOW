package controller;

import dao.TaskCommentDAO;
import dao.TaskDAO;
import dao.TaskHistoryDAO;
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

@WebServlet("/user/task/comment")
public class UserTaskCommentServlet extends HttpServlet {
    private TaskDAO taskDAO;
    private TaskCommentDAO commentDAO;
    private TaskHistoryDAO historyDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
        commentDAO = new TaskCommentDAO();
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
            String message = request.getParameter("message");
            
            if (message == null || message.trim().isEmpty() || message.length() > 1000) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid comment.");
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
            
            TaskComment comment = new TaskComment();
            comment.setTaskId(id);
            comment.setUserId(loggedInUser.getId());
            comment.setMessage(message.trim());
            commentDAO.createComment(comment);
            
            TaskHistory history = new TaskHistory();
            history.setTaskId(task.getId());
            history.setUserId(loggedInUser.getId());
            history.setAction("COMMENT_ADDED");
            historyDAO.createHistory(history);
            
            response.sendRedirect(request.getContextPath() + "/user/task/view?id=" + id + "&success=comment_added");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid Task ID format.");
        } catch (Exception e) {
            getServletContext().log("Error in UserTaskCommentServlet", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error adding comment.");
        }
    }
}
