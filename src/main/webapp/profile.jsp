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
        <div id="profileMessage" class="alert d-none" role="alert"></div>
        <div class="row g-4">
            <div class="col-lg-4">
                <section class="card h-100 shadow-sm border-0">
                    <div class="card-body p-4">
                        <div class="rounded-circle d-flex align-items-center justify-content-center mb-3 profile-avatar">
                            <span id="profileInitials">ST</span>
                        </div>
                        <h4 id="profileDisplayName" class="fw-bold">Student Name</h4>
                        <p id="profileDisplayEmail" class="text-muted">student@example.com</p>
                        <hr>
                        <p class="mb-2"><strong>Department:</strong> <span id="profileDisplayDepartment">CMPN</span></p>
                        <p class="mb-2"><strong>Year:</strong> <span id="profileDisplayYear">Third Year</span></p>
                        <p class="mb-0"><strong>Roll Number:</strong> <span id="profileDisplayRoll">68</span></p>
                    </div>
                </section>
            </div>
            <div class="col-lg-8">
                <section class="card shadow-sm border-0">
                    <div class="card-body p-4">
                        <h4 class="fw-bold mb-4">Academic and Personal Details</h4>
                        <form id="profileForm">
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="studentName" class="form-label">Full Name</label>
                                    <input type="text" class="form-control" id="studentName" required maxlength="80">
                                </div>
                                <div class="col-md-6">
                                    <label for="studentEmail" class="form-label">Email Address</label>
                                    <input type="email" class="form-control" id="studentEmail" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="studentRoll" class="form-label">Roll Number</label>
                                    <input type="text" class="form-control" id="studentRoll" required maxlength="20">
                                </div>
                                <div class="col-md-6">
                                    <label for="studentDepartment" class="form-label">Department</label>
                                    <select class="form-select" id="studentDepartment" required>
                                        <option value="">Select department</option>
                                        <option value="CMPN">Computer Engineering</option>
                                        <option value="INFT">Information Technology</option>
                                        <option value="EXTC">Electronics and Telecommunication</option>
                                        <option value="ECS">Electronics and Computer Science</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="studentYear" class="form-label">Academic Year</label>
                                    <select class="form-select" id="studentYear" required>
                                        <option value="">Select year</option>
                                        <option value="Second Year">Second Year</option>
                                        <option value="Third Year">Third Year</option>
                                        <option value="Final Year">Final Year</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label for="studentCGPA" class="form-label">CGPA</label>
                                    <input type="number" class="form-control" id="studentCGPA"
                                           min="0" max="10" step="0.01" required>
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
    <script src="assets/js/profile.js"></script>
</body>
</html>