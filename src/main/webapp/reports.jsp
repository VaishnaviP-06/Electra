<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Allocation Reports | Electra</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">

    <style>
            .page-heading {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            margin-bottom: 28px;
        }

        .page-heading p {
            max-width: 650px;
            margin-bottom: 0;
        }

        .metric-grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
            margin-bottom: 24px;
        }

        .metric {
            padding: 22px;
            background: #fff;
            border: 1px solid #eee4da;
            border-radius: 14px;
        }

        .metric span {
            display: block;
            color: #786f66;
            font-size: 0.9rem;
            margin-bottom: 8px;
        }

        .metric strong {
            font-size: 1.8rem;
            color: #4a231a;
        }

        .report-note {
            padding: 18px 20px;
            background: #f8f3ed;
            border: 1px solid #eee4da;
            border-radius: 12px;
            margin-bottom: 24px;
        }

        @media (max-width: 768px) {
            .page-heading {
                align-items: flex-start;
                flex-direction: column;
            }

            .metric-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body class="admin-page">

<div class="app-layout">

    <!-- SIDEBAR -->
    <jsp:include page="/WEB-INF/partials/sidebar.jsp">
        <jsp:param name="active" value="reports"/>
    </jsp:include>

    <!-- MAIN CONTENT -->
    <main class="main-content">

        <header class="topbar">
            <div>
                <div class="topbar-label">ELECTRA / ADMINISTRATION</div>
                <div class="topbar-title">Allocation Reports</div>
            </div>

            <span class="academic-year">Academic Year 2026–27</span>
        </header>

        <section class="page-content">

            <div class="page-heading">
                <div>
                    <div class="eyebrow">ADMIN WORKSPACE</div>
                    <h1>Allocation Reports</h1>
                    <p>
                        Review preference submissions, seat utilisation,
                        allocation status and elective enrolment.
                    </p>
                </div>

                <a class="btn btn-outline-secondary" href="admin.jsp">
                    ← Overview
                </a>
            </div>

            <!-- REPORT STATUS -->
            <div class="report-note">
                <strong>Reporting Information</strong>
                <p class="mb-0 mt-2">
                    Report figures depend on allocation and preference data.
                    Live report generation must be connected to the reporting
                    servlet and database.
                </p>
            </div>

            <!-- SUMMARY CARDS -->
            <div class="metric-grid">

                <div class="metric">
                    <span>Preference Submissions</span>
                    <strong id="reportPreferenceCount">—</strong>
                </div>

                <div class="metric">
                    <span>Seats Allocated</span>
                    <strong id="reportSeatsAllocated">—</strong>
                </div>

                <div class="metric">
                    <span>Below Minimum Enrolment</span>
                    <strong id="reportLowEnrolment">—</strong>
                </div>

            </div>

            <!-- EXPORT REPORT -->
            <section class="surface">

                <div class="mb-4">
                    <h2 class="h5 mb-1">Export Report</h2>
                    <p class="form-hint mb-0">
                        Choose an allocation form and export format.
                    </p>
                </div>

                <form class="row g-3" id="reportForm">

                    <div class="col-md-6">
                        <label class="form-label" for="reportFormId">
                            Allocation Form
                        </label>

                        <select class="form-select" id="reportFormId">
                            <option value="">Select a form</option>
                            <option value="OEC">Open Elective (OEC)</option>
                            <option value="DE">Departmental Elective</option>
                            <option value="PE">Professional Elective</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label" for="reportFormat">
                            Export Format
                        </label>

                        <select class="form-select" id="reportFormat">
                            <option value="csv">CSV</option>
                            <option value="xml">XML</option>
                        </select>
                    </div>

                    <div class="col-md-3 d-flex align-items-end">
                        <button
                            type="button"
                            class="btn btn-primary w-100"
                            id="prepareReportButton"
                            onclick="alert('Connect this export action to the report servlet.')">
                            Prepare Export
                        </button>
                    </div>

                </form>

                <!-- REPORT TABLE -->
                <div class="table-responsive mt-4">

                    <table class="table align-middle">

                        <thead>
                            <tr>
                                <th>Elective</th>
                                <th>Capacity</th>
                                <th>Allocated</th>
                                <th>Utilisation</th>
                                <th>Enrolment Status</th>
                            </tr>
                        </thead>

                        <tbody id="reportRows">
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <strong>No report data available</strong>
                                        <p class="mb-0">
                                            Run and publish an allocation to
                                            populate this report.
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