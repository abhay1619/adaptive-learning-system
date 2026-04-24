package com.adaptive.servlet;

import com.adaptive.db.DBConnection;
import com.adaptive.model.Question;
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

@WebServlet("/quiz")
public class QuizServlet extends HttpServlet {
    
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
        String subject = request.getParameter("subject");
        
        if (subject == null || subject.trim().isEmpty()) {
            subject = "Mathematics"; // Default subject
        }
        
        try (Connection conn = DBConnection.getNewConnection()) {
            // Get or create user progress for this subject
            int currentLevel = 1;
            String progressSql = "SELECT current_level FROM user_progress WHERE user_id = ? AND subject = ?";
            PreparedStatement progressStmt = conn.prepareStatement(progressSql);
            progressStmt.setInt(1, userId);
            progressStmt.setString(2, subject);
            ResultSet progressRs = progressStmt.executeQuery();
            
            if (progressRs.next()) {
                currentLevel = progressRs.getInt("current_level");
            } else {
                // Create new progress entry
                String insertProgressSql = "INSERT INTO user_progress (user_id, subject, current_level) VALUES (?, ?, 1)";
                PreparedStatement insertStmt = conn.prepareStatement(insertProgressSql);
                insertStmt.setInt(1, userId);
                insertStmt.setString(2, subject);
                insertStmt.executeUpdate();
            }
            
            // Get a question at or near current difficulty (adaptive range: current-1 to current+1)
            int minLevel = Math.max(1, currentLevel - 1);
            int maxLevel = Math.min(5, currentLevel + 1);
            
            // Get questions not recently attempted by user
            String questionSql = "SELECT q.* FROM questions q " +
                                "WHERE q.subject = ? AND q.difficulty_level BETWEEN ? AND ? " +
                                "AND q.question_id NOT IN (SELECT question_id FROM quiz_attempts WHERE user_id = ? " +
                                "AND attempted_at > DATE_SUB(NOW(), INTERVAL 1 HOUR)) " +
                                "ORDER BY ABS(q.difficulty_level - ?), RAND() LIMIT 1";
            
            PreparedStatement questionStmt = conn.prepareStatement(questionSql);
            questionStmt.setString(1, subject);
            questionStmt.setInt(2, minLevel);
            questionStmt.setInt(3, maxLevel);
            questionStmt.setInt(4, userId);
            questionStmt.setInt(5, currentLevel);
            
            ResultSet questionRs = questionStmt.executeQuery();
            
            Question question = null;
            if (questionRs.next()) {
                question = new Question();
                question.setQuestionId(questionRs.getInt("question_id"));
                question.setSubject(questionRs.getString("subject"));
                question.setTopic(questionRs.getString("topic"));
                question.setQuestionText(questionRs.getString("question_text"));
                question.setOptionA(questionRs.getString("option_a"));
                question.setOptionB(questionRs.getString("option_b"));
                question.setOptionC(questionRs.getString("option_c"));
                question.setOptionD(questionRs.getString("option_d"));
                question.setDifficultyLevel(questionRs.getInt("difficulty_level"));
                question.setPoints(questionRs.getInt("points"));
            } else {
                // If no fresh questions, get any question from subject
                String fallbackSql = "SELECT * FROM questions WHERE subject = ? ORDER BY RAND() LIMIT 1";
                PreparedStatement fallbackStmt = conn.prepareStatement(fallbackSql);
                fallbackStmt.setString(1, subject);
                ResultSet fallbackRs = fallbackStmt.executeQuery();
                
                if (fallbackRs.next()) {
                    question = new Question();
                    question.setQuestionId(fallbackRs.getInt("question_id"));
                    question.setSubject(fallbackRs.getString("subject"));
                    question.setTopic(fallbackRs.getString("topic"));
                    question.setQuestionText(fallbackRs.getString("question_text"));
                    question.setOptionA(fallbackRs.getString("option_a"));
                    question.setOptionB(fallbackRs.getString("option_b"));
                    question.setOptionC(fallbackRs.getString("option_c"));
                    question.setOptionD(fallbackRs.getString("option_d"));
                    question.setDifficultyLevel(fallbackRs.getInt("difficulty_level"));
                    question.setPoints(fallbackRs.getInt("points"));
                }
            }
            
            // Get available subjects
            String subjectsSql = "SELECT DISTINCT subject FROM questions ORDER BY subject";
            PreparedStatement subjectsStmt = conn.prepareStatement(subjectsSql);
            ResultSet subjectsRs = subjectsStmt.executeQuery();
            List<String> subjects = new ArrayList<>();
            while (subjectsRs.next()) {
                subjects.add(subjectsRs.getString("subject"));
            }
            
            request.setAttribute("question", question);
            request.setAttribute("currentLevel", currentLevel);
            request.setAttribute("currentSubject", subject);
            request.setAttribute("subjects", subjects);
            request.setAttribute("questionStartTime", System.currentTimeMillis());
            session.setAttribute("questionStartTime", System.currentTimeMillis());
            
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", e.getMessage());
        }
        
        request.getRequestDispatcher("/WEB-INF/jsp/quiz.jsp").forward(request, response);
    }
}
