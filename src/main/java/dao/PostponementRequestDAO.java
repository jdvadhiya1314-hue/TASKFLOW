package dao;

import model.PostponementRequest;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PostponementRequestDAO {

    public void createRequest(PostponementRequest req) throws SQLException {
        String sql = "INSERT INTO postponement_requests (task_id, user_id, current_deadline, requested_deadline, reason, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, req.getTaskId());
            stmt.setInt(2, req.getUserId());
            stmt.setTimestamp(3, req.getCurrentDeadline());
            stmt.setTimestamp(4, req.getRequestedDeadline());
            stmt.setString(5, req.getReason());
            stmt.setString(6, req.getStatus());
            stmt.executeUpdate();

            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    req.setId(rs.getInt(1));
                }
            }
        }
    }

    public PostponementRequest getRequestById(int id) throws SQLException {
        String sql = "SELECT * FROM postponement_requests WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRequest(rs);
                }
            }
        }
        return null;
    }

    public List<PostponementRequest> getAllRequests() throws SQLException {
        List<PostponementRequest> requests = new ArrayList<>();
        String sql = "SELECT * FROM postponement_requests ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                requests.add(mapRequest(rs));
            }
        }
        return requests;
    }

    public List<PostponementRequest> getRequestsByUserId(int userId) throws SQLException {
        List<PostponementRequest> requests = new ArrayList<>();
        String sql = "SELECT * FROM postponement_requests WHERE user_id = ? ORDER BY created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    requests.add(mapRequest(rs));
                }
            }
        }
        return requests;
    }
    
    public void updateRequest(PostponementRequest req) throws SQLException {
        String sql = "UPDATE postponement_requests SET status = ?, admin_response = ?, responded_at = ?, responded_by = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, req.getStatus());
            stmt.setString(2, req.getAdminResponse());
            stmt.setTimestamp(3, req.getRespondedAt());
            if (req.getRespondedBy() != null) {
                stmt.setInt(4, req.getRespondedBy());
            } else {
                stmt.setNull(4, java.sql.Types.INTEGER);
            }
            stmt.setInt(5, req.getId());
            stmt.executeUpdate();
        }
    }

    public int getPendingRequestCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM postponement_requests WHERE status = 'PENDING'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    private PostponementRequest mapRequest(ResultSet rs) throws SQLException {
        PostponementRequest req = new PostponementRequest();
        req.setId(rs.getInt("id"));
        req.setTaskId(rs.getInt("task_id"));
        req.setUserId(rs.getInt("user_id"));
        req.setCurrentDeadline(rs.getTimestamp("current_deadline"));
        req.setRequestedDeadline(rs.getTimestamp("requested_deadline"));
        req.setReason(rs.getString("reason"));
        req.setStatus(rs.getString("status"));
        req.setAdminResponse(rs.getString("admin_response"));
        req.setCreatedAt(rs.getTimestamp("created_at"));
        req.setRespondedAt(rs.getTimestamp("responded_at"));
        int respondedBy = rs.getInt("responded_by");
        if (!rs.wasNull()) {
            req.setRespondedBy(respondedBy);
        }
        return req;
    }
}
