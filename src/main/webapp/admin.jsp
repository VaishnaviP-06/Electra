<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (request.getAttribute("adminData") == null) {
        response.sendRedirect(request.getContextPath() + "/dashboard");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Panel | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/dashboard.css">
    <link rel="stylesheet" href="assets/css/admin.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body data-user-id="${sessionScope.userId}" data-role="${sessionScope.role}">
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

            <!-- ADMINISTRATIVE TOOLS -->
            <section class="admin-toolbar mt-4 mb-4">
                <div>
                    <h2 class="section-title">Administrative Workspaces</h2>
                    <p class="section-description">
                        Access allocation settings, elective management, and reports.
                    </p>
                </div>
                <div class="admin-toolbar-actions d-flex gap-2">
                    <a href="${pageContext.request.contextPath}/admin-electives" class="btn btn-outline-secondary">
                        Manage Electives
                    </a>
                    <a href="${pageContext.request.contextPath}/reports" class="btn btn-primary">
                        View Reports &amp; XML Export
                    </a>
                </div>
            </section>

            <!-- OVERVIEW -->
            <div class="section-heading">
                <h2>Overview</h2>
                <p>Summary of the current database records.</p>
            </div>
            <div class="stats-grid admin-stats-grid">
                <!-- TOTAL ELECTIVES -->
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Active Electives</span>
                        <span class="stat-icon icon-sand">
                            <svg class="icon" aria-hidden="true">
                                <use href="#i-book"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-number" id="totalElectives"><c:out value="${adminData.totalElectives}"/></div>
                    <div class="stat-caption">
                        Active electives in database
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
                    <div class="stat-number" id="totalSeats"><c:out value="${adminData.totalSeats}"/></div>
                    <div class="stat-caption">
                        Total seat capacity across electives
                    </div>
                </article>
                <!-- TOTAL STUDENTS -->
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Total Students</span>
                        <span class="stat-icon icon-sage">
                            <svg class="icon" aria-hidden="true">
                                <use href="#i-users"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-number" id="totalStudents"><c:out value="${adminData.totalStudents}"/></div>
                    <div class="stat-caption">
                        Registered student profiles
                    </div>
                </article>
                <!-- ALLOCATION FORMS -->
                <article class="stat-card">
                    <div class="stat-top">
                        <span>Allocation Forms</span>
                        <span class="stat-icon icon-sand">
                            <svg class="icon" aria-hidden="true">
                                <use href="#i-settings"/>
                            </svg>
                        </span>
                    </div>
                    <div class="stat-number" id="totalForms"><c:out value="${adminData.totalForms}"/></div>
                    <div class="stat-caption">
                        Configured allocation cycles
                    </div>
                </article>
            </div>

            <!-- QUICK ADMINISTRATIVE ACTIONS -->
            <section class="admin-section mt-5">
                <div class="section-heading section-heading-spaced">
                    <h2>Quick Actions</h2>
                    <p>
                        Direct navigation to operational administration modules.
                    </p>
                </div>
                <div class="row g-4">
                    <div class="col-md-4">
                        <div class="card p-4 border h-100 shadow-sm">
                            <h4 class="fw-bold mb-2">Manage Electives</h4>
                            <p class="text-muted small mb-4">Add new courses, configure seat capacities, minimum CGPA eligibility, and manage active/inactive status.</p>
                            <a href="${pageContext.request.contextPath}/admin-electives" class="btn btn-outline-primary mt-auto">
                                Open Electives &rarr;
                            </a>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card p-4 border h-100 shadow-sm">
                            <h4 class="fw-bold mb-2">Student Directory</h4>
                            <p class="text-muted small mb-4">Review registered students, department cohorts, academic standing, and eligibility criteria.</p>
                            <a href="${pageContext.request.contextPath}/admin-students" class="btn btn-outline-primary mt-auto">
                                Open Students &rarr;
                            </a>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="card p-4 border h-100 shadow-sm">
                            <h4 class="fw-bold mb-2">Allocation Workflow</h4>
                            <p class="text-muted small mb-4">Run merit allocation engine, review minimum enrolment thresholds, finalize, and publish official results.</p>
                            <a href="${pageContext.request.contextPath}/admin-allocations" class="btn btn-outline-primary mt-auto">
                                Open Allocation &rarr;
                            </a>
                        </div>
                    </div>
                </div>
            </section>

            <!-- FOOTER -->
            <footer class="page-footer mt-5">
                <span>Electra</span>
                · Departmental Elective Allocation System
                <span class="footer-year">2026–27</span>
            </footer>
        </section>
    </main>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
