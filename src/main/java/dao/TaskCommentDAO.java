package dao;

import model.TaskComment;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskCommentDAO {
    
    public void createComment(TaskComment comment) throws SQLException {
        String sql = "INSERT INTO task_comments (task_id, user_id, message) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, comment.getTaskId());
            stmt.setInt(2, comment.getUserId());
            stmt.setString(3, comment.getMessage());
            stmt.executeUpdate();
            
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    comment.setId(rs.getInt(1));
                }
            }
        }
    }

    public List<TaskComment> getCommentsForTask(int taskId) throws SQLException {
        List<TaskComment> comments = new ArrayList<>();
        String sql = "SELECT * FROM task_comments WHERE task_id = ? ORDER BY created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, taskId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    TaskComment c = new TaskComment();
                    c.setId(rs.getInt("id"));
                    c.setTaskId(rs.getInt("task_id"));
                    c.setUserId(rs.getInt("user_id"));
                    c.setMessage(rs.getString("message"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    comments.add(c);
                }
            }
        }
        return comments;
    }
}
