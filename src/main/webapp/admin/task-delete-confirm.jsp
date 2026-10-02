<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Task" %>
<%
    Task task = (Task) request.getAttribute("task");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Delete Task - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; margin: 0; display: flex; align-items: center; justify-content: center; height: 100vh; }
        .card { background: white; padding: 2rem; border-radius: 0.5rem; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); max-width: 500px; text-align: center; }
        .card h1 { color: #991b1b; margin-top: 0; }
        .btn { padding: 0.75rem 1.5rem; border: none; border-radius: 0.375rem; font-weight: 500; cursor: pointer; text-decoration: none; display: inline-block; font-size: 1rem; }
        .btn-danger { background-color: #ef4444; color: white; }
        .btn-cancel { background-color: #f3f4f6; color: #374151; margin-left: 1rem; }
    </style>
</head>
<body>
    <div class="card">
        <h1>Confirm Deletion</h1>
        <p>Are you sure you want to permanently delete task: <strong><%= task.getTitle() %></strong> (ID: <%= task.getId() %>)?</p>
        <p style="color: #6b7280; font-size: 0.875rem; margin-bottom: 2rem;">This action cannot be undone.</p>
        
        <form action="<%= request.getContextPath() %>/admin/task/delete" method="post" style="display:inline-block;">
            <input type="hidden" name="id" value="<%= task.getId() %>">
            <button type="submit" class="btn btn-danger">Yes, Delete Task</button>
        </form>
        <a href="<%= request.getContextPath() %>/admin/tasks" class="btn btn-cancel">Cancel</a>
    </div>
</body>
</html>
