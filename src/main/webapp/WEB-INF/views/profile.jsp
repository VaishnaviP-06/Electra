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
            <p class="text-uppercase small fw-semibold mb-2">Student account</p>
            <h1 class="fw-bold">My Profile</h1>
            <p class="text-muted">Manage your academic and contact details.</p>
        </div>
        <c:if test="${not empty message}">
            <div class="alert alert-${messageType}" role="alert">
                <c:out value="${message}"/>
            </div>
        </c:if>
        <div class="row g-4">
            <div class="col-lg-4">
                <section class="card h-100 shadow-sm border-0">
                    <div class="card-body p-4">
                        <div class="rounded-circle d-flex align-items-center justify-content-center mb-3 profile-avatar">
                            <span><c:out value="${profile.initials}"/></span>
                        </div>
                        <h4 class="fw-bold"><c:out value="${profile.fullName}"/></h4>
                        <p class="text-muted"><c:out value="${profile.email}"/></p>
                        <hr>
                        <p class="mb-2"><strong>Department:</strong> <c:out value="${profile.department}"/></p>
                        <p class="mb-2"><strong>Year:</strong> <c:out value="${profile.academicYear}"/></p>
                        <p class="mb-0"><strong>Roll Number:</strong> <c:out value="${profile.rollNumber}"/></p>
                    </div>
                </section>
            </div>
            <div class="col-lg-8">
                <section class="card shadow-sm border-0">
                    <div class="card-body p-4">
                        <h4 class="fw-bold mb-4">Academic and Personal Details</h4>
                        <form id="profileForm" action="${pageContext.request.contextPath}/profile" method="post">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="studentName" class="form-label">Full Name</label>
                                    <input type="text" class="form-control" id="studentName" name="fullName" required minlength="2" maxlength="100" value="<c:out value='${profile.fullName}'/>">
                                </div>
                                <div class="col-md-6">
                                    <label for="studentEmail" class="form-label">Email Address</label>
                                    <input type="email" class="form-control" id="studentEmail" name="email" required maxlength="150" value="<c:out value='${profile.email}'/>">
                                </div>
                                <div class="col-md-6">
                                    <label for="studentRoll" class="form-label">Roll Number</label>
                                    <input type="text" class="form-control" id="studentRoll" name="rollNumber" required maxlength="30" value="<c:out value='${profile.rollNumber}'/>">
                                </div>
                                <div class="col-md-6">
                                    <label for="studentDepartment" class="form-label">Department</label>
                                    <select class="form-select" id="studentDepartment" name="department" required>
                                        <option value="">Select department</option>
                                        <option value="CMPN" <c:if test="${profile.department == 'CMPN'}">selected</c:if>>Computer Engineering</option>
                                        <option value="INFT" <c:if test="${profile.department == 'INFT'}">selected</c:if>>Information Technology</option>
                                        <option value="EXTC" <c:if test="${profile.department == 'EXTC'}">selected</c:if>>Electronics and Telecommunication</option>
                                        <option value="ECS" <c:if test="${profile.department == 'ECS'}">selected</c:if>>Electronics and Computer Science</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="studentYear" class="form-label">Academic Year</label>
                                    <select class="form-select" id="studentYear" name="academicYear" required>
                                        <option value="">Select year</option>
                                        <option value="Second Year" <c:if test="${profile.academicYear == 'Second Year'}">selected</c:if>>Second Year</option>
                                        <option value="Third Year" <c:if test="${profile.academicYear == 'Third Year'}">selected</c:if>>Third Year</option>
                                        <option value="Final Year" <c:if test="${profile.academicYear == 'Final Year'}">selected</c:if>>Final Year</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="studentCGPA" class="form-label">CGPA</label>
                                    <input type="number" class="form-control" id="studentCGPA"
                                           name="cgpa" min="0" max="10" step="0.01" required
                                           value="<c:out value='${not empty cgpaValue ? cgpaValue : profile.cgpa}'/>">
                                </div>
                            </div>
                            <div class="d-flex gap-2 mt-4 flex-wrap">
                                <button type="submit" class="btn btn-primary">Save Profile</button>
                                <button type="reset" class="btn btn-outline-secondary">Reset Form</button>
                            </div>
                        </form>
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