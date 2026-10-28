<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Preferences | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/forms.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body class="electra-form-page">
    <div class="app-layout">
        <jsp:include page="/WEB-INF/partials/sidebar.jsp">
            <jsp:param name="active" value="preferences"/>
        </jsp:include>
        <main class="main-content">
    <div class="container form-page-container">
        <div class="page-intro">
            <span class="eyebrow">YOUR FUTURE, YOUR CHOICE</span>
            <h1>Rank your <em>preferences.</em></h1>
            <p>
                Rank all available electives from your highest to lowest preference.
                Your first choice is your highest priority.
            </p>
        </div>
        <div class="form-notice">
            <span class="notice-symbol">i</span>
            <div>
                <strong>Before you begin</strong>
                <p>
                    Rank each available elective once, in the order that best matches
                    your interests. These selections are currently saved in this browser only.
                </p>
            </div>
        </div>
        <div class="preference-layout">
            <section class="form-card">
                <div class="form-card-heading">
                    <span class="eyebrow">PREFERENCE FORM</span>
                    <h2>Your elective choices</h2>
                    <p>Arrange your choices from most preferred to least preferred.</p>
                </div>
                <form id="preferenceForm" novalidate>
                    <div class="student-summary">
                        <div class="student-avatar">S</div>
                        <div>
                            <strong id="studentName">Student Demo</strong>
                            <span id="studentId">Demo account · Frontend preview</span>
                        </div>
                        <span class="demo-tag">DEMO</span>
                    </div>
                    <div id="preferenceFields" aria-live="polite"></div>
                    <div id="validationMessage" class="form-feedback" role="alert" aria-live="polite"></div>
                    <div class="form-actions">
                        <button type="button" id="resetPreferences" class="btn btn-outline-electra">
                            Clear choices
                        </button>
                        <button type="submit" class="btn btn-electra">
                            Save preferences →
                        </button>
                    </div>
                </form>
            </section>
            <aside class="preference-sidebar">
                <section class="side-info-card">
                    <span class="eyebrow">YOUR PROGRESS</span>
                    <h3>Preference summary</h3>
                    <div class="progress-track">
                        <div id="preferenceProgress" class="progress-fill"></div>
                    </div>
                    <p id="preferenceProgressText">0 of 0 electives ranked</p>
                    <div id="preferenceSummary" class="summary-list">
                        <p class="summary-empty">Your selections will appear here.</p>
                    </div>
                </section>
                <section class="side-info-card deadline-card">
                    <span class="eyebrow">REMEMBER</span>
                    <h3>Choose thoughtfully.</h3>
                    <p>
                        Allocation will depend on the official rules,
                        eligibility requirements, merit criteria and available seats.
                    </p>
                    <a href="electives.jsp" class="text-link">
                        Explore all electives →
                    </a>
                </section>
                <section class="side-info-card">
                    <span class="eyebrow">NEED HELP?</span>
                    <h3>Not sure what to choose?</h3>
                    <p>Review the syllabus and course information before deciding.</p>
                    <a href="electives.jsp" class="btn btn-outline-electra w-100">
                        Browse electives
                    </a>
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
