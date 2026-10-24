
/* ========================================
   ELECTRA - PREFERENCES AND RESULTS
   ======================================== */

const PREFERENCE_STORAGE_KEY = "electraPreferences";

/* Populate the three preference dropdowns */

function populatePreferenceDropdowns() {
    const selects = [
        document.getElementById("preference1"),
        document.getElementById("preference2"),
        document.getElementById("preference3")
    ];

    selects.forEach((select) => {
        if (!select) return;

        electives.forEach((elective) => {
            const option = document.createElement("option");

            option.value = elective.id;
            option.textContent = `${elective.code} — ${elective.name}`;

            select.appendChild(option);
        });
    });
}

/* Keep duplicate choices out of the other dropdowns */

function updatePreferenceOptions() {
    const selects = [
        document.getElementById("preference1"),
        document.getElementById("preference2"),
        document.getElementById("preference3")
    ];

    const selectedIds = selects
        .filter(Boolean)
        .map((select) => select.value)
        .filter(Boolean);

    selects.forEach((select) => {
        if (!select) return;

        Array.from(select.options).forEach((option) => {
            if (!option.value) return;

            const selectedElsewhere =
                selectedIds.includes(option.value) &&
                option.value !== select.value;

            option.disabled = selectedElsewhere;
        });
    });
}

/* Update the progress bar and summary panel */

function updatePreferenceSummary() {
    const selects = [
        document.getElementById("preference1"),
        document.getElementById("preference2"),
        document.getElementById("preference3")
    ];

    const summary = document.getElementById("preferenceSummary");
    const progress = document.getElementById("preferenceProgress");
    const progressText = document.getElementById("preferenceProgressText");

    if (!summary || !progress || !progressText) return;

    const selected = selects
        .map((select, index) => ({
            rank: index + 1,
            id: select?.value || ""
        }))
        .filter((item) => item.id);

    summary.innerHTML = "";

    progress.style.width = `${(selected.length / 3) * 100}%`;
    progressText.textContent =
        `${selected.length} of 3 preferences selected`;

    if (selected.length === 0) {
        const empty = document.createElement("p");
        empty.className = "summary-empty";
        empty.textContent = "Your selections will appear here.";
        summary.appendChild(empty);
        return;
    }

    selected.forEach((item) => {
        const elective = electives.find((e) => e.id === item.id);

        if (!elective) return;

        const row = document.createElement("div");
        row.className = "summary-item";

        const rank = document.createElement("span");
        rank.className = "summary-rank";
        rank.textContent = String(item.rank).padStart(2, "0");

        const details = document.createElement("div");

        const title = document.createElement("strong");
        title.textContent = elective.name;

        const code = document.createElement("small");
        code.textContent = elective.code;

        details.append(title, code);
        row.append(rank, details);
        summary.appendChild(row);
    });
}

/* Restore previously saved choices when the page opens */

function restoreSavedPreferences() {
    const saved = getSavedPreferences();

    if (!saved) return;

    const selects = [
        document.getElementById("preference1"),
        document.getElementById("preference2"),
        document.getElementById("preference3")
    ];

    saved.preferences.forEach((item, index) => {
        if (selects[index]) {
            selects[index].value = item.id;
        }
    });

    updatePreferenceOptions();
    updatePreferenceSummary();
}

/* Save the student's preferences */

function handlePreferenceSubmit(event) {
    event.preventDefault();

    const validation = validatePreferences();

    if (!validation.valid) {
        showPreferenceMessage(validation.message, "error");
        return;
    }

    const selectedIds = getSelectedPreferenceIds();

    const preferences = selectedIds
        .map((id, index) => ({
            id,
            rank: index + 1
        }))
        .filter((item) => item.id);

    const savedSuccessfully = savePreferencesToBrowser(preferences);

    if (!savedSuccessfully) {
        showPreferenceMessage(
            "Your choices could not be saved in this browser. Check your browser storage settings and try again.",
            "error"
        );
        return;
    }

    showPreferenceMessage(
        "Your preferences have been saved in this browser. This is a frontend demonstration, not an official submission.",
        "success"
    );

    updatePreferenceOptions();
    updatePreferenceSummary();
}

/* Clear current choices and saved demonstration data */

function clearPreferences() {
    const selects = [
        document.getElementById("preference1"),
        document.getElementById("preference2"),
        document.getElementById("preference3")
    ];

    selects.forEach((select) => {
        if (select) {
            select.value = "";
            select.classList.remove("is-invalid");
        }
    });

    try {
        localStorage.removeItem(PREFERENCE_STORAGE_KEY);
    } catch (error) {
        console.error("Could not clear saved preferences:", error);
    }

    clearPreferenceMessage();
    updatePreferenceOptions();
    updatePreferenceSummary();
}

/* Render saved preferences on the allocation results page */

function renderAllocationResults() {
    const resultsContainer = document.getElementById("savedPreferences");

    if (!resultsContainer) return;

    const noPreferences = document.getElementById("noPreferences");
    const resultActions = document.getElementById("resultActions");

    const statusHeading = document.getElementById("resultStatusHeading");
    const statusDescription = document.getElementById("resultStatusDescription");
    const statusBadge = document.getElementById("resultStatusBadge");

    const saved = getSavedPreferences();

    resultsContainer.innerHTML = "";

    if (!saved || saved.preferences.length === 0) {
        if (noPreferences) noPreferences.hidden = false;
        if (resultActions) resultActions.hidden = true;

        statusHeading.textContent = "No preferences submitted";
        statusDescription.textContent =
            "Choose and save your preferences to see them on this page.";

        statusBadge.textContent = "NOT SUBMITTED";
        statusBadge.className = "status-badge pending";

        return;
    }

    if (noPreferences) noPreferences.hidden = true;
    if (resultActions) resultActions.hidden = false;

    statusHeading.textContent = "Allocation pending";
    statusDescription.textContent =
        "Your preferences are saved locally. Final allocation has not been run or published.";

    statusBadge.textContent = "PENDING";
    statusBadge.className = "status-badge pending";

    saved.preferences
        .slice()
        .sort((a, b) => a.rank - b.rank)
        .forEach((item) => {
            const elective = electives.find((e) => e.id === item.id);

            if (!elective) return;

            const row = document.createElement("div");
            row.className = "saved-preference-row";

            const rank = document.createElement("span");
            rank.className = "saved-preference-rank";
            rank.textContent = String(item.rank).padStart(2, "0");

            const details = document.createElement("div");
            details.className = "saved-preference-info";

            const title = document.createElement("h3");
            title.textContent = elective.name;

            const description = document.createElement("p");
            description.textContent =
                `${elective.code} · ${elective.category}`;

            const label = document.createElement("span");
            label.className = "preference-status-label";
            label.textContent = "Awaiting allocation";

            details.append(title, description, label);
            row.append(rank, details);

            resultsContainer.appendChild(row);
        });
}

/* Initialise the appropriate page */

document.addEventListener("DOMContentLoaded", () => {
    const preferenceForm = document.getElementById("preferenceForm");
    const resetButton = document.getElementById("resetPreferences");

    if (preferenceForm) {
        populatePreferenceDropdowns();
        restoreSavedPreferences();

        [
            document.getElementById("preference1"),
            document.getElementById("preference2"),
            document.getElementById("preference3")
        ].forEach((select) => {
            if (!select) return;

            select.addEventListener("change", () => {
                clearPreferenceMessage();
                select.classList.remove("is-invalid");
                updatePreferenceOptions();
                updatePreferenceSummary();
            });
        });

        preferenceForm.addEventListener("submit", handlePreferenceSubmit);

        if (resetButton) {
            resetButton.addEventListener("click", clearPreferences);
        }
    }

    renderAllocationResults();
});
