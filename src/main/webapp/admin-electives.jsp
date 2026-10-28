<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Electives | Electra</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">

    <style>
            .page-content {
            padding-bottom: 32px;
        }

        .page-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 28px;
        }

        .page-heading h1 {
            margin-bottom: 8px;
        }

        .page-heading p {
            max-width: 650px;
            margin-bottom: 0;
        }

        .surface {
            margin-bottom: 24px;
        }

        .required {
            color: #b54735;
        }

        .form-hint {
            font-size: 0.85rem;
            color: #786f66;
        }

        @media (max-width: 768px) {
            .page-heading {
                align-items: flex-start;
                flex-direction: column;
            }
        }
    </style>
</head>

<body class="admin-page">

<div class="app-layout">

    <!-- SIDEBAR -->
    <jsp:include page="/WEB-INF/partials/sidebar.jsp">
        <jsp:param name="active" value="manage-electives"/>
    </jsp:include>

    <!-- MAIN CONTENT -->
    <main class="main-content">

        <header class="topbar">
            <div>
                <div class="topbar-label">ELECTRA / ADMINISTRATION</div>
                <div class="topbar-title">Manage Electives</div>
            </div>

            <span class="academic-year">Academic Year 2026–27</span>
        </header>

        <section class="page-content">

            <div class="page-heading">
                <div>
                    <div class="eyebrow">ADMIN WORKSPACE</div>
                    <h1>Elective Catalogue</h1>
                    <p>
                        Manage elective subjects, allocation forms, seat capacity
                        and minimum eligibility requirements.
                    </p>
                </div>

                <a class="btn btn-outline-secondary" href="admin.jsp">
                    ← Overview
                </a>
            </div>

            <!-- ADD ELECTIVE -->
            <section class="surface">

                <h2 class="h5 mb-4">Add an Elective</h2>

                <form id="electiveForm" class="row g-3">

                    <div class="col-md-4">
                        <label class="form-label" for="electiveCode">
                            Course Code <span class="required">*</span>
                        </label>

                        <input
                            class="form-control"
                            id="electiveCode"
                            name="electiveCode"
                            required
                            placeholder="e.g. CSE-401">
                    </div>

                    <div class="col-md-8">
                        <label class="form-label" for="electiveName">
                            Elective Title <span class="required">*</span>
                        </label>

                        <input
                            class="form-control"
                            id="electiveName"
                            name="electiveName"
                            required
                            placeholder="Enter elective name">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label" for="electiveFormType">
                            Allocation Form
                        </label>

                        <select class="form-select" id="electiveFormType">
                            <option>Departmental Elective</option>
                            <option>Open Elective</option>
                            <option>Professional Elective</option>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label" for="seatCapacity">
                            Seat Capacity
                        </label>

                        <input
                            class="form-control"
                            type="number"
                            id="seatCapacity"
                            min="1"
                            required
                            placeholder="e.g. 60">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label" for="minimumCgpa">
                            Minimum CGPA
                        </label>

                        <input
                            class="form-control"
                            type="number"
                            id="minimumCgpa"
                            min="0"
                            max="10"
                            step="0.01"
                            value="0">
                    </div>

                    <div class="col-12">
                        <label class="form-label" for="electiveDescription">
                            Description
                        </label>

                        <textarea
                            class="form-control"
                            id="electiveDescription"
                            rows="3"
                            placeholder="Briefly describe the elective"></textarea>
                    </div>

                    <div class="col-12 d-flex gap-2">
                        <button class="btn btn-primary" type="submit">
                            Save Elective
                        </button>

                        <button class="btn btn-outline-secondary" type="reset">
                            Clear Form
                        </button>
                    </div>

                    <p class="form-hint mb-0">
                        Database persistence must be connected through the
                        appropriate servlet and DAO.
                    </p>

                </form>
            </section>

            <!-- ELECTIVE TABLE -->
            <section class="surface">

                <div class="toolbar mb-3">
                    <div>
                        <h2 class="h5 mb-1">Current Electives</h2>
                        <p class="form-hint mb-0">
                            Search and review the elective catalogue.
                        </p>
                    </div>

                    <input
                        class="form-control"
                        id="electiveSearch"
                        style="max-width: 280px;"
                        placeholder="Search electives"
                        aria-label="Search electives">
                </div>

                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Elective</th>
                                <th>Form</th>
                                <th>Capacity</th>
                                <th>Min. CGPA</th>
                                <th>Status</th>
                            </tr>
                        </thead>

                        <tbody id="electiveRows">
                            <tr>
                                <td colspan="6">
                                    <div class="empty-state">
                                        <strong>No electives loaded</strong>
                                        <p class="mb-0">
                                            Elective records will appear here
                                            when connected to the data source.
                                        </p>
                                    </div>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

            </section>

            <footer class="app-footer">
                Electra · Departmental Elective Allocation System
            </footer>

        </section>
    </main>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="assets/js/admin.js"></script>

</body>
</html>