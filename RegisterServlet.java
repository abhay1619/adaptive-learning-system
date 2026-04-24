package com.adaptive.servlet;

import com.adaptive.db.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        String fullName = request.getParameter("fullName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        
        // Validation
        if (fullName == null || username == null || email == null || password == null ||
            fullName.trim().isEmpty() || username.trim().isEmpty() || 
            email.trim().isEmpty() || password.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"All fields are required\"}");
            return;
        }
        
        if (password.length() < 6) {
            out.print("{\"success\": false, \"message\": \"Password must be at least 6 characters\"}");
            return;
        }
        
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            out.print("{\"success\": false, \"message\": \"Invalid email format\"}");
            return;
        }
        
        try (Connection conn = DBConnection.getNewConnection()) {
            // Check if username or email exists
            String checkSql = "SELECT user_id FROM users WHERE username = ? OR email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, username);
            checkStmt.setString(2, email);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                out.print("{\"success\": false, \"message\": \"Username or email already exists\"}");
                return;
            }
            
            // Insert new user
            String insertSql = "INSERT INTO users (username, email, password, full_name, role, current_difficulty, total_score) VALUES (?, ?, ?, ?, 'student', 1, 0)";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, username.trim());
            insertStmt.setString(2, email.trim());
            insertStmt.setString(3, password); // In production, hash this!
            insertStmt.setString(4, fullName.trim());
            
            int result = insertStmt.executeUpdate();
            
            if (result > 0) {
                out.print("{\"success\": true, \"message\": \"Registration successful! Please login.\"}");
            } else {
                out.print("{\"success\": false, \"message\": \"Registration failed. Please try again.\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Server error: " + e.getMessage() + "\"}");
        }
    }
}
