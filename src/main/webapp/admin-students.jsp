<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Students | Electra</title>

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
        <jsp:param name="active" value="students"/>
    </jsp:include>

    <!-- MAIN CONTENT -->
    <main class="main-content">

        <header class="topbar">
            <div>
                <div class="topbar-label">ELECTRA / ADMINISTRATION</div>
                <div class="topbar-title">Manage Students</div>
            </div>

            <span class="academic-year">Academic Year 2026–27</span>
        </header>

        <section class="page-content">

            <div class="page-heading">
                <div>
                    <div class="eyebrow">ADMIN WORKSPACE</div>
                    <h1>Student Directory</h1>
                    <p>
                        Review student records, academic details and
                        eligibility for elective allocation.
                    </p>
                </div>

                <a class="btn btn-outline-secondary" href="admin.jsp">
                    ← Overview
                </a>
            </div>

            <!-- SUMMARY CARDS -->
            <div class="metric-grid">

                <div class="metric">
                    <span>Total Students</span>
                    <strong id="totalStudents">—</strong>
                </div>

                <div class="metric">
                    <span>Eligible Students</span>
                    <strong id="eligibleStudents">—</strong>
                </div>

                <div class="metric">
                    <span>Needs Review</span>
                    <strong id="studentsNeedsReview">—</strong>
                </div>

            </div>

            <!-- STUDENT DIRECTORY -->
            <section class="surface">

                <div class="toolbar mb-3">
                    <div>
                        <h2 class="h5 mb-1">Student Records</h2>
                        <p class="form-hint mb-0">
                            Search by roll number, name or email.
                        </p>
                    </div>

                    <div class="d-flex gap-2">
                        <input
                            id="studentSearch"
                            class="form-control"
                            placeholder="Search students"
                            aria-label="Search students">

                        <button
                            class="btn btn-primary"
                            type="button"
                            id="importStudentsButton"
                            onclick="alert('Connect this action to the student servlet to import records.')">
                            Import List
                        </button>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table align-middle">

                        <thead>
                            <tr>
                                <th>Roll Number</th>
                                <th>Student</th>
                                <th>Email</th>
                                <th>CGPA</th>
                                <th>Eligibility</th>
                            </tr>
                        </thead>

                        <tbody id="studentRows">
                            <tr>
                                <td colspan="5">
                                    <div class="empty-state">
                                        <strong>No student records loaded</strong>
                                        <p class="mb-0">
                                            Connect the student management
                                            servlet to display database records.
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