package dao;

import model.Task;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class TaskDAO {
    
    public void createTask(Task task) throws SQLException {
        String sql = "INSERT INTO tasks (title, description, assigned_to, created_by, start_date, deadline, priority, status, progress) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, task.getTitle());
            stmt.setString(2, task.getDescription());
            if (task.getAssignedTo() != null) stmt.setInt(3, task.getAssignedTo()); else stmt.setNull(3, Types.INTEGER);
            if (task.getCreatedBy() != null) stmt.setInt(4, task.getCreatedBy()); else stmt.setNull(4, Types.INTEGER);
            stmt.setTimestamp(5, task.getStartDate());
            stmt.setTimestamp(6, task.getDeadline());
            stmt.setString(7, task.getPriority());
            stmt.setString(8, task.getStatus());
            stmt.setInt(9, task.getProgress());
            stmt.executeUpdate();
            
            try (ResultSet rs = stmt.getGeneratedKeys()) {
                if (rs.next()) {
                    task.setId(rs.getInt(1));
                }
            }
        }
    }

    public Task getTaskById(int id) throws SQLException {
        String sql = "SELECT * FROM tasks WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapTask(rs);
                }
            }
        }
        return null;
    }

    public List<Task> getAllTasks() throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM tasks";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                tasks.add(mapTask(rs));
            }
        }
        return tasks;
    }

    public int getTaskCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM tasks";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getTaskCountByStatus(String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tasks WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Task> getTasksByAssignedUser(int userId) throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE assigned_to = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapTask(rs));
                }
            }
        }
        return tasks;
    }
    
    public List<Task> getTasksByAssignedUserAndStatus(int userId, String status) throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE assigned_to = ? AND status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, status);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapTask(rs));
                }
            }
        }
        return tasks;
    }
    
    public List<Task> getTasksByStatus(String status) throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapTask(rs));
                }
            }
        }
        return tasks;
    }

    public void updateTask(Task task) throws SQLException {
        String sql = "UPDATE tasks SET title = ?, description = ?, assigned_to = ?, start_date = ?, deadline = ?, priority = ?, status = ?, progress = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, task.getTitle());
            stmt.setString(2, task.getDescription());
            if (task.getAssignedTo() != null) stmt.setInt(3, task.getAssignedTo()); else stmt.setNull(3, Types.INTEGER);
            stmt.setTimestamp(4, task.getStartDate());
            stmt.setTimestamp(5, task.getDeadline());
            stmt.setString(6, task.getPriority());
            stmt.setString(7, task.getStatus());
            stmt.setInt(8, task.getProgress());
            stmt.setInt(9, task.getId());
            stmt.executeUpdate();
        }
    }

    public void deleteTask(int id) throws SQLException {
        String sql = "DELETE FROM tasks WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            stmt.executeUpdate();
        }
    }

    public int getOverdueTasksCount() throws SQLException {
        String sql = "SELECT COUNT(*) FROM tasks WHERE deadline < NOW() AND status != 'COMPLETED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int getOverdueTasksCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tasks WHERE assigned_to = ? AND deadline < NOW() AND status != 'COMPLETED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getTaskCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tasks WHERE assigned_to = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public int getTaskCountByStatus(int userId, String status) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tasks WHERE assigned_to = ? AND status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, status);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Task> getUpcomingTasks(int userId, int limit) throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE assigned_to = ? AND status != 'COMPLETED' AND deadline >= NOW() ORDER BY deadline ASC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setInt(2, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapTask(rs));
                }
            }
        }
        return tasks;
    }

    public List<Task> getOverdueTasks(int userId) throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM tasks WHERE assigned_to = ? AND deadline < NOW() AND status != 'COMPLETED' ORDER BY deadline ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapTask(rs));
                }
            }
        }
        return tasks;
    }

    public List<Task> getRecentTasks(int limit) throws SQLException {
        List<Task> tasks = new ArrayList<>();
        String sql = "SELECT * FROM tasks ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapTask(rs));
                }
            }
        }
        return tasks;
    }

    public List<Task> searchTasks(Integer assignedTo, String search, String status, String priority, Integer filterUser, Boolean overdue, String sort) throws SQLException {
        List<Task> tasks = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM tasks WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (assignedTo != null) {
            sql.append(" AND assigned_to = ?");
            params.add(assignedTo);
        } else if (filterUser != null && filterUser > 0) {
            sql.append(" AND assigned_to = ?");
            params.add(filterUser);
        }

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (title LIKE ? OR description LIKE ?)");
            params.add("%" + search.trim() + "%");
            params.add("%" + search.trim() + "%");
        }

        if (status != null && !status.isEmpty() && !status.equals("All")) {
            sql.append(" AND status = ?");
            params.add(status);
        }

        if (priority != null && !priority.isEmpty() && !priority.equals("All")) {
            sql.append(" AND priority = ?");
            params.add(priority);
        }

        if (overdue != null && overdue) {
            sql.append(" AND deadline < NOW() AND status != 'COMPLETED'");
        }

        if (sort != null) {
            switch (sort) {
                case "oldest":
                    sql.append(" ORDER BY created_at ASC");
                    break;
                case "deadline_asc":
                    sql.append(" ORDER BY deadline ASC");
                    break;
                case "deadline_desc":
                    sql.append(" ORDER BY deadline DESC");
                    break;
                case "priority_high":
                    sql.append(" ORDER BY CASE priority WHEN 'URGENT' THEN 1 WHEN 'HIGH' THEN 2 WHEN 'MEDIUM' THEN 3 WHEN 'LOW' THEN 4 ELSE 5 END ASC");
                    break;
                case "priority_low":
                    sql.append(" ORDER BY CASE priority WHEN 'LOW' THEN 1 WHEN 'MEDIUM' THEN 2 WHEN 'HIGH' THEN 3 WHEN 'URGENT' THEN 4 ELSE 5 END ASC");
                    break;
                case "newest":
                default:
                    sql.append(" ORDER BY created_at DESC");
                    break;
            }
        } else {
            sql.append(" ORDER BY created_at DESC");
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                stmt.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tasks.add(mapTask(rs));
                }
            }
        }
        return tasks;
    }

    private Task mapTask(ResultSet rs) throws SQLException {
        Task task = new Task();
        task.setId(rs.getInt("id"));
        task.setTitle(rs.getString("title"));
        task.setDescription(rs.getString("description"));
        
        int assignedTo = rs.getInt("assigned_to");
        if (!rs.wasNull()) task.setAssignedTo(assignedTo);
        
        int createdBy = rs.getInt("created_by");
        if (!rs.wasNull()) task.setCreatedBy(createdBy);
        
        task.setStartDate(rs.getTimestamp("start_date"));
        task.setDeadline(rs.getTimestamp("deadline"));
        task.setPriority(rs.getString("priority"));
        task.setStatus(rs.getString("status"));
        task.setProgress(rs.getInt("progress"));
        task.setCreatedAt(rs.getTimestamp("created_at"));
        return task;
    }
}
