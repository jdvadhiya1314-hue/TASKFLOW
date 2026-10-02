package dao;

import model.TaskHistory;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskHistoryDAO {

    public void createHistory(TaskHistory history) throws SQLException {
        String sql = "INSERT INTO task_history (task_id, user_id, action) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, history.getTaskId());
            if (history.getUserId() != null) stmt.setInt(2, history.getUserId()); else stmt.setNull(2, Types.INTEGER);
            stmt.setString(3, history.getAction());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    history.setId(rs.getInt(1));
                }
            }
        }
    }

    public List<TaskHistory> getHistoryForTask(int taskId) throws SQLException {
        List<TaskHistory> historyList = new ArrayList<>();
        String sql = "SELECT * FROM task_history WHERE task_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, taskId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskHistory h = new TaskHistory();
                    h.setId(rs.getInt("id"));
                    h.setTaskId(rs.getInt("task_id"));
                    
                    int userId = rs.getInt("user_id");
                    if (!rs.wasNull()) h.setUserId(userId);
                    
                    h.setAction(rs.getString("action"));
                    h.setCreatedAt(rs.getTimestamp("created_at"));
                    historyList.add(h);
                }
            }
        }
        return historyList;
    }

    public List<TaskHistory> getRecentHistory(int limit) throws SQLException {
        List<TaskHistory> historyList = new ArrayList<>();
        String sql = "SELECT * FROM task_history ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskHistory h = new TaskHistory();
                    h.setId(rs.getInt("id"));
                    h.setTaskId(rs.getInt("task_id"));
                    int userId = rs.getInt("user_id");
                    if (!rs.wasNull()) h.setUserId(userId);
                    h.setAction(rs.getString("action"));
                    h.setCreatedAt(rs.getTimestamp("created_at"));
                    historyList.add(h);
                }
            }
        }
        return historyList;
    }

    public List<TaskHistory> getRecentHistory(int userId, int limit) throws SQLException {
        List<TaskHistory> historyList = new ArrayList<>();
        String sql = "SELECT h.* FROM task_history h JOIN tasks t ON h.task_id = t.id WHERE t.assigned_to = ? ORDER BY h.created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskHistory h = new TaskHistory();
                    h.setId(rs.getInt("id"));
                    h.setTaskId(rs.getInt("task_id"));
                    int uid = rs.getInt("user_id");
                    if (!rs.wasNull()) h.setUserId(uid);
                    h.setAction(rs.getString("action"));
                    h.setCreatedAt(rs.getTimestamp("created_at"));
                    historyList.add(h);
                }
            }
        }
        return historyList;
    }
}
