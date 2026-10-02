<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Page Not Found - TaskFlow</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f9fafb; color: #111827; margin: 0; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .error-container { text-align: center; background: white; padding: 3rem; border-radius: 0.5rem; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06); max-width: 400px; width: 100%; border: 1px solid #e5e7eb; }
        h1 { font-size: 3rem; color: #4f46e5; margin: 0 0 1rem 0; }
        h2 { font-size: 1.5rem; margin: 0 0 1rem 0; }
        p { color: #6b7280; margin-bottom: 2rem; }
        .btn { background-color: #4f46e5; color: white; padding: 0.75rem 1.5rem; text-decoration: none; border-radius: 0.375rem; font-weight: 500; display: inline-block; }
    </style>
</head>
<body>
    <div class="error-container">
        <h1>404</h1>
        <h2>Page not found</h2>
        <p>The page you're looking for doesn't exist or has been moved.</p>
        <a href="<%= request.getContextPath() %>/" class="btn">Return Home</a>
    </div>
</body>
</html>
