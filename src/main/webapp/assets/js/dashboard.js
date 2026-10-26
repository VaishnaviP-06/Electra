const userId = sessionStorage.getItem("electraDemoUser");
const role = sessionStorage.getItem("electraDemoRole");
if (!userId || !role) {
    window.location.replace("login.jsp");
} else {
    initializeDashboard();
}
function initializeDashboard() {
    const isAdmin = role === "admin";
    document.getElementById("sidebarUser").textContent = userId;
    document.getElementById("userAvatar").textContent =
        userId.charAt(0).toUpperCase();
    document.getElementById("sidebarRole").textContent =
        isAdmin ? "Admin / Faculty" : "Student";
    document.getElementById("welcomeTitle").textContent =
        `Welcome back, ${userId}!`;
    document.getElementById("welcomeDescription").textContent =
        isAdmin
            ? "Manage departmental electives and oversee student allocation."
            : "Explore electives, submit preferences and track your allocation.";
    document.getElementById("adminNavigation").classList.toggle(
        "d-none",
        !isAdmin
    );
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
        document.getElementById("actionsGrid").innerHTML = `
            <a href="admin-electives.jsp" class="action-card">
                <div class="action-icon icon-sand">&#9776;</div>
                <h3>Manage Electives</h3>
                <p>Add subjects, configure seat capacity and maintain syllabus details.</p>
                <span class="action-link">Manage subjects &#8594;</span>
            </a>
            <a href="admin-students.jsp" class="action-card">
                <div class="action-icon icon-terracotta">&#9787;</div>
                <h3>Manage Students</h3>
                <p>Review student records and eligibility information.</p>
                <span class="action-link">View students &#8594;</span>
            </a>
            <a href="admin-allocations.jsp" class="action-card">
                <div class="action-icon icon-sage">&#9636;</div>
                <h3>Allocation Reports</h3>
                <p>Review allocation outcomes and prepare final reports.</p>
                <span class="action-link">View reports &#8594;</span>
            </a>
        `;
        document.getElementById("electivesLink").textContent =
            "☷ Manage Electives";
        document.getElementById("preferencesLink").textContent =
            "⇅ Preference Monitor";
        document.getElementById("allocationLink").textContent =
            "✓ Allocation Results";
    }
}
document.getElementById("logoutButton").addEventListener("click", function () {
    sessionStorage.removeItem("electraDemoUser");
    sessionStorage.removeItem("electraDemoRole");
    window.location.replace("login.jsp");
});