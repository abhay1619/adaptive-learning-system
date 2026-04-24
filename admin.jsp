<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.adaptive.model.User" %>
<%@ page import="com.adaptive.model.Question" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !"admin".equals(user.getRole())) {
        response.sendRedirect("login.html");
        return;
    }
    List<User> users = (List<User>) request.getAttribute("users");
    List<Question> questions = (List<Question>) request.getAttribute("questions");
    
    Integer totalStudents = (Integer) request.getAttribute("totalStudents");
    Integer totalQuestions = (Integer) request.getAttribute("totalQuestions");
    Integer totalAttempts = (Integer) request.getAttribute("totalAttempts");
    Integer totalSubjects = (Integer) request.getAttribute("totalSubjects");
    
    if (totalStudents == null) totalStudents = 0;
    if (totalQuestions == null) totalQuestions = 0;
    if (totalAttempts == null) totalAttempts = 0;
    if (totalSubjects == null) totalSubjects = 0;
    
    SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - AdaptLearn</title>
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
                    <span class="nav-section-title">Admin Panel</span>
                    <a href="admin" class="nav-item active">
                        <i class="fas fa-tachometer-alt"></i>
                        <span>Dashboard</span>
                    </a>
                    <a href="#users" class="nav-item">
                        <i class="fas fa-users"></i>
                        <span>Students</span>
                        <span class="nav-badge"><%= totalStudents %></span>
                    </a>
                    <a href="#questions" class="nav-item">
                        <i class="fas fa-question-circle"></i>
                        <span>Questions</span>
                        <span class="nav-badge"><%= totalQuestions %></span>
                    </a>
                </div>
            </nav>
            
            <div class="sidebar-footer">
                <div class="user-profile">
                    <div class="user-avatar" style="background: linear-gradient(135deg, #f59e0b, #ef4444);">
                        <i class="fas fa-crown"></i>
                    </div>
                    <div class="user-info">
                        <h4><%= user.getFullName() %></h4>
                        <span>Administrator</span>
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
                        <h1><i class="fas fa-shield-alt me-2 text-warning"></i>Admin Dashboard</h1>
                        <p class="text-muted mb-0">Manage students, questions, and monitor platform activity</p>
                    </div>
                    <button class="btn btn-glow" onclick="openAddQuestionModal()">
                        <i class="fas fa-plus me-2"></i>Add Question
                    </button>
                </div>
            </header>
            
            <div class="content-body">
                <!-- Stats -->
                <div class="stats-grid">
                    <div class="stat-card primary">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= totalStudents %></div>
                                <div class="stat-card-label">Total Students</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-users"></i>
                            </div>
                        </div>
                    </div>
                    
                    <div class="stat-card success">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= totalQuestions %></div>
                                <div class="stat-card-label">Total Questions</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-question-circle"></i>
                            </div>
                        </div>
                    </div>
                    
                    <div class="stat-card warning">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= totalAttempts %></div>
                                <div class="stat-card-label">Quiz Attempts</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-clipboard-check"></i>
                            </div>
                        </div>
                    </div>
                    
                    <div class="stat-card info">
                        <div class="stat-card-header">
                            <div>
                                <div class="stat-card-value"><%= totalSubjects %></div>
                                <div class="stat-card-label">Subjects</div>
                            </div>
                            <div class="stat-card-icon">
                                <i class="fas fa-book"></i>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Students Table -->
                <div class="row g-4 mt-2" id="users">
                    <div class="col-12">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <h3><i class="fas fa-users me-2"></i>Students</h3>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="admin-table">
                                        <thead>
                                            <tr>
                                                <th>Student</th>
                                                <th>Email</th>
                                                <th>Level</th>
                                                <th>Score</th>
                                                <th>Streak</th>
                                                <th>Joined</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (users != null) { for (User u : users) { %>
                                            <tr>
                                                <td>
                                                    <div class="d-flex align-items-center gap-2">
                                                        <div class="user-avatar" style="width: 35px; height: 35px; font-size: 0.875rem;">
                                                            <%= u.getFullName().substring(0, 1).toUpperCase() %>
                                                        </div>
                                                        <div>
                                                            <strong><%= u.getFullName() %></strong>
                                                            <div class="text-muted" style="font-size: 0.8rem;">@<%= u.getUsername() %></div>
                                                        </div>
                                                    </div>
                                                </td>
                                                <td><%= u.getEmail() %></td>
                                                <td>
                                                    <span class="difficulty-badge level-<%= u.getCurrentDifficulty() %>">
                                                        Level <%= u.getCurrentDifficulty() %>
                                                    </span>
                                                </td>
                                                <td><strong><%= u.getTotalScore() %></strong></td>
                                                <td><%= u.getStreakDays() %> days 🔥</td>
                                                <td><%= u.getCreatedAt() != null ? sdf.format(u.getCreatedAt()) : "N/A" %></td>
                                            </tr>
                                            <% } } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Questions Table -->
                <div class="row g-4 mt-2" id="questions">
                    <div class="col-12">
                        <div class="dashboard-card">
                            <div class="card-header">
                                <h3><i class="fas fa-question-circle me-2"></i>Questions</h3>
                                <button class="btn btn-glow btn-sm" onclick="openAddQuestionModal()">
                                    <i class="fas fa-plus me-2"></i>Add New
                                </button>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="admin-table">
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Question</th>
                                                <th>Subject</th>
                                                <th>Topic</th>
                                                <th>Level</th>
                                                <th>Answer</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <% if (questions != null) { for (Question q : questions) { %>
                                            <tr>
                                                <td><%= q.getQuestionId() %></td>
                                                <td>
                                                    <span style="max-width: 250px; display: inline-block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">
                                                        <%= q.getQuestionText() %>
                                                    </span>
                                                </td>
                                                <td><%= q.getSubject() %></td>
                                                <td><%= q.getTopic() %></td>
                                                <td>
                                                    <span class="difficulty-badge level-<%= q.getDifficultyLevel() %>">
                                                        L<%= q.getDifficultyLevel() %>
                                                    </span>
                                                </td>
                                                <td><strong><%= q.getCorrectOption() %></strong></td>
                                                <td>
                                                    <button class="btn-icon delete" onclick="deleteQuestion(<%= q.getQuestionId() %>)">
                                                        <i class="fas fa-trash"></i>
                                                    </button>
                                                </td>
                                            </tr>
                                            <% } } %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <!-- Add Question Modal -->
    <div class="modal-overlay" id="addQuestionModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-plus-circle me-2"></i>Add New Question</h3>
                <button class="modal-close" onclick="closeModal('addQuestionModal')">
                    <i class="fas fa-times"></i>
                </button>
            </div>
            <form onsubmit="handleAddQuestion(event)">
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Subject</label>
                            <select name="subject" class="form-control-custom" required>
                                <option value="Mathematics">Mathematics</option>
                                <option value="Science">Science</option>
                                <option value="Programming">Programming</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Topic</label>
                            <input type="text" name="topic" class="form-control-custom" placeholder="e.g., Algebra" required>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Question</label>
                            <textarea name="questionText" class="form-control-custom" rows="3" placeholder="Enter your question..." required></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Option A</label>
                            <input type="text" name="optionA" class="form-control-custom" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Option B</label>
                            <input type="text" name="optionB" class="form-control-custom" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Option C</label>
                            <input type="text" name="optionC" class="form-control-custom" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Option D</label>
                            <input type="text" name="optionD" class="form-control-custom" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Correct Option</label>
                            <select name="correctOption" class="form-control-custom" required>
                                <option value="A">A</option>
                                <option value="B">B</option>
                                <option value="C">C</option>
                                <option value="D">D</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Difficulty Level</label>
                            <select name="difficulty" class="form-control-custom" required>
                                <option value="1">Level 1 - Easy</option>
                                <option value="2">Level 2 - Medium Easy</option>
                                <option value="3">Level 3 - Medium</option>
                                <option value="4">Level 4 - Hard</option>
                                <option value="5">Level 5 - Expert</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="form-label">Explanation (Optional)</label>
                            <textarea name="explanation" class="form-control-custom" rows="2" placeholder="Explain the answer..."></textarea>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary-glow" onclick="closeModal('addQuestionModal')">Cancel</button>
                    <button type="submit" class="btn btn-glow">
                        <i class="fas fa-plus me-2"></i>Add Question
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script src="[cdn.jsdelivr.net](https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js)"></script>
    <script src="js/app.js"></script>
</body>
</html>
