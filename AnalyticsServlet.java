package com.adaptive.servlet;

import com.adaptive.db.DBConnection;
import com.adaptive.model.User;
import com.adaptive.model.UserProgress;
import com.adaptive.model.QuizAttempt;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/analytics")
public class AnalyticsServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            response.sendRedirect("login.html");
            return;
        }
        
        User user = (User) session.getAttribute("user");
        int userId = user.getUserId();
        
        try (Connection conn = DBConnection.getNewConnection()) {
            // Get progress by subject
            List<UserProgress> progressList = new ArrayList<>();
            String progressSql = "SELECT * FROM user_progress WHERE user_id = ? ORDER BY subject";
            PreparedStatement progressStmt = conn.prepareStatement(progressSql);
            progressStmt.setInt(1, userId);
            ResultSet progressRs = progressStmt.executeQuery();
            
            while (progressRs.next()) {
                UserProgress progress = new UserProgress();
                progress.setSubject(progressRs.getString("subject"));
                progress.setCurrentLevel(progressRs.getInt("current_level"));
                progress.setQuestionsAttempted(progressRs.getInt("questions_attempted"));
                progress.setCorrectAnswers(progressRs.getInt("correct_answers"));
                progress.setAccuracyRate(progressRs.getDouble("accuracy_rate"));
                progressList.add(progress);
            }
            request.setAttribute("progressList", progressList);
            
            // Get recent attempts
            List<QuizAttempt> recentAttempts = new ArrayList<>();
            String attemptsSql = "SELECT qa.*, q.question_text, q.subject, q.correct_option " +
                                "FROM quiz_attempts qa JOIN questions q ON qa.question_id = q.question_id " +
                                "WHERE qa.user_id = ? ORDER BY qa.attempted_at DESC LIMIT 20";
            PreparedStatement attemptsStmt = conn.prepareStatement(attemptsSql);
            attemptsStmt.setInt(1, userId);
            ResultSet attemptsRs = attemptsStmt.executeQuery();
            
            while (attemptsRs.next()) {
                QuizAttempt attempt = new QuizAttempt();
                attempt.setAttemptId(attemptsRs.getInt("attempt_id"));
                attempt.setQuestionText(attemptsRs.getString("question_text"));
                attempt.setSubject(attemptsRs.getString("subject"));
                attempt.setSelectedOption(attemptsRs.getString("selected_option").charAt(0));
                attempt.setCorrectOption(attemptsRs.getString("correct_option").charAt(0));
                attempt.setCorrect(attemptsRs.getBoolean("is_correct"));
                attempt.setResponseTimeSeconds(attemptsRs.getInt("response_time_seconds"));
                attempt.setDifficultyAtAttempt(attemptsRs.getInt("difficulty_at_attempt"));
                attempt.setPointsEarned(attemptsRs.getInt("points_earned"));
                attempt.setAttemptedAt(attemptsRs.getTimestamp("attempted_at"));
                recentAttempts.add(attempt);
            }
            request.setAttribute("recentAttempts", recentAttempts);
            
            // Get daily performance for chart (last 7 days)
            String dailySql = "SELECT DATE(attempted_at) as date, COUNT(*) as total, " +
                             "SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct, " +
                             "SUM(points_earned) as points " +
                             "FROM quiz_attempts WHERE user_id = ? AND attempted_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) " +
                             "GROUP BY DATE(attempted_at) ORDER BY date";
            PreparedStatement dailyStmt = conn.prepareStatement(dailySql);
            dailyStmt.setInt(1, userId);
            ResultSet dailyRs = dailyStmt.executeQuery();
            
            List<Map<String, Object>> dailyStats = new ArrayList<>();
            while (dailyRs.next()) {
                Map<String, Object> dayStat = new HashMap<>();
                dayStat.put("date", dailyRs.getDate("date").toString());
                dayStat.put("total", dailyRs.getInt("total"));
                dayStat.put("correct", dailyRs.getInt("correct"));
                dayStat.put("points", dailyRs.getInt("points"));
                dailyStats.add(dayStat);
            }
            request.setAttribute("dailyStats", dailyStats);
            
            // Overall stats
            String overallSql = "SELECT COUNT(*) as total_attempts, " +
                               "SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as total_correct, " +
                               "SUM(points_earned) as total_points, " +
                               "AVG(response_time_seconds) as avg_time " +
                               "FROM quiz_attempts WHERE user_id = ?";
            PreparedStatement overallStmt = conn.prepareStatement(overallSql);
            overallStmt.setInt(1, userId);
            ResultSet overallRs = overallStmt.executeQuery();
            
            if (overallRs.next()) {
                request.setAttribute("totalAttempts", overallRs.getInt("total_attempts"));
                request.setAttribute("totalCorrect", overallRs.getInt("total_correct"));
                request.setAttribute("totalPoints", overallRs.getInt("total_points"));
                request.setAttribute("avgTime", Math.round(overallRs.getDouble("avg_time")));
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
        }
        
        request.getRequestDispatcher("/WEB-INF/jsp/analytics.jsp").forward(request, response);
    }
}
