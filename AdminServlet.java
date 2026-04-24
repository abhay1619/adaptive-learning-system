package com.adaptive.servlet;

import com.adaptive.db.DBConnection;
import com.adaptive.model.User;
import com.adaptive.model.Question;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.html");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getRole())) {
            response.sendRedirect("dashboard");
            return;
        }
        
        try (Connection conn = DBConnection.getNewConnection()) {
            // Get all users
            List<User> users = new ArrayList<>();
            String usersSql = "SELECT * FROM users WHERE role = 'student' ORDER BY total_score DESC";
            PreparedStatement usersStmt = conn.prepareStatement(usersSql);
            ResultSet usersRs = usersStmt.executeQuery();
            
            while (usersRs.next()) {
                User u = new User();
                u.setUserId(usersRs.getInt("user_id"));
                u.setUsername(usersRs.getString("username"));
                u.setFullName(usersRs.getString("full_name"));
                u.setEmail(usersRs.getString("email"));
                u.setCurrentDifficulty(usersRs.getInt("current_difficulty"));
                u.setTotalScore(usersRs.getInt("total_score"));
                u.setStreakDays(usersRs.getInt("streak_days"));
                u.setCreatedAt(usersRs.getTimestamp("created_at"));
                users.add(u);
            }
            request.setAttribute("users", users);
            
            // Get all questions
            List<Question> questions = new ArrayList<>();
            String questionsSql = "SELECT * FROM questions ORDER BY subject, difficulty_level";
            PreparedStatement questionsStmt = conn.prepareStatement(questionsSql);
            ResultSet questionsRs = questionsStmt.executeQuery();
            
            while (questionsRs.next()) {
                Question q = new Question();
                q.setQuestionId(questionsRs.getInt("question_id"));
                q.setSubject(questionsRs.getString("subject"));
                q.setTopic(questionsRs.getString("topic"));
                q.setQuestionText(questionsRs.getString("question_text"));
                q.setDifficultyLevel(questionsRs.getInt("difficulty_level"));
                q.setCorrectOption(questionsRs.getString("correct_option").charAt(0));
                questions.add(q);
            }
            request.setAttribute("questions", questions);
            
            // Get stats
            String statsSql = "SELECT " +
                             "(SELECT COUNT(*) FROM users WHERE role = 'student') as total_students, " +
                             "(SELECT COUNT(*) FROM questions) as total_questions, " +
                             "(SELECT COUNT(*) FROM quiz_attempts) as total_attempts, " +
                             "(SELECT COUNT(DISTINCT subject) FROM questions) as total_subjects";
            PreparedStatement statsStmt = conn.prepareStatement(statsSql);
            ResultSet statsRs = statsStmt.executeQuery();
            
            if (statsRs.next()) {
                request.setAttribute("totalStudents", statsRs.getInt("total_students"));
                request.setAttribute("totalQuestions", statsRs.getInt("total_questions"));
                request.setAttribute("totalAttempts", statsRs.getInt("total_attempts"));
                request.setAttribute("totalSubjects", statsRs.getInt("total_subjects"));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
        }
        
        request.getRequestDispatcher("/WEB-INF/jsp/admin.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\": false, \"message\": \"Unauthorized\"}");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        if (!"admin".equals(user.getRole())) {
            out.print("{\"success\": false, \"message\": \"Unauthorized\"}");
            return;
        }
        
        String action = request.getParameter("action");
        
        try (Connection conn = DBConnection.getNewConnection()) {
            if ("addQuestion".equals(action)) {
                String subject = request.getParameter("subject");
                String topic = request.getParameter("topic");
                String questionText = request.getParameter("questionText");
                String optionA = request.getParameter("optionA");
                String optionB = request.getParameter("optionB");
                String optionC = request.getParameter("optionC");
                String optionD = request.getParameter("optionD");
                String correctOption = request.getParameter("correctOption");
                int difficulty = Integer.parseInt(request.getParameter("difficulty"));
                String explanation = request.getParameter("explanation");
                
                String sql = "INSERT INTO questions (subject, topic, question_text, option_a, option_b, option_c, option_d, correct_option, difficulty_level, explanation) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, subject);
                stmt.setString(2, topic);
                stmt.setString(3, questionText);
                stmt.setString(4, optionA);
                stmt.setString(5, optionB);
                stmt.setString(6, optionC);
                stmt.setString(7, optionD);
                stmt.setString(8, correctOption);
                stmt.setInt(9, difficulty);
                stmt.setString(10, explanation);
                
                int result = stmt.executeUpdate();
                if (result > 0) {
                    out.print("{\"success\": true, \"message\": \"Question added successfully!\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to add question\"}");
                }
                
            } else if ("deleteQuestion".equals(action)) {
                int questionId = Integer.parseInt(request.getParameter("questionId"));
                
                String sql = "DELETE FROM questions WHERE question_id = ?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setInt(1, questionId);
                
                int result = stmt.executeUpdate();
                if (result > 0) {
                    out.print("{\"success\": true, \"message\": \"Question deleted successfully!\"}");
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to delete question\"}");
                }
                
            } else {
                out.print("{\"success\": false, \"message\": \"Invalid action\"}");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Server error: " + e.getMessage() + "\"}");
        }
    }
}
