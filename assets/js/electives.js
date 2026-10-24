
/* ========================================
   ELECTRA - ELECTIVE CATALOGUE
   Demonstration data; backend comes later.
   ======================================== */

const electives = [
    {
        id: "ai",
        code: "EC501",
        name: "Artificial Intelligence",
        category: "AI & Data",
        faculty: "Dr. A. Sharma",
        seats: 60,
        description:
            "Explore intelligent systems, problem-solving techniques and the foundations of AI.",
        syllabus: [
            "Introduction to artificial intelligence",
            "Search strategies and problem solving",
            "Knowledge representation and reasoning",
            "Introduction to machine learning",
            "AI applications and ethical considerations"
        ],
        eligibility: "Eligible departmental students",
        credits: 3
    },
    {
        id: "ml",
        code: "EC502",
        name: "Machine Learning",
        category: "AI & Data",
        faculty: "Prof. R. Mehta",
        seats: 50,
        description:
            "Understand how systems learn from data through models, algorithms and evaluation.",
        syllabus: [
            "Introduction to machine learning",
            "Data preparation and feature selection",
            "Supervised learning",
            "Unsupervised learning",
            "Model evaluation and applications"
        ],
        eligibility: "Eligible departmental students",
        credits: 3
    },
    {
        id: "cloud",
        code: "EC503",
        name: "Cloud Computing",
        category: "Software",
        faculty: "Prof. S. Desai",
        seats: 55,
        description:
            "Learn the principles of cloud infrastructure, virtualization and scalable services.",
        syllabus: [
            "Cloud computing fundamentals",
            "Virtualization and containers",
            "Cloud service and deployment models",
            "Storage and resource management",
            "Cloud security and applications"
        ],
        eligibility: "Eligible departmental students",
        credits: 3
    },
    {
        id: "devops",
        code: "EC504",
        name: "DevOps Engineering",
        category: "Software",
        faculty: "Prof. K. Rao",
        seats: 45,
        description:
            "Discover collaborative software delivery, automated testing and deployment pipelines.",
        syllabus: [
            "DevOps principles and culture",
            "Version control and collaboration",
            "Continuous integration",
            "Continuous delivery and deployment",
            "Monitoring and infrastructure automation"
        ],
        eligibility: "Eligible departmental students",
        credits: 3
    },
    {
        id: "networks",
        code: "EC505",
        name: "Advanced Computer Networks",
        category: "Networks",
        faculty: "Dr. P. Shah",
        seats: 50,
        description:
            "Study network protocols, modern communication systems and network performance.",
        syllabus: [
            "Advanced networking concepts",
            "Routing and switching",
            "Network performance and quality of service",
            "Wireless and modern networks",
            "Network monitoring and troubleshooting"
        ],
        eligibility: "Eligible departmental students",
        credits: 3
    },
    {
        id: "security",
        code: "EC506",
        name: "Cybersecurity Fundamentals",
        category: "Security",
        faculty: "Prof. M. Kulkarni",
        seats: 40,
        description:
            "Learn security principles, common threats, risk reduction and defensive practices.",
        syllabus: [
            "Security principles and risk assessment",
            "Common cyber threats and vulnerabilities",
            "Authentication and access control",
            "Network and application security",
            "Security policies and incident response"
        ],
        eligibility: "Eligible departmental students",
        credits: 3
    }
];

/* Render catalogue cards */

function renderElectives(list) {
    const grid = document.getElementById("electiveGrid");
    const count = document.getElementById("electiveCount");
    const emptyState = document.getElementById("emptyState");

    if (!grid) return;

    grid.innerHTML = "";

    if (count) {
        count.textContent =
            `${list.length} ${list.length === 1 ? "elective" : "electives"}`;
    }

    if (emptyState) {
        emptyState.hidden = list.length !== 0;
    }

    list.forEach((elective, index) => {
        const column = document.createElement("div");
        column.className = "col-12 col-md-6 col-xl-4";

        const card = document.createElement("article");
        card.className = "elective-card";

        card.innerHTML = `
            <div class="elective-card-top">
                <span class="elective-number">
                    ${String(index + 1).padStart(2, "0")}
                </span>
                <span class="category-tag"></span>
            </div>

            <div class="elective-card-body">
                <span class="elective-code"></span>
                <h3></h3>
                <p class="elective-description"></p>

                <div class="elective-meta">
                    <div>
                        <span class="meta-label">Seat capacity</span>
                        <span class="meta-value">${elective.seats} seats</span>
                    </div>
                    <div>
                        <span class="meta-label">Credits</span>
                        <span class="meta-value">${elective.credits} credits</span>
                    </div>
                </div>

                <a class="btn btn-electra"></a>
            </div>
        `;

        // Use textContent for text taken from the data.
        card.querySelector(".category-tag").textContent = elective.category;
        card.querySelector(".elective-code").textContent = elective.code;
        card.querySelector("h3").textContent = elective.name;
        card.querySelector(".elective-description").textContent =
            elective.description;

        const link = card.querySelector("a");
        link.href = `elective-details.html?id=${encodeURIComponent(elective.id)}`;
        link.textContent = "View Details →";
        link.setAttribute(
            "aria-label",
            `View details for ${elective.name}`
        );

        column.appendChild(card);
        grid.appendChild(column);
    });
}

/* Search and category filtering */

function filterElectives() {
    const searchInput = document.getElementById("searchInput");
    const categoryFilter = document.getElementById("departmentFilter");

    if (!searchInput || !categoryFilter) return;

    const searchTerm = searchInput.value.trim().toLowerCase();
    const selectedCategory = categoryFilter.value;

    const filtered = electives.filter((elective) => {
        const searchableText = [
            elective.name,
            elective.code,
            elective.category,
            elective.description,
            elective.faculty
        ].join(" ").toLowerCase();

        const matchesSearch = searchableText.includes(searchTerm);

        const matchesCategory =
            selectedCategory === "all" ||
            elective.category === selectedCategory;

        return matchesSearch && matchesCategory;
    });

    renderElectives(filtered);
}

/* Render one elective's details */

function renderElectiveDetails() {
    const container = document.getElementById("electiveDetail");

    if (!container) return;

    const params = new URLSearchParams(window.location.search);
    const electiveId = params.get("id");

    const elective = electives.find((item) => item.id === electiveId);

    if (!elective) {
        container.innerHTML = `
            <section class="detail-panel text-center">
                <h2>Elective not found</h2>
                <p>Please return to the catalogue and choose an elective.</p>
                <a href="electives.html" class="btn btn-electra">
                    Browse Electives
                </a>
            </section>
        `;
        return;
    }

    container.innerHTML = `
        <section class="detail-hero">
            <span class="eyebrow">ELECTIVE DETAILS</span>
            <div class="detail-code"></div>
            <h1></h1>
            <p class="detail-description"></p>
        </section>

        <div class="detail-layout">
            <div>
                <section class="detail-panel">
                    <h2>About this elective</h2>
                    <p class="detail-about"></p>
                </section>

                <section class="detail-panel">
                    <h2>Indicative syllabus</h2>
                    <ul class="syllabus-list"></ul>
                </section>
            </div>

            <aside>
                <section class="detail-panel">
                    <h2>At a glance</h2>

                    <div class="detail-stat">
                        <span>Category</span>
                        <strong class="stat-category"></strong>
                    </div>

                    <div class="detail-stat">
                        <span>Faculty</span>
                        <strong class="stat-faculty"></strong>
                    </div>

                    <div class="detail-stat">
                        <span>Seat capacity</span>
                        <strong class="stat-seats"></strong>
                    </div>

                    <div class="detail-stat">
                        <span>Credits</span>
                        <strong class="stat-credits"></strong>
                    </div>

                    <div class="detail-stat">
                        <span>Eligibility</span>
                        <strong class="stat-eligibility"></strong>
                    </div>

                    <div class="detail-actions">
                        <a href="preferences.html"
                           class="btn btn-electra">
                            Go to Preferences →
                        </a>

                        <a href="electives.html"
                           class="btn btn-outline-electra">
                            Back to Catalogue
                        </a>
                    </div>
                </section>
            </aside>
        </div>
    `;

    container.querySelector(".detail-code").textContent = elective.code;
    container.querySelector("h1").textContent = elective.name;
    container.querySelector(".detail-description").textContent =
        elective.description;
    container.querySelector(".detail-about").textContent =
        elective.description;

    container.querySelector(".stat-category").textContent = elective.category;
    container.querySelector(".stat-faculty").textContent = elective.faculty;
    container.querySelector(".stat-seats").textContent =
        `${elective.seats} seats`;
    container.querySelector(".stat-credits").textContent =
        `${elective.credits} credits`;
    container.querySelector(".stat-eligibility").textContent =
        elective.eligibility;

    const syllabusList = container.querySelector(".syllabus-list");

    elective.syllabus.forEach((topic) => {
        const item = document.createElement("li");
        item.textContent = topic;
        syllabusList.appendChild(item);
    });
}

/* Initialise the page */

document.addEventListener("DOMContentLoaded", () => {
    const searchInput = document.getElementById("searchInput");
    const categoryFilter = document.getElementById("departmentFilter");
    const clearButton = document.getElementById("clearFilters");

    if (searchInput && categoryFilter) {
        renderElectives(electives);

        searchInput.addEventListener("input", filterElectives);
        categoryFilter.addEventListener("change", filterElectives);

        if (clearButton) {
            clearButton.addEventListener("click", () => {
                searchInput.value = "";
                categoryFilter.value = "all";
                filterElectives();
            });
        }
    }

    renderElectiveDetails();
});
