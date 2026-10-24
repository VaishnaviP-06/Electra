
function getSelectedPreferenceIds() {
    return [
        document.getElementById("preference1")?.value || "",
        document.getElementById("preference2")?.value || "",
        document.getElementById("preference3")?.value || ""
    ];
}

function validatePreferences() {
    const selected = getSelectedPreferenceIds();
    const chosen = selected.filter(Boolean);
    const available = getAvailableElectives().map(item => String(item.id));

    if (!selected[0]) {
        return {
            valid: false,
            message: "Please select your first preference."
        };
    }

    if (new Set(chosen).size !== chosen.length) {
        return {
            valid: false,
            message: "Please choose a different elective for each preference."
        };
    }

    if (chosen.some(id => !available.includes(String(id)))) {
        return {
            valid: false,
            message: "One of your selected electives is no longer available. Please select again."
        };
    }

    return {
        valid: true,
        message: "Your preferences are valid."
    };
}

function showPreferenceMessage(message, type = "info") {
    const box = document.getElementById("validationMessage");

    if (!box) return;

    box.textContent = message;
    box.className = "alert alert-" + type;
}

function clearPreferenceMessage() {
    const box = document.getElementById("validationMessage");

    if (!box) return;

    box.textContent = "";
    box.className = "alert d-none";
}

function savePreferencesToBrowser(preferences) {
    try {
        const record = {
            preferences: preferences,
            submittedAt: new Date().toISOString(),
            status: "Pending"
        };

        localStorage.setItem("electraPreferences", JSON.stringify(record));
        return true;
    } catch (error) {
        console.error("Unable to save preferences:", error);
        return false;
    }
}

function getSavedPreferences() {
    try {
        const stored = localStorage.getItem("electraPreferences");
        return stored ? JSON.parse(stored) : null;
    } catch (error) {
        console.error("Unable to read preferences:", error);
        return null;
    }
}
