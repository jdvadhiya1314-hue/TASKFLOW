# TASKFLOW — Final Presentation Outline

## SLIDE 1 — TITLE
**TASKFLOW**
**Task Management and Workflow System**

**Submitted By:** [Student Name]  
**Enrollment/Roll Number:** [Roll Number]  
**Program:** Master of Computer Applications (MCA)  
**University:** [University Name]  
**Under the Guidance of:** [Professor/Guide Name]  
**Academic Year:** [202X-202X]  

---

## SLIDE 2 — INTRODUCTION
**What is TASKFLOW?**
- A centralized web application for managing tasks and team workflows.
- Designed to replace disjointed communication methods like email and spreadsheets.
- Empowers administrators to assign tasks, set deadlines, and enforce execution sequences.
- Enables users to track their workload, report progress, and formally request deadline extensions.
- Provides complete transparency through automated history auditing and real-time notifications.

---

## SLIDE 3 — PROBLEM STATEMENT
**Challenges with Manual Task Management:**
- **Task Assignment:** Assignments get lost in emails or chats, leading to dropped responsibilities.
- **Deadline Tracking:** Difficult to track impending deadlines; overdue tasks often go unnoticed.
- **Status Tracking:** No single source of truth for current progress (Not Started, In Progress, Done).
- **Postponement Communication:** Informal extension requests lack formal approval processes and documentation.
- **Dependencies:** Unable to strictly enforce the required order of operations.
- **Lack of History:** No audit trail to see who changed a task or when it was updated.

---

## SLIDE 4 — OBJECTIVES
**Project Objectives:**
1. **Centralize Task Management:** Provide a unified platform for tracking all operational tasks.
2. **Assign Tasks & Track Status:** Implement a strict, observable lifecycle (Assigned → In Progress → Completed).
3. **Manage Deadlines:** Highlight overdue tasks automatically across all dashboards.
4. **Handle Postponements:** Establish a formal workflow for users to request extensions and admins to review them.
5. **Manage Task Dependencies:** Ensure workflows execute in order by enforcing prerequisite completion.
6. **Provide Notifications:** Deliver real-time, in-app alerts for critical workflow events.
7. **Maintain Task History:** Automatically log an immutable audit trail of all actions.

---

## SLIDE 5 — EXISTING SYSTEM
**Limitations of Basic/Manual Systems:**
- High reliance on human memory and manual follow-ups.
- No automated way to prevent tasks from being started out of order.
- Difficult to generate a quick overview of team productivity or delayed assignments.
- Re-assigning a task or changing a deadline requires manually notifying all stakeholders.
- High risk of miscommunication regarding task requirements or shifting deadlines.

---

## SLIDE 6 — PROPOSED SYSTEM
**How TASKFLOW Addresses These Problems:**
- **Structured Lifecycles:** Enforces clear task states so progress is immediately visible.
- **Automated Protections:** The system strictly prevents starting a task if prerequisites are pending.
- **Formalized Workflows:** Postponement requests are submitted formally, reviewed by Admins, and logged historically.
- **Automated Communication:** In-app notifications ensure users are immediately aware of new assignments or rejected extensions.
- **Transparent Accountability:** Every status change, assignment, and comment is permanently recorded in the task's history.

---

## SLIDE 7 — TECHNOLOGY STACK
**Backend:**
- **Language:** Java 21
- **Architecture:** Jakarta Servlet, Jakarta JSP, JSTL
- **Build Tool:** Apache Maven

**Database & Server:**
- **Database:** MySQL 8.4
- **Connectivity:** JDBC
- **Web Server:** Apache Tomcat 10.1

**Frontend:**
- **Structure & Style:** HTML5, Vanilla CSS
- **Interactivity:** JavaScript

---

## SLIDE 8 — SYSTEM ARCHITECTURE
**MVC Architecture Flow:**

`Browser` 
   ↓
`JSP (View)` 
   ↓
`Servlet (Controller)` 
   ↓
`DAO (Model Data Access)` 
   ↓
`DBConnection` 
   ↓
`MySQL (Database)`

- **JSP:** Handles the dynamic rendering of the user interface using JSTL. No business logic resides here.
- **Servlet:** Intercepts requests, validates input, applies business rules, and routes data.
- **DAO:** Encapsulates all SQL queries using PreparedStatements for secure database access via DBConnection.

---

## SLIDE 9 — MAIN MODULES
**Admin Modules:**
- **Dashboard:** High-level metrics and recent activity feeds.
- **Task Management:** Full CRUD operations and assignment control.
- **Dependencies:** Add/remove prerequisites with circular-dependency protection.
- **Postponement Management:** Approve/Reject queue for deadline extensions.

**User Modules:**
- **Dashboard & My Tasks:** Filtered views of assigned pending, in-progress, and completed work.
- **Task Lifecycle:** Controls to Start and Complete tasks.
- **Comments:** Discussion thread for task updates.

**System Modules:**
- **Notifications:** In-app alerts with unread badge indicators.
- **History:** Automated audit trail generator.
- **Search/Filter:** Dynamic querying engine for task discovery.

---

## SLIDE 10 — TASK WORKFLOW
**The Core Lifecycle:**

`Admin Creates Task`
   ↓
`Assigns User`
   ↓
`[ ASSIGNED ]`
   ↓ *(User clicks Start Task)*
`[ IN_PROGRESS ]`
   ↓ *(User clicks Complete Task)*
`[ COMPLETED ]`

**Dependency Blocking:**
If a prerequisite task is NOT completed, the "Start Task" button is blocked and safely informs the user: *"Blocked by: [Task Title] - [Status]"*.

---

## SLIDE 11 — POSTPONEMENT + NOTIFICATION WORKFLOW
**Extension Request Process:**

`User Requests Postponement` (Requires valid date & reason)
   ↓
`Admin Reviews Request`
   ↙         ↘
`Approve`      `Reject` (Requires admin reason)
   ↓             ↓
`Deadline`     `Deadline remains unchanged`
`Updated`
   ↘         ↙
`User Receives In-App Notification`

---

## SLIDE 12 — TASK DEPENDENCIES
**Dependency Management Features:**
- **Add/Remove:** Admins establish prerequisite links between tasks.
- **Self-Dependency Protection:** A task cannot depend on itself.
- **Duplicate Protection:** Prevents adding the exact same dependency twice.
- **Circular Dependency Protection:** Prevents endless loops (e.g., Task A depends on Task B, Task B depends on Task A).
- **Execution Blocking:** Users absolutely cannot transition a task to `IN_PROGRESS` until the module confirms all prerequisites are `COMPLETED`.

---

## SLIDE 13 — DASHBOARD + SEARCH
**Dashboard Capabilities:**
- **Statistics:** Real-time calculation of total and overdue tasks.
- **Overdue Detection:** Visual red badges automatically flag tasks where `deadline < NOW()` (excluding completed tasks).
- **Recent Activity:** Feed of the latest system interactions.

**Search & Filtering:**
- **Search:** Keyword matching against title and description.
- **Filters:** Isolate by Status (e.g., Pending), Priority (e.g., Urgent), or Assigned User.
- **Sorting:** Dynamically order by Deadline (Asc/Desc), Priority, or Creation Date.

---

## SLIDE 14 — SECURITY + TESTING
**Implemented Security Mechanisms:**
- **Session Authentication:** Handled centrally by `AuthenticationFilter`.
- **Role Authorization:** Strict separation of `/admin/` and `/user/` routes.
- **Ownership Validation:** Backend verifies user identity before allowing task modifications or comments.
- **PreparedStatements:** Used exclusively across all DAOs to prevent SQL Injection.
- **Sort Whitelisting:** Dynamic sorting safely uses hardcoded `switch` cases instead of raw SQL concatenation.

**Manual Testing Performed:**
- Verified Authentication, CRUD operations, Task Lifecycle, Dependency blocking, Postponement workflows, Notifications, and Search filtering.
- *Note: Testing was conducted manually; automated unit/integration tests were not utilized.*

---

## SLIDE 15 — CONCLUSION & FUTURE SCOPE
**Conclusion:**
TASKFLOW successfully centralizes task management, enforces strict operational lifecycles, and maintains robust accountability through automated history and dependency tracking. It provides a clean, responsive, and framework-independent MVC solution.

**Future Scope:**
- **Security:** Implement BCrypt password hashing and CSRF protection tokens.
- **Performance:** Add database pagination for massive task lists.
- **Testing:** Integrate JUnit and Mockito for automated testing.
- **Features:** Introduce email notifications and file attachments.
- **Architecture:** Transition to a REST API for future Mobile Application integration or Cloud Deployment.

---
---

# Speaker Notes

**Slide 1:** Welcome the examiners. Introduce yourself, your project title, and acknowledge your guide.

**Slide 2:** Keep it brief. Emphasize that TASKFLOW moves teams away from messy email threads into a centralized, transparent platform where everyone knows exactly what they need to do and when.

**Slide 3:** Focus on the pain points. When managers use spreadsheets, it's hard to track what's overdue, it's hard to enforce the order of operations (dependencies), and there's no history to see who changed what.

**Slide 4:** These are our goals. We wanted a system that doesn't just list tasks, but actively manages them through a lifecycle, handles extensions formally, and blocks users from doing things out of order.

**Slide 5:** Reiterate that manual systems rely entirely on human memory. If a deadline shifts, someone has to manually email five different people. TASKFLOW automates this.

**Slide 6:** Explain how TASKFLOW solves the problems. Mention the strict states (Assigned, In Progress, Completed), the formal postponement queue for admins, and the automated audit trail.

**Slide 7:** We built this using core Java technologies. Emphasize that we used standard Jakarta Servlets and JSPs rather than relying on heavy frameworks like Spring, demonstrating a deep understanding of core web architecture.

**Slide 8:** Walk through the MVC flow. The user clicks a button (Browser), the Servlet intercepts it, validates the input, talks to the DAO which securely queries MySQL via DBConnection, and finally the Servlet forwards the data to the JSP to render the HTML.

**Slide 9:** Briefly list the modules. Note the clear separation between what an Admin can do (manage dependencies, approve postponements) and what a User can do (execute tasks, request postponements).

**Slide 10:** Walk through the lifecycle. Crucially, mention that if Task B depends on Task A, the User cannot click "Start Task" on Task B. The button will literally tell them they are blocked until Task A is completed.

**Slide 11:** Explain the extension process. A user can't just change a deadline. They submit a formal request. The Admin reviews it. Whatever the Admin decides, the User gets an instant in-app notification.

**Slide 12:** Highlight the logic behind dependencies. We didn't just add a table; we wrote algorithms to prevent infinite loops (circular dependencies) and self-dependencies to ensure the workflow logic remains sound.

**Slide 13:** The dashboard isn't static. It calculates overdue tasks dynamically based on the server clock. The search module uses a dynamic query builder in the DAO to combine text searches with multiple dropdown filters simultaneously.

**Slide 14:** Be honest about security. We implemented strong baseline security (PreparedStatements to stop SQL injection, Role checks, Ownership checks to stop users editing other people's tasks). Be transparent that testing was manual to verify business logic.

**Slide 15:** Conclude confidently. The system works and meets all objectives. Then, discuss future scope. Acknowledge that for a real enterprise release, we would add password hashing, email alerts, and pagination.

---
---

# 5-Minute Demo Sequence

1. **Login & Admin Dashboard (1 min):**
   - Log in as the Admin. 
   - Show the dashboard highlighting total tasks, overdue tasks, and recent activity.
2. **Task Creation & Dependency (1.5 min):**
   - Navigate to "Create Task". Create Task A and assign it to the Demo User.
   - Create Task B and assign it to the Demo User.
   - Open Task B, scroll to Dependencies, and add Task A as a prerequisite. 
   - Demonstrate the protection by trying to add Task B as a dependency to Task B (Self-dependency error).
3. **User Execution & Blocking (1.5 min):**
   - Log out. Log in as the Demo User.
   - Go to "My Tasks". Open Task B. 
   - Attempt to start Task B. Show the error: "Blocked by: Task A - ASSIGNED".
   - Open Task A. Click "Start Task" then "Complete Task".
   - Return to Task B. Show that it is now unblocked and can be started.
4. **Postponement & Notifications (1 min):**
   - While still on Task B, click "Request Postponement". Enter a new date and a reason.
   - Log out. Log in as Admin. 
   - Open "Postponement Requests". Approve the request.
   - Log out. Log back in as the Demo User. 
   - Click the Notifications bell. Show the unread notification stating the postponement was approved. 
   - Open the task and show the updated deadline and the complete chronological Task History at the bottom of the page.

---
---

# 10 Likely Viva Questions & Answers

**Q1: Why didn't you use Spring Boot or Hibernate?**
*A1:* The objective was to build a strong foundational understanding of MVC architecture, HTTP request lifecycles, and raw SQL management. Using raw Jakarta Servlets and JDBC DAOs demonstrates a deep understanding of core Java web technologies without the "magic" of heavy frameworks.

**Q2: How do you prevent SQL Injection in your application?**
*A2:* All database queries in the DAO layer use JDBC `PreparedStatement` objects. This ensures that user inputs are treated strictly as data parameters and are safely escaped by the database driver, completely preventing SQL injection.

**Q3: Explain how the circular dependency protection works.**
*A3:* When an Admin tries to add a dependency, the system checks if the relationship already exists in reverse. It recursively checks the prerequisite chain to ensure the new dependency doesn't create an infinite loop that would permanently block task execution.

**Q4: How do you differentiate between an Admin and a User?**
*A4:* During login, the user's role is fetched from the database and stored in the `HttpSession`. A global `AuthenticationFilter` intercepts every request. If a user tries to access an `/admin/` URL, the filter checks the session role and blocks them with a 403 Forbidden error if they aren't an Admin.

**Q5: What happens if a User tries to edit another user's task by changing the ID in the URL?**
*A5:* The application performs Ownership Validation. When a user attempts an action (like commenting or starting a task), the Servlet fetches the task from the database and verifies that `task.getAssignedTo()` matches the `loggedInUser.getId()` in the session. If they don't match, access is denied.

**Q6: How does the system know a task is overdue?**
*A6:* Overdue status is calculated dynamically. The application compares the task's `deadline` timestamp against the server's current time (`new java.util.Date()`). If the deadline has passed and the status is not `COMPLETED`, the UI dynamically renders the red OVERDUE badge.

**Q7: How is the Task History generated?**
*A7:* We implemented a `TaskHistoryDAO`. Whenever a significant action occurs in a Servlet (e.g., creating a task, adding a comment, approving a postponement), the Servlet creates a `TaskHistory` object and saves it to the database immediately after the main action succeeds, ensuring a permanent audit trail.

**Q8: Why is password hashing listed in Future Scope instead of being implemented now?**
*A8:* For the scope of this college project, we prioritized complex business logic like dependency blocking, postponement workflows, and MVC structure. Plain-text passwords were used to simplify database seeding and manual testing. In a real-world deployment, implementing BCrypt hashing would be the immediate first step.

**Q9: How do you handle dynamic searching and sorting in SQL without risking SQL injection?**
*A9:* We use a dynamic `StringBuilder` for the SQL query, adding `?` placeholders for text searches and filters, which are then filled via `PreparedStatement`. For sorting (`ORDER BY`), we use a strict Java `switch` statement containing hardcoded safe SQL strings (whitelist approach) rather than concatenating user input directly into the query.

**Q10: What is the purpose of the `DBConnection` utility class?**
*A10:* It centralizes database connectivity. Instead of writing connection strings in every DAO, all DAOs call `DBConnection.getConnection()`. This encapsulates the JDBC driver loading and credentials in one place, making the code cleaner and easier to maintain.
