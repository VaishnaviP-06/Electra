
/* ========================================
   ELECTRA - REUSABLE VALIDATION
   ======================================== */

function getSelectedPreferenceIds() {
    return [
        document.getElementById("preference1")?.value || "",
        document.getElementById("preference2")?.value || "",
        document.getElementById("preference3")?.value || ""
    ];
}

function validatePreferences() {
    const selects = [
        document.getElementById("preference1"),
        document.getElementById("preference2"),
        document.getElementById("preference3")
    ];

    const selectedIds = getSelectedPreferenceIds();
    const filledIds = selectedIds.filter(Boolean);

    selects.forEach((select) => {
        if (select) {
            select.classList.remove("is-invalid");
        }
    });

    if (!selectedIds[0]) {
        selects[0]?.classList.add("is-invalid");

        return {
            valid: false,
            message: "Please select your first preference before saving."
        };
    }

    const uniqueIds = new Set(filledIds);

    if (uniqueIds.size !== filledIds.length) {
        const seen = new Set();

        selectedIds.forEach((id, index) => {
            if (!id) return;

            if (seen.has(id)) {
                selects[index]?.classList.add("is-invalid");
            }

            seen.add(id);
        });

        return {
            valid: false,
            message: "Each preference must be a different elective. Please remove duplicate choices."
        };
    }

    return {
        valid: true,
        message: ""
    };
}

function showPreferenceMessage(message, type) {
    const messageBox = document.getElementById("validationMessage");

    if (!messageBox) return;

    messageBox.textContent = message;
    messageBox.className = `form-feedback show ${type}`;
}

function clearPreferenceMessage() {
    const messageBox = document.getElementById("validationMessage");

    if (!messageBox) return;

    messageBox.textContent = "";
    messageBox.className = "form-feedback";
}

function savePreferencesToBrowser(preferences) {
    try {
        localStorage.setItem(
            "electraPreferences",
            JSON.stringify({
                preferences: preferences,
                submittedAt: new Date().toISOString(),
                status: "Pending"
            })
        );

        return true;
    } catch (error) {
        console.error("Could not save preferences:", error);
        return false;
    }
}

function getSavedPreferences() {
    try {
        const saved = localStorage.getItem("electraPreferences");

        if (!saved) return null;

        const parsed = JSON.parse(saved);

        if (!parsed || !Array.isArray(parsed.preferences)) {
            return null;
        }

        return parsed;
    } catch (error) {
        console.error("Could not read saved preferences:", error);
        return null;
    }
}
