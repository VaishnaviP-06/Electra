<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Allocation Forms | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body class="admin-page">
    <div class="app-layout">
        <jsp:include page="/WEB-INF/partials/sidebar.jsp">
            <jsp:param name="active" value="allocations"/>
        </jsp:include>
        <main class="main-content">
            <header class="topbar">
                <div>
                    <div class="topbar-label">
                        ELECTRA / ADMINISTRATION
                    </div>
                    <div class="topbar-title">
                        Allocation Forms
                    </div>
                </div>
                <span class="academic-year">
                    Academic Year 2026–27
                </span>
            </header>
            <section class="page-content">
                <div class="page-heading">
                    <div>
                        <div class="eyebrow">
                            ADMIN WORKSPACE
                        </div>
                        <h1>Allocation forms &amp; settings</h1>
                        <p>
                            Each allocation form has its own deadline, preferences,
                            allocation run and publication status.
                        </p>
                    </div>
                    <a class="btn btn-outline-primary" href="admin.jsp">
                        ← Dashboard
                    </a>
                </div>
                <section class="surface mb-4">
                    <h2 class="h5 mb-3">
                        Create allocation form
                    </h2>
                    <form id="allocationForm" class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" for="formName">
                                Form name <span class="required">*</span>
                            </label>
                            <input
                                id="formName"
                                class="form-control"
                                required
                                placeholder="e.g. OEC Semester VI"
                            >
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" for="formType">
                                Form type
                            </label>
                            <select id="formType" class="form-select">
                                <option>Open Elective (OEC)</option>
                                <option>Departmental Elective</option>
                                <option>Professional Elective</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="formOpen">
                                Opens at
                            </label>
                            <input
                                id="formOpen"
                                type="datetime-local"
                                class="form-control"
                                required
                            >
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="formDeadline">
                                Submission deadline
                            </label>
                            <input
                                id="formDeadline"
                                type="datetime-local"
                                class="form-control"
                                required
                            >
                        </div>
                        <div class="col-md-4">
                            <label class="form-label" for="formMinEnrolment">
                                Minimum enrolment
                            </label>
                            <input
                                id="formMinEnrolment"
                                type="number"
                                min="1"
                                value="10"
                                class="form-control"
                                required
                            >
                        </div>
                        <div class="col-12">
                            <label class="form-label" for="formDescription">
                                Instructions
                            </label>
                            <textarea
                                id="formDescription"
                                class="form-control"
                                rows="3"
                                placeholder="Eligibility, selection rules and instructions"
                            ></textarea>
                        </div>
                        <div class="col-12">
                            <button class="btn btn-primary" type="submit">
                                Create form
                            </button>
                        </div>
                        <p class="form-hint mb-0">
                            Creation, status changes and allocation actions must be
                            submitted to the protected admin servlets.
                        </p>
                    </form>
                </section>
                <section class="surface">
                    <div class="toolbar">
                        <h2 class="h5 mb-0">
                            Forms overview
                        </h2>
                        <span class="status-pill warning">
                            Backend connection pending
                        </span>
                    </div>
                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Form</th>
                                    <th>Type</th>
                                    <th>Deadline</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td colspan="5">
                                        <div class="empty-state">
                                            <div class="empty-icon">
                                                ⚙
                                            </div>
                                            <strong>
                                                No allocation forms loaded
                                            </strong>
                                            <p class="mb-0">
                                                Forms will be listed here when connected to MySQL.
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
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js">
    </script>
    <script src="assets/js/admin.js"></script>
</body>
</html>