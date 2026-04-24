<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.adaptive.model.User" %>
<%@ page import="com.adaptive.model.Question" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect("login.html");
        return;
    }
    Question question = (Question) request.getAttribute("question");
    Integer currentLevel = (Integer) request.getAttribute("currentLevel");
    String currentSubject = (String) request.getAttribute("currentSubject");
    List<String> subjects = (List<String>) request.getAttribute("subjects");
    
    if (currentLevel == null) currentLevel = 1;
    if (currentSubject == null) currentSubject = "Mathematics";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quiz - <%= currentSubject %> - AdaptLearn</title>
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
                    <a href="quiz" class="nav-item active">
                        <i class="fas fa-brain"></i>
                        <span>Quiz</span>
                    </a>
                    <a href="analytics" class="nav-item">
                        <i class="fas fa-chart-line"></i>
                        <span>Analytics</span>
                    </a>
                </div>
                
                <div class="nav-section">
                    <span class="nav-section-title">Switch Subject</span>
                    <% if (subjects != null) { 
                        for (String subject : subjects) { 
                            String icon = "fa-book";
                            if (subject.equals("Mathematics")) icon = "fa-calculator";
                            else if (subject.equals("Science")) icon = "fa-flask";
                            else if (subject.equals("Programming")) icon = "fa-code";
                            boolean isActive = subject.equals(currentSubject);
                    %>
                    <a href="quiz?subject=<%= subject %>" class="nav-item <%= isActive ? "active" : "" %>">
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
                        <span><%= user.getTotalScore() %> points</span>
                    </div>
                </div>
            </div>
        </aside>

        <!-- Main Content -->
        <main class="main-content">
            <header class="content-header">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <h1><i class="fas fa-brain me-2 text-primary"></i><%= currentSubject %> Quiz</h1>
                        <p class="text-muted mb-0">Answer questions to level up your skills</p>
                    </div>
                    <a href="dashboard" class="btn btn-secondary-glow">
                        <i class="fas fa-arrow-left me-2"></i>Back to Dashboard
                    </a>
                </div>
            </header>
            
            <div class="content-body">
                <div class="quiz-container">
                    <% if (question != null) { %>
                    <!-- Quiz Header -->
                    <div class="quiz-header">
                        <div class="quiz-info">
                            <div class="quiz-info-item">
                                <i class="fas fa-clock"></i>
                                <span id="quizTimer">00:00</span>
                            </div>
                            <div class="quiz-info-item">
                                <i class="fas fa-star"></i>
                                <span><%= question.getPoints() %> points</span>
                            </div>
                            <div class="quiz-info-item">
                                <span class="difficulty-badge level-<%= question.getDifficultyLevel() %>">
                                    <i class="fas fa-signal"></i> Level <%= question.getDifficultyLevel() %>
                                </span>
                            </div>
                        </div>
                    </div>

                    <!-- Question Card -->
                    <div class="question-card">
                        <div class="question-number">
                            <i class="fas fa-tag me-2"></i><%= question.getTopic() %>
                        </div>
                        <h2 class="question-text"><%= question.getQuestionText() %></h2>
                        
                        <input type="hidden" id="questionId" value="<%= question.getQuestionId() %>">
                        <input type="hidden" id="currentSubject" value="<%= currentSubject %>">
                        
                        <div class="options-grid">
                            <div class="option-item" data-option="A" onclick="selectOption(this)">
                                <span class="option-letter">A</span>
                                <span class="option-text"><%= question.getOptionA() %></span>
                                <span class="option-status"></span>
                            </div>
                            <div class="option-item" data-option="B" onclick="selectOption(this)">
                                <span class="option-letter">B</span>
                                <span class="option-text"><%= question.getOptionB() %></span>
                                <span class="option-status"></span>
                            </div>
                            <div class="option-item" data-option="C" onclick="selectOption(this)">
                                <span class="option-letter">C</span>
                                <span class="option-text"><%= question.getOptionC() %></span>
                                <span class="option-status"></span>
                            </div>
                            <div class="option-item" data-option="D" onclick="selectOption(this)">
                                <span class="option-letter">D</span>
                                <span class="option-text"><%= question.getOptionD() %></span>
                                <span class="option-status"></span>
                            </div>
                        </div>
                    </div>

                    <!-- Result Container -->
                    <div id="resultContainer" style="display: none;"></div>

                    <!-- Quiz Actions -->
                    <div class="quiz-actions">
                        <button id="submitAnswerBtn" class="btn btn-secondary-glow" onclick="submitAnswer()" disabled>
                            <i class="fas fa-check me-2"></i>Submit Answer
                        </button>
                        <button id="nextQuestionBtn" class="btn btn-glow" onclick="nextQuestion()" style="display: none;">
                            <i class="fas fa-arrow-right me-2"></i>Next Question
                        </button>
                    </div>

                    <!-- Keyboard Shortcuts -->
                    <div class="text-center mt-4">
                        <p class="text-muted" style="font-size: 0.8rem;">
                            <i class="fas fa-keyboard me-2"></i>
                            Tip: Press 1-4 to select options, Enter to submit
                        </p>
                    </div>
                    
                    <% } else { %>
                    <!-- No Questions Available -->
                    <div class="glass-card text-center p-5">
                        <div class="mb-4">
                            <i class="fas fa-graduation-cap" style="font-size: 4rem; color: var(--accent-primary);"></i>
                        </div>
                        <h2>Great Job! 🎉</h2>
                        <p class="text-secondary mb-4">
                            You've completed all available questions for <%= currentSubject %> at your current level.<br>
                            Try another subject or come back later for new questions!
                        </p>
                        <div class="d-flex gap-3 justify-content-center">
                            <a href="dashboard" class="btn btn-glow">
                                <i class="fas fa-home me-2"></i>Go to Dashboard
                            </a>
                            <% if (subjects != null && subjects.size() > 1) { 
                                for (String subject : subjects) { 
                                    if (!subject.equals(currentSubject)) { %>
                            <a href="quiz?subject=<%= subject %>" class="btn btn-outline-glow">
                                <i class="fas fa-arrow-right me-2"></i>Try <%= subject %>
                            </a>
                            <% break; } } } %>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>
        </main>
    </div>

    <script src="[cdn.jsdelivr.net](https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js)"></script>
    <script src="js/app.js"></script>
    <% if (question != null) { %>
    <script>
        // Initialize quiz on page load
        document.addEventListener('DOMContentLoaded', initQuiz);
    </script>
    <% } %>
</body>
</html>
