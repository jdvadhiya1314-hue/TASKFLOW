<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.PostponementRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("loggedInUser");
    List<PostponementRequest> requests = (List<PostponementRequest>) request.getAttribute("postponementRequests");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String currentRoute = (String) request.getAttribute("currentRoute"); 
    if (currentRoute == null) currentRoute = "/user/postponement-requests";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Postponement Requests - TaskFlow</title>
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
        
        .request-list { display: grid; gap: 1rem; }
        .request-card { background: white; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb; }
        .request-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; }
        .request-title { margin: 0; font-size: 1.125rem; font-weight: 600; }
        .request-reason { color: #4b5563; margin-bottom: 1rem; background: #f9fafb; padding: 1rem; border-radius: 0.5rem; border: 1px solid #e5e7eb; }
        
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; }
        .badge-pending { background-color: #fef3c7; color: #92400e; }
        .badge-approved { background-color: #d1fae5; color: #065f46; }
        .badge-rejected { background-color: #fee2e2; color: #991b1b; }
        
        .meta-info { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; font-size: 0.875rem; margin-bottom: 1rem; }
        .meta-label { color: #6b7280; font-weight: 500; }
        .meta-value { font-weight: 600; }
        
        .admin-response { background-color: #f3f4f6; padding: 1rem; border-radius: 0.5rem; font-size: 0.875rem; border-left: 4px solid #4f46e5; }
        .empty-state { background: white; padding: 3rem; text-align: center; border-radius: 0.5rem; border: 1px dashed #d1d5db; color: #6b7280; }
        
        @media (max-width: 768px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; height: auto; position: static; padding: 1rem; border-right: none; border-bottom: 1px solid #e5e7eb; }
            .main-content { margin-left: 0; padding: 1rem; }
            .header { flex-direction: column; align-items: flex-start; gap: 1rem; }
            .user-info { text-align: left; }
            .meta-info { grid-template-columns: 1fr; }
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
                <h1>Postponement Requests</h1>
            </div>
            <div class="user-info">
                <span><%= user.getEmail() %><br><small style="color: #6b7280;">USER</small></span>
            </div>
        </div>

        <% if (requests == null || requests.isEmpty()) { %>
            <div class="empty-state">
                <svg style="width: 48px; height: 48px; margin: 0 auto 1rem auto; color: #9ca3af;" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
                <p style="margin: 0; font-size: 1.125rem; font-weight: 500;">No postponement requests.</p>
                <p style="margin: 0.5rem 0 0 0; font-size: 0.875rem;">You have not made any deadline extension requests.</p>
            </div>
        <% } else { %>
            <div class="request-list">
                <% for (PostponementRequest req : requests) { 
                    String statusClass = "badge-pending";
                    if ("APPROVED".equals(req.getStatus())) statusClass = "badge-approved";
                    else if ("REJECTED".equals(req.getStatus())) statusClass = "badge-rejected";
                %>
                <div class="request-card">
                    <div class="request-header">
                        <h3 class="request-title">Request for Task #<%= req.getTaskId() %></h3>
                        <span class="badge <%= statusClass %>"><%= req.getStatus() %></span>
                    </div>
                    
                    <div class="meta-info">
                        <div>
                            <span class="meta-label">Current Deadline:</span> 
                            <span class="meta-value"><%= req.getCurrentDeadline() != null ? sdf.format(req.getCurrentDeadline()) : "N/A" %></span>
                        </div>
                        <div>
                            <span class="meta-label">Requested Deadline:</span> 
                            <span class="meta-value"><%= req.getRequestedDeadline() != null ? sdf.format(req.getRequestedDeadline()) : "N/A" %></span>
                        </div>
                        <div>
                            <span class="meta-label">Submitted On:</span> 
                            <span class="meta-value"><%= req.getCreatedAt() != null ? sdf.format(req.getCreatedAt()) : "N/A" %></span>
                        </div>
                    </div>
                    
                    <div class="request-reason">
                        <strong>Reason:</strong><br>
                        <%= req.getReason() %>
                    </div>
                    
                    <% if (req.getAdminResponse() != null && !req.getAdminResponse().trim().isEmpty()) { %>
                    <div class="admin-response">
                        <strong>Admin Response:</strong><br>
                        <%= req.getAdminResponse() %>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>
