<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocation Results | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/forms.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body class="electra-form-page">
    <div class="app-layout">
        <jsp:include page="/WEB-INF/partials/sidebar.jsp">
            <jsp:param name="active" value="allocation"/>
        </jsp:include>
        <main class="main-content">
    <div class="container form-page-container">
        <div class="page-intro">
            <span class="eyebrow">ALLOCATION CENTRE</span>
            <h1>Your results, <em>in one place.</em></h1>
            <p>
                Review your saved preferences and check your allocation status.
                Final results will appear here after the administrator publishes them.
            </p>
        </div>
        <section class="result-status-card">
            <div class="status-icon" aria-hidden="true">◷</div>
            <div class="status-content">
                <span class="eyebrow">CURRENT STATUS</span>
                <h2 id="resultStatusHeading">Allocation pending</h2>
                <p id="resultStatusDescription">
                    Your final allocation has not been published yet.
                </p>
            </div>
            <span id="resultStatusBadge" class="status-badge pending">PENDING</span>
        </section>
        <div class="results-grid">
            <section class="form-card">
                <div class="form-card-heading">
                    <span class="eyebrow">YOUR SUBMISSION</span>
                    <h2>Saved preferences</h2>
                    <p>Your choices in their submitted priority order.</p>
                </div>
                <div id="savedPreferences" class="saved-preferences">
                    <p class="summary-empty">Loading your saved preferences...</p>
                </div>
                <div id="noPreferences" class="no-preferences" hidden>
                    <div class="empty-icon">⌕</div>
                    <h3>No preferences saved yet</h3>
                    <p>Explore the elective catalogue and submit your choices first.</p>
                    <a href="preferences.jsp" class="btn btn-electra">
                        Choose preferences →
                    </a>
                </div>
                <div id="resultActions" class="form-actions">
                    <a href="preferences.jsp" class="btn btn-outline-electra">
                        Review preferences
                    </a>
                    <a href="electives.jsp" class="btn btn-electra">
                        Browse electives
                    </a>
                </div>
            </section>
            <aside class="preference-sidebar">
                <section class="side-info-card">
                    <span class="eyebrow">ALLOCATION GUIDE</span>
                    <h3>What happens next?</h3>
                    <div class="timeline-step">
                        <span class="timeline-dot complete">✓</span>
                        <div>
                            <strong>Submit preferences</strong>
                            <p>Save your ranked elective choices.</p>
                        </div>
                    </div>
                    <div class="timeline-step">
                        <span class="timeline-dot">2</span>
                        <div>
                            <strong>Allocation processing</strong>
                            <p>The system checks eligibility, priority and seat availability.</p>
                        </div>
                    </div>
                    <div class="timeline-step">
                        <span class="timeline-dot">3</span>
                        <div>
                            <strong>Results published</strong>
                            <p>View your assigned elective after official publication.</p>
                        </div>
                    </div>
                </section>
                <section class="side-info-card">
                    <span class="eyebrow">PLEASE NOTE</span>
                    <h3>Demonstration mode</h3>
                    <p>
                        This page currently reads saved choices from this browser.
                        Official results require the backend and database.
                    </p>
                </section>
            </aside>
        </div>
    </div>
        </main>
    </div>
    <footer class="electra-footer">
        <div class="container">
            <span>Electra</span>
            <p>The Right Choice. The Right Future.</p>
            <small>Departmental Elective Allocation System</small>
        </div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="assets/js/electives.js"></script>
    <script src="assets/js/validation.js"></script>
    <script src="assets/js/preferences.js"></script>
</body>
</html>
