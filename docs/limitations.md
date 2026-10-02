# System Limitations

While TASKFLOW is fully functional and successfully meets all stated college-project requirements, its current architecture contains specific limitations that should be noted before considering public or commercial deployment.

## 1. Plain-Text Passwords
User passwords are currently stored in plain text within the MySQL database. There is no implementation of cryptographic hashing algorithms (like BCrypt or Argon2). In a production environment, this is a critical vulnerability.

## 2. No CSRF Protection
The HTML forms utilized for data submission (task creation, postponement requests, etc.) do not include Anti-Cross Site Request Forgery (CSRF) tokens. This leaves active, authenticated sessions theoretically vulnerable to forged requests from malicious external websites.

## 3. Lack of Pagination
The task viewing interfaces (`/admin/tasks` and `/user/tasks`) retrieve and render all matching tasks at once. While performant for smaller datasets, this approach will cause significant memory overhead and slow page loads if the system scales to thousands of concurrent tasks.

## 4. No Automated Testing
The application's reliability is currently verified solely through manual smoke testing. It lacks a suite of automated Unit or Integration tests (e.g., JUnit, Mockito), which makes future refactoring riskier.

## 5. String-Based Status/Priority Values
Throughout the Java codebase, core enumerations like task statuses (e.g., `"COMPLETED"`, `"IN_PROGRESS"`) and priorities (e.g., `"HIGH"`) are handled as raw string literals. This lacks the type safety that strongly-typed Java `Enum` classes provide, increasing the risk of typographical errors in the business logic.

## 6. College-Project Scope
The application is scoped strictly as an academic/demonstration project. It lacks standard enterprise features like password recovery/reset workflows, email integration, file attachment capabilities, and a robust user registration workflow (users must be manually seeded in the database).
