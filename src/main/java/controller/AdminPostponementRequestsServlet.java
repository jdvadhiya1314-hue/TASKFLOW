package controller;

import dao.PostponementRequestDAO;
import dao.UserDAO;
import dao.TaskDAO;
import model.PostponementRequest;
import model.User;
import model.Task;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

@WebServlet("/admin/postponement-requests")
public class AdminPostponementRequestsServlet extends HttpServlet {
    private PostponementRequestDAO requestDAO;
    private UserDAO userDAO;
    private TaskDAO taskDAO;

    @Override
    public void init() throws ServletException {
        requestDAO = new PostponementRequestDAO();
        userDAO = new UserDAO();
        taskDAO = new TaskDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            List<PostponementRequest> requests = requestDAO.getAllRequests();
            
            Map<Integer, String> userMap = new HashMap<>();
            for (User u : userDAO.getAllUsers()) {
                userMap.put(u.getId(), u.getName() + " (" + u.getEmail() + ")");
            }
            
            Map<Integer, String> taskMap = new HashMap<>();
            for (Task t : taskDAO.getAllTasks()) {
                taskMap.put(t.getId(), t.getTitle());
            }
            
            request.setAttribute("postponementRequests", requests);
            request.setAttribute("userMap", userMap);
            request.setAttribute("taskMap", taskMap);
            
            request.getRequestDispatcher("/admin/postponement-requests.jsp").forward(request, response);
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load postponement requests.");
        }
    }
}
