function getSelectedPreferenceIds() {
    return Array.from(document.querySelectorAll("#preferenceFields .preference-select"))
        .map(select => select.value || "");
}
function validatePreferences() {
    const selected = getSelectedPreferenceIds();
    const chosen = selected.filter(Boolean);
    const available = getAvailableElectives().map(item => String(item.id));
    if (available.length === 0) {
        return { valid: false, message: "No electives are currently available to rank." };
    }
    if (chosen.length !== available.length || selected.some(id => !id)) {
        return {
            valid: false,
            message: "Please rank every available elective before saving your preferences."
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
