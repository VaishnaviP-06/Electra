<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Elective Details | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/electives.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body class="electives-page">
    <div class="app-layout">
        <jsp:include page="/WEB-INF/partials/sidebar.jsp">
            <jsp:param name="active" value="electives"/>
        </jsp:include>
        <main class="main-content">
    <div class="container detail-container">
        <a href="electives" class="back-link">
            <span aria-hidden="true">←</span> Back to all electives
        </a>
        <div id="electiveDetail">
            <div class="detail-loading">
                Loading elective details...
            </div>
        </div>
    </div>
    <footer class="electra-footer">
        <div class="container">
            <span>Electra</span>
            <p>The Right Choice. The Right Future.</p>
            <small>Departmental Elective Allocation System</small>
        </div>
    </footer>
        </main>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="assets/js/electives.js"></script>
</body>
</html>
