const loginForm = document.getElementById("loginForm");
const passwordInput = document.getElementById("password");
const togglePassword = document.getElementById("togglePassword");
const loginMessage = document.getElementById("loginMessage");
togglePassword.addEventListener("click", function () {
    const isHidden = passwordInput.type === "password";
    passwordInput.type = isHidden ? "text" : "password";
    togglePassword.textContent = isHidden ? "Hide" : "Show";
});
loginForm.addEventListener("submit", function (event) {
    event.preventDefault();
    const role = document.getElementById("role").value;
    const userId = document.getElementById("userId").value.trim();
    const password = passwordInput.value;
    loginMessage.className = "alert mt-3 d-none";
    loginMessage.textContent = "";
    if (!userId || !password.trim()) {
        showMessage("Please enter your user ID and password.", "danger");
        return;
    }
    /*
     * DEMO ONLY:
     * This does not authenticate users securely.
     * Replace with LoginServlet and MySQL authentication later.
     */
    sessionStorage.setItem("electraDemoUser", userId);
    sessionStorage.setItem("electraDemoRole", role);
    window.location.href = "dashboard.jsp";
});
document.getElementById("forgotLink").addEventListener("click", function (event) {
    event.preventDefault();
    showMessage(
        "Password recovery will be available after backend integration.",
        "warning"
    );
});
function showMessage(message, type) {
    loginMessage.textContent = message;
    loginMessage.className = "alert mt-3 alert-" + type;
}