# Module Description

The TASKFLOW application is divided into several interconnected modules:

## 1. Authentication Module
Handles user identity verification and session generation. Utilizes the `AuthenticationFilter` to guard routes based on the authenticated user's role (ADMIN vs. USER).

## 2. Admin Dashboard Module
Provides administrators with an aggregated view of the system. Displays total task counts, overdue metrics, pending postponement requests, and a feed of recent system-wide activity.

## 3. User Dashboard Module
Provides users with a personalized overview. Highlights tasks specifically assigned to them, segregating them into upcoming and overdue, while displaying a personal recent activity feed.

## 4. Task Management Module (CRUD)
The core administrative module. Enables Admins to create new tasks, update titles and descriptions, change priorities, modify deadlines, assign tasks to specific users, and delete tasks.

## 5. Task Lifecycle Module
The core user workflow. Enables Users to progress a task's status from `ASSIGNED` to `IN_PROGRESS` (Start Task) and finally to `COMPLETED` (Complete Task).

## 6. Comments Module
Allows Users to append messages to their assigned tasks, facilitating communication and providing updates on task execution.

## 7. Postponement Management Module
Handles the workflow for deadline extensions. Users can submit structured requests (with reasons) for tasks they own. Admins review these requests in a dedicated interface and can Approve (automatically updating the task deadline) or Reject (supplying a required explanation).

## 8. Notifications Module
Generates and delivers in-app alerts to users. Notifications are automatically triggered when a user is assigned a new task, or when their postponement request is approved or rejected. Includes global unread counters and "Mark as Read" functionality.

## 9. Task Dependencies Module
Ensures tasks are executed in the correct operational sequence. Admins define prerequisite links between tasks. The module prevents illogical setups (circular references, self-dependencies). Users are strictly blocked from starting a task until the module confirms all prerequisites are `COMPLETED`.

## 10. Task History Module
An automated background module that listens for significant events across other modules (creation, edits, assignments, comments, status changes) and logs them immutably. Used to generate audit trails visible on task detail pages.

## 11. Search/Filtering/Sorting Module
A dynamic query builder within the `TaskDAO` that allows users and admins to search tasks by text, filter by status, priority, and assigned user, and sort by dates or priorities, all without refreshing the page structure.

## 12. Error Handling Module
Provides graceful degradation when exceptions occur. Catches server errors or missing pages and routes users to custom `404.jsp` and `500.jsp` pages, while securely logging stack traces to the server context rather than exposing them to the client.
