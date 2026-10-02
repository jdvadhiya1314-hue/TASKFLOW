package model;

import java.sql.Timestamp;

public class PostponementRequest {
    private int id;
    private int taskId;
    private int userId;
    private Timestamp currentDeadline;
    private Timestamp requestedDeadline;
    private String reason;
    private String status;
    private String adminResponse;
    private Timestamp createdAt;
    private Timestamp respondedAt;
    private Integer respondedBy;

    public PostponementRequest() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public Timestamp getCurrentDeadline() { return currentDeadline; }
    public void setCurrentDeadline(Timestamp currentDeadline) { this.currentDeadline = currentDeadline; }
    public Timestamp getRequestedDeadline() { return requestedDeadline; }
    public void setRequestedDeadline(Timestamp requestedDeadline) { this.requestedDeadline = requestedDeadline; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminResponse() { return adminResponse; }
    public void setAdminResponse(String adminResponse) { this.adminResponse = adminResponse; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
    public Timestamp getRespondedAt() { return respondedAt; }
    public void setRespondedAt(Timestamp respondedAt) { this.respondedAt = respondedAt; }
    public Integer getRespondedBy() { return respondedBy; }
    public void setRespondedBy(Integer respondedBy) { this.respondedBy = respondedBy; }
}
