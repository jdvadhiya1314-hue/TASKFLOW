package model;

public class TaskDependency {
    private int taskId;
    private int prerequisiteTaskId;

    public TaskDependency() {}

    public int getTaskId() { return taskId; }
    public void setTaskId(int taskId) { this.taskId = taskId; }
    public int getPrerequisiteTaskId() { return prerequisiteTaskId; }
    public void setPrerequisiteTaskId(int prerequisiteTaskId) { this.prerequisiteTaskId = prerequisiteTaskId; }
}
