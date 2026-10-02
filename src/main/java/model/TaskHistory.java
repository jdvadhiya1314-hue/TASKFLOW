package model;

import java.sql.Timestamp;

public class TaskHistory {
    private int id;
    private int taskId;
    private Integer userId; // Integer to handle possible nulls
    private String action;
    private Timestamp createdAt;

    public TaskHistory() {}

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }
    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }
    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}
