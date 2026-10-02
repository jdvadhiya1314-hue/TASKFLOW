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

@WebServlet("/user/tasks/completed")
public class UserTasksCompletedServlet extends HttpServlet {
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
                    List<Task> assignedTasks = taskDAO.getTasksByAssignedUserAndStatus(loggedInUser.getId(), "COMPLETED");
                    request.setAttribute("assignedTasks", assignedTasks);
                    request.setAttribute("currentRoute", "/user/tasks/completed");
                    request.setAttribute("pageTitle", "Completed Tasks");
                } catch (Exception e) {
                    getServletContext().log("Error", e);
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load completed tasks.");
                    return;
                }
            }
        }
        
        request.getRequestDispatcher("/user/tasks.jsp").forward(request, response);
    }
}
