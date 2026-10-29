<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (request.getAttribute("students") == null) {
        String query = request.getQueryString();
        response.sendRedirect(request.getContextPath() + "/admin-students" + (query != null ? "?" + query : ""));
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Students | Electra</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
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

        .badge-eligible {
            background: #e8f5e9;
            color: #2e7d32;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 6px;
        }

        .badge-review {
            background: #fff3e0;
            color: #e65100;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 6px;
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
                        Review student records, academic details, and
                        merit eligibility for elective allocation.
                    </p>
                </div>

                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin.jsp">
                    ← Overview
                </a>
            </div>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <c:out value="${error}"/>
                </div>
            </c:if>

            <!-- SUMMARY CARDS -->
            <div class="metric-grid">
                <div class="metric">
                    <span>Total Students</span>
                    <strong id="totalStudents"><c:out value="${totalStudents}"/></strong>
                </div>

                <div class="metric">
                    <span>Eligible Students (CGPA ≥ 6.0)</span>
                    <strong id="eligibleStudents"><c:out value="${eligibleStudents}"/></strong>
                </div>

                <div class="metric">
                    <span>Review Recommended (CGPA &lt; 6.0)</span>
                    <strong id="studentsNeedsReview"><c:out value="${needsReview}"/></strong>
                </div>
            </div>

            <!-- STUDENT DIRECTORY -->
            <section class="surface p-4 bg-white border rounded-3 mb-4">

                <div class="toolbar mb-3 d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <h2 class="h5 mb-1">Student Records</h2>
                        <p class="form-hint mb-0 text-muted small">
                            Search by roll number, name, department, or email.
                        </p>
                    </div>

                    <div class="d-flex gap-2">
                        <input
                            id="studentSearch"
                            class="form-control"
                            style="max-width: 280px;"
                            placeholder="Search students..."
                            aria-label="Search students">
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table align-middle">
                        <thead>
                            <tr>
                                <th>Roll Number</th>
                                <th>Student Name</th>
                                <th>Email</th>
                                <th>Batch / Cycle</th>
                                <th>CGPA</th>
                                <th>Eligibility Status</th>
                            </tr>
                        </thead>

                        <tbody id="studentRows">
                            <c:choose>
                                <c:when test="${not empty students}">
                                    <c:forEach var="s" items="${students}">
                                        <tr class="student-row" data-search="${s.rollNumber} ${s.fullName} ${s.email} ${s.academicYear}">
                                            <td><strong><c:out value="${s.rollNumber}"/></strong></td>
                                            <td><c:out value="${s.fullName}"/></td>
                                            <td><c:out value="${s.email}"/></td>
                                            <td><c:out value="${s.academicYear != null ? s.academicYear : '—'}"/></td>
                                            <td><strong><c:out value="${s.cgpa != null ? s.cgpa : '—'}"/></strong></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${s.cgpa != null && s.cgpa >= 6.0}">
                                                        <span class="badge-eligible">Eligible ✓</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge-review">Review</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6">
                                            <div class="empty-state text-center py-4 text-muted">
                                                <strong>No student records loaded</strong>
                                                <p class="mb-0">
                                                    No registered students found in the database.
                                                </p>
                                            </div>
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>

            </section>


        </section>
    </main>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.getElementById("studentSearch")?.addEventListener("input", function(e) {
        const query = e.target.value.toLowerCase().trim();
        document.querySelectorAll(".student-row").forEach(function(row) {
            const text = (row.getAttribute("data-search") || "").toLowerCase();
            row.style.display = text.includes(query) ? "" : "none";
        });
    });
</script>

</body>
</html>
