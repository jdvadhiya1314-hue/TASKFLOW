<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Task" %>
<%@ page import="model.User" %>
<%@ page import="model.TaskComment" %>
<%@ page import="model.TaskHistory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    Task task = (Task) request.getAttribute("task");
    User assignedUser = (User) request.getAttribute("assignedUser");
    User creator = (User) request.getAttribute("creator");
    List<TaskComment> comments = (List<TaskComment>) request.getAttribute("comments");
    List<TaskHistory> historyList = (List<TaskHistory>) request.getAttribute("historyList");
    Map<Integer, String> userMap = (Map<Integer, String>) request.getAttribute("userMap");
    SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>View Task - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; margin: 0; display: flex; }
        .sidebar { width: 250px; background-color: #ffffff; height: 100vh; padding: 1.5rem 1rem; border-right: 1px solid #e5e7eb; box-sizing: border-box; }
        .sidebar h2 { margin-top: 0; color: #4f46e5; font-size: 1.5rem; margin-bottom: 2rem; }
        .sidebar a { display: block; padding: 0.75rem 1rem; color: #4b5563; text-decoration: none; border-radius: 0.375rem; margin-bottom: 0.5rem; font-weight: 500; }
        .sidebar a:hover, .sidebar a.active { background-color: #f3f4f6; color: #111827; }
        .main-content { flex: 1; padding: 2rem; overflow-y: auto; height: 100vh; box-sizing: border-box; }
        .card { background: white; padding: 2rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); max-width: 800px; }
        .card-header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid #e5e7eb; padding-bottom: 1.5rem; margin-bottom: 1.5rem; }
        .card-header h1 { margin: 0 0 0.5rem 0; }
        .badge { padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; display: inline-block; margin-right: 0.5rem; }
        .badge-HIGH { background-color: #fee2e2; color: #991b1b; }
        .badge-MEDIUM { background-color: #fef3c7; color: #92400e; }
        .badge-LOW { background-color: #d1fae5; color: #065f46; }
        .badge-status { background-color: #e0e7ff; color: #3730a3; }
        .detail-row { display: flex; margin-bottom: 1rem; }
        .detail-label { width: 150px; font-weight: 500; color: #6b7280; }
        .detail-value { flex: 1; color: #111827; }
        .btn { background-color: #4f46e5; color: white; padding: 0.5rem 1rem; text-decoration: none; border-radius: 0.375rem; font-weight: 500; display: inline-block; }
        
        .section-title { font-size: 1.25rem; border-bottom: 1px solid #e5e7eb; padding-bottom: 0.5rem; margin-bottom: 1rem; margin-top: 0; }
        .comment-box { border: 1px solid #e5e7eb; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1rem; background-color: #f9fafb; }
        .comment-meta { font-size: 0.875rem; color: #6b7280; margin-bottom: 0.5rem; }
        .comment-body { margin: 0; white-space: pre-wrap; }
        .history-item { padding: 0.5rem 0; border-bottom: 1px solid #f3f4f6; font-size: 0.875rem; display: flex; justify-content: space-between; }
        .history-item:last-child { border-bottom: none; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>TaskFlow</h2>
        <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/admin/tasks">All Tasks</a>
        <a href="<%= request.getContextPath() %>/admin/postponement-requests">Postponement Requests</a>
        <a href="<%= request.getContextPath() %>/admin/task/create">Create Task</a>
        <a href="<%= request.getContextPath() %>/logout" style="color: #dc2626; margin-top: auto;">Logout</a>
    </div>
    
    <div class="main-content">
        <div style="margin-bottom: 1rem;">
            <a href="<%= request.getContextPath() %>/admin/tasks" style="color: #4f46e5; text-decoration: none;">&larr; Back to Tasks</a>
        </div>
        
        <div class="card">
            <div class="card-header">
                <div>
                    <h1><%= task.getTitle() %></h1>
                    <% if (task.getDeadline() != null && task.getDeadline().before(new java.util.Date()) && !"COMPLETED".equals(task.getStatus())) { %>
                        <span class="badge" style="background-color: #fee2e2; color: #b91c1c;">OVERDUE</span>
                    <% } %>
                    <span class="badge badge-<%= task.getPriority() %>"><%= task.getPriority() %></span>
                    <span class="badge badge-status"><%= task.getStatus() %></span>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/admin/task/edit?id=<%= task.getId() %>" class="btn">Edit Task</a>
                </div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Description:</div>
                <div class="detail-value" style="white-space: pre-wrap;"><%= task.getDescription() != null ? task.getDescription() : "No description provided." %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Assigned To:</div>
                <div class="detail-value"><%= assignedUser != null ? assignedUser.getName() + " (" + assignedUser.getEmail() + ")" : "Unassigned" %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Start Date:</div>
                <div class="detail-value"><%= task.getStartDate() != null ? task.getStartDate().toString().substring(0, 16) : "" %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Deadline:</div>
                <div class="detail-value"><%= task.getDeadline() != null ? task.getDeadline().toString().substring(0, 16) : "" %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Created By:</div>
                <div class="detail-value"><%= creator != null ? creator.getName() : "System" %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Created At:</div>
                <div class="detail-value"><%= task.getCreatedAt() != null ? task.getCreatedAt().toString().substring(0, 16) : "" %></div>
            </div>
        </div>
        
        <div class="card" style="margin-bottom: 2rem;">
            <h2 class="section-title">Task Dependencies</h2>
            
            <% if (request.getParameter("error") != null) { 
                String err = request.getParameter("error");
                String msg = "Error adding dependency.";
                if ("self_dependency".equals(err)) msg = "A task cannot depend on itself.";
                else if ("duplicate_dependency".equals(err)) msg = "This dependency already exists.";
                else if ("circular_dependency".equals(err)) msg = "Cannot add this dependency as it would create a circular reference.";
            %>
                <div style="background-color: #fee2e2; color: #991b1b; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1.5rem;"><%= msg %></div>
            <% } %>
            
            <% if (request.getParameter("success") != null && request.getParameter("success").startsWith("dependency")) { 
                String succ = request.getParameter("success");
                String msg = "Dependency added successfully.";
                if ("dependency_removed".equals(succ)) msg = "Dependency removed successfully.";
            %>
                <div style="background-color: #d1fae5; color: #065f46; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1.5rem;"><%= msg %></div>
            <% } %>
            
            <% 
                java.util.List<model.TaskDependency> deps = (java.util.List<model.TaskDependency>) request.getAttribute("dependencies");
                java.util.List<Task> allTasks = (java.util.List<Task>) request.getAttribute("allTasks");
                java.util.Map<Integer, Task> taskMap = (java.util.Map<Integer, Task>) request.getAttribute("taskMap");
                
                if (deps == null || deps.isEmpty()) { 
            %>
                <p style="color: #6b7280; font-size: 0.875rem;">No dependencies.</p>
            <% } else { %>
                <table style="width: 100%; border-collapse: collapse; margin-bottom: 1.5rem;">
                    <thead>
                        <tr style="border-bottom: 1px solid #e5e7eb; text-align: left;">
                            <th style="padding: 0.75rem 0; color: #4b5563;">Dependency Task</th>
                            <th style="padding: 0.75rem 0; color: #4b5563;">Status</th>
                            <th style="padding: 0.75rem 0; color: #4b5563; text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (model.TaskDependency dep : deps) { 
                        Task prereq = taskMap.get(dep.getPrerequisiteTaskId());
                        if (prereq != null) {
                    %>
                        <tr style="border-bottom: 1px solid #f3f4f6;">
                            <td style="padding: 0.75rem 0;"><strong>#<%= prereq.getId() %></strong> <%= prereq.getTitle() %></td>
                            <td style="padding: 0.75rem 0;"><span class="badge badge-status-<%= prereq.getStatus() %>"><%= prereq.getStatus() %></span></td>
                            <td style="padding: 0.75rem 0; text-align: right;">
                                <form action="<%= request.getContextPath() %>/admin/task/dependency/remove" method="post" style="display:inline;">
                                    <input type="hidden" name="taskId" value="<%= task.getId() %>">
                                    <input type="hidden" name="dependsOnTaskId" value="<%= prereq.getId() %>">
                                    <button type="submit" style="background: none; border: none; color: #ef4444; cursor: pointer; font-size: 0.875rem; font-weight: 500;">Remove</button>
                                </form>
                            </td>
                        </tr>
                    <%  }
                       } %>
                    </tbody>
                </table>
            <% } %>
            
            <div style="background-color: #f9fafb; padding: 1rem; border-radius: 0.375rem; border: 1px solid #e5e7eb; margin-top: 1.5rem;">
                <h3 style="margin-top: 0; font-size: 1rem; margin-bottom: 1rem;">Add Dependency</h3>
                <form action="<%= request.getContextPath() %>/admin/task/dependency/add" method="post" style="display: flex; gap: 1rem; align-items: center;">
                    <input type="hidden" name="taskId" value="<%= task.getId() %>">
                    <select name="dependsOnTaskId" required style="flex: 1; padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem; background-color: white;">
                        <option value="">Select a task...</option>
                        <% for (Task t : allTasks) { 
                            if (t.getId() != task.getId()) {
                        %>
                            <option value="<%= t.getId() %>">#<%= t.getId() %> - <%= t.getTitle() %></option>
                        <%  }
                           } %>
                    </select>
                    <button type="submit" class="btn" style="white-space: nowrap;">Add Dependency</button>
                </form>
            </div>
        </div>
        
        <div style="display: flex; gap: 2rem; flex-wrap: wrap;">
            <!-- Comments Section -->
            <div class="card" style="flex: 2; min-width: 300px;">
                <h2 class="section-title">Comments</h2>
                <div style="margin-bottom: 2rem;">
                    <% if (comments == null || comments.isEmpty()) { %>
                        <p style="color: #6b7280; font-size: 0.875rem;">No comments yet.</p>
                    <% } else { 
                        for (TaskComment c : comments) { 
                            String authorName = userMap.containsKey(c.getUserId()) ? userMap.get(c.getUserId()) : "User";
                    %>
                        <div class="comment-box">
                            <div class="comment-meta">
                                <strong><%= authorName %></strong> &bull; <%= sdf.format(c.getCreatedAt()) %>
                            </div>
                            <p class="comment-body"><%= c.getMessage() %></p>
                        </div>
                    <%  }
                    } %>
                </div>
            </div>
            
            <!-- History Section -->
            <div class="card" style="flex: 1; min-width: 250px;">
                <h2 class="section-title">Task History</h2>
                <%!
                    public String getActionLabel(String action) {
                        if (action == null) return "Unknown Action";
                        String upper = action.toUpperCase();
                        if (upper.startsWith("TASK_CREATED")) return "Task Created";
                        if (upper.startsWith("TASK_STARTED")) return "Task Started";
                        if (upper.startsWith("TASK_COMPLETED")) return "Task Completed";
                        if (upper.startsWith("COMMENT_ADDED")) return "Comment Added";
                        if (upper.startsWith("POSTPONEMENT_REQUESTED")) return "Postponement Requested";
                        if (upper.startsWith("POSTPONEMENT_APPROVED")) return "Postponement Approved";
                        if (upper.startsWith("POSTPONEMENT_REJECTED")) return "Postponement Rejected";
                        if (upper.startsWith("TASK_DEPENDENCY_ADDED")) return "Dependency Added";
                        if (upper.startsWith("TASK_DEPENDENCY_REMOVED")) return "Dependency Removed";
                        if (upper.startsWith("TASK_ASSIGNED")) return "Task Assigned";
                        return action;
                    }
                %>
                <% if (historyList == null || historyList.isEmpty()) { %>
                    <p style="color: #6b7280; font-size: 0.875rem;">No activity yet.</p>
                <% } else { %>
                    <div style="display: flex; flex-direction: column; gap: 1rem;">
                    <% for (TaskHistory h : historyList) { 
                        String actorName = h.getUserId() != null && userMap.containsKey(h.getUserId()) ? userMap.get(h.getUserId()) : "Unknown User";
                        String label = getActionLabel(h.getAction());
                    %>
                        <div style="border-left: 2px solid #e5e7eb; padding-left: 1rem; margin-left: 0.5rem; position: relative;">
                            <div style="position: absolute; left: -0.375rem; top: 0.25rem; width: 0.75rem; height: 0.75rem; background-color: #4f46e5; border-radius: 50%;"></div>
                            <div style="font-weight: bold; color: #111827; margin-bottom: 0.25rem;"><%= label %></div>
                            <div style="color: #4b5563; font-weight: 500; font-size: 0.875rem;"><%= actorName %></div>
                            <div style="color: #6b7280; font-size: 0.875rem; margin-bottom: 0.25rem;"><%= h.getAction() %></div>
                            <div style="color: #9ca3af; font-size: 0.75rem;"><%= sdf.format(h.getCreatedAt()) %></div>
                        </div>
                    <%  } %>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</body>
</html>
