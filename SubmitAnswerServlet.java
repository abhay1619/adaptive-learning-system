package com.adaptive.servlet;

import com.adaptive.db.DBConnection;
import com.adaptive.model.User;
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

@WebServlet("/submitAnswer")
public class SubmitAnswerServlet extends HttpServlet {
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            out.print("{\"success\": false, \"message\": \"Session expired. Please login again.\"}");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();
        
        String questionIdStr = request.getParameter("questionId");
        String selectedOption = request.getParameter("selectedOption");
        String responseTimeStr = request.getParameter("responseTime");
        
        if (questionIdStr == null || selectedOption == null) {
            out.print("{\"success\": false, \"message\": \"Invalid submission\"}");
            return;
        }
        
        int questionId = Integer.parseInt(questionIdStr);
        int responseTime = responseTimeStr != null ? Integer.parseInt(responseTimeStr) : 30;
        
        try (Connection conn = DBConnection.getNewConnection()) {
            // Get question details
            String questionSql = "SELECT * FROM questions WHERE question_id = ?";
            PreparedStatement questionStmt = conn.prepareStatement(questionSql);
            questionStmt.setInt(1, questionId);
            ResultSet questionRs = questionStmt.executeQuery();
            
            if (!questionRs.next()) {
                out.print("{\"success\": false, \"message\": \"Question not found\"}");
                return;
            }
            
            char correctOption = questionRs.getString("correct_option").charAt(0);
            String subject = questionRs.getString("subject");
            int difficulty = questionRs.getInt("difficulty_level");
            int points = questionRs.getInt("points");
            String explanation = questionRs.getString("explanation");
            
            boolean isCorrect = selectedOption.charAt(0) == correctOption;
            int pointsEarned = isCorrect ? points : 0;
            
            // Bonus points for fast correct answers
            if (isCorrect && responseTime < 10) {
                pointsEarned += 5; // Speed bonus
            }
            
            // Record the attempt
            String attemptSql = "INSERT INTO quiz_attempts (user_id, question_id, selected_option, is_correct, response_time_seconds, difficulty_at_attempt, points_earned) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement attemptStmt = conn.prepareStatement(attemptSql);
            attemptStmt.setInt(1, userId);
            attemptStmt.setInt(2, questionId);
            attemptStmt.setString(3, selectedOption);
            attemptStmt.setBoolean(4, isCorrect);
            attemptStmt.setInt(5, responseTime);
            attemptStmt.setInt(6, difficulty);
            attemptStmt.setInt(7, pointsEarned);
            attemptStmt.executeUpdate();
            
            // Update user's total score
            String updateScoreSql = "UPDATE users SET total_score = total_score + ? WHERE user_id = ?";
            PreparedStatement updateScoreStmt = conn.prepareStatement(updateScoreSql);
            updateScoreStmt.setInt(1, pointsEarned);
            updateScoreStmt.setInt(2, userId);
            updateScoreStmt.executeUpdate();
            
            // ADAPTIVE DIFFICULTY ALGORITHM
            // Get recent performance (last 5 questions in this subject)
            String recentSql = "SELECT COUNT(*) as total, SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct " +
                              "FROM quiz_attempts qa JOIN questions q ON qa.question_id = q.question_id " +
                              "WHERE qa.user_id = ? AND q.subject = ? ORDER BY qa.attempted_at DESC LIMIT 5";
            PreparedStatement recentStmt = conn.prepareStatement(recentSql);
            recentStmt.setInt(1, userId);
            recentStmt.setString(2, subject);
            ResultSet recentRs = recentStmt.executeQuery();
            
            int newLevel = difficulty;
            String adaptiveMessage = "";
            
            if (recentRs.next()) {
                int recentTotal = recentRs.getInt("total");
                int recentCorrect = recentRs.getInt("correct");
                double recentAccuracy = recentTotal > 0 ? (double) recentCorrect / recentTotal * 100 : 0;
                
                // Adaptive logic:
                // If accuracy > 80% for 3+ questions, increase difficulty
                // If accuracy < 40% for 3+ questions, decrease difficulty
                if (recentTotal >= 3) {
                    if (recentAccuracy >= 80 && difficulty < 5) {
                        newLevel = Math.min(5, difficulty + 1);
                        adaptiveMessage = "Great job! Difficulty increased to Level " + newLevel;
                    } else if (recentAccuracy <= 40 && difficulty > 1) {
                        newLevel = Math.max(1, difficulty - 1);
                        adaptiveMessage = "Let's practice more. Difficulty adjusted to Level " + newLevel;
                    }
                }
            }
            
            // Update user progress for this subject
            String updateProgressSql = "INSERT INTO user_progress (user_id, subject, current_level, questions_attempted, correct_answers, accuracy_rate) " +
                                       "VALUES (?, ?, ?, 1, ?, ?) " +
                                       "ON DUPLICATE KEY UPDATE " +
                                       "current_level = ?, " +
                                       "questions_attempted = questions_attempted + 1, " +
                                       "correct_answers = correct_answers + ?, " +
                                       "accuracy_rate = (correct_answers + ?) * 100.0 / (questions_attempted + 1)";
            
            PreparedStatement updateProgressStmt = conn.prepareStatement(updateProgressSql);
            updateProgressStmt.setInt(1, userId);
            updateProgressStmt.setString(2, subject);
            updateProgressStmt.setInt(3, newLevel);
            updateProgressStmt.setInt(4, isCorrect ? 1 : 0);
            updateProgressStmt.setDouble(5, isCorrect ? 100.0 : 0.0);
            updateProgressStmt.setInt(6, newLevel);
            updateProgressStmt.setInt(7, isCorrect ? 1 : 0);
            updateProgressStmt.setInt(8, isCorrect ? 1 : 0);
            updateProgressStmt.executeUpdate();
            
            // Update user's current difficulty
            String updateDiffSql = "UPDATE users SET current_difficulty = ? WHERE user_id = ?";
            PreparedStatement updateDiffStmt = conn.prepareStatement(updateDiffSql);
            updateDiffStmt.setInt(1, newLevel);
            updateDiffStmt.setInt(2, userId);
            updateDiffStmt.executeUpdate();
            
            // Build response
            StringBuilder json = new StringBuilder();
            json.append("{");
            json.append("\"success\": true,");
            json.append("\"isCorrect\": ").append(isCorrect).append(",");
            json.append("\"correctOption\": \"").append(correctOption).append("\",");
            json.append("\"pointsEarned\": ").append(pointsEarned).append(",");
            json.append("\"explanation\": \"").append(escapeJson(explanation)).append("\",");
            json.append("\"newLevel\": ").append(newLevel).append(",");
            json.append("\"adaptiveMessage\": \"").append(adaptiveMessage).append("\"");
            json.append("}");
            
            out.print(json.toString());
            
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\": false, \"message\": \"Server error: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}
