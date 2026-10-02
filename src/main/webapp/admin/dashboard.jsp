<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%
    User user = (User) session.getAttribute("loggedInUser");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; color: #111827; margin: 0; display: flex; }
        .sidebar { width: 250px; background-color: #ffffff; height: 100vh; padding: 1.5rem 1rem; border-right: 1px solid #e5e7eb; box-sizing: border-box; }
        .sidebar h2 { margin-top: 0; color: #4f46e5; font-size: 1.5rem; margin-bottom: 2rem; }
        .sidebar a { display: block; padding: 0.75rem 1rem; color: #4b5563; text-decoration: none; border-radius: 0.375rem; margin-bottom: 0.5rem; font-weight: 500; }
        .sidebar a:hover, .sidebar a.active { background-color: #f3f4f6; color: #111827; }
        .main-content { flex: 1; padding: 2rem; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .header h1 { margin: 0; font-size: 1.875rem; }
        .user-info { display: flex; align-items: center; gap: 1rem; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: white; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #f3f4f6; }
        .stat-card h3 { margin: 0 0 0.5rem 0; font-size: 0.875rem; color: #6b7280; text-transform: uppercase; letter-spacing: 0.05em; }
        .stat-card .value { font-size: 2.25rem; font-weight: bold; color: #111827; margin: 0; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>TaskFlow</h2>
        <a href="<%= request.getContextPath() %>/admin/dashboard" class="active">Dashboard</a>
        <a href="<%= request.getContextPath() %>/admin/tasks">All Tasks</a>
        <a href="<%= request.getContextPath() %>/admin/postponement-requests">Postponement Requests</a>
        <a href="<%= request.getContextPath() %>/admin/task/create">Create Task</a>
        <a href="<%= request.getContextPath() %>/logout" style="color: #dc2626; margin-top: auto;">Logout</a>
    </div>
    
    <div class="main-content">
        <div class="header">
            <div>
                <h1>Good morning, <%= user.getName() %></h1>
                <p style="color: #6b7280; margin: 0.5rem 0 0 0;">Here's what's happening with your tasks today.</p>
            </div>
            <div class="user-info">
                <span><%= user.getEmail() %> (ADMIN)</span>
            </div>
        </div>

        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Tasks</h3>
                <p class="value"><%= request.getAttribute("totalTasks") %></p>
            </div>
            <div class="stat-card">
                <h3>Assigned (Pending)</h3>
                <p class="value" style="color: #4f46e5;"><%= request.getAttribute("pendingTasks") %></p>
            </div>
            <div class="stat-card">
                <h3>In Progress</h3>
                <p class="value" style="color: #d97706;"><%= request.getAttribute("inProgressTasks") %></p>
            </div>
            <div class="stat-card">
                <h3>Completed</h3>
                <p class="value" style="color: #059669;"><%= request.getAttribute("completedTasks") %></p>
            </div>
            <div class="stat-card">
                <h3>Overdue</h3>
                <p class="value" style="color: #dc2626;"><%= request.getAttribute("overdueTasks") %></p>
            </div>
            <div class="stat-card">
                <h3>Postponement Requests</h3>
                <p class="value" style="color: #ea580c;"><%= request.getAttribute("postponementRequests") %></p>
            </div>
        </div>

        <div style="display: flex; gap: 2rem; flex-wrap: wrap;">
            <!-- Recent Tasks Section -->
            <div style="flex: 2; min-width: 300px; background: white; border-radius: 0.5rem; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #f3f4f6;">
                <h2 style="margin-top: 0; font-size: 1.25rem; margin-bottom: 1rem;">Recent Tasks</h2>
                <% 
                    java.util.List<model.Task> recentTasks = (java.util.List<model.Task>) request.getAttribute("recentTasks");
                    java.util.Map<Integer, String> userMap = (java.util.Map<Integer, String>) request.getAttribute("userMap");
                    if (recentTasks == null || recentTasks.isEmpty()) { 
                %>
                    <p style="color: #6b7280; font-size: 0.875rem;">No tasks assigned yet.</p>
                <% } else { %>
                    <table style="width: 100%; border-collapse: collapse;">
                        <thead>
                            <tr style="border-bottom: 1px solid #e5e7eb; text-align: left; color: #6b7280; font-size: 0.875rem;">
                                <th style="padding: 0.75rem 0;">Task</th>
                                <th style="padding: 0.75rem 0;">Assigned To</th>
                                <th style="padding: 0.75rem 0;">Priority</th>
                                <th style="padding: 0.75rem 0;">Status</th>
                                <th style="padding: 0.75rem 0; text-align: right;">Deadline</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% 
                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("MMM d, yyyy HH:mm");
                            for (model.Task t : recentTasks) { 
                                String assignedName = (t.getAssignedTo() != null && userMap.containsKey(t.getAssignedTo())) ? userMap.get(t.getAssignedTo()) : "Unassigned";
                        %>
                            <tr style="border-bottom: 1px solid #f3f4f6;">
                                <td style="padding: 0.75rem 0;">
                                    <a href="<%= request.getContextPath() %>/admin/task/view?id=<%= t.getId() %>" style="color: #4f46e5; text-decoration: none; font-weight: 500;"><%= t.getTitle() %></a>
                                </td>
                                <td style="padding: 0.75rem 0; font-size: 0.875rem;"><%= assignedName %></td>
                                <td style="padding: 0.75rem 0;">
                                    <span style="font-size: 0.75rem; padding: 0.25rem 0.5rem; border-radius: 9999px; font-weight: 500; background-color: #f3f4f6; color: #4b5563;"><%= t.getPriority() %></span>
                                </td>
                                <td style="padding: 0.75rem 0;">
                                    <% if (t.getDeadline() != null && t.getDeadline().before(new java.util.Date()) && !"COMPLETED".equals(t.getStatus())) { %>
                                        <span style="font-size: 0.75rem; padding: 0.25rem 0.5rem; border-radius: 9999px; font-weight: 500; background-color: #fee2e2; color: #b91c1c; margin-right: 0.25rem;">OVERDUE</span>
                                    <% } %>
                                    <span style="font-size: 0.75rem; padding: 0.25rem 0.5rem; border-radius: 9999px; font-weight: 500; background-color: #e0e7ff; color: #3730a3;"><%= t.getStatus() %></span>
                                </td>
                                <td style="padding: 0.75rem 0; text-align: right; font-size: 0.875rem; color: #6b7280;">
                                    <%= t.getDeadline() != null ? sdf.format(t.getDeadline()) : "N/A" %>
                                </td>
                            </tr>
                        <%  } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

            <!-- Recent Activity Section -->
            <div style="flex: 1; min-width: 250px; background: white; border-radius: 0.5rem; padding: 1.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #f3f4f6;">
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
                        java.text.SimpleDateFormat sdf2 = new java.text.SimpleDateFormat("MMM d, HH:mm");
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
    </div>
</body>
</html>
