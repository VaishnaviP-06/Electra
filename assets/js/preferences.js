
document.addEventListener("DOMContentLoaded", function () {
    const preferenceForm = document.getElementById("preferenceForm");

    const preferenceSelects = [
        document.getElementById("preference1"),
        document.getElementById("preference2"),
        document.getElementById("preference3")
    ].filter(Boolean);

    function populatePreferenceOptions() {
        const currentElectives = getAvailableElectives();

        preferenceSelects.forEach(function (select) {
            const oldValue = select.value;

            select.replaceChildren();

            const placeholder = document.createElement("option");
            placeholder.value = "";
            placeholder.textContent = "Select an elective";
            select.appendChild(placeholder);

            currentElectives.forEach(function (item) {
                const option = document.createElement("option");
                option.value = String(item.id);
                option.textContent = item.code + " — " + item.name;
                select.appendChild(option);
            });

            if ([...select.options].some(option => option.value === oldValue)) {
                select.value = oldValue;
            }
        });
    }

    function updatePreferenceSummary() {
        const selectedIds = getSelectedPreferenceIds();
        const chosenIds = selectedIds.filter(Boolean);
        const currentElectives = getAvailableElectives();

        const progress = document.getElementById("preferenceProgress");
        const progressText = document.getElementById("preferenceProgressText");
        const summary = document.getElementById("preferenceSummary");

        if (progress) {
            progress.style.width = (chosenIds.length / 3 * 100) + "%";
            progress.setAttribute("aria-valuenow", chosenIds.length);
        }

        if (progressText) {
            progressText.textContent = chosenIds.length + " of 3 preferences selected";
        }

        if (summary) {
            summary.replaceChildren();

            selectedIds.forEach(function (id, index) {
                const elective = currentElectives.find(
                    item => String(item.id) === String(id)
                );

                const line = document.createElement("p");
                line.className = "mb-2";

                line.textContent = id && elective
                    ? (index + 1) + ". " + elective.code + " — " + elective.name
                    : (index + 1) + ". Not selected";

                summary.appendChild(line);
            });
        }

        // Avoid allowing the same elective to be chosen twice.
        preferenceSelects.forEach(function (select) {
            const otherSelectedIds = selectedIds.filter(
                (id, index) => id && preferenceSelects[index] !== select
            );

            [...select.options].forEach(function (option) {
                if (!option.value) return;

                option.disabled = otherSelectedIds.includes(option.value);
            });
        });
    }

    function restorePreferences() {
        const saved = getSavedPreferences();

        if (!saved || !Array.isArray(saved.preferences)) return;

        preferenceSelects.forEach(function (select, index) {
            select.value = String(saved.preferences[index] || "");
        });

        updatePreferenceSummary();
    }

    function renderAllocationResults() {
        const heading = document.getElementById("resultStatusHeading");
        const description = document.getElementById("resultStatusDescription");
        const badge = document.getElementById("resultStatusBadge");
        const savedList = document.getElementById("savedPreferences");
        const noPreferences = document.getElementById("noPreferences");

        if (!savedList) return;

        savedList.replaceChildren();

        const saved = getSavedPreferences();
        const currentElectives = getAvailableElectives();

        if (!saved || !Array.isArray(saved.preferences) || saved.preferences.length === 0) {
            if (heading) heading.textContent = "No preferences submitted";
            if (description) {
                description.textContent = "Submit your elective preferences to see them here.";
            }
            if (badge) badge.textContent = "Not submitted";
            if (noPreferences) noPreferences.classList.remove("d-none");

            return;
        }

        if (heading) heading.textContent = "Preferences submitted";
        if (description) {
            description.textContent =
                "Your saved preferences are shown below. Final allocation is not yet available.";
        }
        if (badge) badge.textContent = saved.status || "Pending";
        if (noPreferences) noPreferences.classList.add("d-none");

        saved.preferences.forEach(function (id, index) {
            const elective = currentElectives.find(
                item => String(item.id) === String(id)
            );

            const row = document.createElement("li");
            row.className = "list-group-item";

            row.textContent = (index + 1) + ". " +
                (elective
                    ? elective.code + " — " + elective.name
                    : "Elective no longer available");

            savedList.appendChild(row);
        });
    }

    preferenceSelects.forEach(function (select) {
        select.addEventListener("change", function () {
            clearPreferenceMessage();
            updatePreferenceSummary();
        });
    });

    if (preferenceForm) {
        populatePreferenceOptions();
        restorePreferences();
        updatePreferenceSummary();

        preferenceForm.addEventListener("submit", function (event) {
            event.preventDefault();

            const result = validatePreferences();

            if (!result.valid) {
                showPreferenceMessage(result.message, "danger");
                return;
            }

            const selected = getSelectedPreferenceIds().filter(Boolean);

            if (!savePreferencesToBrowser(selected)) {
                showPreferenceMessage(
                    "Could not save preferences. Check browser storage settings.",
                    "danger"
                );
                return;
            }

            showPreferenceMessage(
                "Preferences saved successfully. Your allocation status is pending.",
                "success"
            );
        });

        const resetButton = document.getElementById("resetPreferences");

        if (resetButton) {
            resetButton.addEventListener("click", function () {
                preferenceForm.reset();
                localStorage.removeItem("electraPreferences");
                clearPreferenceMessage();
                updatePreferenceSummary();
            });
        }
    }

    renderAllocationResults();
});
