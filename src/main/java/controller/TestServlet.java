package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.DBConnection;

import java.io.IOException;
import java.sql.Connection;

@WebServlet("/test")
public class TestServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String dbStatus = "Not Connected";
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null && !conn.isClosed()) {
                dbStatus = "Connected successfully to MySQL!";
            }
        } catch (Exception e) {
            dbStatus = "Connection failed: " + e.getMessage();
            getServletContext().log("Error", e);
        }
        
        request.setAttribute("dbStatus", dbStatus);
        request.getRequestDispatcher("/test.jsp").forward(request, response);
    }
}
