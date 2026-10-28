<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (request.getAttribute("forms") == null) {
        String query = request.getQueryString();
        response.sendRedirect(request.getContextPath() + "/admin-electives" + (query != null ? "?" + query : ""));
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Electives | Electra</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">

    <style>
        .page-content { padding-bottom: 32px; }
        .page-heading { display: flex; justify-content: space-between; align-items: center; gap: 20px; margin-bottom: 28px; }
        .page-heading h1 { margin-bottom: 8px; }
        .page-heading p { max-width: 650px; margin-bottom: 0; }
        .surface { margin-bottom: 24px; background: #fff; border: 1px solid #eee4da; border-radius: 12px; padding: 22px; }
        .required { color: #b54735; }
        .form-hint { font-size: 0.85rem; color: #786f66; }
        .badge-active { background: #e8f5e9; color: #2e7d32; font-weight: 600; padding: 4px 8px; border-radius: 6px; }
        .badge-inactive { background: #ffebee; color: #c62828; font-weight: 600; padding: 4px 8px; border-radius: 6px; }
        @media (max-width: 768px) {
            .page-heading { align-items: flex-start; flex-direction: column; }
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
                <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin.jsp">
                    ← Overview
                </a>
            </div>

            <!-- FLASH MESSAGES -->
            <c:if test="${not empty adminElectiveSuccess}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <strong>Success:</strong> <c:out value="${adminElectiveSuccess}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>
            <c:if test="${not empty adminElectiveError}">
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <strong>Error:</strong> <c:out value="${adminElectiveError}"/>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            </c:if>

            <!-- ADD ELECTIVE -->
            <section class="surface">
                <h2 class="h5 mb-4">Add an Elective</h2>

                <form method="POST" action="${pageContext.request.contextPath}/admin-electives" class="row g-3">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="action" value="create">

                    <div class="col-md-4">
                        <label class="form-label" for="formId">
                            Allocation Form <span class="required">*</span>
                        </label>
                        <select class="form-select" id="formId" name="formId" required>
                            <c:forEach var="f" items="${forms}">
                                <option value="${f.formId}" ${selectedForm != null && selectedForm.formId == f.formId ? 'selected' : ''}>
                                    Form #${f.formId} - <c:out value="${f.formName}"/> (<c:out value="${f.categoryName}"/>)
                                </option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-md-4">
                        <label class="form-label" for="electiveCode">
                            Course Code <span class="required">*</span>
                        </label>
                        <input class="form-control" id="electiveCode" name="electiveCode" required placeholder="e.g. CE-OE-601">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label" for="electiveName">
                            Elective Title <span class="required">*</span>
                        </label>
                        <input class="form-control" id="electiveName" name="electiveName" required placeholder="e.g. Distributed Computing">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label" for="facultyName">
                            Faculty Name
                        </label>
                        <input class="form-control" id="facultyName" name="facultyName" placeholder="e.g. Dr. A. Sharma">
                    </div>

                    <div class="col-md-4">
                        <label class="form-label" for="totalSeats">
                            Total Seats <span class="required">*</span>
                        </label>
                        <input class="form-control" type="number" id="totalSeats" name="totalSeats" min="1" required placeholder="e.g. 60">
                    </div>

                    <div class="col-md-2">
                        <label class="form-label" for="minStudents">
                            Min Students
                        </label>
                        <input class="form-control" type="number" id="minStudents" name="minStudents" min="0" value="1" placeholder="1">
                    </div>

                    <div class="col-md-2">
                        <label class="form-label" for="minCgpa">
                            Min. CGPA
                        </label>
                        <input class="form-control" type="number" id="minCgpa" name="minCgpa" min="0" max="10" step="0.01" placeholder="Optional">
                    </div>

                    <div class="col-12">
                        <label class="form-label" for="syllabus">
                            Syllabus / Course Description
                        </label>
                        <textarea class="form-control" id="syllabus" name="syllabus" rows="2" placeholder="Briefly describe course contents and prerequisites"></textarea>
                    </div>

                    <div class="col-12 d-flex gap-2">
                        <button class="btn btn-primary" type="submit">
                            Save Elective
                        </button>
                        <button class="btn btn-outline-secondary" type="reset">
                            Clear Form
                        </button>
                    </div>
                </form>
            </section>

            <!-- ELECTIVE TABLE -->
            <section class="surface">
                <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                    <div>
                        <h2 class="h5 mb-1">Current Electives</h2>
                        <p class="form-hint mb-0">
                            Search and manage the active elective catalogue across forms.
                        </p>
                    </div>

                    <div class="d-flex gap-2">
                        <select class="form-select form-select-sm" style="max-width: 200px;" onchange="window.location.href='${pageContext.request.contextPath}/admin-electives' + (this.value ? '?formId=' + this.value : '');">
                            <option value="">All Allocation Forms</option>
                            <c:forEach var="f" items="${forms}">
                                <option value="${f.formId}" ${selectedForm != null && selectedForm.formId == f.formId ? 'selected' : ''}>
                                    Form #${f.formId} (<c:out value="${f.formName}"/>)
                                </option>
                            </c:forEach>
                        </select>

                        <input class="form-control form-control-sm" id="electiveSearch" style="max-width: 220px;" placeholder="Search electives..." aria-label="Search electives">
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="table align-middle" id="electivesTable">
                        <thead>
                            <tr>
                                <th>Code</th>
                                <th>Elective Name</th>
                                <th>Form</th>
                                <th>Faculty</th>
                                <th>Seats</th>
                                <th>Min. Students</th>
                                <th>Min. CGPA</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>

                        <tbody>
                            <c:choose>
                                <c:when test="${not empty electives}">
                                    <c:forEach var="e" items="${electives}">
                                        <tr class="elective-row" data-search="${e.electiveCode} ${e.electiveName} ${e.facultyName}">
                                            <td><strong><c:out value="${e.electiveCode}"/></strong></td>
                                            <td><c:out value="${e.electiveName}"/></td>
                                            <td><span class="badge bg-light text-dark">Form #${e.formId}</span></td>
                                            <td><c:out value="${e.facultyName != null ? e.facultyName : '—'}"/></td>
                                            <td><c:out value="${e.totalSeats}"/></td>
                                            <td><c:out value="${e.minStudents}"/></td>
                                            <td><c:out value="${e.minCgpa != null ? e.minCgpa : 'None'}"/></td>
                                            <td>
                                                <span class="${e.active ? 'badge-active' : 'badge-inactive'}">
                                                    ${e.active ? 'ACTIVE' : 'INACTIVE'}
                                                </span>
                                            </td>
                                            <td>
                                                <form method="POST" action="${pageContext.request.contextPath}/admin-electives" style="display:inline;">
                                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <input type="hidden" name="action" value="toggleActive">
                                                    <input type="hidden" name="electiveId" value="${e.electiveId}">
                                                    <input type="hidden" name="formId" value="${e.formId}">
                                                    <input type="hidden" name="currentlyActive" value="${e.active}">
                                                    <button type="submit" class="btn btn-sm ${e.active ? 'btn-outline-danger' : 'btn-outline-success'}">
                                                        ${e.active ? 'Deactivate' : 'Activate'}
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="9" class="text-center py-4 text-muted">
                                            No electives found in the database.
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
<script>
    document.getElementById("electiveSearch")?.addEventListener("input", function(e) {
        const query = e.target.value.toLowerCase().trim();
        document.querySelectorAll(".elective-row").forEach(function(row) {
            const text = (row.getAttribute("data-search") || "").toLowerCase();
            row.style.display = text.includes(query) ? "" : "none";
        });
    });
</script>
</body>
</html>
