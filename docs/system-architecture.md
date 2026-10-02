# System Architecture

TASKFLOW is built on a classic Model-View-Controller (MVC) architectural pattern, completely independent of external frameworks like Spring or Hibernate. The request lifecycle follows a strict sequence:

## Execution Flow

**Browser → JSP (View) → Servlet (Controller) → DAO (Model) → JDBC → MySQL**

1. **Browser (Client):** 
   The user interacts with the application via standard web browsers. HTML forms and URL parameters encapsulate the user's intent.

2. **JSP (View Layer):** 
   JavaServer Pages (JSP) are responsible strictly for presentation. They utilize JavaServer Pages Standard Tag Library (JSTL) and expression languages to dynamically render HTML based on data objects passed from the Servlets. JSPs do not contain business logic or direct database queries.

3. **Servlet (Controller Layer):** 
   Jakarta Servlets handle incoming HTTP requests (`GET` and `POST`). They are responsible for:
   - Validating incoming user input.
   - Enforcing business logic and workflow rules.
   - Interacting with Data Access Objects (DAOs) to fetch or modify data.
   - Forwarding the processed data to the appropriate JSP via `request.setAttribute()`, or redirecting the user to a different route.

4. **DAO (Model Layer):** 
   Data Access Objects abstract all database interactions. Each core entity (Task, User, Notification) has a dedicated DAO that encapsulates the SQL necessary to perform CRUD operations. 

5. **JDBC (Java Database Connectivity):** 
   The DAOs utilize the JDBC API to securely communicate with the database. The system uses a centralized `DBConnection` utility to generate database connections and manage resources.

6. **MySQL (Database Layer):** 
   The persistent storage layer where all application state, relations, and historical data are durably stored.
