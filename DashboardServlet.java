package com.adaptive.servlet;

import com.adaptive.db.DBConnection;
import com.adaptive.model.User;
import com.adaptive.model.UserProgress;
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
import java.util.List;

@WebServlet("/dashboard")
public class DashboardServlet extends HttpServlet {
    
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
            // Get updated user info
            String userSql = "SELECT * FROM users WHERE user_id = ?";
            PreparedStatement userStmt = conn.prepareStatement(userSql);
            userStmt.setInt(1, userId);
            ResultSet userRs = userStmt.executeQuery();
            
            if (userRs.next()) {
                user.setTotalScore(userRs.getInt("total_score"));
                user.setCurrentDifficulty(userRs.getInt("current_difficulty"));
                user.setStreakDays(userRs.getInt("streak_days"));
                session.setAttribute("user", user);
            }
            
            // Get user progress by subject
            List<UserProgress> progressList = new ArrayList<>();
            String progressSql = "SELECT * FROM user_progress WHERE user_id = ? ORDER BY subject";
            PreparedStatement progressStmt = conn.prepareStatement(progressSql);
            progressStmt.setInt(1, userId);
            ResultSet progressRs = progressStmt.executeQuery();
            
            while (progressRs.next()) {
                UserProgress progress = new UserProgress();
                progress.setProgressId(progressRs.getInt("progress_id"));
                progress.setSubject(progressRs.getString("subject"));
                progress.setCurrentLevel(progressRs.getInt("current_level"));
                progress.setQuestionsAttempted(progressRs.getInt("questions_attempted"));
                progress.setCorrectAnswers(progressRs.getInt("correct_answers"));
                progress.setAccuracyRate(progressRs.getDouble("accuracy_rate"));
                progressList.add(progress);
            }
            request.setAttribute("progressList", progressList);
            
            // Get total stats
            String statsSql = "SELECT COUNT(*) as total_attempts, SUM(CASE WHEN is_correct THEN 1 ELSE 0 END) as correct, " +
                             "AVG(response_time_seconds) as avg_time FROM quiz_attempts WHERE user_id = ?";
            PreparedStatement statsStmt = conn.prepareStatement(statsSql);
            statsStmt.setInt(1, userId);
            ResultSet statsRs = statsStmt.executeQuery();
            
            if (statsRs.next()) {
                request.setAttribute("totalAttempts", statsRs.getInt("total_attempts"));
                request.setAttribute("totalCorrect", statsRs.getInt("correct"));
                request.setAttribute("avgTime", Math.round(statsRs.getDouble("avg_time")));
            }
            
            // Get available subjects
            String subjectsSql = "SELECT DISTINCT subject FROM questions ORDER BY subject";
            PreparedStatement subjectsStmt = conn.prepareStatement(subjectsSql);
            ResultSet subjectsRs = subjectsStmt.executeQuery();
            List<String> subjects = new ArrayList<>();
            while (subjectsRs.next()) {
                subjects.add(subjectsRs.getString("subject"));
            }
            request.setAttribute("subjects", subjects);
            
            // Get leaderboard top 5
            String leaderSql = "SELECT username, full_name, total_score, streak_days FROM users WHERE role = 'student' ORDER BY total_score DESC LIMIT 5";
            PreparedStatement leaderStmt = conn.prepareStatement(leaderSql);
            ResultSet leaderRs = leaderStmt.executeQuery();
            List<User> leaderboard = new ArrayList<>();
            while (leaderRs.next()) {
                User leader = new User();
                leader.setUsername(leaderRs.getString("username"));
                leader.setFullName(leaderRs.getString("full_name"));
                leader.setTotalScore(leaderRs.getInt("total_score"));
                leader.setStreakDays(leaderRs.getInt("streak_days"));
                leaderboard.add(leader);
            }
            request.setAttribute("leaderboard", leaderboard);
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
        }
        
        request.getRequestDispatcher("/WEB-INF/jsp/dashboard.jsp").forward(request, response);
    }
}
