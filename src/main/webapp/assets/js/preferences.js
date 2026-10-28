document.addEventListener("DOMContentLoaded", function () {
    const preferenceForm = document.getElementById("preferenceForm");
    const fieldsContainer = document.getElementById("preferenceFields");
    let preferenceSelects = [];

    function populatePreferenceOptions() {
        if (!fieldsContainer) return;
        const currentElectives = getAvailableElectives();
        const saved = getSavedPreferences();
        const savedIds = saved && Array.isArray(saved.preferences) ? saved.preferences.map(String) : [];
        fieldsContainer.replaceChildren();
        preferenceSelects = [];
        currentElectives.forEach(function (elective, index) {
            const field = document.createElement("div");
            field.className = "preference-field";
            const label = document.createElement("label");
            label.htmlFor = "preference" + (index + 1);
            const rank = document.createElement("span");
            rank.className = "rank-number";
            rank.textContent = String(index + 1).padStart(2, "0");
            label.appendChild(rank);
            label.appendChild(document.createTextNode("Rank " + (index + 1)));
            const requirement = document.createElement("span");
            requirement.className = index === 0 ? "required-label" : "optional-label";
            requirement.textContent = index === 0 ? "Highest priority" : "Required ranking";
            label.appendChild(requirement);
            const select = document.createElement("select");
            select.id = "preference" + (index + 1);
            select.className = "form-select preference-select";
            select.required = true;
            const placeholder = document.createElement("option");
            placeholder.value = "";
            placeholder.textContent = "Choose an elective for rank " + (index + 1);
            select.appendChild(placeholder);
            currentElectives.forEach(function (item) {
                const option = document.createElement("option");
                option.value = String(item.id);
                option.textContent = item.code + " — " + item.name;
                select.appendChild(option);
            });
            if (savedIds[index] && [...select.options].some(option => option.value === savedIds[index])) {
                select.value = savedIds[index];
            }
            const hint = document.createElement("small");
            hint.textContent = index === 0 ? "Your most preferred elective." : "Choose the elective you want at this rank.";
            field.append(label, select, hint);
            fieldsContainer.appendChild(field);
            preferenceSelects.push(select);
            select.addEventListener("change", function () {
                clearPreferenceMessage();
                updatePreferenceSummary();
            });
        });
    }

    function updatePreferenceSummary() {
        const selectedIds = getSelectedPreferenceIds();
        const chosenIds = selectedIds.filter(Boolean);
        const currentElectives = getAvailableElectives();
        const progress = document.getElementById("preferenceProgress");
        const progressText = document.getElementById("preferenceProgressText");
        const summary = document.getElementById("preferenceSummary");
        const total = currentElectives.length;
        if (progress) {
            progress.style.width = (total ? chosenIds.length / total * 100 : 0) + "%";
            progress.setAttribute("aria-valuemin", "0");
            progress.setAttribute("aria-valuemax", String(total));
            progress.setAttribute("aria-valuenow", String(chosenIds.length));
        }
        if (progressText) progressText.textContent = chosenIds.length + " of " + total + " electives ranked";
        if (summary) {
            summary.replaceChildren();
            selectedIds.forEach(function (id, index) {
                const elective = currentElectives.find(item => String(item.id) === String(id));
                const line = document.createElement("p");
                line.className = "summary-item";
                const rank = document.createElement("span");
                rank.className = "summary-rank";
                rank.textContent = String(index + 1).padStart(2, "0");
                const name = document.createElement("span");
                name.textContent = id && elective ? elective.code + " — " + elective.name : "Not ranked yet";
                line.append(rank, name);
                summary.appendChild(line);
            });
            if (!selectedIds.length) {
                const empty = document.createElement("p");
                empty.className = "summary-empty";
                empty.textContent = "Your rankings will appear here.";
                summary.appendChild(empty);
            }
        }
        // Keep each elective unique across all ranks.
        preferenceSelects.forEach(function (select) {
            const otherSelectedIds = selectedIds.filter((id, index) => id && preferenceSelects[index] !== select);
            [...select.options].forEach(function (option) {
                if (option.value) option.disabled = otherSelectedIds.includes(option.value);
            });
        });
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
            if (description) description.textContent = "Submit your elective preferences to see them here.";
            if (badge) badge.textContent = "Not submitted";
            if (noPreferences) noPreferences.classList.remove("d-none");
            return;
        }
        if (heading) heading.textContent = "Preferences submitted";
        if (description) description.textContent = "Your saved rankings are shown below. Final allocation is not yet available.";
        if (badge) badge.textContent = saved.status || "Pending";
        if (noPreferences) noPreferences.classList.add("d-none");
        saved.preferences.forEach(function (id, index) {
            const elective = currentElectives.find(item => String(item.id) === String(id));
            const row = document.createElement("li");
            row.className = "list-group-item";
            row.textContent = (index + 1) + ". " + (elective ? elective.code + " — " + elective.name : "Elective no longer available");
            savedList.appendChild(row);
        });
    }

    if (preferenceForm) {
        populatePreferenceOptions();
        updatePreferenceSummary();
        preferenceForm.addEventListener("submit", function (event) {
            event.preventDefault();
            const result = validatePreferences();
            if (!result.valid) {
                showPreferenceMessage(result.message, "danger");
                return;
            }
            if (!savePreferencesToBrowser(getSelectedPreferenceIds())) {
                showPreferenceMessage("Could not save preferences. Check browser storage settings.", "danger");
                return;
            }
            showPreferenceMessage("All elective rankings saved successfully. Your allocation status is pending.", "success");
        });
        const resetButton = document.getElementById("resetPreferences");
        if (resetButton) resetButton.addEventListener("click", function () {
            preferenceForm.reset();
            localStorage.removeItem("electraPreferences");
            clearPreferenceMessage();
            updatePreferenceSummary();
        });
    }
    renderAllocationResults();
});
