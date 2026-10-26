<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/dashboard.css">
</head>
<body>
<div class="app-layout">
    <aside class="sidebar">
        <a href="dashboard.jsp" class="sidebar-brand">
            <span class="sidebar-logo">E</span>
            <span>
                <strong>Electra</strong>
                <small>Department Portal</small>
            </span>
        </a>
        <div class="sidebar-label">WORKSPACE</div>
        <nav class="sidebar-nav">
            <a href="dashboard.jsp" class="nav-link active">
                <span class="nav-icon">&#9632;</span> Dashboard
            </a>
            <a href="electives.jsp" class="nav-link" id="electivesLink">
                <span class="nav-icon">&#9776;</span> View Electives
            </a>
            <a href="preferences.jsp" class="nav-link" id="preferencesLink">
                <span class="nav-icon">&#8645;</span> My Preferences
            </a>
            <a href="allocation-results.jsp" class="nav-link" id="allocationLink">
                <span class="nav-icon">&#10003;</span> My Allocation
            </a>
            <div id="adminNavigation" class="d-none">
                <div class="sidebar-label">ADMINISTRATION</div>
                <a href="admin-students.jsp" class="nav-link">
                    <span class="nav-icon">&#9787;</span> Manage Students
                </a>
                <a href="admin-electives.jsp" class="nav-link">
                    <span class="nav-icon">&#9776;</span> Manage Electives
                </a>
                <a href="admin-allocations.jsp" class="nav-link">
                    <span class="nav-icon">&#9881;</span> Allocation Settings
                </a>
                <a href="reports.jsp" class="nav-link">
                    <span class="nav-icon">&#9636;</span> Allocation Reports
                </a>
            </div>
        </nav>
        <div class="sidebar-bottom">
            <div class="sidebar-user">
                <div class="avatar" id="userAvatar">U</div>
                <div class="user-details">
                    <strong id="sidebarUser">Demo User</strong>
                    <small id="sidebarRole">Student</small>
                </div>
            </div>
            <button class="logout-button" id="logoutButton">
                &#8592; Sign Out
            </button>
        </div>
    </aside>
    <main class="main-content">
        <header class="topbar">
            <div>
                <div class="topbar-label">ACADEMIC WORKSPACE</div>
                <div class="topbar-title" id="pageTitle">Dashboard</div>
            </div>
            <div class="topbar-right">
                <span class="status-dot"></span>
                <span class="academic-year">Academic Year 2026–27</span>
            </div>
        </header>
        <section class="page-content">
            <div class="welcome-section">
                <div>
                    <div class="eyebrow">YOUR WORKSPACE</div>
                    <h1 id="welcomeTitle">Welcome back!</h1>
                    <p id="welcomeDescription">
                        Here is an overview of your elective allocation.
                    </p>
                </div>
                <div class="welcome-mark">E.</div>
            </div>
            <div class="alert-banner">
                <div class="alert-symbol">&#9432;</div>
                <div>
                    <strong id="noticeTitle">Preference submission</strong>
                    <p id="noticeText">
                        Check the available electives and submit your preferences
                        before the deadline.
                    </p>
                </div>
            </div>
            <div class="section-heading">
                <div>
                    <h2>Overview</h2>
                    <p>Your academic allocation at a glance.</p>
                </div>
            </div>
            <div class="stats-grid">
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Available Electives</span>
                        <span class="stat-icon icon-sand">&#9776;</span>
                    </div>
                    <div class="stat-number" id="electiveCount">06</div>
                    <div class="stat-caption">Subjects offered this semester</div>
                </article>
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Preferences</span>
                        <span class="stat-icon icon-terracotta">&#8645;</span>
                    </div>
                    <div class="stat-number" id="preferenceCount">00 / 03</div>
                    <div class="stat-caption" id="preferenceCaption">
                        Ranked choices submitted
                    </div>
                </article>
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Allocation Status</span>
                        <span class="stat-icon icon-sage">&#10003;</span>
                    </div>
                    <div class="stat-number stat-status" id="allocationStatus">
                        Pending
                    </div>
                    <div class="stat-caption" id="allocationCaption">
                        Final results not published
                    </div>
                </article>
            </div>
            <div class="section-heading section-heading-spaced">
                <div>
                    <h2 id="quickActionsTitle">Quick Actions</h2>
                    <p id="quickActionsDescription">
                        Continue with your elective selection.
                    </p>
                </div>
            </div>
            <div class="actions-grid" id="actionsGrid">
                <a href="electives.jsp" class="action-card">
                    <div class="action-icon icon-sand">&#9776;</div>
                    <h3>Explore Electives</h3>
                    <p>Review subjects, syllabi, faculty and seat availability.</p>
                    <span class="action-link">View subjects &#8594;</span>
                </a>
                <a href="preferences.jsp" class="action-card">
                    <div class="action-icon icon-terracotta">&#8645;</div>
                    <h3>Submit Preferences</h3>
                    <p>Rank your top three elective choices.</p>
                    <span class="action-link">Choose preferences &#8594;</span>
                </a>
                <a href="allocation-results.jsp" class="action-card">
                    <div class="action-icon icon-sage">&#10003;</div>
                    <h3>View Allocation</h3>
                    <p>Check your final assigned elective when results are released.</p>
                    <span class="action-link">View status &#8594;</span>
                </a>
            </div>
            <footer class="page-footer">
                <span>Electra</span> · Departmental Elective Allocation System
                <span class="footer-year">2026–27</span>
            </footer>
        </section>
    </main>
</div>
<script src="assets/js/dashboard.js"></script>
</body>
</html>