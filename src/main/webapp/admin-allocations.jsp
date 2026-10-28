<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    // Ensure request routes through the controller to load live database records
    if (request.getAttribute("forms") == null) {
        String query = request.getQueryString();
        response.sendRedirect(request.getContextPath() + "/admin-allocations" + (query != null ? "?" + query : ""));
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Allocation Management | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
    <style>
        .workflow-stepper {
            display: flex;
            align-items: center;
            justify-content: space-between;
            background: #fff;
            padding: 20px 24px;
            border-radius: 12px;
            border: 1px solid #eee4da;
            margin-bottom: 24px;
            gap: 12px;
            flex-wrap: wrap;
        }
        .workflow-step {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1;
            min-width: 140px;
        }
        .step-circle {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.9rem;
            background: #f0eae1;
            color: #786f66;
            flex-shrink: 0;
        }
        .step-circle.active {
            background: #b54735;
            color: #fff;
        }
        .step-circle.done {
            background: #2e7d32;
            color: #fff;
        }
        .step-text strong {
            display: block;
            font-size: 0.85rem;
            color: #2b2622;
        }
        .step-text small {
            font-size: 0.75rem;
            color: #786f66;
        }
        .badge-status {
            font-size: 0.78rem;
            font-weight: 600;
            padding: 5px 10px;
            border-radius: 20px;
        }
        .badge-open { background: #e8f5e9; color: #2e7d32; }
        .badge-closed { background: #efebe9; color: #4e342e; }
        .badge-draft { background: #fff3e0; color: #e65100; }
        .badge-completed { background: #e8f5e9; color: #1b5e20; }
        .badge-pending { background: #fff8e1; color: #f57f17; }
        .badge-danger-soft { background: #ffebee; color: #c62828; }
        .table-action-card {
            background: #fff;
            border: 1px solid #eee4da;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 24px;
        }
        .metric-badge {
            background: #f9f6f0;
            border: 1px solid #ebd9c8;
            padding: 6px 14px;
            border-radius: 8px;
            font-size: 0.88rem;
        }
        .table-tight td, .table-tight th {
            padding: 10px 12px;
        }
    </style>
</head>
<body class="admin-page">
    <div class="app-layout">
        <jsp:include page="/WEB-INF/partials/sidebar.jsp">
            <jsp:param name="active" value="allocations"/>
        </jsp:include>
        <main class="main-content">
            <header class="topbar">
                <div>
                    <div class="topbar-label">ELECTRA / ADMINISTRATION</div>
                    <div class="topbar-title">Departmental Elective Allocation Workflow</div>
                </div>
                <span class="academic-year">Academic Year 2026–27</span>
            </header>

            <section class="page-content">
                <div class="page-heading">
                    <div>
                        <div class="eyebrow">ADMIN WORKSPACE</div>
                        <h1>Allocation Forms &amp; Execution</h1>
                        <p>
                            Configure allocation forms, trigger merit-based initial allocation, review minimum enrolment compliance, and finalize outcomes.
                        </p>
                    </div>
                    <div>
                        <a class="btn btn-outline-secondary" href="admin.jsp">← Dashboard</a>
                    </div>
                </div>

                <!-- FEEDBACK NOTIFICATIONS -->
                <c:if test="${not empty adminSuccess}">
                    <div class="alert alert-success alert-dismissible fade show" role="alert">
                        <strong>Success:</strong> <c:out value="${adminSuccess}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>
                <c:if test="${not empty adminError}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <strong>Notice:</strong> <c:out value="${adminError}"/>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <!-- SELECTED FORM WORKFLOW VIEW -->
                <c:if test="${not empty selectedForm}">
                    <div class="surface mb-4 border-primary">
                        <div class="d-flex justify-content-between align-items-start mb-3 flex-wrap gap-2">
                            <div>
                                <span class="badge bg-secondary mb-1">Form #${selectedForm.formId}</span>
                                <h2 class="h4 mb-1"><c:out value="${selectedForm.formName}"/></h2>
                                <div class="text-muted small">
                                    Category: <strong><c:out value="${selectedForm.categoryName}"/></strong> &bull;
                                    Batch: <strong><c:out value="${selectedForm.batchOrCycle}"/></strong> &bull;
                                    Submitted Preferences: <strong><c:out value="${candidateCount}"/> students</strong>
                                </div>
                            </div>
                            <div class="d-flex gap-2 align-items-center flex-wrap">
                                <span class="badge-status ${selectedForm.formStatus == 'OPEN' ? 'badge-open' : (selectedForm.formStatus == 'CLOSED' ? 'badge-closed' : 'badge-draft')}">
                                    Form: <c:out value="${selectedForm.formStatus}"/>
                                </span>
                                <span class="badge-status ${selectedForm.allocationStatus == 'COMPLETED' ? 'badge-completed' : (selectedForm.allocationStatus == 'IN_PROGRESS' ? 'badge-pending' : 'badge-draft')}">
                                    Allocation: <c:out value="${selectedForm.allocationStatus}"/>
                                </span>
                                <span class="badge-status ${selectedForm.reviewStatus == 'REVIEWED' ? 'badge-completed' : (selectedForm.reviewStatus == 'PENDING' ? 'badge-pending' : 'badge-draft')}">
                                    Review: <c:out value="${selectedForm.reviewStatus}"/>
                                </span>
                                <span class="badge-status ${selectedForm.resultsPublished ? 'badge-completed' : 'badge-closed'}">
                                    ${selectedForm.resultsPublished ? 'PUBLISHED' : 'UNPUBLISHED'}
                                </span>
                            </div>
                        </div>

                        <!-- WORKFLOW STEPPER -->
                        <div class="workflow-stepper">
                            <div class="workflow-step">
                                <div class="step-circle ${selectedForm.formStatus == 'CLOSED' ? 'done' : (selectedForm.formStatus == 'OPEN' ? 'active' : '')}">
                                    ${selectedForm.formStatus == 'CLOSED' ? '✓' : '1'}
                                </div>
                                <div class="step-text">
                                    <strong>Form Closed</strong>
                                    <small>${selectedForm.formStatus == 'CLOSED' ? 'Closed for submissions' : (selectedForm.formStatus == 'OPEN' ? 'Submissions open' : 'Draft')}</small>
                                </div>
                            </div>
                            <div class="workflow-step">
                                <div class="step-circle ${selectedForm.allocationStatus == 'COMPLETED' ? 'done' : (selectedForm.formStatus == 'CLOSED' && selectedForm.allocationStatus == 'NOT_STARTED' ? 'active' : '')}">
                                    ${selectedForm.allocationStatus == 'COMPLETED' ? '✓' : '2'}
                                </div>
                                <div class="step-text">
                                    <strong>Initial Allocation</strong>
                                    <small>${selectedForm.allocationStatus == 'COMPLETED' ? 'Merit allocation done' : 'Pending execution'}</small>
                                </div>
                            </div>
                            <div class="workflow-step">
                                <div class="step-circle ${selectedForm.reviewStatus == 'REVIEWED' ? 'done' : (selectedForm.allocationStatus == 'COMPLETED' && selectedForm.reviewStatus == 'PENDING' ? 'active' : '')}">
                                    ${selectedForm.reviewStatus == 'REVIEWED' ? '✓' : '3'}
                                </div>
                                <div class="step-text">
                                    <strong>Min. Enrolment Review</strong>
                                    <small>${selectedForm.reviewStatus == 'REVIEWED' ? 'All reviews complete' : (hasPreparedReviews ? 'Reviews pending' : 'Not prepared')}</small>
                                </div>
                            </div>
                            <div class="workflow-step">
                                <div class="step-circle ${selectedForm.reviewStatus == 'REVIEWED' ? 'done' : ''}">
                                    ${selectedForm.reviewStatus == 'REVIEWED' ? '✓' : '4'}
                                </div>
                                <div class="step-text">
                                    <strong>Finalized</strong>
                                    <small>${selectedForm.reviewStatus == 'REVIEWED' ? 'Allocations finalized' : 'Awaiting review'}</small>
                                </div>
                            </div>
                            <div class="workflow-step">
                                <div class="step-circle ${selectedForm.resultsPublished ? 'done' : ''}">
                                    ${selectedForm.resultsPublished ? '✓' : '5'}
                                </div>
                                <div class="step-text">
                                    <strong>Publication</strong>
                                    <small>${selectedForm.resultsPublished ? 'Visible to students' : 'Results hidden'}</small>
                                </div>
                            </div>
                        </div>

                        <!-- WORKFLOW ACTION CONTROLS -->
                        <div class="p-3 bg-light rounded border mb-4">
                            <h3 class="h6 mb-2">Available Actions for Form #${selectedForm.formId}</h3>
                            <div class="d-flex flex-wrap gap-2 align-items-center">
                                <c:if test="${canClose}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin-allocations" class="d-inline">
                                        <input type="hidden" name="action" value="closeForm">
                                        <input type="hidden" name="formId" value="${selectedForm.formId}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <button type="submit" class="btn btn-warning" onclick="return confirm('Close this form? Submissions will stop and allocation can begin.');">
                                            Close Form for Allocation
                                        </button>
                                    </form>
                                </c:if>

                                <c:if test="${canRunAllocation}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin-allocations" class="d-inline">
                                        <input type="hidden" name="action" value="runAllocation">
                                        <input type="hidden" name="formId" value="${selectedForm.formId}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <button type="submit" class="btn btn-primary" onclick="return confirm('Run merit-based allocation for ${candidateCount} candidates?');">
                                            Run Initial Allocation
                                        </button>
                                    </form>
                                </c:if>

                                <c:if test="${canPrepareReview}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin-allocations" class="d-inline">
                                        <input type="hidden" name="action" value="prepareReview">
                                        <input type="hidden" name="formId" value="${selectedForm.formId}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <button type="submit" class="btn btn-outline-primary" onclick="return confirm('Evaluate minimum enrolment and prepare reviews?');">
                                            Prepare Minimum-Enrolment Review
                                        </button>
                                    </form>
                                </c:if>

                                <c:if test="${canFinalize}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin-allocations" class="d-inline">
                                        <input type="hidden" name="action" value="finalize">
                                        <input type="hidden" name="formId" value="${selectedForm.formId}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <button type="submit" class="btn btn-success" onclick="return confirm('Finalize allocation? Students assigned to under-enrolled electives will become NOT_ALLOTTED. Results remain unpublished.');">
                                            Finalize Allocation
                                        </button>
                                    </form>
                                </c:if>

                                <c:if test="${canPublish}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin-allocations" class="d-inline">
                                        <input type="hidden" name="action" value="publishResults">
                                        <input type="hidden" name="formId" value="${selectedForm.formId}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <button type="submit" class="btn btn-outline-danger" onclick="return confirm('Publish results to students? Once published, results are publicly visible.');">
                                            Publish Results
                                        </button>
                                    </form>
                                </c:if>

                                <c:if test="${!canClose && !canRunAllocation && !canPrepareReview && !canFinalize && !canPublish}">
                                    <span class="text-muted small">No immediate workflow actions required for this form. Current state: <strong>${selectedForm.allocationStatus}</strong> / <strong>${selectedForm.reviewStatus}</strong>.</span>
                                </c:if>
                            </div>
                        </div>

                        <!-- ELECTIVES & REVIEW TABLE -->
                        <c:if test="${not empty reviewDetails}">
                            <div class="mb-3">
                                <h3 class="h5 mb-2">Active Electives &amp; Enrolment Review</h3>
                                <p class="text-muted small">
                                    Under-enrolled electives fall below the minimum required enrolment threshold and require administrator review notes before allocation can be finalized.
                                </p>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-bordered table-tight align-middle bg-white">
                                    <thead class="table-light">
                                        <tr>
                                            <th>Elective</th>
                                            <th>Capacity</th>
                                            <th>Min. Required</th>
                                            <th>Provisional Enrolment</th>
                                            <th>Enrolment Status</th>
                                            <th>Review Status</th>
                                            <th>Review Notes &amp; Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="detail" items="${reviewDetails}">
                                            <tr class="${detail.belowMinimum ? 'table-warning' : ''}">
                                                <td>
                                                    <strong><c:out value="${detail.electiveCode}"/></strong><br>
                                                    <span class="text-muted small"><c:out value="${detail.electiveName}"/></span>
                                                </td>
                                                <td><c:out value="${detail.totalSeats}"/></td>
                                                <td><c:out value="${detail.minStudents}"/></td>
                                                <td>
                                                    <span class="badge ${detail.belowMinimum ? 'bg-danger' : 'bg-primary'} fs-6">
                                                        <c:out value="${detail.provisionalEnrolment}"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${detail.enrolmentStatus == 'OK'}">
                                                            <span class="badge bg-success">OK</span>
                                                        </c:when>
                                                        <c:when test="${detail.enrolmentStatus == 'BELOW_MINIMUM_ENROLMENT'}">
                                                            <span class="badge bg-danger">BELOW MINIMUM</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary"><c:out value="${detail.enrolmentStatus}"/></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${detail.reviewStatus == 'REVIEWED'}">
                                                            <span class="badge bg-success">REVIEWED</span>
                                                        </c:when>
                                                        <c:when test="${detail.reviewStatus == 'BELOW_MINIMUM_ENROLMENT'}">
                                                            <span class="badge bg-warning text-dark">REVIEWED (BELOW MIN)</span>
                                                        </c:when>
                                                        <c:when test="${detail.reviewStatus == 'PENDING'}">
                                                            <span class="badge bg-warning text-dark">PENDING</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-light text-muted">NOT PREPARED</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td style="min-width: 280px;">
                                                    <c:choose>
                                                        <c:when test="${canReview && detail.reviewStatus == 'PENDING'}">
                                                            <form method="post" action="${pageContext.request.contextPath}/admin-allocations" class="d-flex flex-column gap-1">
                                                                <input type="hidden" name="action" value="reviewElective">
                                                                <input type="hidden" name="formId" value="${selectedForm.formId}">
                                                                <input type="hidden" name="electiveId" value="${detail.electiveId}">
                                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                                <div class="input-group input-group-sm">
                                                                    <input type="text" name="notes" class="form-control"
                                                                           placeholder="${detail.belowMinimum ? 'Note required (under-enrolled)' : 'Optional notes'}"
                                                                           ${detail.belowMinimum ? 'required' : ''}>
                                                                    <button type="submit" class="btn btn-outline-dark">Submit</button>
                                                                </div>
                                                                <c:if test="${not empty detail.reviewNotes}">
                                                                    <small class="text-muted"><c:out value="${detail.reviewNotes}"/></small>
                                                                </c:if>
                                                            </form>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="small">
                                                                <c:out value="${detail.reviewNotes != null ? detail.reviewNotes : 'No notes recorded.'}"/>
                                                            </div>
                                                            <c:if test="${not empty detail.reviewerUsername}">
                                                                <div class="text-muted" style="font-size: 0.72rem;">
                                                                    Reviewed by: <c:out value="${detail.reviewerUsername}"/> &bull; <c:out value="${detail.reviewedAt}"/>
                                                                </div>
                                                            </c:if>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </tbody>
                                </table>
                            </div>
                        </c:if>

                        <div class="mt-3">
                            <a href="${pageContext.request.contextPath}/admin-allocations" class="btn btn-sm btn-link text-decoration-none">← Back to all forms</a>
                        </div>
                    </div>
                </c:if>

                <!-- FORMS OVERVIEW TABLE -->
                <section class="surface mb-4">
                    <div class="toolbar mb-3">
                        <div>
                            <h2 class="h5 mb-1">Allocation Forms Directory</h2>
                            <p class="form-hint mb-0">Select any form to inspect its configuration or manage its allocation lifecycle.</p>
                        </div>
                        <button class="btn btn-sm btn-outline-primary" type="button" data-bs-toggle="collapse" data-bs-target="#createFormCollapse" aria-expanded="false" aria-controls="createFormCollapse">
                            + New Form
                        </button>
                    </div>

                    <!-- CREATE FORM COLLAPSIBLE -->
                    <div class="collapse mb-4" id="createFormCollapse">
                        <div class="card card-body bg-light">
                            <h3 class="h6 mb-3">Create New Allocation Form</h3>
                            <form method="post" action="${pageContext.request.contextPath}/admin-allocations" class="row g-3">
                                <input type="hidden" name="action" value="createForm">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">

                                <div class="col-md-4">
                                    <label class="form-label small" for="formName">Form Name <span class="text-danger">*</span></label>
                                    <input id="formName" name="formName" class="form-control form-control-sm" required placeholder="e.g. OEC Allocation 2026">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small" for="categoryName">Category <span class="text-danger">*</span></label>
                                    <select id="categoryName" name="categoryName" class="form-select form-select-sm" required>
                                        <option value="OEC">Open Elective (OEC)</option>
                                        <option value="DEPARTMENTAL">Departmental Elective</option>
                                        <option value="PROFESSIONAL">Professional Elective</option>
                                    </select>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label small" for="batchOrCycle">Batch / Cycle <span class="text-danger">*</span></label>
                                    <input id="batchOrCycle" name="batchOrCycle" class="form-control form-control-sm" required placeholder="e.g. TY-CE-2026">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small" for="openingDate">Opens At</label>
                                    <input id="openingDate" name="openingDate" type="datetime-local" class="form-control form-control-sm">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small" for="submissionDeadline">Submission Deadline</label>
                                    <input id="submissionDeadline" name="submissionDeadline" type="datetime-local" class="form-control form-control-sm">
                                </div>
                                <div class="col-12">
                                    <button class="btn btn-sm btn-primary" type="submit">Create Form (Draft)</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Form Name</th>
                                    <th>Category</th>
                                    <th>Batch</th>
                                    <th>Form Status</th>
                                    <th>Allocation</th>
                                    <th>Review</th>
                                    <th>Published</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty forms}">
                                        <c:forEach var="f" items="${forms}">
                                            <tr class="${selectedForm != null && selectedForm.formId == f.formId ? 'table-active' : ''}">
                                                <td>#<c:out value="${f.formId}"/></td>
                                                <td><strong><c:out value="${f.formName}"/></strong></td>
                                                <td><c:out value="${f.categoryName}"/></td>
                                                <td><c:out value="${f.batchOrCycle}"/></td>
                                                <td>
                                                    <span class="badge-status ${f.formStatus == 'OPEN' ? 'badge-open' : (f.formStatus == 'CLOSED' ? 'badge-closed' : 'badge-draft')}">
                                                        <c:out value="${f.formStatus}"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge-status ${f.allocationStatus == 'COMPLETED' ? 'badge-completed' : (f.allocationStatus == 'IN_PROGRESS' ? 'badge-pending' : 'badge-draft')}">
                                                        <c:out value="${f.allocationStatus}"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge-status ${f.reviewStatus == 'REVIEWED' ? 'badge-completed' : (f.reviewStatus == 'PENDING' ? 'badge-pending' : 'badge-draft')}">
                                                        <c:out value="${f.reviewStatus}"/>
                                                    </span>
                                                </td>
                                                <td>
                                                    <span class="badge-status ${f.resultsPublished ? 'badge-completed' : 'badge-closed'}">
                                                        ${f.resultsPublished ? 'PUBLISHED' : 'NO'}
                                                    </span>
                                                </td>
                                                <td>
                                                    <a href="${pageContext.request.contextPath}/admin-allocations?formId=${f.formId}" class="btn btn-sm ${selectedForm != null && selectedForm.formId == f.formId ? 'btn-primary' : 'btn-outline-primary'}">
                                                        ${selectedForm != null && selectedForm.formId == f.formId ? 'Selected' : 'Manage'}
                                                    </a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="9" class="text-center py-4 text-muted">
                                                No allocation forms found in the database.
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </section>

                <footer class="app-footer">
                    Electra &bull; Departmental Elective Allocation System &bull; Academic Year 2026–27
                </footer>
            </section>
        </main>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
