# Non-Functional Requirements

## 1. Security
- **Role-Based Access Control (RBAC):** The system relies on a central `AuthenticationFilter` to ensure that unauthorized users cannot access protected routes, and that Users cannot access Admin-level functionality.
- **Resource Ownership:** The system enforces strict ownership checks; Users can only view, start, complete, comment on, and request postponements for tasks specifically assigned to them.
- **SQL Injection Prevention:** All database interactions are strictly handled using JDBC `PreparedStatement` objects, preventing SQL injection attacks. Dynamic SQL queries (like sorting) use hardcoded whitelist strategies.

## 2. Usability
- **Responsive UI:** The application is built with responsive HTML and Vanilla CSS, ensuring layouts (including sidebars and tables) adapt gracefully to mobile and desktop screens.
- **Consistent Styling:** The UI maintains a clean, modern aesthetic utilizing standardized badges, rounded cards, and consistent empty-state indicators across all modules.
- **Clear Error Messaging:** System errors and exceptions are intercepted and logged to the server context, while users are presented with clean, user-friendly error pages (`404.jsp`, `500.jsp`) instead of raw stack traces. Dependency blocking presents clear, URL-encoded explanations to the user.

## 3. Maintainability
- **MVC Architecture:** The project strictly separates concerns by isolating database access (DAOs), business logic/routing (Servlets), and presentation (JSPs). 
- **Framework Independence:** The system does not rely on heavy frameworks like Spring or Hibernate, reducing complexity and lowering the barrier to entry for maintenance.

## 4. Performance
- **Connection Pooling:** The system relies on `DBConnection.java` to manage database connections efficiently, ensuring resources are properly closed after query execution.
- *(Note: Currently, the system lacks pagination on task lists, which is a known performance limitation for very large datasets).*

## 5. Reliability
- **Data Integrity:** The database schema enforces strict referential integrity using Foreign Keys with `ON DELETE CASCADE` and `ON DELETE SET NULL` constraints.
- **Transaction History:** The `task_history` module ensures that a reliable, chronological record of all system events is maintained regardless of subsequent edits.

## 6. Scalability Considerations
While designed as a localized college project, the underlying Jakarta Servlet and MySQL architecture is inherently scalable. Future scalability would require the implementation of connection pooling libraries (e.g., HikariCP), query pagination, and database indexing on frequently searched columns like `status` and `assigned_to`.
