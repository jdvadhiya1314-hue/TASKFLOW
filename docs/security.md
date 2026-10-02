# Security Documentation

TASKFLOW implements multiple layers of security tailored for its architecture. 

## Implemented Security Mechanisms

- **Authentication Filter (`AuthenticationFilter.java`):** A global servlet filter that intercepts every incoming HTTP request. It verifies the existence of a valid `HttpSession`. It explicitly checks the authenticated user's role against the requested URI path, strictly isolating `/admin/*` routes from standard users.
- **Session-Based Authentication:** User state is maintained securely on the server via standard Jakarta Servlet sessions, rather than relying on client-side cookies for state holding.
- **Role-Based Authorization (RBAC):** Admin users have overarching access to task creation and system administration, while standard Users are restricted to their specific operational dashboards and endpoints.
- **Task Ownership Validation:** Servlets handling user actions (e.g., `UserTaskCommentServlet`, `UserTaskStartServlet`, `UserTaskPostponeServlet`) explicitly retrieve the target task from the database and verify that `task.getAssignedTo()` matches the `loggedInUser.getId()`. This prevents users from altering or interacting with tasks assigned to others via URL manipulation.
- **Notification Ownership Validation:** Users can only view and interact with notifications linked to their specific User ID.
- **PreparedStatements:** All database interactions across all Data Access Objects (DAOs) utilize JDBC `PreparedStatement` objects. This parameterized execution ensures that all user inputs are properly escaped by the JDBC driver, completely eliminating the risk of SQL Injection attacks.
- **Dynamic Sort Whitelisting:** In `TaskDAO.java`, dynamic `ORDER BY` clauses are constructed using a strict `switch` statement on predefined string values (e.g., `"deadline_asc"`). Raw user input is never concatenated into the SQL string.
- **Dependency Authorization:** Only administrators have the authority to add or remove task prerequisites.
- **Graceful Error Handling:** Exception stack traces are caught and routed to `getServletContext().log()`. End users are presented with generic `500.jsp` error pages, preventing the leakage of internal architecture or database structures to potential attackers.

## Known Security Limitations

*Important: This application is a college project. The following limitations must be addressed before deploying the application to a real, public-facing production environment.*

- **Plain-Text Passwords:** User passwords are currently stored directly in the MySQL database in plain text. They are not hashed (e.g., using BCrypt or Argon2), meaning a database breach would instantly compromise all user accounts.
- **No CSRF Protection:** HTML forms do not implement Anti-Cross Site Request Forgery (CSRF) tokens. The application is theoretically vulnerable to state-changing requests forged by malicious third-party websites if a user is actively authenticated.
- **No Automated Security Tests:** The application relies on manual code reviews and architecture design for security, rather than automated security scanning or penetration testing suites.
