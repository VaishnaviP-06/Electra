/* ==========================================================
   ELECTRA LOGIN PAGE INTERACTIONS
   ========================================================== */
document.addEventListener('DOMContentLoaded', function () {
    const loginForm = document.getElementById('loginForm');
    const passwordInput = document.getElementById('password');
    const togglePassword = document.getElementById('togglePassword');
    const loginMessage = document.getElementById('loginMessage');
    const forgotLink = document.getElementById('forgotLink');
    const forgotModal = document.getElementById('forgotModal');
    const closeForgotModal = document.getElementById('closeForgotModal');
    const STUDENT_EMAIL_DOMAIN = '@student.sfit.ac.in';
    /*
     * STUDENT / ADMIN ROLE SWITCHING
     */
    window.switchRole = function (role) {
        const roleInput = document.getElementById('role');
        const studentBtn = document.getElementById('studentBtn');
        const adminBtn = document.getElementById('adminBtn');
        const idLabel = document.getElementById('idLabel');
        const userId = document.getElementById('userId');
        const subtitle = document.getElementById('cardSubtitle');
        const emailHint = document.getElementById('emailHint');
        const isStudent = role === 'student';
        roleInput.value = role;
        studentBtn.classList.toggle('active', isStudent);
        adminBtn.classList.toggle('active', !isStudent);
        studentBtn.setAttribute('aria-pressed', String(isStudent));
        adminBtn.setAttribute('aria-pressed', String(!isStudent));
        // Update the user ID label.
        idLabel.innerHTML = isStudent
            ? 'Student Email ID <span>*</span>'
            : 'Administrator ID <span>*</span>';
        // Update the input type and placeholder.
        userId.type = isStudent ? 'email' : 'text';
        userId.placeholder = isStudent
            ? 'Enter your student email ID'
            : 'Enter your administrator ID';
        // Show the domain hint only for students.
        if (emailHint) {
            emailHint.style.display = isStudent ? '' : 'none';
        }
        // Update the form description.
        subtitle.textContent = isStudent
            ? 'Access your academic portal and manage your elective preferences, submissions and results.'
            : 'Access administrative tools to manage elective forms, seat capacity and allocation results.';
        clearMessage();
    };
    /*
     * SHOW / HIDE PASSWORD
     */
    if (togglePassword && passwordInput) {
        togglePassword.addEventListener('click', function () {
            const shouldShow = passwordInput.type === 'password';
            passwordInput.type = shouldShow ? 'text' : 'password';
            togglePassword.textContent = shouldShow ? 'Hide' : 'Show';
            togglePassword.setAttribute(
                'aria-label',
                shouldShow ? 'Hide password' : 'Show password'
            );
        });
    }
    /*
     * FORM VALIDATION
     */
    if (loginForm) {
        loginForm.addEventListener('submit', function (event) {
            const role = document.getElementById('role').value;
            const userIdInput = document.getElementById('userId');
            const userId = userIdInput.value.trim();
            const password = passwordInput.value;
            // Check required fields.
            if (!userId || !password.trim()) {
                event.preventDefault();
                showMessage(
                    'Please enter your login ID and password.',
                    'danger'
                );
                return;
            }
            // Student email domain validation.
            if (role === 'student') {
                const normalizedEmail = userId.toLowerCase();
                if (
                    !normalizedEmail.endsWith(STUDENT_EMAIL_DOMAIN) ||
                    normalizedEmail.length === STUDENT_EMAIL_DOMAIN.length
                ) {
                    event.preventDefault();
                    showMessage(
                        'Students must log in using their official email ending in @student.sfit.ac.in.',
                        'danger'
                    );
                    userIdInput.focus();
                    return;
                }
                // Use the trimmed email for submission.
                userIdInput.value = normalizedEmail;
            }
            clearMessage();
            // Valid submissions continue to the existing login servlet.
        });
    }
    /*
     * FORGOT PASSWORD MODAL
     */
    function openForgotModal() {
        if (!forgotModal) {
            return;
        }
        forgotModal.classList.add('active');
        forgotModal.setAttribute('aria-hidden', 'false');
        if (closeForgotModal) {
            closeForgotModal.focus();
        }
    }
    function hideForgotModal() {
        if (!forgotModal) {
            return;
        }
        forgotModal.classList.remove('active');
        forgotModal.setAttribute('aria-hidden', 'true');
        if (forgotLink) {
            forgotLink.focus();
        }
    }
    if (forgotLink) {
        forgotLink.addEventListener('click', function (event) {
            event.preventDefault();
            openForgotModal();
        });
    }
    if (closeForgotModal) {
        closeForgotModal.addEventListener('click', hideForgotModal);
    }
    if (forgotModal) {
        forgotModal.addEventListener('click', function (event) {
            if (event.target === forgotModal) {
                hideForgotModal();
            }
        });
    }
    document.addEventListener('keydown', function (event) {
        if (
            event.key === 'Escape' &&
            forgotModal &&
            forgotModal.classList.contains('active')
        ) {
            hideForgotModal();
        }
    });
    /*
     * DISPLAY VALIDATION MESSAGES
     */
    function showMessage(message, type) {
        if (!loginMessage) {
            return;
        }
        loginMessage.textContent = message;
        loginMessage.className = 'alert mt-3 alert-' + type;
    }
    function clearMessage() {
        if (!loginMessage) {
            return;
        }
        loginMessage.textContent = '';
        loginMessage.className = 'alert mt-3 d-none';
    }
    /*
     * INITIALIZE THE DEFAULT STUDENT ROLE
     */
    window.switchRole('student');
});
