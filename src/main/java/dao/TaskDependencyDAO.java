package dao;

import model.TaskDependency;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskDependencyDAO {
    
    public void createDependency(TaskDependency dependency) throws SQLException {
        String sql = "INSERT INTO task_dependencies (task_id, prerequisite_task_id) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, dependency.getTaskId());
            stmt.setInt(2, dependency.getPrerequisiteTaskId());
            stmt.executeUpdate();
        }
    }

    public List<TaskDependency> getDependenciesForTask(int taskId) throws SQLException {
        List<TaskDependency> dependencies = new ArrayList<>();
        String sql = "SELECT * FROM task_dependencies WHERE task_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, taskId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskDependency dep = new TaskDependency();
                    dep.setTaskId(rs.getInt("task_id"));
                    dep.setPrerequisiteTaskId(rs.getInt("prerequisite_task_id"));
                    dependencies.add(dep);
                }
            }
        }
        return dependencies;
    }

    public void deleteDependency(int taskId, int prerequisiteTaskId) throws SQLException {
        String sql = "DELETE FROM task_dependencies WHERE task_id = ? AND prerequisite_task_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, taskId);
            stmt.setInt(2, prerequisiteTaskId);
            stmt.executeUpdate();
        }
    }
}
