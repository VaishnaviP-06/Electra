<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (request.getAttribute("reportSummary") == null) {
        String query = request.getQueryString();
        response.sendRedirect(request.getContextPath() + "/reports" + (query != null ? "?" + query : ""));
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Allocation Reports | Electra</title>

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

        .report-note {
            padding: 18px 20px;
            background: #f8f3ed;
            border: 1px solid #eee4da;
            border-radius: 12px;
            margin-bottom: 24px;
        }

        .surface {
            background: #fff;
            border: 1px solid #eee4da;
            border-radius: 14px;
            padding: 24px;
            margin-bottom: 24px;
        }

        .badge-status {
            font-size: 0.8rem;
            font-weight: 600;
            padding: 4px 8px;
            border-radius: 6px;
        }
        .badge-ok { background: #e8f5e9; color: #2e7d32; }
        .badge-low { background: #ffebee; color: #c62828; }
        .badge-pending { background: #fff8e1; color: #f57f17; }

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
                <div class="topbar-title">Allocation Reports &amp; Export</div>
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
                        allocation outcomes and export reports in XML format.
                    </p>
                </div>

                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/dashboard">
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
                    <span>Preference Submissions</span>
                    <strong id="reportPreferenceCount"><c:out value="${reportSummary.totalSubmissions}"/></strong>
                </div>

                <div class="metric">
                    <span>Seats Allocated</span>
                    <strong id="reportSeatsAllocated"><c:out value="${reportSummary.totalSeatsAllocated}"/></strong>
                </div>

                <div class="metric">
                    <span>Below Minimum Enrolment</span>
                    <strong id="reportLowEnrolment"><c:out value="${reportSummary.belowMinEnrolmentCount}"/></strong>
                </div>
            </div>

            <!-- EXPORT REPORT & FILTER -->
            <section class="surface">

                <div class="mb-4">
                    <h2 class="h5 mb-1">Export Report (XML Only)</h2>
                    <p class="form-hint mb-0 text-muted small">
                        Choose an allocation form to filter results and download the official report in XML format.
                    </p>
                </div>

                <form class="row g-3" method="GET" action="${pageContext.request.contextPath}/reports">
                    <div class="col-md-6">
                        <label class="form-label" for="reportFormId">
                            Allocation Form Filter
                        </label>

                        <select class="form-select" id="reportFormId" name="formId" onchange="this.form.submit()">
                            <option value="">All Allocation Forms</option>
                            <c:forEach var="f" items="${forms}">
                                <option value="${f.formId}" ${selectedFormId == f.formId ? 'selected' : ''}>
                                    Form #${f.formId} - <c:out value="${f.formName}"/> (<c:out value="${f.categoryName}"/>)
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label class="form-label" for="reportFormat">
                            Export Format
                        </label>
                        <select class="form-select bg-light" id="reportFormat" disabled>
                            <option value="xml" selected>XML Format (.xml)</option>
                        </select>
                    </div>

                    <div class="col-md-3 d-flex align-items-end">
                        <a href="${pageContext.request.contextPath}/reports/export${selectedFormId != null ? '?formId=' : ''}${selectedFormId != null ? selectedFormId : ''}"
                           class="btn btn-primary w-100" id="prepareReportButton">
                            Download XML Report &darr;
                        </a>
                    </div>
                </form>

                <!-- REPORT TABLE -->
                <div class="table-responsive mt-4">
                    <table class="table align-middle">
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Elective Name</th>
                                <th>Capacity</th>
                                <th>Allocated</th>
                                <th>Seat Utilisation</th>
                                <th>Enrolment Status</th>
                            </tr>
                        </thead>

                        <tbody id="reportRows">
                            <c:choose>
                                <c:when test="${not empty reportRows}">
                                    <c:forEach var="row" items="${reportRows}">
                                        <tr>
                                            <td><strong><c:out value="${row.electiveCode}"/></strong></td>
                                            <td><c:out value="${row.electiveName}"/></td>
                                            <td><c:out value="${row.capacity}"/></td>
                                            <td><strong><c:out value="${row.allocatedCount}"/></strong></td>
                                            <td><c:out value="${row.utilisation}"/></td>
                                            <td>
                                                <span class="badge-status ${row.enrolmentStatus == 'OK' ? 'badge-ok' : (row.enrolmentStatus == 'BELOW_MINIMUM_ENROLMENT' ? 'badge-low' : 'badge-pending')}">
                                                    <c:out value="${row.enrolmentStatus}"/>
                                                </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="6">
                                            <div class="empty-state text-center py-4 text-muted">
                                                <strong>No report data available</strong>
                                                <p class="mb-0">
                                                    No electives found for the selected filter.
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

            <footer class="app-footer text-muted small py-3">
                Electra &bull; Departmental Elective Allocation System &bull; Academic Year 2026–27
            </footer>

        </section>
    </main>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
