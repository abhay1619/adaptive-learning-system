<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.adaptive.model.User" %>
<%@ page import="com.adaptive.model.UserProgress" %>
<%@ page import="com.adaptive.model.QuizAttempt" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.html");
        return;
    }
    List<UserProgress> progressList = (List<UserProgress>) request.getAttribute("progressList");
    List<QuizAttempt> recentAttempts = (List<QuizAttempt>) request.getAttribute("recentAttempts");
    List<Map<String, Object>> dailyStats = (List<Map<String, Object>>) request.getAttribute("dailyStats");
    
    Integer totalAttempts = (Integer) request.getAttribute("totalAttempts");
    Integer totalCorrect = (Integer) request.getAttribute("totalCorrect");
    Integer totalPoints = (Integer) request.getAttribute("totalPoints");
    Long avgTime = (Long) request.getAttribute("avgTime");
    
    if (totalAttempts == null) totalAttempts = 0;
    if (totalCorrect == null) totalCorrect = 0;
    if (totalPoints == null) totalPoints = 0;
    if (avgTime == null) avgTime = 0L;
    
    double accuracy = totalAttempts > 0 ? (double) totalCorrect / totalAttempts * 100 : 0;
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Analytics - AdaptLearn</title>
    <link href="[cdn.jsdelivr.net](https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css)" rel="stylesheet">
    <link href="[cdnjs.cloudflare.com](https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css)" rel="stylesheet">
    <link href="[fonts.googleapis.com](https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap)" rel="stylesheet">
    <link href="css/style.css" rel="stylesheet">
</head>
<body>
    <div class="dashboard-wrapper">
        <!-- Sidebar -->
        <aside class="sidebar">
            <div class="sidebar-header">
                <div class="sidebar-logo">
                    <div class="logo-icon">🧠</div>
                    <h2 class="gradient-text">AdaptLearn</h2>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <div class="nav-section">
                    <span class="nav-section-title">Main</span>
                    <a href="dashboard" class="nav-item">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="quiz" class="nav-item">
                        <i class="fas fa-brain"></i>
                        <span>Start Quiz</span>
                    </a>
                    <a href="analytics" class="nav-item active">
                        <i class="fas fa-chart-line"></i>
                        <span>Analytics</span>
                    </a>
                </div>
            </nav>
            
            <div class="sidebar-footer">
                <div class="user-profile">
                    <div class="user-avatar">
                        <%= user.getFullName().substring(0, 1).toUpperCase() %>
                    </div>
                    <div class="user-info">
                        <h4><%= user.getFullName() %></h4>
                        <span><%= user.getTotalScore() %> points</span>
                    </div>
                </div>
                <a href="logout" class="nav-item mt-3">
                    <i class="fas fa-sign-out-alt"></i>
                    <span>Logout</span>
                </a>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <header class="content-header">
                <div>
                    <h1><i class="fas fa-chart-line me-2 text-primary"></i>Analytics</h1>
                    <p class="text-muted mb-0">Track your learning progress and performance</p>
                </div>
            </header>
            
            <div class="content-body">
                <!-- Overview Stats -->
                <div class="stats-grid">
                    <div class="stat-card primary">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= totalAttempts %></div>
                                <div class="stat-card-label">Total Questions</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-question-circle"></i>
                            </div>
                        </div>
                    </div>
                    
                    <div class="stat-card success">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= totalCorrect %></div>
                                <div class="stat-card-label">Correct Answers</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-check-circle"></i>
                            </div>
                        </div>
                    </div>
                    
                    <div class="stat-card warning">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= String.format("%.1f", accuracy) %>%</div>
                                <div class="stat-card-label">Accuracy Rate</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-bullseye"></i>
                            </div>
                        </div>
                    </div>
                    
                    <div class="stat-card info">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= avgTime %>s</div>
                                <div class="stat-card-label">Avg Response Time</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-clock"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mt-2">
                    <!-- Progress by Subject -->
                    <div class="col-lg-6">
                        <div class="dashboard-card h-100">
                            <div class="card-header">
                                <h3><i class="fas fa-chart-bar me-2"></i>Progress by Subject</h3>
                            </div>
                            <div class="card-body">
                                <% if (progressList != null && !progressList.isEmpty()) { %>
                                <div class="progress-list">
                                    <% for (UserProgress progress : progressList) { %>
                                    <div class="progress-item">
                                        <div class="progress-header">
                                            <span class="progress-subject">
                                                <i class="fas fa-book text-primary me-2"></i>
                                                <%= progress.getSubject() %>
                                            </span>
                                            <span class="progress-stats">
                                                Level <%= progress.getCurrentLevel() %> • 
                                                <%= String.format("%.0f", progress.getAccuracyRate()) %>%
                                            </span>
                                        </div>
                                        <div class="progress-bar-container">
                                            <div class="progress-bar" style="width: <%= progress.getAccuracyRate() %>%"></div>
                                        </div>
                                        <div class="d-flex justify-content-between mt-2" style="font-size: 0.8rem; color: var(--text-muted);">
                                            <span><%= progress.getQuestionsAttempted() %> attempted</span>
                                            <span><%= progress.getCorrectAnswers() %> correct</span>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                                <% } else { %>
                                <p class="text-muted text-center py-4">No progress data yet. Start a quiz!</p>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <!-- Performance Overview -->
                    <div class="col-lg-6">
                        <div class="dashboard-card h-100">
                            <div class="card-header">
                                <h3><i class="fas fa-trophy me-2"></i>Performance Overview</h3>
                            </div>
                            <div class="card-body">
                                <div class="text-center py-4">
                                    <div class="mb-4">
                                        <div style="width: 150px; height: 150px; margin: 0 auto; position: relative;">
                                            <svg viewBox="0 0 36 36" style="transform: rotate(-90deg);">
                                                <path d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                                                      fill="none" stroke="rgba(255,255,255,0.1)" stroke-width="3"/>
                                                <path d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                                                      fill="none" stroke="url(#gradient)" stroke-width="3"
                                                      stroke-dasharray="<%= accuracy %>, 100"/>
                                                <defs>
                                                    <linearGradient id="gradient">
                                                        <stop offset="0%" stop-color="#6366f1"/>
                                                        <stop offset="100%" stop-color="#a855f7"/>
                                                    </linearGradient>
                                                </defs>
                                            </svg>
                                            <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); text-align: center;">
                                                <div style="font-size: 2rem; font-weight: 700;"><%= String.format("%.0f", accuracy) %>%</div>
                                                <div style="font-size: 0.8rem; color: var(--text-muted);">Accuracy</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="row text-center">
                                        <div class="col-4">
                                            <div class="stat-card-value" style="font-size: 1.5rem;"><%= user.getStreakDays() %></div>
                                            <div class="text-muted" style="font-size: 0.8rem;">Day Streak</div>
                                        </div>
                                        <div class="col-4">
                                            <div class="stat-card-value" style="font-size: 1.5rem;"><%= user.getCurrentDifficulty() %></div>
                                            <div class="text-muted" style="font-size: 0.8rem;">Current Level</div>
                                        </div>
                                        <div class="col-4">
                                            <div class="stat-card-value" style="font-size: 1.5rem;"><%= user.getTotalScore() %></div>
                                            <div class="text-muted" style="font-size: 0.8rem;">Total Points</div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Recent Activity -->
                <div class="row g-4 mt-2">
                    <div class="col-12">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <h3><i class="fas fa-history me-2"></i>Recent Activity</h3>
                            </div>
                            <div class="card-body p-0">
                                <% if (recentAttempts != null && !recentAttempts.isEmpty()) { %>
                                <div class="table-responsive">
                                    <table class="history-table">
                                        <thead>
                                            <tr>
                                                <th>Question</th>
                                                <th>Subject</th>
                                                <th>Level</th>
                                                <th>Your Answer</th>
                                                <th>Result</th>
                                                <th>Points</th>
                                                <th>Time</th>
                                                <th>Date</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% for (QuizAttempt attempt : recentAttempts) { %>
                                            <tr>
                                                <td>
                                                    <span style="max-width: 200px; display: inline-block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                        <%= attempt.getQuestionText() %>
                                                    </span>
                                                </td>
                                                <td><%= attempt.getSubject() %></td>
                                                <td>
                                                    <span class="difficulty-badge level-<%= attempt.getDifficultyAtAttempt() %>">
                                                        L<%= attempt.getDifficultyAtAttempt() %>
                                                    </span>
                                                </td>
                                                <td><%= attempt.getSelectedOption() %></td>
                                                <td>
                                                    <span class="status-badge <%= attempt.isCorrect() ? "correct" : "incorrect" %>">
                                                        <i class="fas fa-<%= attempt.isCorrect() ? "check" : "times" %>"></i>
                                                        <%= attempt.isCorrect() ? "Correct" : "Incorrect" %>
                                                    </span>
                                                </td>
                                                <td>+<%= attempt.getPointsEarned() %></td>
                                                <td><%= attempt.getResponseTimeSeconds() %>s</td>
                                                <td><%= sdf.format(attempt.getAttemptedAt()) %></td>
                                            </tr>
                                            <% } %>
                                        </tbody>
                                    </table>
                                </div>
                                <% } else { %>
                                <p class="text-muted text-center py-4">No quiz attempts yet. Start your first quiz!</p>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script src="[cdn.jsdelivr.net](https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js)"></script>
    <script src="js/app.js"></script>
</body>
</html>
