(function () {
    "use strict";
    const DEFAULT_ELECTIVES = [
        { id: "1", code: "EC501", name: "Cloud Computing", category: "Professional Elective", seats: 30, description: "Explore cloud platforms, virtualization, distributed services, and scalable infrastructure." },
        { id: "2", code: "EC502", name: "Cyber Security", category: "Departmental", seats: 35, description: "Learn about digital threats, network protection, secure systems, and risk management." },
        { id: "3", code: "EC503", name: "Data Analytics", category: "Open Elective", seats: 40, description: "Turn raw data into useful insights using analysis, visualization, and interpretation." },
        { id: "4", code: "EC504", name: "Artificial Intelligence", category: "Professional Elective", seats: 30, description: "Study intelligent systems, AI methods, and practical applications of machine learning." },
        { id: "5", code: "EC505", name: "Internet of Things", category: "Departmental", seats: 35, description: "Discover connected devices, sensors, embedded systems, and real-world IoT applications." }
    ];
    const STORAGE_KEY = "electraAdminElectives";
    const $ = id => document.getElementById(id);
    function getElectives() {
        try {
            const stored = localStorage.getItem(STORAGE_KEY);
            if (stored !== null) {
                const parsed = JSON.parse(stored);
                if (Array.isArray(parsed)) return parsed;
            }
        } catch (error) { console.error("Could not read elective catalogue", error); }
        return DEFAULT_ELECTIVES.map(item => ({ ...item }));
    }
    let electives = getElectives();
    window.electraDefaultElectives = DEFAULT_ELECTIVES;
    window.electraGetAvailableElectives = getElectives;
    function safeText(value) { return String(value == null ? "" : value); }
    function render() {
        const grid = $("electiveGrid");
        if (!grid) return;
        const query = ($("searchInput")?.value || "").trim().toLowerCase();
        const category = $("departmentFilter")?.value || "all";
        const filtered = electives.filter(item => {
            const searchable = [item.code, item.name, item.category, item.description].map(safeText).join(" ").toLowerCase();
            const categoryMatch = category === "all" || safeText(item.category).toLowerCase() === category.toLowerCase();
            return searchable.includes(query) && categoryMatch;
        });
        grid.replaceChildren();
        filtered.forEach((item, index) => {
            const card = document.createElement("article");
            card.className = "student-elective-card";
            const head = document.createElement("div"); head.className = "student-elective-card-head";
            const number = document.createElement("span"); number.className = "elective-number"; number.textContent = String(index + 1).padStart(2, "0");
            const tag = document.createElement("span"); tag.className = "category-tag"; tag.textContent = safeText(item.category) || "Elective";
            head.append(number, tag);
            const body = document.createElement("div"); body.className = "student-elective-card-body";
            const code = document.createElement("span"); code.className = "elective-code"; code.textContent = safeText(item.code);
            const title = document.createElement("h3"); title.textContent = safeText(item.name) || "Untitled elective";
            const desc = document.createElement("p"); desc.textContent = safeText(item.description) || "Description will be provided by the department.";
            const meta = document.createElement("div"); meta.className = "elective-card-meta";
            const seats = document.createElement("span"); seats.textContent = "Seat capacity: "; const strong = document.createElement("strong"); strong.textContent = safeText(item.seats ?? "—"); seats.appendChild(strong);
            const label = document.createElement("span"); label.textContent = "Academic elective";
            meta.append(seats, label); body.append(code, title, desc, meta); card.append(head, body); grid.appendChild(card);
        });
        const count = $("electiveCount"); if (count) count.textContent = filtered.length + (filtered.length === 1 ? " elective" : " electives");
        const empty = $("emptyState"); if (empty) empty.classList.toggle("show", filtered.length === 0);
        grid.style.display = filtered.length ? "grid" : "none";
    }
    function initialize() {
        $("searchInput")?.addEventListener("input", render);
        $("departmentFilter")?.addEventListener("change", render);
        $("clearFilters")?.addEventListener("click", () => { if ($("searchInput")) $("searchInput").value = ""; if ($("departmentFilter")) $("departmentFilter").value = "all"; render(); });
        render();
    }
    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", initialize); else initialize();
})();