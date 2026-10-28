<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/dashboard.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body data-user-id="${sessionScope.userId}" data-role="${sessionScope.role}">
<div class="app-layout">
    <jsp:include page="/WEB-INF/partials/sidebar.jsp">
        <jsp:param name="active" value="dashboard"/>
    </jsp:include>
    <main class="main-content">
        <header class="topbar">
            <div>
                <div class="topbar-label">Academic Workspace</div>
                <div class="topbar-title" id="pageTitle">Dashboard</div>
            </div>
            <div class="topbar-right">
                <span class="status-dot"></span>
                <span class="academic-year">Academic Year 2026–27</span>
            </div>
        </header>
        <section class="page-content">
            <div class="welcome-section">
                <div class="eyebrow">Your workspace</div>
                <h1 id="welcomeTitle">Welcome back!</h1>
                <p id="welcomeDescription">
                    Here is an overview of your elective allocation.
                </p>
            </div>
            <div class="alert-banner" role="status">
                <svg class="icon alert-symbol" aria-hidden="true" focusable="false"><use href="#i-info"/></svg>
                <div>
                    <strong id="noticeTitle">Preference submission</strong>
                    <p id="noticeText">
                        Review the available electives, then rank all of them in order of
                        preference before the deadline.
                    </p>
                </div>
            </div>
            <div class="section-heading">
                <h2>Overview</h2>
                <p>Your academic allocation at a glance.</p>
            </div>
            <div class="stats-grid">
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Available Electives</span>
                        <span class="stat-icon icon-sand"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-book"/></svg></span>
                    </div>
                    <div class="stat-number" id="electiveCount">—</div>
                    <div class="stat-caption">Subjects offered this semester</div>
                </article>
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Preferences</span>
                        <span class="stat-icon icon-terracotta"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-rank"/></svg></span>
                    </div>
                    <div class="stat-number" id="preferenceCount">—</div>
                    <div class="stat-caption" id="preferenceCaption">Rank every available elective</div>
                </article>
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Allocation Status</span>
                        <span class="stat-icon icon-sage"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-check"/></svg></span>
                    </div>
                    <div class="stat-number stat-status" id="allocationStatus">Pending</div>
                    <div class="stat-caption" id="allocationCaption">Final results not published</div>
                </article>
            </div>
            <div class="section-heading section-heading-spaced">
                <h2 id="quickActionsTitle">Quick Actions</h2>
                <p id="quickActionsDescription">
                    Continue with your elective selection.
                </p>
            </div>
            <div class="actions-grid" id="actionsGrid">
                <a href="electives.jsp" class="action-card">
                    <div class="action-icon icon-sand"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-book"/></svg></div>
                    <h3>Explore Electives</h3>
                    <p>Review subjects, syllabi, faculty and seat availability.</p>
                    <span class="action-link">View subjects <svg class="icon icon-sm" aria-hidden="true" focusable="false"><use href="#i-arrow"/></svg></span>
                </a>
                <a href="preferences.jsp" class="action-card">
                    <div class="action-icon icon-terracotta"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-rank"/></svg></div>
                    <h3>Rank Preferences</h3>
                    <p>Rank all available electives from most to least preferred.</p>
                    <span class="action-link">Rank electives <svg class="icon icon-sm" aria-hidden="true" focusable="false"><use href="#i-arrow"/></svg></span>
                </a>
                <a href="allocation-results.jsp" class="action-card">
                    <div class="action-icon icon-sage"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-check"/></svg></div>
                    <h3>View Allocation</h3>
                    <p>Check your final assigned elective when results are released.</p>
                    <span class="action-link">View status <svg class="icon icon-sm" aria-hidden="true" focusable="false"><use href="#i-arrow"/></svg></span>
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
