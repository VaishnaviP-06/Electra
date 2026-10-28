<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Ensure request routes through the controller to load live database records
    if (request.getAttribute("selectedForm") == null && request.getAttribute("openForms") == null) {
        String query = request.getQueryString();
        response.sendRedirect(request.getContextPath() + "/preferences" + (query != null ? "?" + query : ""));
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Preferences | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/forms.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
    <style>
        .rank-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            background: #4A231A;
            color: #fff;
            border-radius: 8px;
            font-weight: 700;
            margin-right: 12px;
        }
        .form-select-rank {
            padding: 10px 14px;
            border-radius: 8px;
            border: 1px solid #dccbb9;
        }
        .preference-row {
            background: #fff;
            border: 1px solid #eee4da;
            border-radius: 10px;
            padding: 16px;
            margin-bottom: 14px;
            display: flex;
            align-items: center;
            gap: 15px;
        }
    </style>
</head>
<body class="electra-form-page">
    <div class="app-layout">
        <jsp:include page="/WEB-INF/partials/sidebar.jsp">
            <jsp:param name="active" value="preferences"/>
        </jsp:include>
        <main class="main-content">
            <div class="container form-page-container">
                <div class="page-intro">
                    <span class="eyebrow">YOUR FUTURE, YOUR CHOICE</span>
                    <h1>Rank your <em>preferences.</em></h1>
                    <p>
                        Rank all available electives from your highest to lowest preference.
                        Your first choice is your highest priority during merit allocation.
                    </p>
                </div>

                <!-- ALERTS -->
                <c:if test="${not empty preferenceSuccess}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <strong>Success:</strong> <c:out value="${preferenceSuccess}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${not empty preferenceError}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <strong>Notice:</strong> <c:out value="${preferenceError}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- FORM SELECTOR -->
                <c:if test="${not empty openForms}">
                    <div class="mb-4 p-3 bg-white border rounded d-flex justify-content-between align-items-center flex-wrap gap-2">
                        <div>
                            <strong>Active Allocation Form:</strong>
                            <span class="text-muted small ms-2">Switch forms to submit preferences for different categories.</span>
                        </div>
                        <div style="min-width: 250px;">
                            <select class="form-select form-select-sm" onchange="window.location.href='${pageContext.request.contextPath}/preferences?formId=' + this.value;">
                                <c:forEach var="f" items="${openForms}">
                                    <option value="${f.formId}" ${selectedForm != null && selectedForm.formId == f.formId ? 'selected' : ''}>
                                        <c:out value="${f.formName}"/> (<c:out value="${f.categoryName}"/>)
                                    </option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </c:if>

                <c:choose>
                    <c:when test="${selectedForm == null}">
                        <div class="alert alert-info">
                            <strong>No open allocation forms available.</strong>
                            <p class="mb-0">Please check back once the department opens elective submissions.</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="preference-layout">
                            <section class="form-card">
                                <div class="form-card-heading">
                                    <span class="eyebrow"><c:out value="${selectedForm.categoryName}"/> &bull; Form #${selectedForm.formId}</span>
                                    <h2><c:out value="${selectedForm.formName}"/></h2>
                                    <p>Batch: <strong><c:out value="${selectedForm.batchOrCycle}"/></strong></p>
                                </div>

                                <div class="student-summary mb-4">
                                    <div class="student-avatar">S</div>
                                    <div>
                                        <strong id="studentName"><c:out value="${sessionScope.studentName != null ? sessionScope.studentName : 'Student'}"/></strong>
                                        <span id="studentId">Roll Number: <c:out value="${sessionScope.studentRollNumber}"/></span>
                                    </div>
                                    <c:choose>
                                        <c:when test="${isSubmitted}">
                                            <span class="badge bg-success ms-auto fs-6">SUBMITTED</span>
                                        </c:when>
                                        <c:when test="${isDraft}">
                                            <span class="badge bg-warning text-dark ms-auto fs-6">DRAFT SAVED</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary ms-auto fs-6">NOT SUBMITTED</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <c:if test="${isSubmitted}">
                                    <div class="alert alert-success">
                                        <strong>Preferences Submitted &amp; Locked:</strong>
                                        Your ranked choices have been officially recorded in the database. Allocation results will appear on the <em>My Allocation</em> page once published.
                                    </div>
                                </c:if>

                                <form method="post" action="${pageContext.request.contextPath}/preferences" id="preferenceDbForm">
                                    <input type="hidden" name="formId" value="${selectedForm.formId}">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                                    <div id="preferenceFields">
                                        <c:forEach var="elective" items="${activeElectives}" varStatus="status">
                                            <c:set var="rankNum" value="${status.count}"/>
                                            <c:set var="currentElectiveId" value="0"/>

                                            <c:forEach var="p" items="${savedPreferences}">
                                                <c:if test="${p.preferenceRank == rankNum}">
                                                    <c:set var="currentElectiveId" value="${p.electiveId}"/>
                                                </c:if>
                                            </c:forEach>

                                            <div class="preference-field">
                                                <label for="rank_${rankNum}">
                                                    <span class="rank-number"><c:out value="${rankNum}"/></span>
                                                    Rank <c:out value="${rankNum}"/>
                                                    <span class="${rankNum == 1 ? 'required-label' : 'optional-label'}">
                                                        ${rankNum == 1 ? 'Highest priority' : 'Required ranking'}
                                                    </span>
                                                </label>

                                                <select id="rank_${rankNum}" name="rank_${rankNum}" class="form-select preference-select form-select-rank"
                                                        ${isSubmitted ? 'disabled' : 'required'}>
                                                    <option value="">-- Choose elective for Rank ${rankNum} --</option>
                                                    <c:forEach var="item" items="${activeElectives}">
                                                        <option value="${item.electiveId}" ${currentElectiveId == item.electiveId ? 'selected' : ''}>
                                                            <c:out value="${item.electiveCode}"/> — <c:out value="${item.electiveName}"/> (${item.totalSeats} seats)
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                                <small class="text-muted">
                                                    ${rankNum == 1 ? 'Your 1st choice will be evaluated first based on your CGPA merit.' : 'Fallback choice if higher preferences are filled.'}
                                                </small>
                                            </div>
                                        </c:forEach>
                                    </div>

                                    <c:if test="${empty activeElectives}">
                                        <div class="alert alert-warning">
                                            No active electives are currently configured for this form.
                                        </div>
                                    </c:if>

                                    <div class="form-actions mt-4">
                                        <c:choose>
                                            <c:when test="${isSubmitted}">
                                                <a href="${pageContext.request.contextPath}/allocation-results" class="btn btn-electra">
                                                    View Allocation Status →
                                                </a>
                                            </c:when>
                                            <c:when test="${not empty activeElectives}">
                                                <button type="submit" name="action" value="saveDraft" class="btn btn-outline-electra">
                                                    Save Draft
                                                </button>
                                                <button type="submit" name="action" value="submit" class="btn btn-electra"
                                                        onclick="return confirm('Submit your ranked choices? Once submitted, rankings are final and cannot be altered.');">
                                                    Submit Preferences →
                                                </button>
                                            </c:when>
                                        </c:choose>
                                    </div>
                                </form>
                            </section>

                            <aside class="preference-sidebar">
                                <section class="side-info-card">
                                    <span class="eyebrow">ALLOCATION GUIDELINES</span>
                                    <h3>Merit-Based Allocation</h3>
                                    <p>
                                        Electives are allocated strictly in merit order:
                                    </p>
                                    <ol class="small ps-3 mb-3 text-muted">
                                        <li>CGPA (Highest to lowest)</li>
                                        <li>Submission Timestamp (Earliest first)</li>
                                        <li>Roll Number (Alphabetical tie-breaker)</li>
                                    </ol>
                                    <p class="small text-muted mb-0">
                                        Rank every elective once. Ensure no duplicate selections are made.
                                    </p>
                                </section>

                                <section class="side-info-card">
                                    <span class="eyebrow">EXPLORE ELECTIVES</span>
                                    <h3>Catalogue &amp; Syllabi</h3>
                                    <p>Review course descriptions and prerequisites before finalizing your rankings.</p>
                                    <a href="${pageContext.request.contextPath}/electives" class="btn btn-outline-electra w-100">
                                        Browse Elective Catalogue
                                    </a>
                                </section>
                            </aside>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </main>
    </div>

    <footer class="electra-footer">
        <div class="container">
            <span>Electra</span>
            <p>The Right Choice. The Right Future.</p>
            <small>Departmental Elective Allocation System &bull; Academic Year 2026–27</small>
        </div>
    </footer>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
