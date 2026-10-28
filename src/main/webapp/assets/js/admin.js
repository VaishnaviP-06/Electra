document.addEventListener("DOMContentLoaded", function () {
    // ==========================================
    // DOM ELEMENTS
    // ==========================================
    const electiveForm = document.getElementById("electiveForm");
    const electiveTableBody = document.getElementById("electiveTableBody");
    const messageBox = document.getElementById("adminMessage");
    const totalElectivesElement = document.getElementById("totalElectives");
    const totalSeatsElement = document.getElementById("totalSeats");
    const resetButton = document.getElementById("resetDemoData");
    const exportButton = document.getElementById("exportElectivesXml");
    const electiveStorageKey = "electraAdminElectives";
    // ==========================================
    // DEFAULT DEMO ELECTIVES
    // ==========================================
    function getInitialElectives() {
        // Use the defaults from electives.js when available.
        if (
            typeof electraDefaultElectives !== "undefined" &&
            Array.isArray(electraDefaultElectives)
        ) {
            return electraDefaultElectives.map(function (item) {
                return { ...item };
            });
        }
        // Fallback if electives.js is unavailable.
        return [
            {
                id: "1",
                code: "EC501",
                name: "Cloud Computing",
                category: "Professional Elective",
                seats: 30,
                description: "Cloud platforms and services"
            },
            {
                id: "2",
                code: "EC502",
                name: "Cyber Security",
                category: "Departmental",
                seats: 35,
                description: "Security principles and practices"
            },
            {
                id: "3",
                code: "EC503",
                name: "Data Analytics",
                category: "Open Elective",
                seats: 40,
                description: "Data analysis and interpretation"
            },
            {
                id: "4",
                code: "EC504",
                name: "Artificial Intelligence",
                category: "Professional Elective",
                seats: 30,
                description: "AI concepts and intelligent systems"
            },
            {
                id: "5",
                code: "EC505",
                name: "Internet of Things",
                category: "Departmental",
                seats: 35,
                description: "Connected devices and IoT applications"
            }
        ];
    }
    // ==========================================
    // MESSAGE DISPLAY
    // ==========================================
    function showMessage(message, type) {
        if (!messageBox) {
            console[type === "danger" ? "error" : "log"](message);
            return;
        }
        messageBox.textContent = message;
        messageBox.className =
            "alert mt-4 alert-" + type;
        messageBox.setAttribute("role", "alert");
    }
    // ==========================================
    // LOAD ELECTIVES FROM LOCAL STORAGE
    // ==========================================
    function loadElectives() {
        try {
            const saved = localStorage.getItem(electiveStorageKey);
            if (saved !== null) {
                const parsed = JSON.parse(saved);
                if (Array.isArray(parsed)) {
                    return parsed;
                }
                throw new Error("Invalid elective data.");
            }
            const initial = getInitialElectives();
            localStorage.setItem(
                electiveStorageKey,
                JSON.stringify(initial)
            );
            return initial;
        } catch (error) {
            console.error("Unable to load electives:", error);
            showMessage(
                "Unable to load elective data from browser storage.",
                "danger"
            );
            return getInitialElectives();
        }
    }
    let managedElectives = loadElectives();
    // ==========================================
    // SAVE ELECTIVES
    // ==========================================
    function saveElectives() {
        try {
            localStorage.setItem(
                electiveStorageKey,
                JSON.stringify(managedElectives)
            );
            return true;
        } catch (error) {
            console.error("Unable to save electives:", error);
            showMessage(
                "Unable to save electives in browser storage.",
                "danger"
            );
            return false;
        }
    }
    // ==========================================
    // UPDATE SUMMARY STATISTICS
    // ==========================================
    function updateStatistics() {
        if (totalElectivesElement) {
            totalElectivesElement.textContent =
                managedElectives.length;
        }
        const totalSeats = managedElectives.reduce(
            function (total, item) {
                return total + (Number(item.seats) || 0);
            },
            0
        );
        if (totalSeatsElement) {
            totalSeatsElement.textContent = totalSeats;
        }
    }
    // ==========================================
    // RENDER ELECTIVE TABLE
    // ==========================================
    function renderElectives() {
        if (!electiveTableBody) {
            console.error("Elective table body was not found.");
            return;
        }
        electiveTableBody.replaceChildren();
        // Empty state.
        if (managedElectives.length === 0) {
            const row = document.createElement("tr");
            const cell = document.createElement("td");
            cell.colSpan = 5;
            cell.className = "text-center text-muted py-4";
            cell.textContent =
                "No electives available. Add one using the form above.";
            row.appendChild(cell);
            electiveTableBody.appendChild(row);
            updateStatistics();
            return;
        }
        managedElectives.forEach(function (item) {
            const row = document.createElement("tr");
            // Elective information cells.
            const values = [
                item.code ?? "—",
                item.name ?? "—",
                item.category ?? "—",
                String(item.seats ?? 0)
            ];
            values.forEach(function (value) {
                const cell = document.createElement("td");
                // textContent prevents HTML from being interpreted.
                cell.textContent = String(value);
                row.appendChild(cell);
            });
            // Action cell.
            const actionCell = document.createElement("td");
            const removeButton = document.createElement("button");
            removeButton.type = "button";
            removeButton.className = "admin-remove-btn";
            removeButton.textContent = "Remove";
            removeButton.setAttribute(
                "aria-label",
                "Remove elective " + String(item.code ?? "")
            );
            removeButton.addEventListener("click", function () {
                const confirmed = window.confirm(
                    "Remove " +
                    String(item.name ?? item.code ?? "this elective") +
                    " from the admin demo list?"
                );
                if (!confirmed) {
                    return;
                }
                const previousElectives = managedElectives;
                managedElectives = managedElectives.filter(
                    function (elective) {
                        return String(elective.id) !== String(item.id);
                    }
                );
                if (!saveElectives()) {
                    managedElectives = previousElectives;
                    return;
                }
                renderElectives();
                showMessage(
                    "Elective removed from the admin demo list.",
                    "success"
                );
            });
            actionCell.appendChild(removeButton);
            row.appendChild(actionCell);
            electiveTableBody.appendChild(row);
        });
        updateStatistics();
    }
    // ==========================================
    // ADD NEW ELECTIVE
    // ==========================================
    if (electiveForm) {
        electiveForm.addEventListener("submit", function (event) {
            event.preventDefault();
            const code = document.getElementById("electiveCode")
                .value.trim()
                .toUpperCase();
            const name = document.getElementById("electiveName")
                .value.trim();
            const category = document.getElementById("electiveCategory")
                .value;
            const seats = Number(
                document.getElementById("electiveSeats").value
            );
            const description =
                document.getElementById("electiveDescription")
                    .value.trim();
            // Required fields.
            if (!code || !name || !category) {
                showMessage(
                    "Please complete all required elective fields.",
                    "danger"
                );
                return;
            }
            // Seat validation.
            if (
                !Number.isInteger(seats) ||
                seats < 1 ||
                seats > 500
            ) {
                showMessage(
                    "Seats must be a whole number between 1 and 500.",
                    "danger"
                );
                return;
            }
            // Duplicate elective-code validation.
            const duplicate = managedElectives.some(
                function (item) {
                    return String(item.code ?? "").toUpperCase() === code;
                }
            );
            if (duplicate) {
                showMessage(
                    "An elective with this code already exists.",
                    "warning"
                );
                return;
            }
            // Create elective object.
            const newElective = {
                id: String(Date.now()),
                code: code,
                name: name,
                category: category,
                seats: seats,
                description: description
            };
            managedElectives.push(newElective);
            // Roll back the change if saving fails.
            if (!saveElectives()) {
                managedElectives.pop();
                return;
            }
            renderElectives();
            electiveForm.reset();
            document.getElementById("electiveSeats").value = 30;
            showMessage(
                "Elective added successfully to the admin demo list.",
                "success"
            );
        });
    }
    // ==========================================
    // RESET DEMO ELECTIVES
    // ==========================================
    if (resetButton) {
        resetButton.addEventListener("click", function () {
            const confirmed = window.confirm(
                "Reset the admin elective list to its original demo data? " +
                "Any electives you added will be removed."
            );
            if (!confirmed) {
                return;
            }
            const previousElectives = managedElectives;
            managedElectives = getInitialElectives();
            // Restore the previous list if saving fails.
            if (!saveElectives()) {
                managedElectives = previousElectives;
                return;
            }
            renderElectives();
            showMessage(
                "Admin demo electives have been reset to the original defaults.",
                "success"
            );
        });
    }
    // ==========================================
    // XML ESCAPING
    // ==========================================
    function escapeXml(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&apos;");
    }
    // ==========================================
    // EXPORT ELECTIVES TO XML
    // ==========================================
    if (exportButton) {
        exportButton.addEventListener("click", function () {
            const xmlRows = managedElectives.map(function (item) {
                return [
                    "    <elective>",
                    "        <id>" +
                        escapeXml(item.id) +
                        "</id>",
                    "        <code>" +
                        escapeXml(item.code) +
                        "</code>",
                    "        <name>" +
                        escapeXml(item.name) +
                        "</name>",
                    "        <category>" +
                        escapeXml(item.category) +
                        "</category>",
                    "        <seats>" +
                        escapeXml(item.seats) +
                        "</seats>",
                    "        <description>" +
                        escapeXml(item.description) +
                        "</description>",
                    "    </elective>"
                ].join("\n");
            }).join("\n");
            const xmlContent =
                '<?xml version="1.0" encoding="UTF-8"?>\n' +
                "<electives>\n" +
                xmlRows +
                "\n</electives>";
            const blob = new Blob(
                [xmlContent],
                {
                    type: "application/xml;charset=utf-8"
                }
            );
            const url = URL.createObjectURL(blob);
            const link = document.createElement("a");
            link.href = url;
            link.download = "electra-electives.xml";
            document.body.appendChild(link);
            link.click();
            link.remove();
            // Release the generated download URL.
            window.setTimeout(function () {
                URL.revokeObjectURL(url);
            }, 1000);
            showMessage(
                "Elective XML file exported successfully.",
                "success"
            );
        });
    }
    // ==========================================
    // INITIAL PAGE RENDERING
    // ==========================================
    renderElectives();
});