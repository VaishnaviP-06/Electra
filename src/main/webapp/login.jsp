<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Electra Academic Portal</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@600;700&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
          rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/login.css?v=7">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body class="electra-login-page">
<div class="login-layout">
    <aside class="brand-panel">
        <a href="index.jsp" class="brand-header">
            <div class="brand-icon">E</div>
            <div>
                <div class="brand-name">Electra</div>
                <div class="brand-subtitle">Department Portal</div>
            </div>
        </a>
        <div class="brand-content">
            <div class="eyebrow">
                <span class="eyebrow-line"></span>
                ACADEMIC ELECTIVE ALLOCATION
            </div>
            <h1>
                The right choice.<br>
                <span>The right future.</span>
            </h1>
            <p class="brand-description">
                A smarter, simpler way to explore departmental electives,
                submit your preferences and access allocation results.
            </p>
            <div class="feature-grid">
                <div class="feature-item">
                    <div class="feature-icon">01</div>
                    <div>
                        <strong>Preference-based selection</strong>
                        <small>Rank electives according to your interests</small>
                    </div>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">02</div>
                    <div>
                        <strong>Merit-based allocation</strong>
                        <small>A structured and consistent process</small>
                    </div>
                </div>
                <div class="feature-item">
                    <div class="feature-icon">03</div>
                    <div>
                        <strong>Transparent results</strong>
                        <small>Access your published allocation status</small>
                    </div>
                </div>
            </div>
            <div class="brand-quote">
                Your electives.<br>
                <em>Your path.</em>
            </div>
        </div>
        <div class="brand-bottom">
            <span>✦</span>
            <span>Better choices. Brighter futures.</span>
        </div>
    </aside>
    <main class="login-panel">
        <div class="top-slogan">
            BETTER CHOICES <span>✦</span> BRIGHTER FUTURES
        </div>
        <section class="login-container" aria-labelledby="loginTitle">
            <div class="mobile-brand">
                <div class="brand-icon">E</div>
                <div>
                    <div class="brand-name">Electra</div>
                    <div class="brand-subtitle">Department Portal</div>
                </div>
            </div>
            <div class="card-header">
                <span class="welcome-badge">WELCOME BACK</span>
                <h2 class="login-title" id="loginTitle">
                    Sign in to Electra
                </h2>
                <p class="login-description" id="cardSubtitle">
                    Access your academic portal and manage your elective
                    preferences, submissions and results.
                </p>
            </div>
            <div class="role-switcher"
                 role="group"
                 aria-label="Choose account type">
                <button
                    type="button"
                    class="role-btn active"
                    id="studentBtn"
                    aria-pressed="true"
                    onclick="switchRole('student')">
                    <span aria-hidden="true">♟</span>
                    Student
                </button>
                <button
                    type="button"
                    class="role-btn"
                    id="adminBtn"
                    aria-pressed="false"
                    onclick="switchRole('admin')">
                    <span aria-hidden="true">♙</span>
                    Administrator
                </button>
            </div>
            <% if (request.getAttribute("loginError") != null) { String loginError = String.valueOf(request.getAttribute("loginError")).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;"); %>
            <div class="alert alert-danger" role="alert"><%= loginError %></div>
            <% } %>
            <form id="loginForm" action="${pageContext.request.contextPath}/login" method="post" novalidate>
                <input
                    type="hidden"
                    id="role"
                    name="role"
                    value="student">
                <div class="field-group">
                    <label
                        for="userId"
                        class="form-label"
                        id="idLabel">
                        Student Email ID <span>*</span>
                    </label>
                    <div class="input-wrap">
                        <span class="input-symbol" aria-hidden="true">
                            ✉
                        </span>
                        <input
                            type="email"
                            id="userId"
                            name="userId"
                            class="form-control"
                            placeholder="Enter your student email ID"
                            autocomplete="username"
                            required>
                        <div
                            id="userIdError"
                            class="field-error"
                            aria-live="polite">
                        </div>
                    </div>
                </div>
                <div class="field-group">
                    <label for="password" class="form-label">
                        Password <span>*</span>
                    </label>
                    <div class="input-wrap password-wrap">
                        <span class="input-symbol" aria-hidden="true">
                            ▣
                        </span>
                        <input
                            type="password"
                            id="password"
                            name="password"
                            class="form-control"
                            placeholder="Enter your password"
                            autocomplete="current-password"
                            required>
                            <button
                                type="button"
                                id="togglePassword"
                                class="toggle-password"
                                aria-label="Show password">
                                Show
                            </button>
                            </div>
                            <div
                                id="passwordError"
                                class="field-error"
                                aria-live="polite">
                            </div>
                </div>
                <div class="login-options">
                    <label class="remember-label">
                        <input
                            type="checkbox"
                            id="rememberMe"
                            name="rememberMe">
                        <span>Remember me</span>
                    </label>
                    <a href="#" id="forgotLink">
                        Forgot password?
                    </a>
                </div>
                <button type="submit" class="login-button">
                    <span>Sign in to Electra</span>
                    <span aria-hidden="true">→</span>
                </button>
                <div
                    id="loginMessage"
                    class="alert mt-3 d-none"
                    role="alert"
                    aria-live="polite">
                </div>
            </form>
            <div class="security-note">
                <div class="security-icon">✓</div>
                <div>
                    <strong>Secure access</strong>
                    <p>
                        Your academic information is for authorized users only.
                    </p>
                </div>
            </div>
        </section>
    </main>
</div>
<div
    class="modal-overlay"
    id="forgotModal"
    aria-hidden="true">
    <div
        class="modal-box"
        role="dialog"
        aria-modal="true"
        aria-labelledby="modalTitle">
        <div class="modal-icon">✦</div>
        <h3 class="modal-title" id="modalTitle">
            Password recovery
        </h3>
        <p class="modal-desc">
            Please contact your department administrator or academic
            coordinator to reset your login credentials.
        </p>
        <button
            type="button"
            class="modal-close"
            id="closeForgotModal">
            Understood
        </button>
    </div>
</div>
<script src="assets/js/login.js?v=7"></script>
</body>
</html>