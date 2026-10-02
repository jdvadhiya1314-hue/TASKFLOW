<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Task" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("loggedInUser");
    List<Task> assignedTasks = (List<Task>) request.getAttribute("assignedTasks");
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null) pageTitle = "Tasks";
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String currentRoute = (String) request.getAttribute("currentRoute"); 
    if (currentRoute == null) currentRoute = "/user/tasks";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> - TaskFlow</title>
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
                <h1><%= pageTitle %></h1>
            </div>
            <div class="user-info">
                <span><%= user.getEmail() %><br><small style="color: #6b7280;">USER</small></span>
            </div>
        </div>

        <% if ("/user/tasks".equals(currentRoute)) { %>
        <div style="margin-bottom: 2rem; background: white; padding: 1rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb;">
            <form action="<%= request.getContextPath() %>/user/tasks" method="get" style="display: flex; gap: 1rem; flex-wrap: wrap; align-items: center;">
                <input type="text" name="search" placeholder="Search tasks..." value="<%= request.getAttribute("searchParam") != null ? request.getAttribute("searchParam") : "" %>" style="padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem; flex: 1; min-width: 200px;">
                
                <select name="status" style="padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem;">
                    <% String statusP = (String) request.getAttribute("statusParam"); %>
                    <option value="All" <%= "All".equals(statusP) || statusP == null ? "selected" : "" %>>All Statuses</option>
                    <option value="ASSIGNED" <%= "ASSIGNED".equals(statusP) ? "selected" : "" %>>Assigned</option>
                    <option value="IN_PROGRESS" <%= "IN_PROGRESS".equals(statusP) ? "selected" : "" %>>In Progress</option>
                    <option value="COMPLETED" <%= "COMPLETED".equals(statusP) ? "selected" : "" %>>Completed</option>
                </select>
                
                <select name="priority" style="padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem;">
                    <% String priorityP = (String) request.getAttribute("priorityParam"); %>
                    <option value="All" <%= "All".equals(priorityP) || priorityP == null ? "selected" : "" %>>All Priorities</option>
                    <option value="LOW" <%= "LOW".equals(priorityP) ? "selected" : "" %>>Low</option>
                    <option value="MEDIUM" <%= "MEDIUM".equals(priorityP) ? "selected" : "" %>>Medium</option>
                    <option value="HIGH" <%= "HIGH".equals(priorityP) ? "selected" : "" %>>High</option>
                    <option value="URGENT" <%= "URGENT".equals(priorityP) ? "selected" : "" %>>Urgent</option>
                </select>
                
                <select name="sort" style="padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem;">
                    <% String sortP = (String) request.getAttribute("sortParam"); %>
                    <option value="newest" <%= "newest".equals(sortP) || sortP == null ? "selected" : "" %>>Newest First</option>
                    <option value="oldest" <%= "oldest".equals(sortP) ? "selected" : "" %>>Oldest First</option>
                    <option value="deadline_asc" <%= "deadline_asc".equals(sortP) ? "selected" : "" %>>Deadline: Nearest</option>
                    <option value="deadline_desc" <%= "deadline_desc".equals(sortP) ? "selected" : "" %>>Deadline: Farthest</option>
                    <option value="priority_high" <%= "priority_high".equals(sortP) ? "selected" : "" %>>Priority: High to Low</option>
                    <option value="priority_low" <%= "priority_low".equals(sortP) ? "selected" : "" %>>Priority: Low to High</option>
                </select>

                <label style="display: flex; align-items: center; gap: 0.25rem; font-size: 0.875rem;">
                    <input type="checkbox" name="overdue" <%= Boolean.TRUE.equals(request.getAttribute("overdueParam")) ? "checked" : "" %>> Overdue only
                </label>
                
                <button type="submit" style="background-color: #4f46e5; color: white; padding: 0.5rem 1rem; border-radius: 0.375rem; font-weight: 500; border: none; cursor: pointer;">Filter</button>
                <a href="<%= request.getContextPath() %>/user/tasks" style="background-color: #6b7280; color: white; padding: 0.5rem 1rem; border-radius: 0.375rem; font-weight: 500; text-decoration: none; cursor: pointer;">Clear Filters</a>
            </form>
        </div>
        <% } %>

        <% if (assignedTasks == null || assignedTasks.isEmpty()) { %>
            <div class="empty-state">
                <svg style="width: 48px; height: 48px; margin: 0 auto 1rem auto; color: #9ca3af;" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path></svg>
                <% if ("/user/tasks".equals(currentRoute) && (request.getAttribute("searchParam") != null || request.getAttribute("statusParam") != null || request.getAttribute("priorityParam") != null || Boolean.TRUE.equals(request.getAttribute("overdueParam")))) { %>
                    <p style="margin: 0; font-size: 1.125rem; font-weight: 500;">No tasks match your filters.</p>
                    <p style="margin: 0.5rem 0 1rem 0; font-size: 0.875rem;">Try adjusting your search criteria.</p>
                    <a href="<%= request.getContextPath() %>/user/tasks" style="display:inline-block; background-color: #6b7280; color: white; padding: 0.5rem 1rem; border-radius: 0.375rem; font-weight: 500; text-decoration: none; cursor: pointer;">Clear Filters</a>
                <% } else { %>
                    <p style="margin: 0; font-size: 1.125rem; font-weight: 500;">No tasks found.</p>
                    <p style="margin: 0.5rem 0 0 0; font-size: 0.875rem;">You do not have any tasks in this category.</p>
                <% } %>
            </div>
        <% } else { %>
            <div class="task-list">
                <% for (Task t : assignedTasks) { 
                    String statusClass = "";
                    String status = t.getStatus();
                    if ("COMPLETED".equals(status)) statusClass = "badge-completed";
                    else if ("IN_PROGRESS".equals(status)) statusClass = "badge-inprogress";
                    else if ("ASSIGNED".equals(status)) statusClass = "badge-assigned";
                    else statusClass = "badge-pending";
                %>
                <div class="task-card">
                    <div class="task-header">
                        <h3 class="task-title"><%= t.getTitle() %></h3>
                        <div>
                            <% if (t.getDeadline() != null && t.getDeadline().before(new java.util.Date()) && !"COMPLETED".equals(status)) { %>
                                <span class="badge" style="background-color: #fee2e2; color: #b91c1c;">OVERDUE</span>
                            <% } %>
                            <span class="badge <%= statusClass %>"><%= t.getStatus() %></span>
                        </div>
                    </div>
                    <p class="task-desc"><%= t.getDescription() != null ? t.getDescription() : "No description provided." %></p>
                    <div class="task-meta">
                        <span><strong>Priority:</strong> <%= t.getPriority() %></span>
                        <span><strong>Due:</strong> <%= t.getDeadline() != null ? sdf.format(t.getDeadline()) : "N/A" %></span>
                        <span><strong>Created:</strong> <%= t.getCreatedAt() != null ? sdf.format(t.getCreatedAt()) : "N/A" %></span>
                    </div>
                    <div style="margin-top: 1rem; text-align: right;">
                        <a href="<%= request.getContextPath() %>/user/task/view?id=<%= t.getId() %>" style="display:inline-block; padding: 0.5rem 1rem; background-color: #4f46e5; color: white; text-decoration: none; border-radius: 0.375rem; font-weight: 500; font-size: 0.875rem;">View Details &rarr;</a>
                    </div>
                </div>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>
