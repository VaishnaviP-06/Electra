
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Elective Details | Electra</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/electives.css">
</head>

<body class="electives-page">

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
                        <a class="nav-link active" href="electives.jsp">Electives</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="preferences.jsp">My Preferences</a>
                    </li>
                    <li class="nav-item">
                        <a class="btn btn-electra" href="profile.jsp">My Profile</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <main class="container detail-container">

        <a href="electives.jsp" class="back-link">
            <span aria-hidden="true">←</span> Back to all electives
        </a>

        <div id="electiveDetail">
            <div class="detail-loading">
                Loading elective details...
            </div>
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
</body>
</html>
