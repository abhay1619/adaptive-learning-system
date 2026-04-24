-- Adaptive Learning System Database Schema
-- MySQL 8.0+

CREATE DATABASE IF NOT EXISTS adaptive_learning;
USE adaptive_learning;

-- Users Table
DROP TABLE IF EXISTS quiz_attempts;
DROP TABLE IF EXISTS user_progress;
DROP TABLE IF EXISTS questions;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('student', 'admin') DEFAULT 'student',
    current_difficulty INT DEFAULT 1,
    total_score INT DEFAULT 0,
    streak_days INT DEFAULT 0,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Questions Table with Difficulty Levels
CREATE TABLE questions (
    question_id INT PRIMARY KEY AUTO_INCREMENT,
    subject VARCHAR(50) NOT NULL,
    topic VARCHAR(100) NOT NULL,
    question_text TEXT NOT NULL,
    option_a VARCHAR(255) NOT NULL,
    option_b VARCHAR(255) NOT NULL,
    option_c VARCHAR(255) NOT NULL,
    option_d VARCHAR(255) NOT NULL,
    correct_option CHAR(1) NOT NULL,
    difficulty_level INT NOT NULL CHECK (difficulty_level BETWEEN 1 AND 5),
    points INT DEFAULT 10,
    explanation TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Progress Tracking
CREATE TABLE user_progress (
    progress_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    subject VARCHAR(50) NOT NULL,
    current_level INT DEFAULT 1,
    questions_attempted INT DEFAULT 0,
    correct_answers INT DEFAULT 0,
    accuracy_rate DECIMAL(5,2) DEFAULT 0.00,
    avg_response_time DECIMAL(10,2) DEFAULT 0.00,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_user_subject (user_id, subject)
);

-- Quiz Attempts Log
CREATE TABLE quiz_attempts (
    attempt_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    question_id INT NOT NULL,
    selected_option CHAR(1),
    is_correct BOOLEAN DEFAULT FALSE,
    response_time_seconds INT DEFAULT 0,
    difficulty_at_attempt INT NOT NULL,
    points_earned INT DEFAULT 0,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE
);

-- Indexes for Performance
CREATE INDEX idx_questions_difficulty ON questions(difficulty_level);
CREATE INDEX idx_questions_subject ON questions(subject);
CREATE INDEX idx_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_progress_user ON user_progress(user_id);

-- Insert Sample Admin User (password: admin123)
INSERT INTO users (username, email, password, full_name, role) VALUES
('admin', 'admin@adaptive.com', 'admin123', 'System Administrator', 'admin');

-- Insert Sample Students (password: password123)
INSERT INTO users (username, email, password, full_name, role, current_difficulty, total_score, streak_days) VALUES
('john_doe', 'john@email.com', 'password123', 'John Doe', 'student', 2, 450, 5),
('jane_smith', 'jane@email.com', 'password123', 'Jane Smith', 'student', 3, 720, 12),
('mike_wilson', 'mike@email.com', 'password123', 'Mike Wilson', 'student', 1, 180, 2),
('sarah_jones', 'sarah@email.com', 'password123', 'Sarah Jones', 'student', 4, 1250, 21);

-- Insert Sample Questions - Mathematics
INSERT INTO questions (subject, topic, question_text, option_a, option_b, option_c, option_d, correct_option, difficulty_level, points, explanation) VALUES
-- Level 1 - Easy
('Mathematics', 'Basic Arithmetic', 'What is 15 + 27?', '42', '43', '41', '44', 'A', 1, 10, 'Simple addition: 15 + 27 = 42'),
('Mathematics', 'Basic Arithmetic', 'What is 8 × 7?', '54', '56', '58', '52', 'B', 1, 10, 'Multiplication: 8 × 7 = 56'),
('Mathematics', 'Basic Arithmetic', 'What is 100 - 37?', '67', '63', '73', '57', 'B', 1, 10, 'Subtraction: 100 - 37 = 63'),

-- Level 2 - Medium Easy
('Mathematics', 'Fractions', 'What is 1/2 + 1/4?', '2/6', '3/4', '1/6', '2/4', 'B', 2, 15, 'Common denominator: 2/4 + 1/4 = 3/4'),
('Mathematics', 'Percentages', 'What is 25% of 80?', '20', '25', '15', '30', 'A', 2, 15, '25% = 0.25, so 0.25 × 80 = 20'),
('Mathematics', 'Algebra', 'Solve: x + 5 = 12', 'x = 5', 'x = 7', 'x = 17', 'x = 6', 'B', 2, 15, 'x = 12 - 5 = 7'),

-- Level 3 - Medium
('Mathematics', 'Algebra', 'Solve: 2x + 6 = 18', 'x = 6', 'x = 12', 'x = 8', 'x = 4', 'A', 3, 20, '2x = 12, x = 6'),
('Mathematics', 'Geometry', 'Area of rectangle with length 8 and width 5?', '13', '40', '26', '35', 'B', 3, 20, 'Area = length × width = 8 × 5 = 40'),
('Mathematics', 'Statistics', 'Mean of 4, 8, 12, 16?', '8', '10', '12', '9', 'B', 3, 20, 'Mean = (4+8+12+16)/4 = 40/4 = 10'),

-- Level 4 - Hard
('Mathematics', 'Quadratics', 'Solve: x² - 5x + 6 = 0', 'x = 2, 3', 'x = -2, -3', 'x = 1, 6', 'x = -1, 6', 'A', 4, 25, 'Factoring: (x-2)(x-3) = 0'),
('Mathematics', 'Trigonometry', 'What is sin(30°)?', '1', '0.5', '0.866', '0', 'B', 4, 25, 'sin(30°) = 1/2 = 0.5'),
('Mathematics', 'Calculus', 'Derivative of x³?', '3x', '3x²', 'x²', '2x³', 'B', 4, 25, 'Power rule: d/dx(x³) = 3x²'),

-- Level 5 - Expert
('Mathematics', 'Calculus', 'Integral of 2x dx?', 'x²', 'x² + C', '2x² + C', 'x + C', 'B', 5, 30, '∫2x dx = x² + C'),
('Mathematics', 'Linear Algebra', 'Determinant of [[1,2],[3,4]]?', '-2', '2', '-10', '10', 'A', 5, 30, 'det = (1×4) - (2×3) = 4 - 6 = -2'),
('Mathematics', 'Complex Numbers', 'What is i²?', '1', '-1', 'i', '-i', 'B', 5, 30, 'By definition, i² = -1');

-- Insert Sample Questions - Science
INSERT INTO questions (subject, topic, question_text, option_a, option_b, option_c, option_d, correct_option, difficulty_level, points, explanation) VALUES
-- Level 1
('Science', 'Biology', 'What is the powerhouse of the cell?', 'Nucleus', 'Mitochondria', 'Ribosome', 'Golgi Body', 'B', 1, 10, 'Mitochondria produces ATP energy'),
('Science', 'Physics', 'What is the unit of force?', 'Joule', 'Watt', 'Newton', 'Pascal', 'C', 1, 10, 'Force is measured in Newtons'),
('Science', 'Chemistry', 'Chemical symbol for water?', 'H2O', 'CO2', 'NaCl', 'O2', 'A', 1, 10, 'Water is H2O - 2 hydrogen, 1 oxygen'),

-- Level 2
('Science', 'Biology', 'How many chromosomes do humans have?', '23', '46', '42', '48', 'B', 2, 15, 'Humans have 23 pairs = 46 chromosomes'),
('Science', 'Physics', 'Speed of light in vacuum (approx)?', '300,000 km/s', '150,000 km/s', '500,000 km/s', '100,000 km/s', 'A', 2, 15, 'Light travels at ~3×10⁸ m/s'),
('Science', 'Chemistry', 'What is the pH of neutral water?', '0', '7', '14', '1', 'B', 2, 15, 'Neutral pH = 7'),

-- Level 3
('Science', 'Biology', 'Process of plants making food?', 'Respiration', 'Photosynthesis', 'Digestion', 'Fermentation', 'B', 3, 20, 'Photosynthesis converts sunlight to glucose'),
('Science', 'Physics', 'F = ma is which law?', 'First', 'Second', 'Third', 'Zeroth', 'B', 3, 20, 'Newtons Second Law of Motion'),
('Science', 'Chemistry', 'Number of electrons in Carbon?', '4', '6', '8', '12', 'B', 3, 20, 'Carbon has atomic number 6'),

-- Level 4
('Science', 'Biology', 'What enzyme breaks down starch?', 'Pepsin', 'Lipase', 'Amylase', 'Trypsin', 'C', 4, 25, 'Amylase breaks starch into sugars'),
('Science', 'Physics', 'Unit of electrical resistance?', 'Volt', 'Ampere', 'Ohm', 'Watt', 'C', 4, 25, 'Resistance is measured in Ohms'),
('Science', 'Chemistry', 'What is Avogadros number?', '6.022×10²³', '3.14×10²²', '9.8×10²⁴', '1.6×10¹⁹', 'A', 4, 25, 'Avogadros number = 6.022×10²³'),

-- Level 5
('Science', 'Biology', 'What is the Krebs cycle also called?', 'Calvin Cycle', 'Citric Acid Cycle', 'Glycolysis', 'Electron Transport', 'B', 5, 30, 'Krebs cycle = Citric acid cycle'),
('Science', 'Physics', 'Heisenberg Uncertainty Principle relates to?', 'Energy-Time', 'Position-Momentum', 'Mass-Velocity', 'Force-Acceleration', 'B', 5, 30, 'Cannot know both position and momentum precisely'),
('Science', 'Chemistry', 'What is the hybridization of methane?', 'sp', 'sp²', 'sp³', 'sp³d', 'C', 5, 30, 'Methane (CH4) has sp³ hybridization');

-- Insert Sample Questions - Programming
INSERT INTO questions (subject, topic, question_text, option_a, option_b, option_c, option_d, correct_option, difficulty_level, points, explanation) VALUES
-- Level 1
('Programming', 'Basics', 'What does HTML stand for?', 'Hyper Text Markup Language', 'High Tech Modern Language', 'Hyper Transfer Markup Language', 'Home Tool Markup Language', 'A', 1, 10, 'HTML = Hyper Text Markup Language'),
('Programming', 'Basics', 'Which is not a programming language?', 'Java', 'Python', 'HTML', 'C++', 'C', 1, 10, 'HTML is a markup language, not programming'),
('Programming', 'Basics', 'What symbol starts a comment in Python?', '//', '#', '/*', '--', 'B', 1, 10, 'Python uses # for single-line comments'),

-- Level 2
('Programming', 'Data Types', 'Which stores true/false in Java?', 'int', 'String', 'boolean', 'char', 'C', 2, 15, 'boolean stores true or false values'),
('Programming', 'Arrays', 'First index of an array in most languages?', '1', '0', '-1', 'Depends', 'B', 2, 15, 'Most languages use 0-based indexing'),
('Programming', 'Loops', 'Which loop runs at least once?', 'for', 'while', 'do-while', 'foreach', 'C', 2, 15, 'do-while checks condition after first run'),

-- Level 3
('Programming', 'OOP', 'What is encapsulation?', 'Inheritance', 'Data hiding', 'Polymorphism', 'Abstraction', 'B', 3, 20, 'Encapsulation = bundling data and methods, hiding internals'),
('Programming', 'Algorithms', 'Time complexity of binary search?', 'O(n)', 'O(log n)', 'O(n²)', 'O(1)', 'B', 3, 20, 'Binary search divides in half each time'),
('Programming', 'SQL', 'Which retrieves data from database?', 'INSERT', 'UPDATE', 'SELECT', 'DELETE', 'C', 3, 20, 'SELECT is used to query/retrieve data'),

-- Level 4
('Programming', 'Data Structures', 'LIFO principle applies to?', 'Queue', 'Stack', 'Tree', 'Graph', 'B', 4, 25, 'Stack = Last In First Out'),
('Programming', 'OOP', 'Method with same name, different params?', 'Overriding', 'Overloading', 'Polymorphism', 'Inheritance', 'B', 4, 25, 'Overloading = same name, different parameters'),
('Programming', 'Design Patterns', 'Singleton pattern ensures?', 'Multiple instances', 'One instance', 'No instance', 'Abstract instance', 'B', 4, 25, 'Singleton ensures only one instance exists'),

-- Level 5
('Programming', 'Algorithms', 'Dijkstras algorithm finds?', 'Minimum Spanning Tree', 'Shortest Path', 'Maximum Flow', 'Topological Sort', 'B', 5, 30, 'Dijkstra finds shortest path in weighted graph'),
('Programming', 'Complexity', 'Best case of QuickSort?', 'O(n)', 'O(n log n)', 'O(n²)', 'O(log n)', 'B', 5, 30, 'QuickSort best/average = O(n log n)'),
('Programming', 'Systems', 'What is deadlock?', 'Fast execution', 'Circular waiting', 'Memory leak', 'Stack overflow', 'B', 5, 30, 'Deadlock = circular wait for resources');

-- Insert Sample Progress Data
INSERT INTO user_progress (user_id, subject, current_level, questions_attempted, correct_answers, accuracy_rate) VALUES
(2, 'Mathematics', 2, 25, 18, 72.00),
(2, 'Science', 2, 15, 12, 80.00),
(3, 'Mathematics', 3, 45, 38, 84.44),
(3, 'Programming', 3, 30, 24, 80.00),
(4, 'Mathematics', 1, 10, 5, 50.00),
(5, 'Mathematics', 4, 80, 72, 90.00),
(5, 'Science', 4, 60, 51, 85.00),
(5, 'Programming', 3, 40, 32, 80.00);

-- Insert Sample Quiz Attempts
INSERT INTO quiz_attempts (user_id, question_id, selected_option, is_correct, response_time_seconds, difficulty_at_attempt, points_earned) VALUES
(2, 1, 'A', TRUE, 5, 1, 10),
(2, 2, 'B', TRUE, 8, 1, 10),
(2, 4, 'B', TRUE, 12, 2, 15),
(3, 7, 'A', TRUE, 15, 3, 20),
(3, 10, 'A', TRUE, 25, 4, 25),
(5, 13, 'B', TRUE, 30, 5, 30);
