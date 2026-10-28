<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/dashboard.css">
    <link rel="stylesheet" href="assets/css/admin.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body data-user-id="${sessionScope.userId}"
      data-role="${sessionScope.role}">
<div class="app-layout">
    <!-- SIDEBAR -->
    <jsp:include page="/WEB-INF/partials/sidebar.jsp">
        <jsp:param name="active" value="overview"/>
    </jsp:include>
    <!-- MAIN CONTENT -->
    <main class="main-content">
        <!-- TOPBAR -->
        <header class="topbar">
            <div>
                <div class="topbar-label">Academic Workspace</div>
                <div class="topbar-title">Admin Panel</div>
            </div>
            <div class="topbar-right">
                <span class="status-dot"></span>
                <span class="academic-year">Academic Year 2026–27</span>
            </div>
        </header>
        <section class="page-content">
            <!-- WELCOME SECTION -->
            <div class="welcome-section">
                <div class="eyebrow">Administration</div>
                <h1>Elective Management</h1>
                <p>
                    Manage departmental electives, maintain the elective
                    catalogue, and review available seat capacity.
                </p>
            </div>
            <!-- MESSAGE -->
            <div id="adminMessage"
                 class="alert d-none mt-4"
                 role="alert"
                 aria-live="polite">
            </div>
            <!-- ADMINISTRATIVE TOOLS -->
            <section class="admin-toolbar mt-4 mb-4">
                <div>
                    <h2 class="section-title">Administrative Tools</h2>
                    <p class="section-description">
                        Maintain and export the elective catalogue.
                    </p>
                </div>
                <div class="admin-toolbar-actions">
                    <button type="button"
                            class="btn btn-outline-secondary"
                            id="resetDemoData">
                        Reset Demo Electives
                    </button>
                    <button type="button"
                            class="btn btn-primary"
                            id="exportElectivesXml">
                        Export to XML
                    </button>
                </div>
            </section>
            <!-- OVERVIEW -->
            <div class="section-heading">
                <h2>Overview</h2>
                <p>Summary of the current elective catalogue.</p>
            </div>
            <div class="stats-grid admin-stats-grid">
                <!-- TOTAL ELECTIVES -->
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Total Electives</span>
                        <span class="stat-icon icon-sand">
                            <svg class="icon" aria-hidden="true">
                                <use href="#i-book"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-number" id="totalElectives">0</div>
                    <div class="stat-caption">
                        Electives in the catalogue
                    </div>
                </article>
                <!-- TOTAL SEATS -->
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Total Seats</span>
                        <span class="stat-icon icon-terracotta">
                            <svg class="icon" aria-hidden="true">
                                <use href="#i-users"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-number" id="totalSeats">0</div>
                    <div class="stat-caption">
                        Combined seat capacity
                    </div>
                </article>
            </div>
            <!-- ADD ELECTIVE -->
            <section class="admin-section">
                <div class="section-heading section-heading-spaced">
                    <h2>Add a New Elective</h2>
                    <p>
                        Enter the elective details and seat capacity.
                    </p>
                </div>
                <div class="admin-panel-card">
                    <form id="electiveForm">
                        <div class="row g-4">
                            <div class="col-md-6 col-xl-4">
                                <label for="electiveCode" class="form-label">
                                    Elective Code
                                </label>
                                <input type="text"
                                       id="electiveCode"
                                       class="form-control"
                                       placeholder="e.g. EC501"
                                       maxlength="15"
                                       required>
                            </div>
                            <div class="col-md-6 col-xl-4">
                                <label for="electiveName" class="form-label">
                                    Elective Name
                                </label>
                                <input type="text"
                                       id="electiveName"
                                       class="form-control"
                                       placeholder="e.g. Cloud Computing"
                                       maxlength="100"
                                       required>
                            </div>
                            <div class="col-md-6 col-xl-4">
                                <label for="electiveCategory" class="form-label">
                                    Category
                                </label>
                                <select id="electiveCategory"
                                        class="form-select"
                                        required>
                                    <option value="">Select category</option>
                                    <option value="Departmental">Departmental</option>
                                    <option value="Open Elective">Open Elective</option>
                                    <option value="Professional Elective">Professional Elective</option>
                                </select>
                            </div>
                            <div class="col-md-6 col-xl-4">
                                <label for="electiveSeats" class="form-label">
                                    Available Seats
                                </label>
                                <input type="number"
                                       id="electiveSeats"
                                       class="form-control"
                                       min="1"
                                       max="500"
                                       step="1"
                                       value="30"
                                       required>
                            </div>
                            <div class="col-12 col-xl-8">
                                <label for="electiveDescription" class="form-label">
                                    Short Description
                                </label>
                                <input type="text"
                                       id="electiveDescription"
                                       class="form-control"
                                       placeholder="Briefly describe the elective"
                                       maxlength="200">
                            </div>
                        </div>
                        <div class="admin-form-footer">
                            <p class="form-hint mb-0">
                                Verify the elective code and seat capacity
                                before adding the elective.
                            </p>
                            <button type="submit" class="btn btn-primary">
                                Add Elective
                            </button>
                        </div>
                    </form>
                </div>
            </section>
            <!-- MANAGE ELECTIVES -->
            <section class="admin-section">
                <div class="section-heading section-heading-spaced">
                    <h2>Manage Electives</h2>
                    <p>
                        Review elective details and remove entries
                        from the demonstration catalogue.
                    </p>
                </div>
                <div class="admin-panel-card">
                    <div class="admin-table-heading">
                        <div>
                            <h3>Elective Catalogue</h3>
                            <p>
                                Review subject details and seat capacity.
                            </p>
                        </div>
                    </div>
                    <div class="table-responsive admin-table-wrapper">
                        <table class="table align-middle admin-table">
                            <thead>
                                <tr>
                                    <th scope="col">Code</th>
                                    <th scope="col">Elective Name</th>
                                    <th scope="col">Category</th>
                                    <th scope="col">Seats</th>
                                    <th scope="col">Action</th>
                                </tr>
                            </thead>
                            <tbody id="electiveTableBody">
                                <tr>
                                    <td colspan="5"
                                        class="text-center text-muted py-4">
                                        Loading electives...
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
            <!-- DEMO DATA NOTICE -->
            <section class="alert-banner admin-demo-notice mt-4">
                <svg class="icon alert-symbol" aria-hidden="true">
                    <use href="#i-info"/>
                </svg>
                <div>
                    <strong>Demo Data Notice</strong>
                    <p>
                        Elective changes on this page are stored in this
                        browser only. They are not confirmed updates to
                        the college database.
                    </p>
                </div>
            </section>
            <!-- FOOTER -->
            <footer class="page-footer">
                <span>Electra</span>
                · Departmental Elective Allocation System
                <span class="footer-year">2026–27</span>
            </footer>
        </section>
    </main>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="assets/js/electives.js"></script>
<script src="assets/js/admin.js"></script>
</body>
</html>