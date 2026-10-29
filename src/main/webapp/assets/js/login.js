/* ========================================================== ELECTRA LOGIN PAGE INTERACTIONS ========================================================== */
document.addEventListener('DOMContentLoaded', function () {
    const loginForm = document.getElementById('loginForm');
    const passwordInput = document.getElementById('password');
    const togglePassword = document.getElementById('togglePassword');
    const loginMessage = document.getElementById('loginMessage');
    const forgotLink = document.getElementById('forgotLink');
    const forgotModal = document.getElementById('forgotModal');
    const closeForgotModal = document.getElementById('closeForgotModal');
    const userIdError = document.getElementById('userIdError');
    const passwordError = document.getElementById('passwordError');

    /* * STUDENT / ADMIN ROLE SWITCHING */
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

        // Update the user ID label and input details
        idLabel.innerHTML = isStudent
            ? 'Student Identifier <span>*</span>'
            : 'Administrator Username <span>*</span>';

        userId.type = 'text';
        userId.placeholder = isStudent
            ? 'Enter email, roll number, or username'
            : 'Enter administrator username';

        if (emailHint) {
            emailHint.style.display = isStudent ? '' : 'none';
        }

        subtitle.textContent = isStudent
            ? 'Access your academic portal and manage your elective preferences, submissions and results.'
            : 'Access administrative tools to manage elective forms, seat capacity and allocation results.';

        clearFieldErrors();
        clearMessage();
    };

    /* * SHOW / HIDE PASSWORD */
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

    /* * FORM VALIDATION WITH INLINE ERRORS */
    if (loginForm) {
        loginForm.addEventListener('submit', function (event) {
            const userIdInput = document.getElementById('userId');
            const identifier = userIdInput.value.trim();
            const password = passwordInput.value;

            clearFieldErrors();
            clearMessage();
            let hasError = false;

            if (!identifier) {
                setFieldError(userIdError, 'Please enter your login identifier.');
                userIdInput.focus();
                hasError = true;
            }

            // Simple password policy: at least 8 characters
            if (!password) {
                setFieldError(passwordError, 'Please enter your password.');
                if (!hasError) {
                    passwordInput.focus();
                }
                hasError = true;
            } else if (password.length < 8) {
                setFieldError(passwordError, 'Password must be at least 8 characters long.');
                if (!hasError) {
                    passwordInput.focus();
                }
                hasError = true;
            } else if (password.length > 72) {
                setFieldError(passwordError, 'Password cannot exceed 72 characters.');
                if (!hasError) {
                    passwordInput.focus();
                }
                hasError = true;
            }

            if (hasError) {
                event.preventDefault();
                return;
            }

            userIdInput.value = identifier;
        });
    }

    /* * INLINE ERROR HELPERS */
    function setFieldError(element, message) {
        if (element) {
            element.textContent = message;
            element.style.display = 'block';
        }
    }

    function clearFieldErrors() {
        if (userIdError) {
            userIdError.textContent = '';
            userIdError.style.display = 'none';
        }
        if (passwordError) {
            passwordError.textContent = '';
            passwordError.style.display = 'none';
        }
    }

    /* * FORGOT PASSWORD MODAL */
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

    /* * DISPLAY VALIDATION MESSAGES */
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

    /* * INITIALIZE THE DEFAULT STUDENT ROLE */
    window.switchRole('student');
});
