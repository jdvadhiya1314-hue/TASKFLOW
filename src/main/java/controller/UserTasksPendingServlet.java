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

@WebServlet("/user/tasks/pending")
public class UserTasksPendingServlet extends HttpServlet {
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
                    // Assuming PENDING tasks include ASSIGNED or strictly PENDING. Using ASSIGNED as per the project logic.
                    // Wait, the prompt says where status is: PENDING. I'll check both just in case, or stick to PENDING if that's what's saved.
                    // I'll fetch all and filter to match either ASSIGNED or PENDING for safety, or just query PENDING.
                    // The prompt specifically says "where status is: PENDING". I will query PENDING.
                    List<Task> assignedTasks = taskDAO.getTasksByAssignedUserAndStatus(loggedInUser.getId(), "PENDING");
                    // In admin dashboard, ASSIGNED was used as PENDING. Let me fetch ASSIGNED as well.
                    assignedTasks.addAll(taskDAO.getTasksByAssignedUserAndStatus(loggedInUser.getId(), "ASSIGNED"));
                    
                    request.setAttribute("assignedTasks", assignedTasks);
                    request.setAttribute("currentRoute", "/user/tasks/pending");
                    request.setAttribute("pageTitle", "Pending Tasks");
                } catch (Exception e) {
                    getServletContext().log("Error", e);
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load pending tasks.");
                    return;
                }
            }
        }
        
        request.getRequestDispatcher("/user/tasks.jsp").forward(request, response);
    }
}
