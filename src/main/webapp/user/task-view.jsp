<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Task" %>
<%@ page import="model.TaskComment" %>
<%@ page import="model.TaskHistory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("loggedInUser");
    Task task = (Task) request.getAttribute("task");
    List<TaskComment> comments = (List<TaskComment>) request.getAttribute("comments");
    List<TaskHistory> historyList = (List<TaskHistory>) request.getAttribute("historyList");
    Map<Integer, String> userMap = (Map<Integer, String>) request.getAttribute("userMap");
    String currentRoute = (String) request.getAttribute("currentRoute");
    if (currentRoute == null) currentRoute = "/user/tasks";
    SimpleDateFormat sdf = new SimpleDateFormat("MMM d, yyyy HH:mm");
    
    String assignedName = task.getAssignedTo() != null && userMap.containsKey(task.getAssignedTo()) 
        ? userMap.get(task.getAssignedTo()) : "Unassigned";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Task Details - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; margin: 0; display: flex; color: #111827; }
        .sidebar { width: 250px; background-color: #ffffff; height: 100vh; padding: 1.5rem 1rem; border-right: 1px solid #e5e7eb; box-sizing: border-box; position: fixed; }
        .sidebar h2 { margin-top: 0; color: #4f46e5; font-size: 1.5rem; margin-bottom: 2rem; }
        .sidebar a { display: block; padding: 0.75rem 1rem; color: #4b5563; text-decoration: none; border-radius: 0.375rem; margin-bottom: 0.5rem; font-weight: 500; }
        .sidebar a:hover, .sidebar a.active { background-color: #f3f4f6; color: #111827; }
        .main-content { margin-left: 250px; flex: 1; padding: 2rem; min-height: 100vh; box-sizing: border-box; }
        .card { background: white; padding: 2rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 2rem; }
        .card-header { display: flex; justify-content: space-between; align-items: flex-start; border-bottom: 1px solid #e5e7eb; padding-bottom: 1.5rem; margin-bottom: 1.5rem; }
        .card-header h1 { margin: 0 0 0.5rem 0; font-size: 1.5rem; }
        
        .badge { padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; display: inline-block; margin-right: 0.5rem; }
        .badge-HIGH { background-color: #fee2e2; color: #991b1b; }
        .badge-MEDIUM { background-color: #fef3c7; color: #92400e; }
        .badge-LOW { background-color: #d1fae5; color: #065f46; }
        
        .badge-status-COMPLETED { background-color: #d1fae5; color: #065f46; }
        .badge-status-IN_PROGRESS { background-color: #fef3c7; color: #92400e; }
        .badge-status-ASSIGNED { background-color: #e0e7ff; color: #3730a3; }
        .badge-status-PENDING { background-color: #e0e7ff; color: #3730a3; }
        
        .detail-row { display: flex; margin-bottom: 1rem; }
        .detail-label { width: 150px; font-weight: 500; color: #6b7280; }
        .detail-value { flex: 1; color: #111827; }
        
        .btn { background-color: #4f46e5; color: white; padding: 0.5rem 1rem; text-decoration: none; border-radius: 0.375rem; font-weight: 500; border: none; cursor: pointer; display: inline-block; font-size: 1rem; }
        .btn:hover { background-color: #4338ca; }
        .btn-success { background-color: #10b981; }
        .btn-success:hover { background-color: #059669; }
        
        .section-title { font-size: 1.25rem; border-bottom: 1px solid #e5e7eb; padding-bottom: 0.5rem; margin-bottom: 1rem; margin-top: 0; }
        
        .comment-box { border: 1px solid #e5e7eb; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1rem; background-color: #f9fafb; }
        .comment-meta { font-size: 0.875rem; color: #6b7280; margin-bottom: 0.5rem; }
        .comment-body { margin: 0; white-space: pre-wrap; }
        
        .history-item { padding: 0.5rem 0; border-bottom: 1px solid #f3f4f6; font-size: 0.875rem; display: flex; justify-content: space-between; }
        .history-item:last-child { border-bottom: none; }
        
        .form-group { margin-bottom: 1rem; }
        .form-group textarea { width: 100%; padding: 0.75rem; border: 1px solid #d1d5db; border-radius: 0.375rem; box-sizing: border-box; font-family: inherit; }
        
        .alert-success { background-color: #d1fae5; color: #065f46; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1.5rem; }
        
        @media (max-width: 768px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; height: auto; position: static; }
            .main-content { margin-left: 0; padding: 1rem; }
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>TaskFlow</h2>
        <% 
            int unreadCount = 0;
            try {
                dao.NotificationDAO nDao = new dao.NotificationDAO();
                unreadCount = nDao.getUnreadCount(user.getId());
            } catch(Exception e){}
        %>
        <a href="<%= request.getContextPath() %>/user/dashboard" class="<%= "/user/dashboard".equals(currentRoute) ? "active" : "" %>">Dashboard</a>
        <a href="<%= request.getContextPath() %>/user/tasks" class="<%= "/user/tasks".equals(currentRoute) ? "active" : "" %>">My Tasks</a>
        <a href="<%= request.getContextPath() %>/user/tasks/pending" class="<%= "/user/tasks/pending".equals(currentRoute) ? "active" : "" %>">Pending</a>
        <a href="<%= request.getContextPath() %>/user/tasks/in-progress" class="<%= "/user/tasks/in-progress".equals(currentRoute) ? "active" : "" %>">In Progress</a>
        <a href="<%= request.getContextPath() %>/user/tasks/completed" class="<%= "/user/tasks/completed".equals(currentRoute) ? "active" : "" %>">Completed</a>
        <a href="<%= request.getContextPath() %>/user/postponement-requests" class="<%= "/user/postponement-requests".equals(currentRoute) ? "active" : "" %>">Postponement Requests</a>
        <a href="<%= request.getContextPath() %>/user/notifications" class="<%= "/user/notifications".equals(currentRoute) ? "active" : "" %>">
            Notifications
            <% if (unreadCount > 0) { %>
                <span style="background-color: #ef4444; color: white; padding: 0.125rem 0.5rem; border-radius: 9999px; font-size: 0.75rem; margin-left: 0.5rem;"><%= unreadCount %></span>
            <% } %>
        </a>
        <a href="<%= request.getContextPath() %>/logout" style="color: #dc2626; margin-top: 1rem;">Logout</a>
    </div>
    
    <div class="main-content">
        <div style="margin-bottom: 1rem;">
            <a href="<%= request.getContextPath() %>/user/tasks" style="color: #4f46e5; text-decoration: none;">&larr; Back to My Tasks</a>
        </div>
        
        <% if (request.getParameter("success") != null) { 
            String successType = request.getParameter("success");
            String msg = "Operation completed successfully.";
            if ("started".equals(successType)) msg = "Task started successfully!";
            else if ("completed".equals(successType)) msg = "Task marked as completed!";
            else if ("comment_added".equals(successType)) msg = "Comment added successfully!";
        %>
            <div class="alert-success"><%= msg %></div>
        <% } %>
        
        <% if (request.getParameter("error") != null) { 
            String errorType = request.getParameter("error");
            String errMsg = "An error occurred.";
            if ("invalid_date".equals(errorType)) errMsg = "Requested deadline must be after the current deadline.";
            else if ("pending_exists".equals(errorType)) errMsg = "You already have a pending postponement request for this task.";
            else if ("incomplete_dependency".equals(errorType)) {
                String blockedTitle = request.getParameter("blockedTitle");
                String blockedStatus = request.getParameter("blockedStatus");
                errMsg = "Task cannot be started because a required dependency is incomplete.";
                if (blockedTitle != null && blockedStatus != null) {
                    try {
                        // Attempt to decode, though getParameter usually decodes automatically
                        blockedTitle = java.net.URLDecoder.decode(blockedTitle, "UTF-8");
                    } catch (Exception e) {}
                    errMsg += "<br>Blocked by:<br>" + blockedTitle + " — " + blockedStatus;
                }
            }
        %>
            <div style="background-color: #fee2e2; color: #991b1b; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1.5rem;"><%= errMsg %></div>
        <% } %>
        
        <div class="card">
            <div class="card-header">
                <div>
                    <h1><%= task.getTitle() %></h1>
                    <% if (task.getDeadline() != null && task.getDeadline().before(new java.util.Date()) && !"COMPLETED".equals(task.getStatus())) { %>
                        <span class="badge" style="background-color: #fee2e2; color: #b91c1c;">OVERDUE</span>
                    <% } %>
                    <span class="badge badge-<%= task.getPriority() %>"><%= task.getPriority() %></span>
                    <span class="badge badge-status-<%= task.getStatus() %>"><%= task.getStatus() %></span>
                </div>
                <div>
                    <% if ("ASSIGNED".equals(task.getStatus()) || "PENDING".equals(task.getStatus())) { %>
                        <form action="<%= request.getContextPath() %>/user/task/start" method="post" style="display:inline;">
                            <input type="hidden" name="id" value="<%= task.getId() %>">
                            <button type="submit" class="btn">Start Task</button>
                        </form>
                    <% } else if ("IN_PROGRESS".equals(task.getStatus())) { %>
                        <form action="<%= request.getContextPath() %>/user/task/complete" method="post" style="display:inline;">
                            <input type="hidden" name="id" value="<%= task.getId() %>">
                            <button type="submit" class="btn btn-success">Complete Task</button>
                        </form>
                    <% } else if ("COMPLETED".equals(task.getStatus())) { %>
                        <span style="color: #065f46; font-weight: bold; background-color: #d1fae5; padding: 0.5rem 1rem; border-radius: 0.375rem;">Task Completed</span>
                    <% } %>
                    <% if (!"COMPLETED".equals(task.getStatus())) { %>
                        <button type="button" class="btn" style="background-color: #f59e0b;" onclick="document.getElementById('postponeModal').style.display='block'">Request Postponement</button>
                    <% } %>
                </div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Description:</div>
                <div class="detail-value" style="white-space: pre-wrap;"><%= task.getDescription() != null ? task.getDescription() : "No description provided." %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Assigned To:</div>
                <div class="detail-value"><%= assignedName %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Due Date:</div>
                <div class="detail-value"><%= task.getDeadline() != null ? sdf.format(task.getDeadline()) : "" %></div>
            </div>
            
            <div class="detail-row">
                <div class="detail-label">Created Date:</div>
                <div class="detail-value"><%= task.getCreatedAt() != null ? sdf.format(task.getCreatedAt()) : "" %></div>
            </div>
        </div>
        
        <div class="card" style="margin-bottom: 2rem;">
            <h2 class="section-title">Task Dependencies</h2>
            <% 
                java.util.List<model.TaskDependency> deps = (java.util.List<model.TaskDependency>) request.getAttribute("dependencies");
                java.util.Map<Integer, Task> taskMap = (java.util.Map<Integer, Task>) request.getAttribute("taskMap");
                if (deps == null || deps.isEmpty()) { 
            %>
                <p style="color: #6b7280; font-size: 0.875rem; margin: 0;">No dependencies.</p>
            <% } else { %>
                <div style="display: grid; gap: 0.5rem;">
                <% for (model.TaskDependency dep : deps) { 
                    Task prereq = taskMap.get(dep.getPrerequisiteTaskId());
                    if (prereq != null) {
                        String icon = "COMPLETED".equals(prereq.getStatus()) ? "✓" : "○";
                        String color = "COMPLETED".equals(prereq.getStatus()) ? "#065f46" : "#6b7280";
                %>
                    <div style="display: flex; align-items: center; background: #f9fafb; padding: 0.75rem 1rem; border-radius: 0.375rem; border: 1px solid #e5e7eb;">
                        <span style="color: <%= color %>; font-weight: bold; margin-right: 0.75rem; font-size: 1.125rem;"><%= icon %></span>
                        <div style="flex: 1;">
                            <strong><%= prereq.getTitle() %></strong> — <%= prereq.getStatus() %>
                        </div>
                    </div>
                <%  }
                   } %>
                </div>
            <% } %>
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
                
                <form action="<%= request.getContextPath() %>/user/task/comment" method="post">
                    <input type="hidden" name="id" value="<%= task.getId() %>">
                    <div class="form-group">
                        <textarea name="message" rows="3" placeholder="Write a comment..." required></textarea>
                    </div>
                    <button type="submit" class="btn">Add Comment</button>
                </form>
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
        
        <!-- Postponement Modal -->
        <div id="postponeModal" style="display:none; position:fixed; z-index:100; left:0; top:0; width:100%; height:100%; overflow:auto; background-color:rgba(0,0,0,0.4);">
            <div style="background-color:#fefefe; margin:10% auto; padding:2rem; border:1px solid #888; width:80%; max-width:500px; border-radius:0.5rem; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                <h2 style="margin-top:0;">Request Postponement</h2>
                <form action="<%= request.getContextPath() %>/user/task/postpone" method="post">
                    <input type="hidden" name="id" value="<%= task.getId() %>">
                    
                    <div class="form-group">
                        <label style="display:block; margin-bottom:0.5rem; font-weight:500;">Current Due Date:</label>
                        <input type="text" value="<%= task.getDeadline() != null ? sdf.format(task.getDeadline()) : "" %>" disabled style="width:100%; padding:0.75rem; border:1px solid #d1d5db; border-radius:0.375rem; background-color:#f3f4f6; color:#6b7280; box-sizing:border-box;">
                    </div>
                    
                    <div class="form-group">
                        <label style="display:block; margin-bottom:0.5rem; font-weight:500;">Requested Due Date & Time *</label>
                        <input type="datetime-local" name="requestedDeadline" required style="width:100%; padding:0.75rem; border:1px solid #d1d5db; border-radius:0.375rem; box-sizing:border-box;">
                    </div>
                    
                    <div class="form-group">
                        <label style="display:block; margin-bottom:0.5rem; font-weight:500;">Reason *</label>
                        <textarea name="reason" rows="4" required style="width:100%; padding:0.75rem; border:1px solid #d1d5db; border-radius:0.375rem; box-sizing:border-box;"></textarea>
                    </div>
                    
                    <div style="text-align:right; margin-top:1.5rem;">
                        <button type="button" class="btn" style="background-color:#6b7280; margin-right:0.5rem;" onclick="document.getElementById('postponeModal').style.display='none'">Cancel</button>
                        <button type="submit" class="btn">Submit Request</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
