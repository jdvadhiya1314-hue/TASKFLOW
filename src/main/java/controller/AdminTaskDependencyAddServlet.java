package controller;

import dao.TaskDAO;
import dao.TaskDependencyDAO;
import dao.TaskHistoryDAO;
import model.Task;
import model.TaskDependency;
import model.TaskHistory;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/task/dependency/add")
public class AdminTaskDependencyAddServlet extends HttpServlet {
    private TaskDAO taskDAO;
    private TaskDependencyDAO dependencyDAO;
    private TaskHistoryDAO historyDAO;

    @Override
    public void init() throws ServletException {
        taskDAO = new TaskDAO();
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

            if (taskId == dependsOnTaskId) {
                response.sendRedirect(request.getContextPath() + "/admin/task/view?id=" + taskId + "&error=self_dependency");
                return;
            }

            Task task = taskDAO.getTaskById(taskId);
            Task prereqTask = taskDAO.getTaskById(dependsOnTaskId);

            if (task == null || prereqTask == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Task not found");
                return;
            }

            List<TaskDependency> existingDeps = dependencyDAO.getDependenciesForTask(taskId);
            for (TaskDependency dep : existingDeps) {
                if (dep.getPrerequisiteTaskId() == dependsOnTaskId) {
                    response.sendRedirect(request.getContextPath() + "/admin/task/view?id=" + taskId + "&error=duplicate_dependency");
                    return;
                }
            }

            if (hasCircularDependency(dependsOnTaskId, taskId)) {
                response.sendRedirect(request.getContextPath() + "/admin/task/view?id=" + taskId + "&error=circular_dependency");
                return;
            }

            TaskDependency newDep = new TaskDependency();
            newDep.setTaskId(taskId);
            newDep.setPrerequisiteTaskId(dependsOnTaskId);
            dependencyDAO.createDependency(newDep);

            TaskHistory history = new TaskHistory();
            history.setTaskId(taskId);
            history.setUserId(admin.getId());
            history.setAction("TASK_DEPENDENCY_ADDED");
            historyDAO.createHistory(history);

            response.sendRedirect(request.getContextPath() + "/admin/task/view?id=" + taskId + "&success=dependency_added");
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid format");
        } catch (Exception e) {
            getServletContext().log("Error", e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error adding dependency");
        }
    }

    private boolean hasCircularDependency(int currentTaskId, int targetTaskId) throws SQLException {
        if (currentTaskId == targetTaskId) {
            return true;
        }
        List<TaskDependency> deps = dependencyDAO.getDependenciesForTask(currentTaskId);
        for (TaskDependency dep : deps) {
            if (hasCircularDependency(dep.getPrerequisiteTaskId(), targetTaskId)) {
                return true;
            }
        }
        return false;
    }
}
