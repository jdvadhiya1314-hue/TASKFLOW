<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Task" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>All Tasks - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; margin: 0; display: flex; }
        .sidebar { width: 250px; background-color: #ffffff; height: 100vh; padding: 1.5rem 1rem; border-right: 1px solid #e5e7eb; box-sizing: border-box; }
        .sidebar h2 { margin-top: 0; color: #4f46e5; font-size: 1.5rem; margin-bottom: 2rem; }
        .sidebar a { display: block; padding: 0.75rem 1rem; color: #4b5563; text-decoration: none; border-radius: 0.375rem; margin-bottom: 0.5rem; font-weight: 500; }
        .sidebar a:hover, .sidebar a.active { background-color: #f3f4f6; color: #111827; }
        .main-content { flex: 1; padding: 2rem; overflow-y: auto; height: 100vh; box-sizing: border-box; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; }
        .btn { background-color: #4f46e5; color: white; padding: 0.5rem 1rem; text-decoration: none; border-radius: 0.375rem; font-weight: 500; border: none; cursor: pointer; }
        .btn-small { padding: 0.25rem 0.5rem; font-size: 0.875rem; }
        .btn-danger { background-color: #ef4444; }
        .table-container { background: white; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; text-align: left; }
        th, td { padding: 1rem; border-bottom: 1px solid #e5e7eb; }
        th { background-color: #f8fafc; color: #475569; font-weight: 600; font-size: 0.875rem; text-transform: uppercase; }
        .badge { padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; display: inline-block; }
        .badge-HIGH { background-color: #fee2e2; color: #991b1b; }
        .badge-MEDIUM { background-color: #fef3c7; color: #92400e; }
        .badge-LOW { background-color: #d1fae5; color: #065f46; }
        .badge-URGENT { background-color: #7f1d1d; color: white; }
        .success-msg { background-color: #d1fae5; color: #065f46; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>TaskFlow</h2>
        <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/admin/tasks" class="active">All Tasks</a>
        <a href="<%= request.getContextPath() %>/admin/postponement-requests">Postponement Requests</a>
        <a href="<%= request.getContextPath() %>/admin/task/create">Create Task</a>
        <a href="<%= request.getContextPath() %>/logout" style="color: #dc2626; margin-top: auto;">Logout</a>
    </div>
    
    <div class="main-content">
        <div class="header" style="margin-bottom: 1rem;">
            <h1 style="margin:0;">All Tasks</h1>
            <a href="<%= request.getContextPath() %>/admin/task/create" class="btn">+ Create Task</a>
        </div>
        
        <div style="margin-bottom: 2rem; background: white; padding: 1rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb;">
            <form action="<%= request.getContextPath() %>/admin/tasks" method="get" style="display: flex; gap: 1rem; flex-wrap: wrap; align-items: center;">
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
                
                <select name="user" style="padding: 0.5rem; border: 1px solid #d1d5db; border-radius: 0.375rem;">
                    <% String userP = (String) request.getAttribute("userParam"); %>
                    <option value="All Users" <%= "All Users".equals(userP) || userP == null ? "selected" : "" %>>All Users</option>
                    <% 
                        List<model.User> activeUsers = (List<model.User>) request.getAttribute("activeUsers");
                        if (activeUsers != null) {
                            for(model.User u : activeUsers) {
                    %>
                    <option value="<%= u.getId() %>" <%= String.valueOf(u.getId()).equals(userP) ? "selected" : "" %>><%= u.getName() %></option>
                    <%      }
                        }
                    %>
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
                
                <button type="submit" class="btn">Filter</button>
                <a href="<%= request.getContextPath() %>/admin/tasks" class="btn" style="background-color: #6b7280; text-decoration: none;">Clear Filters</a>
            </form>
        </div>
        
        <% if ("created".equals(request.getParameter("success"))) { %>
            <div class="success-msg">Task created successfully!</div>
        <% } else if ("updated".equals(request.getParameter("success"))) { %>
            <div class="success-msg">Task updated successfully!</div>
        <% } else if ("deleted".equals(request.getParameter("success"))) { %>
            <div class="success-msg">Task deleted successfully!</div>
        <% } %>

        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Title</th>
                        <th>Assigned User</th>
                        <th>Priority</th>
                        <th>Status</th>
                        <th>Due Date</th>
                        <th>Created Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        List<Task> tasks = (List<Task>) request.getAttribute("tasks");
                        java.util.Map<Integer, String> userMap = (java.util.Map<Integer, String>) request.getAttribute("userMap");
                        if (tasks != null && !tasks.isEmpty()) {
                            for (Task t : tasks) { 
                                String assignedName = t.getAssignedTo() != null && userMap.containsKey(t.getAssignedTo()) ? userMap.get(t.getAssignedTo()) : "Unassigned";
                    %>
                    <tr>
                        <td>#<%= t.getId() %></td>
                        <td style="font-weight:500;"><%= t.getTitle() %></td>
                        <td><%= assignedName %></td>
                        <td><span class="badge badge-<%= t.getPriority() %>"><%= t.getPriority() %></span></td>
                        <td>
                            <% if (t.getDeadline() != null && t.getDeadline().before(new java.util.Date()) && !"COMPLETED".equals(t.getStatus())) { %>
                                <span class="badge" style="background-color: #fee2e2; color: #b91c1c; margin-right: 0.25rem;">OVERDUE</span>
                            <% } %>
                            <%= t.getStatus() %>
                        </td>
                        <td><%= t.getDeadline() != null ? t.getDeadline().toString().substring(0, 16) : "" %></td>
                        <td><%= t.getCreatedAt() != null ? t.getCreatedAt().toString().substring(0, 16) : "" %></td>
                        <td>
                            <a href="<%= request.getContextPath() %>/admin/task/view?id=<%= t.getId() %>" class="btn btn-small" style="background:#6b7280;">View</a>
                            <a href="<%= request.getContextPath() %>/admin/task/edit?id=<%= t.getId() %>" class="btn btn-small">Edit</a>
                            <form action="<%= request.getContextPath() %>/admin/task/delete" method="post" style="display:inline;">
                                <input type="hidden" name="id" value="<%= t.getId() %>">
                                <button type="submit" class="btn btn-small btn-danger" onclick="return confirm('Are you sure you want to delete this task?');">Delete</button>
                            </form>
                        </td>
                    </tr>
                    <%      }
                        } else { 
                    %>
                    <tr>
                        <td colspan="8" style="text-align:center; padding: 3rem; color: #6b7280;">
                            <div style="font-size: 1.125rem; font-weight: 500; margin-bottom: 0.5rem;">No tasks match your filters.</div>
                            <a href="<%= request.getContextPath() %>/admin/tasks" class="btn btn-small" style="background-color: #6b7280; text-decoration: none;">Clear Filters</a>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>
