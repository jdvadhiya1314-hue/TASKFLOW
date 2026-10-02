<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>TaskFlow - Test Connection</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f3f4f6; color: #1f2937; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; }
        .container { background-color: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); text-align: center; max-width: 500px; width: 100%; }
        h2 { margin-top: 0; color: #111827; }
        .status { padding: 1rem; border-radius: 4px; margin: 1rem 0; word-break: break-word; }
        .success { background-color: #d1fae5; color: #065f46; border: 1px solid #34d399; }
        .error { background-color: #fee2e2; color: #991b1b; border: 1px solid #f87171; }
        .btn { display: inline-block; background-color: #4f46e5; color: white; padding: 0.5rem 1rem; text-decoration: none; border-radius: 4px; font-weight: 500; margin-top: 1rem; transition: background-color 0.2s; }
        .btn:hover { background-color: #4338ca; }
    </style>
</head>
<body>
    <div class="container">
        <h2>Database Connection Status</h2>
        
        <% 
            String statusMsg = (String) request.getAttribute("dbStatus"); 
            boolean isSuccess = statusMsg != null && statusMsg.contains("successfully");
        %>
        
        <div class="status <%= isSuccess ? "success" : "error" %>">
            <strong>Result:</strong> <%= statusMsg != null ? statusMsg : "Unknown error" %>
        </div>
        
        <a href="index.jsp" class="btn">Back Home</a>
    </div>
</body>
</html>
