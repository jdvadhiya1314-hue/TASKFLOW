<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Task" %>
<%@ page import="model.User" %>
<%
    Task task = (Task) request.getAttribute("task");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Task - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; margin: 0; display: flex; }
        .sidebar { width: 250px; background-color: #ffffff; height: 100vh; padding: 1.5rem 1rem; border-right: 1px solid #e5e7eb; box-sizing: border-box; }
        .sidebar h2 { margin-top: 0; color: #4f46e5; font-size: 1.5rem; margin-bottom: 2rem; }
        .sidebar a { display: block; padding: 0.75rem 1rem; color: #4b5563; text-decoration: none; border-radius: 0.375rem; margin-bottom: 0.5rem; font-weight: 500; }
        .sidebar a:hover, .sidebar a.active { background-color: #f3f4f6; color: #111827; }
        .main-content { flex: 1; padding: 2rem; overflow-y: auto; height: 100vh; box-sizing: border-box; }
        .form-container { background: white; padding: 2rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); max-width: 800px; }
        .form-group { margin-bottom: 1.5rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-weight: 500; color: #374151; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 0.75rem; border: 1px solid #d1d5db; border-radius: 0.375rem; box-sizing: border-box; }
        .btn { background-color: #4f46e5; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 0.375rem; font-weight: 500; cursor: pointer; }
        .error { background-color: #fee2e2; color: #991b1b; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1.5rem; border: 1px solid #f87171; }
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
        <h1 style="margin-top:0;">Edit Task #<%= task.getId() %></h1>
        
        <div class="form-container">
            <% if (request.getAttribute("errorMessage") != null) { %>
                <div class="error"><%= request.getAttribute("errorMessage") %></div>
            <% } %>

            <form action="<%= request.getContextPath() %>/admin/task/edit" method="post">
                <input type="hidden" name="id" value="<%= task.getId() %>">
                
                <div class="form-group">
                    <label>Task Title *</label>
                    <input type="text" name="title" value="<%= task.getTitle().replace("\"", "&quot;") %>" required>
                </div>
                
                <div class="form-group">
                    <label>Description</label>
                    <textarea name="description" rows="4"><%= task.getDescription() != null ? task.getDescription() : "" %></textarea>
                </div>
                
                <div class="form-group">
                    <label>Assign To User</label>
                    <select name="assignedTo">
                        <option value="">-- Select User --</option>
                        <% 
                            List<User> users = (List<User>) request.getAttribute("users");
                            if (users != null) {
                                for (User u : users) {
                                    boolean selected = (task.getAssignedTo() != null && task.getAssignedTo() == u.getId());
                        %>
                                <option value="<%= u.getId() %>" <%= selected ? "selected" : "" %>><%= u.getName() %> (<%= u.getEmail() %>)</option>
                        <%      }
                            }
                        %>
                    </select>
                </div>
                
                <div style="display:flex; gap:1rem;">
                    <div class="form-group" style="flex:1;">
                        <label>Start Date & Time *</label>
                        <input type="datetime-local" name="startDate" value="<%= task.getStartDate().toString().substring(0, 16) %>" required>
                    </div>
                    <div class="form-group" style="flex:1;">
                        <label>Deadline *</label>
                        <input type="datetime-local" name="deadline" value="<%= task.getDeadline().toString().substring(0, 16) %>" required>
                    </div>
                </div>
                
                <div style="display:flex; gap:1rem;">
                    <div class="form-group" style="flex:1;">
                        <label>Priority</label>
                        <select name="priority">
                            <option value="LOW" <%= "LOW".equals(task.getPriority()) ? "selected" : "" %>>LOW</option>
                            <option value="MEDIUM" <%= "MEDIUM".equals(task.getPriority()) ? "selected" : "" %>>MEDIUM</option>
                            <option value="HIGH" <%= "HIGH".equals(task.getPriority()) ? "selected" : "" %>>HIGH</option>
                        </select>
                    </div>
                </div>
                
                <button type="submit" class="btn">Update Task</button>
                <a href="<%= request.getContextPath() %>/admin/tasks" style="margin-left:1rem; color:#6b7280; text-decoration:none;">Cancel</a>
            </form>
        </div>
    </div>
</body>
</html>
