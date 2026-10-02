<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.Notification" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("loggedInUser");
    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String currentRoute = (String) request.getAttribute("currentRoute"); 
    if (currentRoute == null) currentRoute = "/user/notifications";
    
    boolean hasUnread = false;
    if (notifications != null) {
        for (Notification n : notifications) {
            if (!n.isRead()) {
                hasUnread = true;
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Notifications - TaskFlow</title>
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
        
        .notification-list { display: grid; gap: 1rem; }
        .notification-card { background: white; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb; display: flex; justify-content: space-between; align-items: center; }
        .notification-card.unread { border-left: 4px solid #4f46e5; background-color: #f5f8ff; }
        
        .notification-content { flex: 1; margin-right: 1.5rem; }
        .notification-message { margin: 0 0 0.5rem 0; font-size: 1rem; color: #111827; }
        .notification-meta { font-size: 0.875rem; color: #6b7280; display: flex; gap: 1rem; }
        
        .btn-mark-read { background: none; border: 1px solid #d1d5db; color: #374151; padding: 0.375rem 0.75rem; border-radius: 0.375rem; font-size: 0.875rem; cursor: pointer; transition: background 0.2s; }
        .btn-mark-read:hover { background: #f3f4f6; }
        
        .btn-mark-all { background: white; border: 1px solid #d1d5db; color: #374151; padding: 0.5rem 1rem; border-radius: 0.375rem; font-size: 0.875rem; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-mark-all:hover { background: #f3f4f6; }
        
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; background-color: #e5e7eb; color: #374151; }
        .badge.unread { background-color: #dbeafe; color: #1e40af; }
        
        .empty-state { background: white; padding: 3rem; text-align: center; border-radius: 0.5rem; border: 1px dashed #d1d5db; color: #6b7280; }
        
        @media (max-width: 768px) {
            body { flex-direction: column; }
            .sidebar { width: 100%; height: auto; position: static; padding: 1rem; border-right: none; border-bottom: 1px solid #e5e7eb; }
            .main-content { margin-left: 0; padding: 1rem; }
            .header { flex-direction: column; align-items: flex-start; gap: 1rem; }
            .user-info { text-align: left; }
            .notification-card { flex-direction: column; align-items: flex-start; gap: 1rem; }
            .notification-content { margin-right: 0; }
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
                <h1>Notifications</h1>
            </div>
            <div class="user-info">
                <span><%= user.getEmail() %><br><small style="color: #6b7280;">USER</small></span>
            </div>
        </div>
        
        <div style="margin-bottom: 1.5rem; display: flex; justify-content: flex-end;">
            <% if (hasUnread) { %>
            <form action="<%= request.getContextPath() %>/user/notifications" method="post" style="margin: 0;">
                <input type="hidden" name="action" value="markAllRead">
                <button type="submit" class="btn-mark-all">Mark All as Read</button>
            </form>
            <% } %>
        </div>

        <% if (notifications == null || notifications.isEmpty()) { %>
            <div class="empty-state">
                <svg style="width: 48px; height: 48px; margin: 0 auto 1rem auto; color: #9ca3af;" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"></path></svg>
                <p style="margin: 0; font-size: 1.125rem; font-weight: 500;">No notifications.</p>
                <p style="margin: 0.5rem 0 0 0; font-size: 0.875rem;">You're all caught up!</p>
            </div>
        <% } else { %>
            <div class="notification-list">
                <% for (Notification n : notifications) { %>
                <div class="notification-card <%= !n.isRead() ? "unread" : "" %>">
                    <div class="notification-content">
                        <p class="notification-message">
                            <% if (!n.isRead()) { %>
                            <span class="badge unread" style="margin-right: 0.5rem;">New</span>
                            <% } %>
                            <%= n.getMessage() %>
                        </p>
                        <div class="notification-meta">
                            <span><%= n.getType() != null ? n.getType() : "System" %></span>
                            <span>&bull;</span>
                            <span><%= n.getCreatedAt() != null ? sdf.format(n.getCreatedAt()) : "N/A" %></span>
                        </div>
                    </div>
                    <% if (!n.isRead()) { %>
                    <div>
                        <form action="<%= request.getContextPath() %>/user/notifications" method="post" style="margin: 0;">
                            <input type="hidden" name="action" value="markRead">
                            <input type="hidden" name="id" value="<%= n.getId() %>">
                            <button type="submit" class="btn-mark-read">Mark as Read</button>
                        </form>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>
