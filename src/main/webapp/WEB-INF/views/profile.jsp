<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/forms.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
</head>
<body>
    <div class="app-layout">
        <jsp:include page="/WEB-INF/partials/sidebar.jsp">
            <jsp:param name="active" value="profile"/>
        </jsp:include>
        <main class="main-content">
            <div class="container py-5">
                <div class="mb-4">
                    <p class="text-uppercase small fw-semibold mb-2">Student Account</p>
                    <h1 class="fw-bold">My Profile</h1>
                    <p class="text-muted">Official academic and personal details as registered in college records (Read-Only).</p>
                </div>

                <c:if test="${not empty message}">
                    <div class="alert alert-${messageType}" role="alert">
                        <c:out value="${message}"/>
                    </div>
                </c:if>

                <div class="row g-4">
                    <div class="col-lg-4">
                        <section class="card h-100 shadow-sm border-0">
                            <div class="card-body p-4 text-center">
                                <div class="rounded-circle d-flex align-items-center justify-content-center mx-auto mb-3 profile-avatar" style="width: 80px; height: 80px; background: #4A231A; color: #F8F3ED; font-size: 1.8rem; font-weight: 700;">
                                    <span><c:out value="${profile.initials}"/></span>
                                </div>
                                <h4 class="fw-bold mb-1"><c:out value="${profile.fullName}"/></h4>
                                <p class="text-muted small mb-3"><c:out value="${profile.email}"/></p>
                                <span class="badge bg-secondary text-light">Roll No: <c:out value="${profile.rollNumber}"/></span>
                                <hr class="my-4">
                                <div class="text-start">
                                    <p class="mb-2 text-muted small">DEPARTMENT</p>
                                    <p class="fw-semibold mb-3"><c:out value="${profile.department}"/></p>
                                    <p class="mb-2 text-muted small">BATCH / CYCLE</p>
                                    <p class="fw-semibold mb-3"><c:out value="${profile.academicYear}"/></p>
                                    <p class="mb-2 text-muted small">CUMULATIVE GPA (CGPA)</p>
                                    <p class="fw-bold text-success mb-0" style="font-size: 1.25rem;"><c:out value="${profile.cgpa}"/></p>
                                </div>
                            </div>
                        </section>
                    </div>

                    <div class="col-lg-8">
                        <section class="card shadow-sm border-0 h-100">
                            <div class="card-body p-4">
                                <div class="d-flex justify-content-between align-items-center mb-4">
                                    <h4 class="fw-bold mb-0">Academic &amp; Registration Record</h4>
                                    <span class="badge bg-light text-dark border">Official Record &bull; View Only</span>
                                </div>

                                <div class="alert alert-info py-2 px-3 small d-flex align-items-center mb-4">
                                    <svg class="icon me-2 flex-shrink-0" style="width: 16px; height: 16px;"><use href="#i-info"/></svg>
                                    <span>Profile details are maintained by the academic registrar. If any details are incorrect, please contact your department coordinator.</span>
                                </div>

                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label text-muted small fw-semibold">FULL NAME</label>
                                        <input type="text" class="form-control bg-light" readonly value="<c:out value='${profile.fullName}'/>">
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label text-muted small fw-semibold">EMAIL ADDRESS</label>
                                        <input type="email" class="form-control bg-light" readonly value="<c:out value='${profile.email}'/>">
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label text-muted small fw-semibold">ROLL NUMBER</label>
                                        <input type="text" class="form-control bg-light" readonly value="<c:out value='${profile.rollNumber}'/>">
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label text-muted small fw-semibold">DEPARTMENT</label>
                                        <input type="text" class="form-control bg-light" readonly value="<c:out value='${profile.department}'/>">
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label text-muted small fw-semibold">BATCH / CYCLE</label>
                                        <input type="text" class="form-control bg-light" readonly value="<c:out value='${profile.academicYear}'/>">
                                    </div>

                                    <div class="col-md-6">
                                        <label class="form-label text-muted small fw-semibold">CGPA</label>
                                        <input type="text" class="form-control bg-light fw-bold text-success" readonly value="<c:out value='${profile.cgpa}'/>">
                                    </div>
                                </div>

                                <div class="mt-4 pt-3 border-top d-flex gap-2">
                                    <a href="${pageContext.request.contextPath}/dashboard" class="btn btn-outline-secondary">
                                        &larr; Back to Dashboard
                                    </a>
                                    <a href="${pageContext.request.contextPath}/preferences" class="btn btn-primary">
                                        View Preferences
                                    </a>
                                </div>
                            </div>
                        </section>
                    </div>
                </div>
            </div>
        </main>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
