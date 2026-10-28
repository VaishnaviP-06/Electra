<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    if (request.getAttribute("electives") == null) {
        String query = request.getQueryString();
        response.sendRedirect(request.getContextPath() + "/electives" + (query != null ? "?" + query : ""));
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Electives Catalogue | Electra</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="assets/css/style.css">
    <link rel="stylesheet" href="assets/css/sidebar.css">
    <link rel="stylesheet" href="assets/css/dashboard.css">
    <link rel="stylesheet" href="assets/css/electives.css">
    <link rel="stylesheet" href="assets/css/app-polish.css">
    <style>
      .student-view-content{max-width:1280px;margin:0 auto}
      .catalogue-intro{padding:30px 32px;border-radius:18px;background:#4A231A;color:#F8F3ED;margin-bottom:30px;display:flex;justify-content:space-between;align-items:center;gap:25px}
      .catalogue-intro .eyebrow{color:#E7B69D}
      .catalogue-intro h1{font-family:Georgia,serif;font-weight:400;font-size:clamp(2rem,4vw,3rem);margin:8px 0 12px}
      .catalogue-intro p{color:#F0DDD1;max-width:650px;margin:0;line-height:1.75}
      .intro-mark{width:105px;height:105px;border:1px solid #BFA18B;border-radius:50%;display:grid;place-items:center;font:4.5rem Georgia,serif;color:#E7C5A7;flex-shrink:0}
      .catalogue-tools{display:grid;grid-template-columns:minmax(0,2fr) minmax(220px,1fr);gap:16px;background:#fff;border:1px solid #EFE7DE;border-radius:14px;padding:20px;margin-bottom:22px}
      .catalogue-tools label{font-size:.85rem;font-weight:600;color:#4C4039;margin-bottom:8px}
      .catalogue-tools .form-control,.catalogue-tools .form-select{min-height:44px;border-color:#DCCBB9;border-radius:9px}
      .student-elective-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:20px}
      .student-elective-card{background:#fff;border:1px solid #EFE7DE;border-radius:15px;overflow:hidden;display:flex;flex-direction:column;min-height:300px;transition:transform .2s,box-shadow .2s}
      .student-elective-card:hover{transform:translateY(-4px);box-shadow:0 12px 28px #432c2014}
      .student-elective-card-head{background:#F1E4D5;padding:20px;display:flex;align-items:center;justify-content:space-between;gap:12px}
      .student-elective-card-head .elective-number{display:grid;place-items:center;width:42px;height:42px;border-radius:12px;background:#4A231A;color:#F8F3ED;font:1.1rem Georgia,serif}
      .student-elective-card-head .category-tag{font-size:.72rem;background:#fff;color:#4A231A;border-radius:30px;padding:6px 10px;font-weight:600}
      .student-elective-card-body{padding:22px;display:flex;flex:1;flex-direction:column}
      .student-elective-card-body .elective-code{font-size:.75rem;font-weight:700;letter-spacing:1px;color:#A46A50}
      .student-elective-card-body h3{font:400 1.45rem/1.3 Georgia,serif;color:#2C2623;margin:8px 0 10px}
      .student-elective-card-body p{font-size:.9rem;line-height:1.7;color:#776A61}
      .elective-card-meta{margin-top:auto;padding-top:15px;border-top:1px solid #F0E7DE;display:flex;justify-content:space-between;gap:10px;color:#6D5E53;font-size:.85rem}
      .elective-card-meta strong{color:#42362F}
      .student-view-note{background:#F1E4D5;padding:15px 18px;border-radius:10px;color:#66564A;margin:22px 0;font-size:.88rem}
      .student-view-empty{display:none;text-align:center;background:#fff;border:1px dashed #DCCBB9;border-radius:14px;padding:45px 20px;color:#776A61}
      .student-view-empty.show{display:block}
      .student-view-bottom{margin-top:35px;padding:28px 30px;border-radius:16px;background:#EFE1D0;display:flex;align-items:center;justify-content:space-between;gap:20px}
      .student-view-bottom h2{font:400 1.7rem Georgia,serif;margin:5px 0}
      .student-view-bottom p{margin:0;color:#76675B}
      .student-view-bottom .btn{background:#4A231A;color:white;border-radius:9px;padding:11px 16px;white-space:nowrap}
      .student-view-bottom .btn:hover{background:#855E4E}
      @media(max-width:1000px){.student-elective-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}
      @media(max-width:700px){.catalogue-intro{padding:25px;}.intro-mark{display:none}.catalogue-tools{grid-template-columns:1fr}.student-elective-grid{grid-template-columns:1fr}.student-view-bottom{align-items:flex-start;flex-direction:column}}
    </style>
</head>
<body data-user-id="${sessionScope.userId}" data-role="${sessionScope.role}">
<div class="app-layout">
    <jsp:include page="/WEB-INF/partials/sidebar.jsp">
        <jsp:param name="active" value="electives"/>
    </jsp:include>
    <main class="main-content">
        <header class="topbar">
            <div>
                <div class="topbar-label">Academic Workspace</div>
                <div class="topbar-title">Elective Catalogue</div>
            </div>
            <div class="topbar-right">
                <span class="status-dot"></span>
                <span class="academic-year">Academic Year 2026–27</span>
            </div>
        </header>

        <section class="page-content student-view-content">
            <section class="catalogue-intro">
                <div>
                    <span class="eyebrow">YOUR ACADEMIC JOURNEY</span>
                    <h1>Explore what <em>moves you.</em></h1>
                    <p>Discover departmental electives, compare subject areas, check seat capacities and minimum CGPA eligibility.</p>
                </div>
                <div class="intro-mark" aria-hidden="true">E</div>
            </section>

            <div class="section-heading">
                <div>
                    <h2>Department Electives</h2>
                    <p>Live departmental offerings for Academic Year 2026–27.</p>
                </div>
                <span class="catalogue-count" id="electiveCount">${electives.size()} electives</span>
            </div>

            <div class="catalogue-tools">
                <div>
                    <label for="searchInput">Search electives</label>
                    <input id="searchInput" type="search" class="form-control" placeholder="Search by name, code, or topic...">
                </div>
                <div>
                    <label for="formSelector">Filter by Allocation Form</label>
                    <select id="formSelector" class="form-select" onchange="window.location.href='${pageContext.request.contextPath}/electives?formId=' + this.value;">
                        <option value="">All Active Forms</option>
                        <c:forEach var="f" items="${forms}">
                            <option value="${f.formId}" ${selectedForm != null && selectedForm.formId == f.formId ? 'selected' : ''}>
                                <c:out value="${f.formName}"/> (<c:out value="${f.categoryName}"/>)
                            </option>
                        </c:forEach>
                    </select>
                </div>
            </div>

            <div class="student-view-note">
                <strong>Academic Notice:</strong> These electives are retrieved directly from the official department database. Allocation is merit-based according to CGPA, submission timestamp, and your ranked preferences.
            </div>

            <!-- LIVE ELECTIVE CARDS -->
            <div id="electiveGrid" class="student-elective-grid" aria-live="polite">
                <c:forEach var="item" items="${electives}" varStatus="loop">
                    <article class="student-elective-card" data-code="${item.electiveCode}" data-name="${item.electiveName}">
                        <div class="student-elective-card-head">
                            <span class="elective-number">${loop.count < 10 ? '0' : ''}${loop.count}</span>
                            <span class="category-tag">Form #${item.formId}</span>
                        </div>
                        <div class="student-elective-card-body">
                            <span class="elective-code"><c:out value="${item.electiveCode}"/></span>
                            <h3><c:out value="${item.electiveName}"/></h3>
                            <p><c:out value="${item.syllabus != null ? item.syllabus : 'Detailed syllabus and lecture schedule will be distributed by department faculty.'}"/></p>
                            <c:if test="${not empty item.facultyName}">
                                <div class="text-muted small mb-2">Faculty: <strong><c:out value="${item.facultyName}"/></strong></div>
                            </c:if>
                            <div class="elective-card-meta">
                                <span>Seats: <strong><c:out value="${item.totalSeats}"/></strong></span>
                                <span>Min CGPA: <strong><c:out value="${item.minCgpa != null ? item.minCgpa : 'None'}"/></strong></span>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>

            <c:if test="${empty electives}">
                <div class="student-view-empty show">
                    <h3>No electives currently found</h3>
                    <p>There are no active electives matching the current filter.</p>
                </div>
            </c:if>

            <section class="student-view-bottom">
                <div>
                    <span class="eyebrow">READY TO DECIDE?</span>
                    <h2>Your next step starts with a choice.</h2>
                    <p>Once you have explored the catalogue, arrange your preferences in order of priority.</p>
                </div>
                <a href="${pageContext.request.contextPath}/preferences" class="btn">
                    Rank My Preferences <span aria-hidden="true">→</span>
                </a>
            </section>

            <footer class="page-footer">
                <span>Electra</span> &bull; Departmental Elective Allocation System &bull; <span class="footer-year">2026–27</span>
            </footer>
        </section>
    </main>
</div>

<script>
    // Client-side quick search
    document.getElementById("searchInput")?.addEventListener("input", function(e) {
        const query = e.target.value.toLowerCase().trim();
        const cards = document.querySelectorAll(".student-elective-card");
        let visibleCount = 0;
        cards.forEach(card => {
            const text = (card.dataset.code + " " + card.dataset.name + " " + card.innerText).toLowerCase();
            const matches = text.includes(query);
            card.style.display = matches ? "flex" : "none";
            if (matches) visibleCount++;
        });
        const countBadge = document.getElementById("electiveCount");
        if (countBadge) countBadge.textContent = visibleCount + (visibleCount === 1 ? " elective" : " electives");
    });
</script>
</body>
</html>
