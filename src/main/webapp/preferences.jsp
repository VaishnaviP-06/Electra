
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Preferences | Electra</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/forms.css">
</head>

<body class="electra-form-page">

    <nav class="navbar navbar-expand-lg electra-navbar">
        <div class="container">
            <a class="navbar-brand electra-brand" href="dashboard.jsp">
                <span class="brand-symbol">E.</span> Electra
            </a>

            <button class="navbar-toggler" type="button"
                    data-bs-toggle="collapse" data-bs-target="#mainNavbar"
                    aria-controls="mainNavbar" aria-expanded="false"
                    aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>

            <div class="collapse navbar-collapse" id="mainNavbar">
                <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-3">
                    <li class="nav-item">
                        <a class="nav-link" href="dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="electives.jsp">Electives</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="preferences.jsp">My Preferences</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="allocation-results.jsp">Results</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-electra" href="profile.jsp">My Profile</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <main class="container form-page-container">

        <div class="page-intro">
            <span class="eyebrow">YOUR FUTURE, YOUR CHOICE</span>
            <h1>Rank your <em>preferences.</em></h1>
            <p>
                Choose up to three electives in the order you prefer them.
                Your first choice will be considered your highest priority.
            </p>
        </div>

        <div class="form-notice">
            <span class="notice-symbol">i</span>
            <div>
                <strong>Before you begin</strong>
                <p>
                    Select different electives for each rank. You can choose
                    fewer than three, but you must select at least one.
                    These selections are currently saved in this browser only.
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

                    <div class="preference-field">
                        <label for="preference1">
                            <span class="rank-number">01</span>
                            First preference
                            <span class="required-label">Required</span>
                        </label>
                        <select id="preference1" class="form-select preference-select" required>
                            <option value="">Choose your first preference</option>
                        </select>
                        <small>Your most preferred elective.</small>
                    </div>

                    <div class="preference-field">
                        <label for="preference2">
                            <span class="rank-number">02</span>
                            Second preference
                            <span class="optional-label">Optional</span>
                        </label>
                        <select id="preference2" class="form-select preference-select">
                            <option value="">Choose your second preference</option>
                        </select>
                        <small>Your alternative if the first choice is unavailable.</small>
                    </div>

                    <div class="preference-field">
                        <label for="preference3">
                            <span class="rank-number">03</span>
                            Third preference
                            <span class="optional-label">Optional</span>
                        </label>
                        <select id="preference3" class="form-select preference-select">
                            <option value="">Choose your third preference</option>
                        </select>
                        <small>Your additional alternative.</small>
                    </div>

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
                    <p id="preferenceProgressText">0 of 3 preferences selected</p>

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
    </main>

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
