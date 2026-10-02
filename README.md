# TASKFLOW — Task Management and Workflow System

## 1. Project Overview
TASKFLOW is a web-based task management and workflow system designed to centralize and track assignments. It provides administrators with the ability to assign tasks, set deadlines, and track dependencies, while users can manage their workload, report progress, and request deadline postponements when necessary.

## 2. Problem Statement
Many small organizations and academic projects rely on informal tools like emails or spreadsheets for task management. This leads to lost requests, missed deadlines, lack of accountability, and poor visibility into task dependencies. TASKFLOW solves this by providing a structured, centralized system for task lifecycle management, complete with automated audit trails and notifications.

## 3. Objectives
- Centralize task management for admins and users.
- Facilitate task assignment and deadline management.
- Provide a robust task status lifecycle (Assigned → In Progress → Completed).
- Handle deadline postponement requests systematically.
- Enforce task dependencies to ensure correct workflow execution order.
- Deliver real-time application notifications for critical updates.
- Maintain a complete history/audit trail of all task activities.
- Provide comprehensive search, filtering, and sorting for task lists.

## 4. Key Features
- **Role-Based Dashboards:** Distinct dashboards for Admin and User roles offering relevant statistics and recent activity feeds.
- **Task Dependencies:** Administrators can set prerequisites for tasks. The system automatically prevents self, duplicate, and circular dependencies. Users are blocked from starting a task until its prerequisites are completed.
- **Postponement Workflow:** Users can submit requests to postpone a deadline, requiring a reason. Administrators can approve or reject these requests with a response.
- **In-App Notifications:** Real-time badge indicators for unread notifications related to new assignments, postponement approvals, and rejections.
- **Task History:** A complete audit trail tracking task creation, edits, assignment changes, comments, dependencies, and status updates.
- **Advanced Search & Filter:** Search by text, and filter tasks by status, priority, overdue status, and assigned user. Sort results dynamically.

## 5. User Roles
- **ADMIN:** Responsible for creating, editing, and deleting tasks. Assigns tasks to users, manages task dependencies, and reviews postponement requests.
- **USER:** Responsible for executing assigned tasks. Can start/complete tasks, post comments, and request deadline extensions.

## 6. Technology Stack
- **Language:** Java 21
- **Backend Architecture:** Jakarta Servlet, Jakarta JSP, JSTL
- **Build Tool:** Maven
- **Server:** Apache Tomcat 10.1
- **Database:** MySQL 8.4 (with JDBC)
- **Frontend:** HTML, Vanilla CSS, JavaScript

## 7. Architecture
TASKFLOW strictly follows an MVC pattern:
**Browser → JSP (View) → Servlet (Controller) → DAO (Model Data Access) → DBConnection → MySQL**
No third-party frameworks like Spring, Hibernate, or ORMs are used, keeping the footprint minimal and the architecture highly transparent.

## 8. Project Structure
- `src/main/java/controller/` - Contains all Servlet classes (e.g., `TaskCreateServlet`, `UserTaskCompleteServlet`).
- `src/main/java/dao/` - Contains Data Access Objects for database interaction (e.g., `TaskDAO`, `UserDAO`).
- `src/main/java/model/` - Contains POJOs (Plain Old Java Objects) representing database tables.
- `src/main/java/filter/` - Contains `AuthenticationFilter` for role-based route protection.
- `src/main/java/util/` - Contains `DBConnection` utility.
- `src/main/webapp/` - Contains all JSP view files, organized by role (`admin/`, `user/`, `error/`).
- `src/main/resources/database.sql` - Database initialization and seeding script.

## 9. Database Overview
The application utilizes MySQL with the following primary tables:
- `users`: Stores user credentials, roles, and status.
- `tasks`: Core task data including deadlines, priority, and progress.
- `task_dependencies`: Tracks prerequisite task relationships.
- `postponement_requests`: Tracks deadline extension requests and admin responses.
- `task_comments`: Stores user discussions on specific tasks.
- `task_history`: Maintains an immutable audit trail of actions.
- `notifications`: Stores system alerts for users.

## 10. Main Modules
1. **Authentication:** Secure login and session handling with `AuthenticationFilter`.
2. **Dashboard Analytics:** High-level task metrics and recent activity feeds.
3. **Task CRUD & Lifecycle:** Complete control over task states (`ASSIGNED` → `IN_PROGRESS` → `COMPLETED`).
4. **Postponement Workflow:** Systematic handling of deadline extensions.
5. **Dependency Management:** Enforcement of task execution order.
6. **Audit & Notifications:** Transparent history tracking and user alerts.

## 11. Installation Requirements
- **Java Development Kit (JDK) 21**
- **Apache Maven 3.x**
- **Apache Tomcat 10.1**
- **MySQL Server 8.4**

## 12. MySQL & Database Setup
1. Open your MySQL terminal or GUI client (like MySQL Workbench).
2. Execute the provided SQL script to construct the database schema and seed data:
   `SOURCE src/main/resources/database.sql;`
3. Set the required environment variables for the database connection:
   - `DB_URL` (Optional, defaults to local taskflow database)
   - `DB_USER` (Optional, defaults to `root`)
   - `DB_PASSWORD` (Required, your MySQL password)

   **Example (Linux/macOS):**
   ```bash
   export DB_USER="root"
   export DB_PASSWORD="your_password_here"
   ```

   **Example (Windows Command Prompt):**
   ```cmd
   set DB_USER=root
   set DB_PASSWORD=your_password_here
   ```

## 13. Configuration Instructions
- Ensure Tomcat 10.1 is configured to run on port `8080`.
- Verify the deployment context path is set to `/taskflow`.

## 14. Maven Build Instructions
Compile and package the application using Maven from the project root directory:
```bash
mvn clean package
```
This generates `target/taskflow-1.0-SNAPSHOT.war`.

## 15. Tomcat Deployment Instructions
Deploy the `.war` file to your Tomcat server:
- Copy the generated `.war` file to your Tomcat `webapps/` directory and rename it to `taskflow.war`.
- Restart Tomcat.

## 16. Application URLs
- **Base URL:** `http://localhost:8080/taskflow`
- **Login:** `http://localhost:8080/taskflow/login.jsp`
- **Admin Dashboard:** `http://localhost:8080/taskflow/admin/dashboard`
- **User Dashboard:** `http://localhost:8080/taskflow/user/dashboard`

## 17. Default/Demo Credentials
The database initialization script provides two seeded accounts:
- **Admin Account:** `admin@taskflow.local` / `password`
- **User Account:** `user@taskflow.local` / `password`

## 18. Feature Walkthrough
1. **Login:** Log in as the Admin user.
2. **Create Task:** Navigate to "Create Task", enter details, and assign it to the Demo User.
3. **Add Dependency:** View the newly created task and add another task as a dependency.
4. **User View:** Log out and log in as the Demo User. Navigate to "My Tasks".
5. **Task Lifecycle:** Attempt to start the task. It will be blocked if the dependency is incomplete. Complete the dependency first, then start the main task.
6. **Postponement:** If a task needs more time, submit a "Request Postponement".
7. **Admin Review:** Log back in as Admin, view "Postponement Requests", and Approve or Reject the request.
8. **History:** Open the task details to view the complete chronological audit trail of all actions performed.

## 19. Known Limitations
- Passwords are currently stored in plain text.
- HTML forms lack Anti-CSRF protection tokens.
- Task lists do not currently implement pagination, which may affect performance with large datasets.
- No automated unit/integration test coverage is provided.

## 20. Future Improvements
- Implement password hashing (e.g., BCrypt).
- Implement CSRF protection.
- Introduce email notifications alongside in-app alerts.
- Add pagination to all task lists and history tables.
- Add robust automated testing (JUnit/Mockito).
- Enable file attachments on tasks and comments.

---
*For detailed internal documentation, please refer to the `docs/` directory.*
