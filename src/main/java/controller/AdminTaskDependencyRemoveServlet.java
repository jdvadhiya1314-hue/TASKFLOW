package controller;

import dao.TaskDependencyDAO;
import dao.TaskHistoryDAO;
import model.TaskHistory;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/admin/task/dependency/remove")
public class AdminTaskDependencyRemoveServlet extends HttpServlet {
    private TaskDependencyDAO dependencyDAO;
    private TaskHistoryDAO historyDAO;

    @Override
    public void init() throws ServletException {
        dependencyDAO = new TaskDependencyDAO();
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
            int taskId = Integer.parseInt(request.getParameter("taskId"));
            int dependsOnTaskId = Integer.parseInt(request.getParameter("dependsOnTaskId"));

            dependencyDAO.deleteDependency(taskId, dependsOnTaskId);

            TaskHistory history = new TaskHistory();
            history.setTaskId(taskId);
            history.setUserId(admin.getId());
            history.setAction("TASK_DEPENDENCY_REMOVED");
            historyDAO.createHistory(history);

            response.sendRedirect(request.getContextPath() + "/admin/task/view?id=" + taskId + "&success=dependency_removed");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid format");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error removing dependency");
        }
    }
}
