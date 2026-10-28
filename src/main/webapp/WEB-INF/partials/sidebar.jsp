<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%--
    Shared Electra sidebar (used by every authenticated page).

    Usage, inside <div class="app-layout"> and before <main class="main-content">:
        <jsp:include page="/WEB-INF/partials/sidebar.jsp">
            <jsp:param name="active" value="dashboard"/>
        </jsp:include>

    "active" keys
        student: dashboard | electives | preferences | allocation | profile
        admin  : overview | students | manage-electives | allocations | reports | electives (Student View)

    The links shown depend on session attribute "role" (set by LoginServlet).
    Access control is NOT done here; AuthFilter remains the single authority.
--%>
<%
    String ctx = request.getContextPath();
    String active = request.getParameter("active");
    if (active == null) active = "";
    String role = (String) session.getAttribute("role");
    boolean isAdmin = "ADMIN".equals(role);
    String rawName = (String) session.getAttribute("username");
    if (rawName == null || rawName.trim().isEmpty()) rawName = (String) session.getAttribute("userId");
    if (rawName == null || rawName.trim().isEmpty()) rawName = isAdmin ? "Administrator" : "Student";
    String displayName = rawName.trim()
            .replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
            .replace("\"", "&quot;").replace("'", "&#39;");
    String initial = rawName.trim().substring(0, 1).toUpperCase();
    initial = initial.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    String home = isAdmin ? "admin.jsp" : "dashboard.jsp";
%>
<svg xmlns="http://www.w3.org/2000/svg" width="0" height="0" style="position:absolute" aria-hidden="true" focusable="false">
    <defs>
        <symbol id="i-dashboard" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9" rx="1.5"/><rect x="14" y="3" width="7" height="5" rx="1.5"/><rect x="14" y="12" width="7" height="9" rx="1.5"/><rect x="3" y="16" width="7" height="5" rx="1.5"/></symbol>
        <symbol id="i-book" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 5.5A2.5 2.5 0 0 1 6.5 3H20v16H6.5A2.5 2.5 0 0 0 4 21.5z"/><path d="M4 5.5v16"/><path d="M9 8h6"/></symbol>
        <symbol id="i-rank" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M8 4v16M8 4 4.5 7.5M8 4l3.5 3.5"/><path d="M16 20V4m0 16-3.5-3.5M16 20l3.5-3.5"/></symbol>
        <symbol id="i-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="m8 12.5 2.8 2.8L16 9.5"/></symbol>
        <symbol id="i-users" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.5"/><path d="M2.5 20a6.5 6.5 0 0 1 13 0"/><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8M18 14.2a6.5 6.5 0 0 1 3.5 5.8"/></symbol>
        <symbol id="i-settings" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 7h10M18 7h2M4 17h2M10 17h10"/><circle cx="16" cy="7" r="2"/><circle cx="8" cy="17" r="2"/></symbol>
        <symbol id="i-report" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 3H7a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V8z"/><path d="M14 3v5h5M9 17v-3M12 17v-5M15 17v-2"/></symbol>
        <symbol id="i-logout" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h3"/><path d="m16 17 5-5-5-5M21 12H9"/></symbol>
        <symbol id="i-info" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 11v5M12 7.8v.2"/></symbol>
        <symbol id="i-arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14M13 6l6 6-6 6"/></symbol>
        <symbol id="i-user" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"/><path d="M4.5 20.5a7.5 7.5 0 0 1 15 0"/></symbol>
    </defs>
</svg>
<aside class="sidebar">
    <a href="<%= ctx %>/<%= home %>" class="sidebar-brand">
        <span class="sidebar-logo">E</span>
        <span class="sidebar-brand-text">
            <strong>Electra</strong>
            <small>Department Portal</small>
        </span>
    </a>
<% if (isAdmin) { %>
    <div class="sidebar-label">Administration</div>
    <nav class="sidebar-nav" aria-label="Administrator navigation">
            <a href="<%= ctx %>/dashboard" class="nav-link<%= "overview".equals(active) ? " active" : "" %>"<%= "overview".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-dashboard"/></svg></span><span class="nav-text">Overview</span>
            </a>
            <a href="<%= ctx %>/admin-students" class="nav-link<%= "students".equals(active) ? " active" : "" %>"<%= "students".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-users"/></svg></span><span class="nav-text">Manage Students</span>
            </a>
            <a href="<%= ctx %>/admin-electives" class="nav-link<%= "manage-electives".equals(active) ? " active" : "" %>"<%= "manage-electives".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-book"/></svg></span><span class="nav-text">Manage Electives</span>
            </a>
            <a href="<%= ctx %>/admin-allocations" class="nav-link<%= "allocations".equals(active) ? " active" : "" %>"<%= "allocations".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-settings"/></svg></span><span class="nav-text">Allocation Settings</span>
            </a>
            <a href="<%= ctx %>/reports" class="nav-link<%= "reports".equals(active) ? " active" : "" %>"<%= "reports".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-report"/></svg></span><span class="nav-text">Reports</span>
            </a>
            <a href="<%= ctx %>/electives" class="nav-link<%= "electives".equals(active) ? " active" : "" %>"<%= "electives".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-rank"/></svg></span><span class="nav-text">Student View</span>
            </a>
    </nav>
<% } else { %>
    <div class="sidebar-label">Workspace</div>
    <nav class="sidebar-nav" aria-label="Main navigation">
            <a href="<%= ctx %>/dashboard" class="nav-link<%= "dashboard".equals(active) ? " active" : "" %>"<%= "dashboard".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-dashboard"/></svg></span><span class="nav-text">Dashboard</span>
            </a>
            <a href="<%= ctx %>/electives" class="nav-link<%= "electives".equals(active) ? " active" : "" %>"<%= "electives".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-book"/></svg></span><span class="nav-text">View Electives</span>
            </a>
            <a href="<%= ctx %>/preferences" class="nav-link<%= "preferences".equals(active) ? " active" : "" %>"<%= "preferences".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-rank"/></svg></span><span class="nav-text">My Preferences</span>
            </a>
            <a href="<%= ctx %>/allocation-results" class="nav-link<%= "allocation".equals(active) ? " active" : "" %>"<%= "allocation".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-check"/></svg></span><span class="nav-text">My Allocation</span>
            </a>
            <a href="<%= ctx %>/profile" class="nav-link<%= "profile".equals(active) ? " active" : "" %>"<%= "profile".equals(active) ? " aria-current=\"page\"" : "" %>>
                <span class="nav-icon"><svg class="icon" aria-hidden="true" focusable="false"><use href="#i-user"/></svg></span><span class="nav-text">My Profile</span>
            </a>
    </nav>
<% } %>
    <div class="sidebar-bottom">
        <div class="sidebar-user">
            <div class="avatar" id="userAvatar"><%= initial %></div>
            <div class="user-details">
                <strong id="sidebarUser"><%= displayName %></strong>
                <small id="sidebarRole"><%= isAdmin ? "Administrator" : "Student" %></small>
            </div>
        </div>
        <a href="<%= ctx %>/logout" class="logout-button" id="logoutButton">
            <svg class="icon" aria-hidden="true" focusable="false"><use href="#i-logout"/></svg><span>Sign Out</span>
        </a>
    </div>
</aside>
