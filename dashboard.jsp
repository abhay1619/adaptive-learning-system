<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.adaptive.model.User" %>
<%@ page import="com.adaptive.model.UserProgress" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.html");
        return;
    }
    List<UserProgress> progressList = (List<UserProgress>) request.getAttribute("progressList");
    List<String> subjects = (List<String>) request.getAttribute("subjects");
    List<User> leaderboard = (List<User>) request.getAttribute("leaderboard");
    Integer totalAttempts = (Integer) request.getAttribute("totalAttempts");
    Integer totalCorrect = (Integer) request.getAttribute("totalCorrect");
    Long avgTime = (Long) request.getAttribute("avgTime");
    
    if (totalAttempts == null) totalAttempts = 0;
    if (totalCorrect == null) totalCorrect = 0;
    if (avgTime == null) avgTime = 0L;
    
    double accuracy = totalAttempts > 0 ? (double) totalCorrect / totalAttempts * 100 : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - AdaptLearn</title>
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
                    <a href="dashboard" class="nav-item active">
                        <i class="fas fa-home"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="quiz" class="nav-item">
                        <i class="fas fa-brain"></i>
                        <span>Start Quiz</span>
                        <span class="nav-badge">Go</span>
                    </a>
                    <a href="analytics" class="nav-item">
                        <i class="fas fa-chart-line"></i>
                        <span>Analytics</span>
                    </a>
                </div>
                
                <div class="nav-section">
                    <span class="nav-section-title">Subjects</span>
                    <% if (subjects != null) { 
                        for (String subject : subjects) { 
                            String icon = "fa-book";
                            if (subject.equals("Mathematics")) icon = "fa-calculator";
                            else if (subject.equals("Science")) icon = "fa-flask";
                            else if (subject.equals("Programming")) icon = "fa-code";
                    %>
                    <a href="quiz?subject=<%= subject %>" class="nav-item">
                        <i class="fas <%= icon %>"></i>
                        <span><%= subject %></span>
                    </a>
                    <% } } %>
                </div>
            </nav>
            
            <div class="sidebar-footer">
                <div class="user-profile">
                    <div class="user-avatar">
                        <%= user.getFullName().substring(0, 1).toUpperCase() %>
                    </div>
                    <div class="user-info">
                        <h4><%= user.getFullName() %></h4>
                        <span>Level <%= user.getCurrentDifficulty() %> Learner</span>
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
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h1>Welcome back, <%= user.getFullName().split(" ")[0] %>! 👋</h1>
                        <p class="text-muted mb-0">Ready to continue your learning journey?</p>
                    </div>
                    <a href="quiz" class="btn btn-glow">
                        <i class="fas fa-play me-2"></i>Start Quiz
                    </a>
                </div>
            </header>
            
            <div class="content-body">
                <!-- Stats Cards -->
                <div class="stats-grid">
                    <div class="stat-card primary">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value" data-counter="<%= user.getTotalScore() %>"><%= user.getTotalScore() %></div>
                                <div class="stat-card-label">Total Points</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-star"></i>
                            </div>
                        </div>
                        <div class="stat-card-trend up">
                            <i class="fas fa-arrow-up"></i>
                            <span>Keep it up!</span>
                        </div>
                    </div>
                    
                    <div class="stat-card success">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= String.format("%.1f", accuracy) %>%</div>
                                <div class="stat-card-label">Accuracy Rate</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-bullseye"></i>
                            </div>
                        </div>
                        <div class="stat-card-trend <%= accuracy >= 70 ? "up" : "down" %>">
                            <i class="fas fa-arrow-<%= accuracy >= 70 ? "up" : "down" %>"></i>
                            <span><%= accuracy >= 70 ? "Great accuracy!" : "Room to improve" %></span>
                        </div>
                    </div>
                    
                    <div class="stat-card warning">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= user.getStreakDays() %></div>
                                <div class="stat-card-label">Day Streak 🔥</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-fire"></i>
                            </div>
                        </div>
                        <div class="stat-card-trend up">
                            <i class="fas fa-calendar-check"></i>
                            <span>Keep the streak alive!</span>
                        </div>
                    </div>
                    
                    <div class="stat-card info">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value">Level <%= user.getCurrentDifficulty() %></div>
                                <div class="stat-card-label">Current Level</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-signal"></i>
                            </div>
                        </div>
                        <div class="stat-card-trend up">
                            <i class="fas fa-chart-line"></i>
                            <span>Adaptive difficulty</span>
                        </div>
                    </div>
                </div>

                <div class="row g-4 mt-2">
                    <!-- Subjects -->
                    <div class="col-lg-8">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <h3><i class="fas fa-book-open me-2"></i>Choose a Subject</h3>
                                <a href="quiz" class="btn btn-secondary-glow btn-sm">View All</a>
                            </div>
                            <div class="card-body">
                                <div class="subject-grid">
                                    <% if (subjects != null) { 
                                        String[] cardClasses = {"math", "science", "programming"};
                                        String[] icons = {"fa-calculator", "fa-flask", "fa-code"};
                                        int i = 0;
                                        for (String subject : subjects) { 
                                            String cardClass = cardClasses[i % cardClasses.length];
                                            String icon = icons[i % icons.length];
                                            
                                            // Find progress for this subject
                                            int level = 1;
                                            int attempted = 0;
                                            double subjectAccuracy = 0;
                                            if (progressList != null) {
                                                for (UserProgress p : progressList) {
                                                    if (p.getSubject().equals(subject)) {
                                                        level = p.getCurrentLevel();
                                                        attempted = p.getQuestionsAttempted();
                                                        subjectAccuracy = p.getAccuracyRate();
                                                        break;
                                                    }
                                                }
                                            }
                                    %>
                                    <a href="quiz?subject=<%= subject %>" class="subject-card <%= cardClass %> text-decoration-none">
                                        <div class="subject-icon">
                                            <i class="fas <%= icon %>"></i>
                                        </div>
                                        <h4><%= subject %></h4>
                                        <p>Level <%= level %> • <%= attempted %> questions attempted</p>
                                        <div class="subject-progress">
                                            <div class="subject-progress-bar" style="width: <%= subjectAccuracy %>%"></div>
                                        </div>
                                        <div class="subject-stats">
                                            <span><%= String.format("%.0f", subjectAccuracy) %>% accuracy</span>
                                            <span><i class="fas fa-arrow-right"></i></span>
                                        </div>
                                    </a>
                                    <% i++; } } %>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Leaderboard -->
                    <div class="col-lg-4">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <h3><i class="fas fa-trophy me-2"></i>Leaderboard</h3>
                            </div>
                            <div class="card-body">
                                <% if (leaderboard != null && !leaderboard.isEmpty()) {
                                    int rank = 1;
                                    for (User leader : leaderboard) {
                                        String rankClass = rank == 1 ? "gold" : rank == 2 ? "silver" : rank == 3 ? "bronze" : "default";
                                %>
                                <div class="leaderboard-item">
                                    <div class="leaderboard-rank <%= rankClass %>">
                                        <% if (rank <= 3) { %>
                                            <i class="fas fa-crown"></i>
                                        <% } else { %>
                                            <%= rank %>
                                        <% } %>
                                    </div>
                                    <div class="leaderboard-user">
                                        <h5><%= leader.getFullName() %></h5>
                                        <span>🔥 <%= leader.getStreakDays() %> day streak</span>
                                    </div>
                                    <div class="leaderboard-score">
                                        <strong><%= leader.getTotalScore() %></strong>
                                        <span>points</span>
                                    </div>
                                </div>
                                <% rank++; } } else { %>
                                <p class="text-muted text-center py-4">No leaderboard data yet</p>
                                <% } %>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Progress by Subject -->
                <% if (progressList != null && !progressList.isEmpty()) { %>
                <div class="row g-4 mt-2">
                    <div class="col-12">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <h3><i class="fas fa-chart-bar me-2"></i>Your Progress</h3>
                                <a href="analytics" class="btn btn-secondary-glow btn-sm">View Details</a>
                            </div>
                            <div class="card-body">
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
                                                <%= progress.getCorrectAnswers() %>/<%= progress.getQuestionsAttempted() %> correct
                                            </span>
                                        </div>
                                        <div class="progress-bar-container">
                                            <div class="progress-bar" style="width: <%= progress.getAccuracyRate() %>%"></div>
                                        </div>
                                    </div>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </main>
    </div>

    <script src="[cdn.jsdelivr.net](https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js)"></script>
    <script src="js/app.js"></script>
</body>
</html>
