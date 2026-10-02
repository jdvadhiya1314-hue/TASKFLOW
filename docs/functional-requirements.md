# Functional Requirements

The functional requirements of TASKFLOW dictate the specific behaviors and capabilities of the system, categorized by role.

## ADMIN Requirements
- **Task CRUD:** The Admin must be able to Create, Read, Update, and Delete tasks.
- **Task Assignment:** The Admin must be able to assign tasks to specific users.
- **Dependency Management:** The Admin must be able to add and remove prerequisites for any task. The system must prevent self-dependencies, duplicate dependencies, and circular dependencies.
- **Postponement Review:** The Admin must be able to view all postponement requests submitted by users and choose to either Approve or Reject them. Rejections must include an admin response/reason.
- **Admin Dashboard:** The Admin must have access to a dashboard displaying total tasks, overdue tasks, pending requests, and a feed of recent system-wide activity.
- **Task Viewing & Searching:** The Admin must be able to view all tasks in the system, search by text, filter by status, priority, and assigned user, and sort the results dynamically.

## USER Requirements
- **Task Execution:** The User must be able to view tasks assigned to them and transition their status from `ASSIGNED` to `IN_PROGRESS`, and from `IN_PROGRESS` to `COMPLETED`.
- **Dependency Blocking:** The User must be prevented from starting a task if its prerequisite dependencies have not yet been marked as `COMPLETED`.
- **Task Comments:** The User must be able to add comments to tasks they are assigned to.
- **Postponement Requests:** The User must be able to submit a request to postpone a task's deadline, providing a requested date and a mandatory reason.
- **User Dashboard:** The User must have access to a dashboard displaying their personal task statistics, upcoming deadlines, overdue tasks, and a feed of recent activity on their tasks.
- **Notifications:** The User must receive and be able to read in-app notifications when assigned a new task, or when a postponement request is approved/rejected.
- **Task Searching:** The User must be able to view their assigned tasks, search by text, filter by status and priority, and sort the results dynamically.

## SYSTEM Requirements
- **Authentication:** The system must securely authenticate users via email and password before granting access.
- **Role Authorization:** The system must restrict access to Admin-specific routes and User-specific routes based on the authenticated user's assigned role.
- **Task History Auditing:** The system must automatically generate and store immutable audit log entries (Task History) whenever a task is created, edited, assigned, commented on, modified by dependencies, or undergoes a status change.
- **Automated Deadline Evaluation:** The system must dynamically evaluate task deadlines against the current time and flag incomplete tasks as `OVERDUE` across all relevant views.
