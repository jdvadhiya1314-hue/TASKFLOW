package controller;

import dao.TaskDAO;
import model.Task;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/admin/tasks")
public class TaskListServlet extends HttpServlet {
    private TaskDAO taskDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            String search = request.getParameter("search");
            String status = request.getParameter("status");
            String priority = request.getParameter("priority");
            String userStr = request.getParameter("user");
            String overdueStr = request.getParameter("overdue");
            String sort = request.getParameter("sort");

            Integer filterUser = null;
            if (userStr != null && !userStr.isEmpty() && !userStr.equals("All Users")) {
                try {
                    filterUser = Integer.parseInt(userStr);
                } catch (NumberFormatException ignored) {}
            }

            Boolean overdue = "on".equals(overdueStr);

            // Pass null for assignedTo, meaning it's an admin search
            List<Task> tasks = taskDAO.searchTasks(null, search, status, priority, filterUser, overdue, sort);
            
            dao.UserDAO userDAO = new dao.UserDAO();
            List<model.User> usersList = userDAO.getAllUsers();
            java.util.Map<Integer, String> userMap = new java.util.HashMap<>();
            for (model.User u : usersList) {
                userMap.put(u.getId(), u.getName());
            }
            
            request.setAttribute("tasks", tasks);
            request.setAttribute("userMap", userMap);
            request.setAttribute("activeUsers", userDAO.getActiveUsers());
            
            request.setAttribute("searchParam", search);
            request.setAttribute("statusParam", status);
            request.setAttribute("priorityParam", priority);
            request.setAttribute("userParam", userStr);
            request.setAttribute("overdueParam", overdue);
            request.setAttribute("sortParam", sort);
            
            request.setAttribute("currentStatus", status == null ? "All" : status);
            request.getRequestDispatcher("/admin/tasks.jsp").forward(request, response);
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Could not load tasks.");
        }
    }
}
