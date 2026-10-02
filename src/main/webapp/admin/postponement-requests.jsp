<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %>
<%@ page import="model.PostponementRequest" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    List<PostponementRequest> requests = (List<PostponementRequest>) request.getAttribute("postponementRequests");
    Map<Integer, String> userMap = (Map<Integer, String>) request.getAttribute("userMap");
    Map<Integer, String> taskMap = (Map<Integer, String>) request.getAttribute("taskMap");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Postponement Requests - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; color: #111827; margin: 0; display: flex; }
        .sidebar { width: 250px; background-color: #ffffff; height: 100vh; padding: 1.5rem 1rem; border-right: 1px solid #e5e7eb; box-sizing: border-box; position: fixed; }
        .sidebar h2 { margin-top: 0; color: #4f46e5; font-size: 1.5rem; margin-bottom: 2rem; }
        .sidebar a { display: block; padding: 0.75rem 1rem; color: #4b5563; text-decoration: none; border-radius: 0.375rem; margin-bottom: 0.5rem; font-weight: 500; }
        .sidebar a:hover, .sidebar a.active { background-color: #f3f4f6; color: #111827; }
        .main-content { margin-left: 250px; flex: 1; padding: 2rem; min-height: 100vh; box-sizing: border-box; }
        
        .request-list { display: grid; gap: 1.5rem; }
        .request-card { background: white; padding: 1.5rem; border-radius: 0.5rem; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb; }
        .request-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; border-bottom: 1px solid #e5e7eb; padding-bottom: 1rem; }
        .request-title { margin: 0; font-size: 1.125rem; font-weight: 600; }
        
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; }
        .badge-pending { background-color: #fef3c7; color: #92400e; }
        .badge-approved { background-color: #d1fae5; color: #065f46; }
        .badge-rejected { background-color: #fee2e2; color: #991b1b; }
        
        .meta-info { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; font-size: 0.875rem; margin-bottom: 1rem; }
        .meta-label { color: #6b7280; font-weight: 500; }
        .meta-value { font-weight: 600; }
        
        .admin-response { background-color: #f3f4f6; padding: 1rem; border-radius: 0.5rem; font-size: 0.875rem; border-left: 4px solid #4f46e5; margin-top: 1rem; }
        
        .btn { background-color: #4f46e5; color: white; padding: 0.5rem 1rem; border: none; border-radius: 0.375rem; font-weight: 500; cursor: pointer; }
        .btn-success { background-color: #10b981; }
        .btn-danger { background-color: #ef4444; }
        
        .action-form { background: #f9fafb; padding: 1rem; border-radius: 0.5rem; border: 1px solid #e5e7eb; margin-top: 1rem; }
        .action-form textarea { width: 100%; padding: 0.75rem; border: 1px solid #d1d5db; border-radius: 0.375rem; box-sizing: border-box; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <div class="sidebar">
        <h2>TaskFlow</h2>
        <a href="<%= request.getContextPath() %>/admin/dashboard">Dashboard</a>
        <a href="<%= request.getContextPath() %>/admin/tasks">All Tasks</a>
        <a href="<%= request.getContextPath() %>/admin/postponement-requests" class="active">Postponement Requests</a>
        <a href="<%= request.getContextPath() %>/admin/task/create">Create Task</a>
        <a href="<%= request.getContextPath() %>/logout" style="color: #dc2626; margin-top: auto;">Logout</a>
    </div>
    
    <div class="main-content">
        <h1 style="margin-top:0;">Manage Postponement Requests</h1>
        
        <% if (request.getParameter("success") != null) { %>
            <div style="background-color: #d1fae5; color: #065f46; padding: 1rem; border-radius: 0.375rem; margin-bottom: 1.5rem;">Action successfully recorded.</div>
        <% } %>
        
        <% if (requests == null || requests.isEmpty()) { %>
            <div style="background: white; padding: 3rem; text-align: center; border-radius: 0.5rem; border: 1px dashed #d1d5db; color: #6b7280;">No postponement requests.</div>
        <% } else { %>
            <div class="request-list">
                <% for (PostponementRequest req : requests) { 
                    String statusClass = "badge-pending";
                    if ("APPROVED".equals(req.getStatus())) statusClass = "badge-approved";
                    else if ("REJECTED".equals(req.getStatus())) statusClass = "badge-rejected";
                    
                    String userName = userMap.getOrDefault(req.getUserId(), "Unknown");
                    String taskTitle = taskMap.getOrDefault(req.getTaskId(), "Unknown Task");
                %>
                <div class="request-card">
                    <div class="request-header">
                        <h3 class="request-title">Task #<%= req.getTaskId() %>: <%= taskTitle %></h3>
                        <span class="badge <%= statusClass %>"><%= req.getStatus() %></span>
                    </div>
                    
                    <div class="meta-info">
                        <div><span class="meta-label">Requested By:</span> <span class="meta-value"><%= userName %></span></div>
                        <div><span class="meta-label">Submitted On:</span> <span class="meta-value"><%= req.getCreatedAt() != null ? sdf.format(req.getCreatedAt()) : "N/A" %></span></div>
                        <div><span class="meta-label">Current Deadline:</span> <span class="meta-value"><%= req.getCurrentDeadline() != null ? sdf.format(req.getCurrentDeadline()) : "N/A" %></span></div>
                        <div><span class="meta-label">Requested Deadline:</span> <span class="meta-value"><%= req.getRequestedDeadline() != null ? sdf.format(req.getRequestedDeadline()) : "N/A" %></span></div>
                    </div>
                    
                    <div style="background: #f9fafb; padding: 1rem; border-radius: 0.5rem; border: 1px solid #e5e7eb; margin-bottom: 1rem;">
                        <strong>User Reason:</strong><br><%= req.getReason() %>
                    </div>
                    
                    <% if ("PENDING".equals(req.getStatus())) { %>
                        <div class="action-form">
                            <form action="<%= request.getContextPath() %>/admin/postponement/action" method="post">
                                <input type="hidden" name="id" value="<%= req.getId() %>">
                                <strong>Admin Response:</strong>
                                <textarea name="adminResponse" rows="2" placeholder="Provide a reason if rejecting (optional if approving)..."></textarea>
                                
                                <div style="display:flex; gap:1rem;">
                                    <button type="submit" name="action" value="approve" class="btn btn-success">Approve Request</button>
                                    <button type="submit" name="action" value="reject" class="btn btn-danger">Reject Request</button>
                                </div>
                            </form>
                        </div>
                    <% } else { %>
                        <div class="admin-response">
                            <strong>Admin Response:</strong><br>
                            <%= req.getAdminResponse() != null ? req.getAdminResponse() : "No response provided." %><br><br>
                            <span style="color:#6b7280;">Action by Admin ID: <%= req.getRespondedBy() %> on <%= req.getRespondedAt() != null ? sdf.format(req.getRespondedAt()) : "N/A" %></span>
                        </div>
                    <% } %>
                </div>
                <% } %>
            </div>
        <% } %>
    </div>
</body>
</html>
