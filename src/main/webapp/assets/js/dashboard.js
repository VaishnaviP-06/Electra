// Authentication and role authorization are handled by LoginServlet and AuthFilter.
// The sidebar (links, user card, sign-out) is rendered by WEB-INF/partials/sidebar.jsp.
const userId = document.body.dataset.userId || "Student";
const role = (document.body.dataset.role || "STUDENT").toLowerCase();
function icon(name, extraClass) {
    return `<svg class="icon ${extraClass || ""}" aria-hidden="true" focusable="false"><use href="#i-${name}"/></svg>`;
}
function actionCard(href, iconName, tone, title, text, linkText) {
    return `
            <a href="${href}" class="action-card">
                <div class="action-icon icon-${tone}">${icon(iconName)}</div>
                <h3>${title}</h3>
                <p>${text}</p>
                <span class="action-link">${linkText} ${icon("arrow", "icon-sm")}</span>
            </a>`;
}
function initializeDashboard() {
    const isAdmin = role === "admin";
    document.getElementById("welcomeTitle").textContent =
        `Welcome back, ${userId}!`;
    document.getElementById("welcomeDescription").textContent =
        isAdmin
            ? "Manage departmental electives and oversee student allocation."
            : "Explore electives, rank all available options and track your allocation.";
    if (isAdmin) {
        document.getElementById("pageTitle").textContent = "Admin Dashboard";
        document.getElementById("noticeTitle").textContent =
            "Allocation management";
        document.getElementById("noticeText").textContent =
            "Review student preferences and configure allocation settings before generating results.";
        document.getElementById("preferenceCount").textContent = "—";
        document.getElementById("preferenceCaption").textContent =
            "Submission statistics will appear here";
        document.getElementById("allocationStatus").textContent = "Pending";
        document.getElementById("allocationCaption").textContent =
            "Allocation has not been run";
        document.getElementById("quickActionsTitle").textContent =
            "Administrative Actions";
        document.getElementById("quickActionsDescription").textContent =
            "Manage the elective allocation process.";
        document.getElementById("actionsGrid").innerHTML =
            actionCard("admin-electives.jsp", "book", "sand", "Manage Electives",
                "Add subjects, configure seat capacity and maintain syllabus details.", "Manage subjects") +
            actionCard("admin-students.jsp", "users", "terracotta", "Manage Students",
                "Review student records and eligibility information.", "View students") +
            actionCard("admin-allocations.jsp", "report", "sage", "Allocation Reports",
                "Review allocation outcomes and prepare final reports.", "View reports");
    }
}
initializeDashboard();
