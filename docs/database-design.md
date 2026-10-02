# Database Design

The TASKFLOW database (`taskflow`) utilizes MySQL and consists of the following 7 interrelated tables:

## 1. `users`
- **Purpose:** Stores user credentials, roles, and account status.
- **Primary Key:** `id`
- **Important Fields:** `email` (UNIQUE), `password`, `role` (ENUM: ADMIN, USER).

## 2. `tasks`
- **Purpose:** The core entity representing a unit of work.
- **Primary Key:** `id`
- **Important Fields:** `title`, `deadline`, `priority` (ENUM), `status` (ENUM: ASSIGNED, IN_PROGRESS, COMPLETED, etc.).
- **Foreign Keys:** 
  - `assigned_to` references `users(id)` (ON DELETE SET NULL)
  - `created_by` references `users(id)` (ON DELETE SET NULL)

## 3. `task_dependencies`
- **Purpose:** Tracks prerequisite relationships between tasks to enforce workflow order.
- **Primary Key:** Composite key `(task_id, prerequisite_task_id)`
- **Foreign Keys:**
  - `task_id` references `tasks(id)` (ON DELETE CASCADE)
  - `prerequisite_task_id` references `tasks(id)` (ON DELETE CASCADE)

## 4. `postponement_requests`
- **Purpose:** Records user requests to extend task deadlines and admin responses.
- **Primary Key:** `id`
- **Important Fields:** `current_deadline`, `requested_deadline`, `reason`, `status` (ENUM: PENDING, APPROVED, REJECTED), `admin_response`.
- **Foreign Keys:**
  - `task_id` references `tasks(id)` (ON DELETE CASCADE)
  - `user_id` references `users(id)` (ON DELETE CASCADE)

## 5. `task_comments`
- **Purpose:** Stores user discussions and updates on tasks.
- **Primary Key:** `id`
- **Important Fields:** `message`, `created_at`.
- **Foreign Keys:**
  - `task_id` references `tasks(id)` (ON DELETE CASCADE)
  - `user_id` references `users(id)` (ON DELETE CASCADE)

## 6. `task_history`
- **Purpose:** Maintains an immutable audit log of all actions performed on a task.
- **Primary Key:** `id`
- **Important Fields:** `action` (VARCHAR description of the event).
- **Foreign Keys:**
  - `task_id` references `tasks(id)` (ON DELETE CASCADE)
  - `user_id` references `users(id)` (ON DELETE SET NULL)

## 7. `notifications`
- **Purpose:** Stores system-generated alerts for users.
- **Primary Key:** `id`
- **Important Fields:** `message`, `is_read`.
- **Foreign Keys:**
  - `user_id` references `users(id)` (ON DELETE CASCADE)

---

# Database Relationships

The database is heavily normalized to ensure referential integrity:

- **User → Tasks:** A One-to-Many relationship. A user can be assigned multiple tasks, but a task is assigned to only one user.
- **User → Comments:** A One-to-Many relationship. A user can author multiple comments.
- **User → Notifications:** A One-to-Many relationship. A user possesses an inbox of multiple notifications.
- **User → Task History:** A One-to-Many relationship. A user's actions generate multiple history records.
- **Task → Dependencies:** A Many-to-Many relationship mapped through `task_dependencies`. A task can have multiple prerequisites, and a task can serve as a prerequisite for multiple other tasks.
- **Task → Comments:** A One-to-Many relationship. A task can contain multiple comments.
- **Task → History:** A One-to-Many relationship. A single task accumulates a sequential trail of multiple history events over its lifecycle.
- **Task → Postponement Requests:** A One-to-Many relationship. A task can have multiple requests for deadline extensions over time.
