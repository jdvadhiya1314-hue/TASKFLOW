package controller;

import dao.PostponementRequestDAO;
import model.PostponementRequest;
import model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/user/postponement-requests")
public class UserPostponementRequestsServlet extends HttpServlet {
    private PostponementRequestDAO requestDAO;

    @Override
    public void init() throws ServletException {
        requestDAO = new PostponementRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null) {
            User loggedInUser = (User) session.getAttribute("loggedInUser");
            if (loggedInUser != null) {
                try {
                    List<PostponementRequest> requests = requestDAO.getRequestsByUserId(loggedInUser.getId());
                    request.setAttribute("postponementRequests", requests);
                    request.setAttribute("currentRoute", "/user/postponement-requests");
                } catch (Exception e) {
                    getServletContext().log("Error", e);
                    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Failed to load postponement requests.");
                    return;
                }
            }
        }
        
        request.getRequestDispatcher("/user/postponement-requests.jsp").forward(request, response);
    }
}
