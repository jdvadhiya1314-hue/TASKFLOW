<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Task" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("loggedInUser");
    List<Task> assignedTasks = (List<Task>) request.getAttribute("assignedTasks");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Dashboard - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; color: #111827; margin: 0; display: flex; }
        .sidebar { width: 250px; background-color: #ffffff; height: 100vh; padding: 1.5rem 1rem; border-right: 1px solid #e5e7eb; box-sizing: border-box; position: fixed; }
        .sidebar h2 { margin-top: 0; color: #4f46e5; font-size: 1.5rem; margin-bottom: 2rem; }
        .sidebar a { display: block; padding: 0.75rem 1rem; color: #4b5563; text-decoration: none; border-radius: 0.375rem; margin-bottom: 0.5rem; font-weight: 500; }
        .sidebar a:hover, .sidebar a.active { background-color: #f3f4f6; color: #111827; }
        .main-content { margin-left: 250px; flex: 1; padding: 2rem; min-height: 100vh; box-sizing: border-box; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .header h1 { margin: 0; font-size: 1.875rem; }
        .user-info { display: flex; align-items: center; gap: 1rem; text-align: right; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb; }
        .stat-card h3 { margin: 0 0 0.5rem 0; font-size: 0.875rem; color: #6b7280; text-transform: uppercase; letter-spacing: 0.05em; }
        .stat-card .value { font-size: 2.25rem; font-weight: bold; color: #111827; margin: 0; }
        
        .section-title { font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem; border-bottom: 1px solid #e5e7eb; padding-bottom: 0.5rem; }
        .task-list { display: grid; gap: 1rem; }
        .task-card { background: white; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb; }
        .task-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; }
        .task-title { margin: 0; font-size: 1.125rem; font-weight: 600; }
        .task-desc { color: #4b5563; margin-bottom: 1rem; }
        
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; }
        .badge-pending { background-color: #fee2e2; color: #991b1b; }
        .badge-inprogress { background-color: #fef3c7; color: #92400e; }
        .badge-completed { background-color: #d1fae5; color: #065f46; }
        .badge-assigned { background-color: #e0e7ff; color: #3730a3; }
        
        .task-meta { display: flex; gap: 1.5rem; font-size: 0.875rem; color: #6b7280; flex-wrap: wrap; }
        .empty-state { background: white; padding: 3rem; text-align: center; border-radius: 0.5rem; border: 1px dashed #d1d5db; color: #6b7280; }
        
        @media (max-width: 768px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; height: auto; position: static; padding: 1rem; border-right: none; border-bottom: 1px solid #e5e7eb; }
            .main-content { margin-left: 0; padding: 1rem; }
            .header { flex-direction: column; align-items: flex-start; gap: 1rem; }
            .user-info { text-align: left; }
        }
    </style>
</head>
<body>
    <% String currentRoute = (String) request.getAttribute("currentRoute"); if (currentRoute == null) currentRoute = "/user/dashboard"; %>
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
        <div class="header">
            <div>
                <h1>Good morning, <%= user.getName() %></h1>
                <p style="color: #6b7280; margin: 0.5rem 0 0 0;">Here's what's happening with your tasks today.</p>
            </div>
            <div class="user-info">
                <span><%= user.getEmail() %><br><small style="color: #6b7280;">USER</small></span>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Tasks</h3>
                <p class="value"><%= request.getAttribute("totalTasks") != null ? request.getAttribute("totalTasks") : 0 %></p>
            </div>
            <div class="stat-card">
                <h3>Pending</h3>
                <p class="value" style="color: #4f46e5;"><%= request.getAttribute("pendingTasks") != null ? request.getAttribute("pendingTasks") : 0 %></p>
            </div>
            <div class="stat-card">
                <h3>In Progress</h3>
                <p class="value" style="color: #d97706;"><%= request.getAttribute("inProgressTasks") != null ? request.getAttribute("inProgressTasks") : 0 %></p>
            </div>
            <div class="stat-card">
                <h3>Completed</h3>
                <p class="value" style="color: #059669;"><%= request.getAttribute("completedTasks") != null ? request.getAttribute("completedTasks") : 0 %></p>
            </div>
            <div class="stat-card">
                <h3>Overdue</h3>
                <p class="value" style="color: #dc2626;"><%= request.getAttribute("overdueTasks") != null ? request.getAttribute("overdueTasks") : 0 %></p>
            </div>
            <div class="stat-card">
                <h3>Unread Notifications</h3>
                <p class="value" style="color: #ea580c;"><%= request.getAttribute("unreadNotifications") != null ? request.getAttribute("unreadNotifications") : 0 %></p>
            </div>
        </div>

        <div style="display: flex; gap: 2rem; flex-wrap: wrap; margin-bottom: 2rem;">
            <!-- Overdue Tasks Section -->
            <div style="flex: 1; min-width: 300px; background: white; border-radius: 0.5rem; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #fca5a5;">
                <h2 style="margin-top: 0; font-size: 1.25rem; margin-bottom: 1rem; color: #b91c1c;">Overdue Tasks</h2>
                <% 
                    java.util.List<model.Task> overdueTasksList = (java.util.List<model.Task>) request.getAttribute("overdueTasksList");
                    if (overdueTasksList == null || overdueTasksList.isEmpty()) { 
                %>
                    <p style="color: #6b7280; font-size: 0.875rem;">No overdue tasks.</p>
                <% } else { %>
                    <div style="display: flex; flex-direction: column; gap: 1rem;">
                    <% for (model.Task t : overdueTasksList) { %>
                        <div style="border-left: 4px solid #ef4444; padding: 0.75rem 1rem; background: #fef2f2; border-radius: 0.25rem;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.25rem;">
                                <a href="<%= request.getContextPath() %>/user/task/view?id=<%= t.getId() %>" style="color: #991b1b; text-decoration: none; font-weight: 600;"><%= t.getTitle() %></a>
                                <span style="font-size: 0.75rem; padding: 0.125rem 0.5rem; border-radius: 9999px; font-weight: 500; background-color: #fee2e2; color: #991b1b;"><%= t.getStatus() %></span>
                            </div>
                            <div style="display: flex; gap: 1rem; font-size: 0.875rem; color: #b91c1c;">
                                <span><strong>Priority:</strong> <%= t.getPriority() %></span>
                                <span><strong>Due:</strong> <%= t.getDeadline() != null ? sdf.format(t.getDeadline()) : "N/A" %></span>
                            </div>
                        </div>
                    <% } %>
                    </div>
                <% } %>
            </div>

            <!-- Upcoming Tasks Section -->
            <div style="flex: 1; min-width: 300px; background: white; border-radius: 0.5rem; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb;">
                <h2 style="margin-top: 0; font-size: 1.25rem; margin-bottom: 1rem;">Upcoming Tasks</h2>
                <% 
                    java.util.List<model.Task> upcomingTasks = (java.util.List<model.Task>) request.getAttribute("upcomingTasks");
                    if (upcomingTasks == null || upcomingTasks.isEmpty()) { 
                %>
                    <p style="color: #6b7280; font-size: 0.875rem;">No upcoming tasks.</p>
                <% } else { %>
                    <div style="display: flex; flex-direction: column; gap: 1rem;">
                    <% for (model.Task t : upcomingTasks) { %>
                        <div style="border: 1px solid #e5e7eb; padding: 0.75rem 1rem; border-radius: 0.25rem;">
                            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.25rem;">
                                <a href="<%= request.getContextPath() %>/user/task/view?id=<%= t.getId() %>" style="color: #4f46e5; text-decoration: none; font-weight: 500;"><%= t.getTitle() %></a>
                                <span style="font-size: 0.75rem; padding: 0.125rem 0.5rem; border-radius: 9999px; font-weight: 500; background-color: #e0e7ff; color: #3730a3;"><%= t.getStatus() %></span>
                            </div>
                            <div style="display: flex; gap: 1rem; font-size: 0.875rem; color: #6b7280;">
                                <span><strong>Priority:</strong> <%= t.getPriority() %></span>
                                <span><strong>Due:</strong> <%= t.getDeadline() != null ? sdf.format(t.getDeadline()) : "N/A" %></span>
                            </div>
                        </div>
                    <% } %>
                    </div>
                <% } %>
            </div>
        </div>

        <!-- Recent Activity Section -->
        <div style="background: white; border-radius: 0.5rem; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb;">
            <h2 style="margin-top: 0; font-size: 1.25rem; margin-bottom: 1rem;">Recent Activity</h2>
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
            <% 
                java.util.List<model.TaskHistory> recentActivity = (java.util.List<model.TaskHistory>) request.getAttribute("recentActivity");
                if (recentActivity == null || recentActivity.isEmpty()) { 
            %>
                <p style="color: #6b7280; font-size: 0.875rem;">No activity yet.</p>
            <% } else { %>
                <div style="display: flex; flex-direction: column; gap: 1rem;">
                <% 
                    java.text.SimpleDateFormat sdf2 = new java.text.SimpleDateFormat("MMM d, yyyy HH:mm");
                    java.util.Map<Integer, String> userMap = (java.util.Map<Integer, String>) request.getAttribute("userMap");
                    for (model.TaskHistory h : recentActivity) { 
                        String actorName = h.getUserId() != null && userMap.containsKey(h.getUserId()) ? userMap.get(h.getUserId()) : "Unknown User";
                        String label = getActionLabel(h.getAction());
                %>
                    <div style="border-left: 2px solid #e5e7eb; padding-left: 1rem; margin-left: 0.5rem; position: relative;">
                        <div style="position: absolute; left: -0.375rem; top: 0.25rem; width: 0.75rem; height: 0.75rem; background-color: #4f46e5; border-radius: 50%;"></div>
                        <div style="font-weight: bold; color: #111827; margin-bottom: 0.25rem; font-size: 0.875rem;"><%= label %> <span style="color: #6b7280; font-weight: normal;">(Task #<%= h.getTaskId() %>)</span></div>
                        <div style="color: #4b5563; font-weight: 500; font-size: 0.875rem;"><%= actorName %></div>
                        <div style="color: #6b7280; font-size: 0.75rem; margin-bottom: 0.25rem;"><%= h.getAction() %></div>
                        <div style="color: #9ca3af; font-size: 0.75rem;"><%= sdf2.format(h.getCreatedAt()) %></div>
                    </div>
                <%  } %>
                </div>
            <% } %>
        </div>
    </div>
</body>
</html>
