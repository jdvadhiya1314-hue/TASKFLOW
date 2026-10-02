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

@WebServlet("/user/tasks")
public class UserTasksServlet extends HttpServlet {
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
                    String search = request.getParameter("search");
                    String status = request.getParameter("status");
                    String priority = request.getParameter("priority");
                    String overdueStr = request.getParameter("overdue");
                    String sort = request.getParameter("sort");

                    Boolean overdue = "on".equals(overdueStr);

                    List<Task> assignedTasks = taskDAO.searchTasks(loggedInUser.getId(), search, status, priority, null, overdue, sort);
                    
                    request.setAttribute("assignedTasks", assignedTasks);
                    
                    request.setAttribute("searchParam", search);
                    request.setAttribute("statusParam", status);
                    request.setAttribute("priorityParam", priority);
                    request.setAttribute("overdueParam", overdue);
                    request.setAttribute("sortParam", sort);
                    
                    request.setAttribute("currentRoute", "/user/tasks");
                    request.setAttribute("pageTitle", "My Tasks");
                } catch (Exception e) {
                    getServletContext().log("Error", e);
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load tasks.");
                    return;
                }
            }
        }
        
        request.getRequestDispatcher("/user/tasks.jsp").forward(request, response);
    }
}
