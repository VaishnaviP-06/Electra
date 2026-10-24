document.addEventListener("DOMContentLoaded", function () {
    const profileForm = document.getElementById("profileForm");
    const messageBox = document.getElementById("profileMessage");

    const fields = {
        name: document.getElementById("studentName"),
        email: document.getElementById("studentEmail"),
        roll: document.getElementById("studentRoll"),
        department: document.getElementById("studentDepartment"),
        year: document.getElementById("studentYear"),
        cgpa: document.getElementById("studentCGPA")
    };

    const storageKey = "electraStudentProfile";

    function showMessage(message, type) {
        messageBox.textContent = message;
        messageBox.className = "alert alert-" + type;
    }

    function getDefaultProfile() {
        const demoUser = sessionStorage.getItem("electraDemoUser") || "";

        return {
            name: demoUser,
            email: "",
            roll: "",
            department: "CMPN",
            year: "Third Year",
            cgpa: ""
        };
    }

    function renderProfile(profile) {
        fields.name.value = profile.name || "";
        fields.email.value = profile.email || "";
        fields.roll.value = profile.roll || "";
        fields.department.value = profile.department || "";
        fields.year.value = profile.year || "";
        fields.cgpa.value = profile.cgpa ?? "";

        document.getElementById("profileDisplayName").textContent =
            profile.name || "Student Name";

        document.getElementById("profileDisplayEmail").textContent =
            profile.email || "No email added";

        document.getElementById("profileDisplayDepartment").textContent =
            profile.department || "Not specified";

        document.getElementById("profileDisplayYear").textContent =
            profile.year || "Not specified";

        document.getElementById("profileDisplayRoll").textContent =
            profile.roll || "Not specified";

        const initials = (profile.name || "Student")
            .trim()
            .split(/\s+/)
            .slice(0, 2)
            .map(part => part.charAt(0).toUpperCase())
            .join("");

        document.getElementById("profileInitials").textContent = initials;
    }

    function loadProfile() {
        try {
            const savedProfile = localStorage.getItem(storageKey);
            const profile = savedProfile
                ? JSON.parse(savedProfile)
                : getDefaultProfile();

            renderProfile(profile);
        } catch (error) {
            renderProfile(getDefaultProfile());
            showMessage("Could not load the saved profile.", "warning");
        }
    }

    profileForm.addEventListener("submit", function (event) {
        event.preventDefault();

        const cgpa = Number(fields.cgpa.value);

        if (fields.name.value.trim().length < 2) {
            showMessage("Enter a valid full name.", "danger");
            return;
        }

        if (!fields.email.validity.valid) {
            showMessage("Enter a valid email address.", "danger");
            return;
        }

        if (!Number.isFinite(cgpa) || cgpa < 0 || cgpa > 10) {
            showMessage("CGPA must be between 0 and 10.", "danger");
            return;
        }

        const profile = {
            name: fields.name.value.trim(),
            email: fields.email.value.trim(),
            roll: fields.roll.value.trim(),
            department: fields.department.value,
            year: fields.year.value,
            cgpa: cgpa
        };

        try {
            localStorage.setItem(storageKey, JSON.stringify(profile));
            renderProfile(profile);
            showMessage("Profile saved successfully in this browser.", "success");
        } catch (error) {
            showMessage("Unable to save the profile in browser storage.", "danger");
        }
    });

    profileForm.addEventListener("reset", function () {
        setTimeout(function () {
            loadProfile();
            messageBox.className = "alert d-none";
        }, 0);
    });

    loadProfile();
});
