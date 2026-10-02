# Testing Documentation

Testing for the TASKFLOW project was conducted manually to verify the correct execution of all functional requirements and business logic workflows. No automated unit or integration test suites were utilized.

## Manual Test Scenarios Performed

### 1. Authentication
- **Admin Login:** Verified that logging in with Admin credentials successfully redirects to `/admin/dashboard` and grants access to all `/admin/` routes.
- **User Login:** Verified that logging in with User credentials redirects to `/user/dashboard`. Verified that attempting to access `/admin/tasks` as a User results in an authorization error.
- **Logout:** Verified that the logout action correctly invalidates the session and redirects to the login screen, effectively preventing back-button access to protected pages.

### 2. Task Management (CRUD)
- **Create:** Verified that Admins can create tasks, that required fields are validated, and that tasks correctly appear in the system.
- **Assign:** Verified that tasks can be assigned to active users and immediately populate on that user's specific dashboard.
- **Edit/Delete:** Verified Admins can modify existing details and delete tasks (confirming cascading deletes on related comments and history).

### 3. Task Lifecycle
- **Start:** Verified Users can click "Start Task" to transition the status from `ASSIGNED` to `IN_PROGRESS`.
- **Complete:** Verified Users can click "Complete Task" to transition the status to `COMPLETED`. Verified completed tasks do not display as overdue.

### 4. Postponement Workflow
- **Request:** Verified Users can submit postponement requests with a valid future date and reason. Verified the request appears in the Admin's queue.
- **Approve:** Verified Admin approval updates the task's deadline and generates a notification for the user.
- **Reject:** Verified Admin rejection requires a reason, leaves the deadline unchanged, and alerts the user.

### 5. Notifications
- **Trigger Events:** Verified notifications are successfully generated upon Task Assignment, Postponement Approval, and Postponement Rejection.
- **Badge Indicators:** Verified the unread notification count accurately reflects the database state.
- **Mark as Read:** Verified users can mark individual alerts or all alerts as read, clearing the indicators.

### 6. Dependency Management
- **Add/Remove:** Verified Admins can successfully link and unlink prerequisite tasks.
- **Validation:** Verified the system rejects attempts to link a task to itself (Self-dependency), link the same task twice (Duplicate), or create an endless loop (Circular dependency).
- **Blocking Logic:** Verified Users receive a specific error ("Blocked by: <Task Title> - <Status>") when attempting to start a task with incomplete prerequisites.
- **Unblocking:** Verified that once the prerequisite task is marked `COMPLETED`, the blocked task becomes startable.

### 7. Task History
- **Event Logging:** Verified that creations, edits, assignments, comments, and status changes all automatically generate timestamped history entries.
- **Display:** Verified the history trail displays chronologically on the task view page.

### 8. Search, Filter, and Sort
- **Filtering:** Verified that filtering by "Status", "Priority", and "Assigned User" successfully restricts the visible list.
- **Search:** Verified keyword searches correctly match against task titles and descriptions.
- **Sorting:** Verified sorting by Deadline (Asc/Desc) and Priority correctly orders the resulting table.
- **Overdue Toggle:** Verified the "Show Overdue Only" toggle accurately isolates tasks where the deadline is past the current time and status is not completed.

### 9. Dashboards
- **Statistics:** Verified aggregate counts (Total, Overdue, Pending Requests) calculate accurately based on live database data.
- **Recent Activity:** Verified the recent activity feeds fetch and display the most recent task history events.
