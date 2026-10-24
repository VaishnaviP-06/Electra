
document.addEventListener("DOMContentLoaded", function () {
    const electiveForm = document.getElementById("electiveForm");
    const electiveTableBody = document.getElementById("electiveTableBody");
    const studentTableBody = document.getElementById("studentTableBody");
    const messageBox = document.getElementById("adminMessage");

    const electiveStorageKey = "electraAdminElectives";
    const profileStorageKey = "electraStudentProfile";

    // Load the default electives from electives.js.
    function getInitialElectives() {
        if (
            typeof electraDefaultElectives !== "undefined" &&
            Array.isArray(electraDefaultElectives)
        ) {
            return electraDefaultElectives.map(item => ({ ...item }));
        }

        // Fallback in case electives.js is unavailable.
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

    // Display messages on the admin page.
    function showMessage(message, type) {
        messageBox.textContent = message;
        messageBox.className = "alert alert-" + type;
    }

    // Load electives from browser storage.
    function loadElectives() {
        try {
            const saved = localStorage.getItem(electiveStorageKey);

            if (saved !== null) {
                const parsed = JSON.parse(saved);

                if (Array.isArray(parsed)) {
                    return parsed;
                }

                throw new Error("Invalid elective data");
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

    // Save the current elective list.
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

    // Update dashboard statistics.
    function updateStatistics() {
        document.getElementById("totalElectives").textContent =
            managedElectives.length;

        const totalSeats = managedElectives.reduce(function (total, item) {
            return total + (Number(item.seats) || 0);
        }, 0);

        document.getElementById("totalSeats").textContent = totalSeats;

        let studentCount = 0;

        try {
            if (localStorage.getItem(profileStorageKey)) {
                studentCount = 1;
            }
        } catch (error) {
            studentCount = 0;
        }

        document.getElementById("totalStudents").textContent =
            studentCount;
    }

    // Display all electives in the table.
    function renderElectives() {
        electiveTableBody.replaceChildren();

        if (managedElectives.length === 0) {
            const row = document.createElement("tr");
            const cell = document.createElement("td");

            cell.colSpan = 5;
            cell.className = "text-center text-muted";
            cell.textContent =
                "No electives available. Add one using the form above.";

            row.appendChild(cell);
            electiveTableBody.appendChild(row);

            updateStatistics();
            return;
        }

        managedElectives.forEach(function (item) {
            const row = document.createElement("tr");

            [
                item.code,
                item.name,
                item.category,
                String(item.seats)
            ].forEach(function (value) {
                const cell = document.createElement("td");
                cell.textContent = value;
                row.appendChild(cell);
            });

            const actionCell = document.createElement("td");
            const removeButton = document.createElement("button");

            removeButton.type = "button";
            removeButton.className = "admin-remove-btn";
            removeButton.textContent = "Remove";
            removeButton.setAttribute(
                "aria-label",
                "Remove elective " + item.code
            );

            removeButton.addEventListener("click", function () {
                const confirmed = window.confirm(
                    "Remove " + item.name + " from the admin demo list?"
                );

                if (!confirmed) {
                    return;
                }

                const previousElectives = managedElectives;

                managedElectives = managedElectives.filter(function (elective) {
                    return String(elective.id) !== String(item.id);
                });

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

    // Display the saved student profile.
    function renderStudentProfile() {
        studentTableBody.replaceChildren();

        let profile = null;

        try {
            const savedProfile = localStorage.getItem(profileStorageKey);
            profile = savedProfile ? JSON.parse(savedProfile) : null;
        } catch (error) {
            console.error("Unable to load student profile:", error);
        }

        if (!profile || typeof profile !== "object") {
            const row = document.createElement("tr");
            const cell = document.createElement("td");

            cell.colSpan = 5;
            cell.className = "text-center text-muted";
            cell.textContent =
                "No saved profile found. Save a profile from the student page.";

            row.appendChild(cell);
            studentTableBody.appendChild(row);

            updateStatistics();
            return;
        }

        const row = document.createElement("tr");

        [
            profile.name || "—",
            profile.roll || "—",
            profile.department || "—",
            profile.year || "—",
            profile.cgpa ?? "—"
        ].forEach(function (value) {
            const cell = document.createElement("td");
            cell.textContent = String(value);
            row.appendChild(cell);
        });

        studentTableBody.appendChild(row);
        updateStatistics();
    }

    // Add a new elective.
    electiveForm.addEventListener("submit", function (event) {
        event.preventDefault();

        const code = document.getElementById("electiveCode")
            .value.trim().toUpperCase();

        const name = document.getElementById("electiveName")
            .value.trim();

        const category = document.getElementById("electiveCategory").value;

        const seats = Number(
            document.getElementById("electiveSeats").value
        );

        const description = document.getElementById("electiveDescription")
            .value.trim();

        if (!code || !name || !category) {
            showMessage(
                "Please complete all required elective fields.",
                "danger"
            );
            return;
        }

        if (!Number.isInteger(seats) || seats < 1 || seats > 500) {
            showMessage(
                "Seats must be a whole number between 1 and 500.",
                "danger"
            );
            return;
        }

        const duplicate = managedElectives.some(function (item) {
            return item.code.toUpperCase() === code;
        });

        if (duplicate) {
            showMessage(
                "An elective with this code already exists.",
                "warning"
            );
            return;
        }

        const newElective = {
            id: String(Date.now()),
            code: code,
            name: name,
            category: category,
            seats: seats,
            description: description
        };

        managedElectives.push(newElective);

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

    // Reset electives to the original five defaults.
    document.getElementById("resetDemoData").addEventListener(
        "click",
        function () {
            const confirmed = window.confirm(
                "Reset the admin elective list to its original demo data? " +
                "Any electives you added will be removed."
            );

            if (!confirmed) {
                return;
            }

            const previousElectives = managedElectives;

            // Corrected line: restore the original default list.
            managedElectives = getInitialElectives();

            if (!saveElectives()) {
                managedElectives = previousElectives;
                return;
            }

            renderElectives();

            showMessage(
                "Admin demo electives have been reset to the original defaults.",
                "success"
            );
        }
    );

    // Escape XML special characters.
    function escapeXml(value) {
        return String(value ?? "")
            .replace(/&/g, "&amp;")
            .replace(/</g, "&lt;")
            .replace(/>/g, "&gt;")
            .replace(/"/g, "&quot;")
            .replace(/'/g, "&apos;");
    }

    // Export the elective list to an XML file.
    const exportButton = document.getElementById("exportElectivesXml");

    if (exportButton) {
        exportButton.addEventListener("click", function () {
            const xmlRows = managedElectives.map(function (item) {
                return [
                    "    <elective>",
                    "        <id>" + escapeXml(item.id) + "</id>",
                    "        <code>" + escapeXml(item.code) + "</code>",
                    "        <name>" + escapeXml(item.name) + "</name>",
                    "        <category>" + escapeXml(item.category) + "</category>",
                    "        <seats>" + escapeXml(item.seats) + "</seats>",
                    "        <description>" + escapeXml(item.description) + "</description>",
                    "    </elective>"
                ].join("\n");
            }).join("\n");

            const xmlContent =
                '<?xml version="1.0" encoding="UTF-8"?>\n' +
                "<electives>\n" +
                xmlRows + "\n" +
                "</electives>";

            const blob = new Blob(
                [xmlContent],
                { type: "application/xml;charset=utf-8" }
            );

            const url = URL.createObjectURL(blob);
            const link = document.createElement("a");

            link.href = url;
            link.download = "electra-electives.xml";

            document.body.appendChild(link);
            link.click();
            link.remove();

            URL.revokeObjectURL(url);

            showMessage(
                "Elective XML file exported successfully.",
                "success"
            );
        });
    }

    // Initial page rendering.
    renderElectives();
    renderStudentProfile();
});
