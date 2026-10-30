<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%--
  Allocation Results page — student view.
  Requires controller: StudentAllocationServlet sets 'allocationViews',
  'hasSubmissions', 'hasPublishedResults' request attributes.
  If accessed directly (no attributes), redirect to servlet.
--%>
<%
    if (request.getAttribute("allocationViews") == null) {
        response.sendRedirect(request.getContextPath() + "/allocation-results");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Allocation Results | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/forms.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
    <style>
        .results-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1.25rem;
        }
        .result-card {
            background: var(--card-bg, #fff);
            border: 1px solid var(--border-color, #e5e7eb);
            border-radius: 12px;
            padding: 1.5rem;
        }
        .result-card-header {
            display: flex; align-items: center; justify-content: space-between;
            margin-bottom: 1rem;
        }
        .result-card-header h3 { margin: 0; font-size: 1.05rem; font-weight: 600; }
        .form-eyebrow {
            font-size: 0.7rem; font-weight: 700; letter-spacing: 0.08em;
            text-transform: uppercase; color: var(--muted, #6b7280); margin-bottom: 0.25rem;
        }
        .result-detail-grid {
            display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: 0.75rem; margin-top: 0.75rem;
        }
        .detail-item label {
            display: block; font-size: 0.7rem; font-weight: 600; text-transform: uppercase;
            letter-spacing: 0.06em; color: var(--muted, #6b7280); margin-bottom: 0.2rem;
        }
        .detail-item span { font-size: 0.9rem; font-weight: 500; }
        .badge-allocated { background: #d1fae5; color: #065f46; }
        .badge-not-allotted { background: #fee2e2; color: #991b1b; }
        .badge-pending { background: #fef9c3; color: #854d0e; }
        .badge-submitted { background: #dbeafe; color: #1e40af; }
        .badge-draft { background: #f3f4f6; color: #374151; }
        .badge-hidden { background: #f3f4f6; color: #374151; font-style: italic; }
        .status-banner {
            border-radius: 10px; padding: 1.25rem 1.5rem;
            display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem;
        }
        .status-banner.info { background: #eff6ff; border: 1px solid #bfdbfe; }
        .status-banner.success { background: #f0fdf4; border: 1px solid #bbf7d0; }
        .status-banner.warning { background: #fffbeb; border: 1px solid #fde68a; }
        .status-banner .icon { font-size: 2rem; }
        .status-banner h2 { margin: 0 0 0.2rem; font-size: 1.05rem; }
        .status-banner p { margin: 0; font-size: 0.88rem; color: var(--muted, #6b7280); }
        .empty-state { text-align: center; padding: 3rem 1rem; color: var(--muted, #6b7280); }
        .empty-state .icon { font-size: 3rem; margin-bottom: 1rem; }
        .reason-text { font-size: 0.8rem; color: var(--muted, #6b7280); margin-top: 0.25rem; font-style: italic; }
        @media (max-width: 768px) {
            .results-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body class="electra-form-page">
<div class="app-layout">
    <jsp:include page="/WEB-INF/partials/sidebar.jsp">
        <jsp:param name="active" value="allocation"/>
    </jsp:include>
    <main class="main-content">
        <div class="container form-page-container">

            <div class="page-intro">
                <span class="eyebrow">ALLOCATION CENTRE</span>
                <h1>Your results, <em>in one place.</em></h1>
                <p>Review your preference submissions and allocation status below.
                   Elective details are only shown after the administrator publishes results.</p>
            </div>

            <%-- Error message if any --%>
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger mb-3" role="alert">
                    <strong>Error:</strong> <c:out value="${errorMessage}"/>
                </div>
            </c:if>

            <%-- Overall status banner --%>
            <c:choose>
                <c:when test="${hasPublishedResults}">
                    <div class="status-banner success">
                        <span class="icon">🎓</span>
                        <div>
                            <h2>Results Available</h2>
                            <p>At least one of your allocation results has been published. See details below.</p>
                        </div>
                    </div>
                </c:when>
                <c:when test="${hasSubmissions}">
                    <div class="status-banner info">
                        <span class="icon">⏳</span>
                        <div>
                            <h2>Allocation Pending</h2>
                            <p>Your preferences have been submitted. Results will appear here once published by the administrator.</p>
                        </div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="status-banner warning">
                        <span class="icon">📋</span>
                        <div>
                            <h2>No Submissions Yet</h2>
                            <p>You haven't submitted preferences for any open form. Visit the Preferences page to get started.</p>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

            <%-- Results grid --%>
            <c:choose>
                <c:when test="${empty allocationViews}">
                    <div class="empty-state">
                        <div class="icon">📭</div>
                        <p>No allocation records found. Submit your preferences from the
                           <a href="${pageContext.request.contextPath}/preferences">Preferences</a> page.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="results-grid">
                        <c:forEach var="view" items="${allocationViews}">
                            <div class="result-card">
                                <div class="result-card-header">
                                    <div>
                                        <div class="form-eyebrow">Allocation Form</div>
                                        <h3><c:out value="${view.formName}"/></h3>
                                    </div>
                                    <%-- Submission status badge --%>
                                    <c:choose>
                                        <c:when test="${view.submissionStatus == 'SUBMITTED'}">
                                            <span class="badge badge-submitted">Submitted</span>
                                        </c:when>
                                        <c:when test="${view.submissionStatus == 'DRAFT'}">
                                            <span class="badge badge-draft">Draft</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge badge-pending">Not Submitted</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="result-detail-grid">
                                    <%-- Submission timestamp --%>
                                    <div class="detail-item">
                                        <label>Submitted At</label>
                                        <c:choose>
                                            <c:when test="${view.submittedAt != null}">
                                                <span><fmt:formatDate value="${view.submittedAt}" pattern="dd MMM yyyy, HH:mm"/></span>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:var(--muted,#6b7280)">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <%-- Allocation status --%>
                                    <div class="detail-item">
                                        <label>Allocation Status</label>
                                        <c:choose>
                                            <c:when test="${view.resultsPublished and view.allocationStatus == 'ALLOCATED'}">
                                                <span class="badge badge-allocated">Allocated ✓</span>
                                            </c:when>
                                            <c:when test="${view.resultsPublished and view.allocationStatus == 'NOT_ALLOTTED'}">
                                                <span class="badge badge-not-allotted">Not Allotted</span>
                                            </c:when>
                                            <c:when test="${view.resultsPublished and view.allocationStatus != null}">
                                                <span class="badge badge-pending"><c:out value="${view.allocationStatus}"/></span>
                                            </c:when>
                                            <c:when test="${view.submissionStatus == 'SUBMITTED'}">
                                                <span class="badge badge-pending">Awaiting Results</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-hidden">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <%-- Elective details: only shown if results published --%>
                                    <c:if test="${view.resultsPublished and view.allocationStatus == 'ALLOCATED'}">
                                        <div class="detail-item">
                                            <label>Elective</label>
                                            <span><c:out value="${view.electiveName}"/></span>
                                        </div>
                                        <div class="detail-item">
                                            <label>Code</label>
                                            <span><c:out value="${view.electiveCode}"/></span>
                                        </div>
                                        <c:if test="${not empty view.facultyName}">
                                            <div class="detail-item">
                                                <label>Faculty</label>
                                                <span><c:out value="${view.facultyName}"/></span>
                                            </div>
                                        </c:if>
                                    </c:if>

                                    <%-- Reason for NOT_ALLOTTED --%>
                                    <c:if test="${view.resultsPublished and view.allocationStatus == 'NOT_ALLOTTED' and not empty view.allocationReason}">
                                        <div class="detail-item" style="grid-column: 1 / -1;">
                                            <label>Reason</label>
                                            <p class="reason-text"><c:out value="${view.allocationReason}"/></p>
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>

            <%-- Action links --%>
            <div class="mt-4 d-flex gap-3">
                <a href="${pageContext.request.contextPath}/preferences" class="btn btn-outline-primary btn-sm">
                    ← Back to Preferences
                </a>
                <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-outline-secondary btn-sm">
                    Dashboard
                </a>
            </div>

        </div>
    </main>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
