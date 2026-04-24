// ===================================
// ADAPTIVE LEARNING SYSTEM - JavaScript
// ===================================

// Toast Notification System
class ToastManager {
    constructor() {
        this.container = document.createElement('div');
        this.container.className = 'toast-container';
        document.body.appendChild(this.container);
    }

    show(message, type = 'info', duration = 4000) {
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const icons = {
            success: 'fas fa-check-circle',
            error: 'fas fa-times-circle',
            warning: 'fas fa-exclamation-triangle',
            info: 'fas fa-info-circle'
        };

        toast.innerHTML = `
            <i class="toast-icon ${icons[type]}"></i>
            <span class="toast-message">${message}</span>
            <button class="toast-close" onclick="this.parentElement.remove()">
                <i class="fas fa-times"></i>
            </button>
        `;

        this.container.appendChild(toast);

        setTimeout(() => {
            toast.style.animation = 'slideIn 0.3s ease reverse';
            setTimeout(() => toast.remove(), 300);
        }, duration);
    }
}

const toast = new ToastManager();

// Form Validation
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(email);
}

function validatePassword(password) {
    return password.length >= 6;
}

// Login Form Handler
function handleLogin(event) {
    event.preventDefault();
    
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    const submitBtn = event.target.querySelector('button[type="submit"]');
    
    if (!username || !password) {
        toast.show('Please fill in all fields', 'error');
        return;
    }

    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Signing in...';

    fetch('login', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `username=${encodeURIComponent(username)}&password=${encodeURIComponent(password)}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            toast.show('Login successful! Redirecting...', 'success');
            setTimeout(() => {
                window.location.href = data.redirect || 'dashboard';
            }, 1000);
        } else {
            toast.show(data.message || 'Login failed', 'error');
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Sign In';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        toast.show('Connection error. Please try again.', 'error');
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-sign-in-alt"></i> Sign In';
    });
}

// Register Form Handler
function handleRegister(event) {
    event.preventDefault();
    
    const fullName = document.getElementById('fullName').value.trim();
    const username = document.getElementById('username').value.trim();
    const email = document.getElementById('email').value.trim();
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    const submitBtn = event.target.querySelector('button[type="submit"]');

    // Validation
    if (!fullName || !username || !email || !password || !confirmPassword) {
        toast.show('Please fill in all fields', 'error');
        return;
    }

    if (!validateEmail(email)) {
        toast.show('Please enter a valid email address', 'error');
        return;
    }

    if (!validatePassword(password)) {
        toast.show('Password must be at least 6 characters', 'error');
        return;
    }

    if (password !== confirmPassword) {
        toast.show('Passwords do not match', 'error');
        return;
    }

    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Creating account...';

    fetch('register', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `fullName=${encodeURIComponent(fullName)}&username=${encodeURIComponent(username)}&email=${encodeURIComponent(email)}&password=${encodeURIComponent(password)}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            toast.show('Registration successful! Redirecting to login...', 'success');
            setTimeout(() => {
                window.location.href = 'login.html';
            }, 2000);
        } else {
            toast.show(data.message || 'Registration failed', 'error');
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-user-plus"></i> Create Account';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        toast.show('Connection error. Please try again.', 'error');
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-user-plus"></i> Create Account';
    });
}

// Quiz Timer
class QuizTimer {
    constructor(displayElement, onTimeout) {
        this.display = displayElement;
        this.onTimeout = onTimeout;
        this.seconds = 0;
        this.interval = null;
        this.startTime = null;
    }

    start() {
        this.startTime = Date.now();
        this.seconds = 0;
        this.interval = setInterval(() => {
            this.seconds++;
            this.updateDisplay();
        }, 1000);
    }

    stop() {
        if (this.interval) {
            clearInterval(this.interval);
            this.interval = null;
        }
        return this.seconds;
    }

    updateDisplay() {
        const minutes = Math.floor(this.seconds / 60);
        const secs = this.seconds % 60;
        this.display.textContent = `${minutes.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }

    getElapsedSeconds() {
        return this.seconds;
    }
}

// Quiz Handler
let quizTimer = null;
let selectedOption = null;
let isAnswerSubmitted = false;

function initQuiz() {
    const timerDisplay = document.getElementById('quizTimer');
    if (timerDisplay) {
        quizTimer = new QuizTimer(timerDisplay);
        quizTimer.start();
    }

    // Setup option click handlers
    document.querySelectorAll('.option-item').forEach(option => {
        option.addEventListener('click', () => selectOption(option));
    });
}

function selectOption(optionElement) {
    if (isAnswerSubmitted) return;

    // Remove selection from all options
    document.querySelectorAll('.option-item').forEach(opt => {
        opt.classList.remove('selected');
    });

    // Select clicked option
    optionElement.classList.add('selected');
    selectedOption = optionElement.dataset.option;

    // Enable submit button
    const submitBtn = document.getElementById('submitAnswerBtn');
    if (submitBtn) {
        submitBtn.disabled = false;
        submitBtn.classList.add('btn-glow');
    }
}

function submitAnswer() {
    if (!selectedOption || isAnswerSubmitted) return;

    const questionId = document.getElementById('questionId').value;
    const responseTime = quizTimer ? quizTimer.stop() : 30;
    const submitBtn = document.getElementById('submitAnswerBtn');

    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Checking...';
    isAnswerSubmitted = true;

    // Disable all options
    document.querySelectorAll('.option-item').forEach(opt => {
        opt.classList.add('disabled');
    });

    fetch('submitAnswer', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `questionId=${questionId}&selectedOption=${selectedOption}&responseTime=${responseTime}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            showResult(data);
        } else {
            toast.show(data.message || 'Error submitting answer', 'error');
            isAnswerSubmitted = false;
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="fas fa-check"></i> Submit Answer';
        }
    })
    .catch(error => {
        console.error('Error:', error);
        toast.show('Connection error. Please try again.', 'error');
        isAnswerSubmitted = false;
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-check"></i> Submit Answer';
    });
}

function showResult(data) {
    // Highlight correct/incorrect options
    document.querySelectorAll('.option-item').forEach(opt => {
        const optionLetter = opt.dataset.option;
        
        if (optionLetter === data.correctOption) {
            opt.classList.add('correct');
            opt.querySelector('.option-status').innerHTML = '<i class="fas fa-check"></i>';
        } else if (optionLetter === selectedOption && !data.isCorrect) {
            opt.classList.add('incorrect');
            opt.querySelector('.option-status').innerHTML = '<i class="fas fa-times"></i>';
        }
    });

    // Show result card
    const resultContainer = document.getElementById('resultContainer');
    resultContainer.innerHTML = `
        <div class="result-card ${data.isCorrect ? 'correct' : 'incorrect'}">
            <div class="result-header">
                <div class="result-icon">
                    <i class="fas fa-${data.isCorrect ? 'check' : 'times'}"></i>
                </div>
                <div>
                    <h3>${data.isCorrect ? 'Correct!' : 'Incorrect'}</h3>
                    <p class="result-points">+${data.pointsEarned} points</p>
                </div>
            </div>
            ${data.explanation ? `
                <div class="result-explanation">
                    <h4><i class="fas fa-lightbulb"></i> Explanation</h4>
                    <p>${data.explanation}</p>
                </div>
            ` : ''}
            ${data.adaptiveMessage ? `
                <div class="adaptive-message">
                    <i class="fas fa-chart-line"></i>
                    <span>${data.adaptiveMessage}</span>
                </div>
            ` : ''}
        </div>
    `;
    resultContainer.style.display = 'block';

    // Update difficulty badge
    const difficultyBadge = document.querySelector('.difficulty-badge');
    if (difficultyBadge && data.newLevel) {
        difficultyBadge.className = `difficulty-badge level-${data.newLevel}`;
        difficultyBadge.innerHTML = `<i class="fas fa-signal"></i> Level ${data.newLevel}`;
    }

    // Show next question button
    document.getElementById('submitAnswerBtn').style.display = 'none';
    document.getElementById('nextQuestionBtn').style.display = 'inline-flex';

    // Show toast
    toast.show(
        data.isCorrect ? `+${data.pointsEarned} points earned!` : 'Keep practicing!',
        data.isCorrect ? 'success' : 'warning'
    );
}

function nextQuestion() {
    const subject = document.getElementById('currentSubject').value;
    window.location.href = `quiz?subject=${encodeURIComponent(subject)}`;
}

function changeSubject(subject) {
    window.location.href = `quiz?subject=${encodeURIComponent(subject)}`;
}

// Admin Functions
function openAddQuestionModal() {
    document.getElementById('addQuestionModal').classList.add('active');
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('active');
}

function handleAddQuestion(event) {
    event.preventDefault();
    
    const formData = new FormData(event.target);
    const params = new URLSearchParams();
    params.append('action', 'addQuestion');
    
    for (let [key, value] of formData.entries()) {
        params.append(key, value);
    }

    const submitBtn = event.target.querySelector('button[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';

    fetch('admin', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: params.toString()
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            toast.show('Question added successfully!', 'success');
            closeModal('addQuestionModal');
            setTimeout(() => location.reload(), 1000);
        } else {
            toast.show(data.message || 'Failed to add question', 'error');
        }
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus"></i> Add Question';
    })
    .catch(error => {
        console.error('Error:', error);
        toast.show('Connection error', 'error');
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-plus"></i> Add Question';
    });
}

function deleteQuestion(questionId) {
    if (!confirm('Are you sure you want to delete this question?')) return;

    fetch('admin', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: `action=deleteQuestion&questionId=${questionId}`
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            toast.show('Question deleted successfully!', 'success');
            setTimeout(() => location.reload(), 1000);
        } else {
            toast.show(data.message || 'Failed to delete question', 'error');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        toast.show('Connection error', 'error');
    });
}

// Sidebar Toggle (Mobile)
function toggleSidebar() {
    document.querySelector('.sidebar').classList.toggle('open');
}

// Animated Counter
function animateCounter(element, target, duration = 2000) {
    const start = 0;
    const increment = target / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if (current >= target) {
            element.textContent = Math.round(target).toLocaleString();
            clearInterval(timer);
        } else {
            element.textContent = Math.round(current).toLocaleString();
        }
    }, 16);
}

// Initialize counters on page load
document.addEventListener('DOMContentLoaded', () => {
    // Animate stat counters
    document.querySelectorAll('[data-counter]').forEach(el => {
        const target = parseInt(el.dataset.counter);
        animateCounter(el, target);
    });

    // Initialize quiz if on quiz page
    if (document.getElementById('quizTimer')) {
        initQuiz();
    }

    // Close modal on outside click
    document.querySelectorAll('.modal-overlay').forEach(modal => {
        modal.addEventListener('click', (e) => {
            if (e.target === modal) {
                modal.classList.remove('active');
            }
        });
    });

    // Close modal on Escape key
    document.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay.active').forEach(modal => {
                modal.classList.remove('active');
            });
        }
    });
});

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function(e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Password visibility toggle
function togglePassword(inputId) {
    const input = document.getElementById(inputId);
    const icon = input.nextElementSibling.querySelector('i');
    
    if (input.type === 'password') {
        input.type = 'text';
        icon.classList.replace('fa-eye', 'fa-eye-slash');
    } else {
        input.type = 'password';
        icon.classList.replace('fa-eye-slash', 'fa-eye');
    }
}

// Subject hover effect
document.querySelectorAll('.subject-card').forEach(card => {
    card.addEventListener('mouseenter', () => {
        card.style.transform = 'translateY(-8px) scale(1.02)';
    });
    
    card.addEventListener('mouseleave', () => {
        card.style.transform = 'translateY(0) scale(1)';
    });
});

// Keyboard shortcuts
document.addEventListener('keydown', (e) => {
    // Quiz shortcuts
    if (document.getElementById('quizTimer') && !isAnswerSubmitted) {
        if (e.key >= '1' && e.key <= '4') {
            const optionIndex = parseInt(e.key) - 1;
            const options = document.querySelectorAll('.option-item');
            if (options[optionIndex]) {
                selectOption(options[optionIndex]);
            }
        }
        
        if (e.key === 'Enter' && selectedOption) {
            submitAnswer();
        }
    }
    
    // Next question shortcut
    if (e.key === 'Enter' && isAnswerSubmitted) {
        nextQuestion();
    }
});

// Progress bar animation
function animateProgressBar(element, targetWidth) {
    element.style.width = '0%';
    setTimeout(() => {
        element.style.width = targetWidth + '%';
    }, 100);
}

// Initialize progress bars
document.querySelectorAll('.progress-bar, .subject-progress-bar').forEach(bar => {
    const width = bar.style.width;
    bar.style.width = '0%';
    setTimeout(() => {
        bar.style.width = width;
    }, 500);
});

// Chart initialization (if using charts)
function initCharts() {
    // Performance chart placeholder
    const performanceChart = document.getElementById('performanceChart');
    if (performanceChart) {
        // Add chart library integration here if needed
    }
}

// Export functions for global access
window.handleLogin = handleLogin;
window.handleRegister = handleRegister;
window.submitAnswer = submitAnswer;
window.nextQuestion = nextQuestion;
window.changeSubject = changeSubject;
window.openAddQuestionModal = openAddQuestionModal;
window.closeModal = closeModal;
window.handleAddQuestion = handleAddQuestion;
window.deleteQuestion = deleteQuestion;
window.toggleSidebar = toggleSidebar;
window.togglePassword = togglePassword;
