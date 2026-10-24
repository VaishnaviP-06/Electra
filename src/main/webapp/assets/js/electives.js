
const electraDefaultElectives = [
    {
        id: "1",
        code: "EC501",
        name: "Cloud Computing",
        category: "Professional Elective",
        seats: 30,
        description: "Cloud platforms, virtualization and cloud services"
    },
    {
        id: "2",
        code: "EC502",
        name: "Cyber Security",
        category: "Departmental",
        seats: 35,
        description: "Network security, threats and protection"
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

const ELECTRA_ELECTIVES_KEY = "electraAdminElectives";

// Read the shared elective list.
function getAvailableElectives() {
    try {
        const stored = localStorage.getItem(ELECTRA_ELECTIVES_KEY);

        if (stored !== null) {
            const parsed = JSON.parse(stored);

            if (Array.isArray(parsed)) {
                return parsed;
            }
        }
    } catch (error) {
        console.error("Unable to read saved electives:", error);
    }

    return electraDefaultElectives.map(item => ({ ...item }));
}

// Keep the global variable for pages that already use `electives`.
var electives = getAvailableElectives();
