package com.electra.controller;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;
import java.util.UUID;

@WebFilter(urlPatterns = {
    "/dashboard",
    "/dashboard.jsp",
    "/student/dashboard",
    "/admin/dashboard",
    "/profile",
    "/preferences.jsp",
    "/preferences",
    "/allocation-results.jsp",
    "/allocation-results",
    "/electives.jsp",
    "/electives",
    "/elective-details.jsp",
    "/admin.jsp",
    "/admin-electives.jsp",
    "/admin-electives",
    "/admin-students.jsp",
    "/admin-students",
    "/admin-allocations.jsp",
    "/admin-allocations",
    "/admin/allocation",
    "/reports.jsp",
    "/reports",
    "/reports/export"
})
public class AuthFilter implements Filter {

    // Endpoints accessible only to administrators.
    private static final Set<String> ADMIN_PATHS = Set.of(
        "/admin.jsp",
        "/admin/dashboard",
        "/admin-electives.jsp",
        "/admin-electives",
        "/admin-students.jsp",
        "/admin-students",
        "/admin-allocations.jsp",
        "/admin-allocations",
        "/admin/allocation",
        "/reports.jsp",
        "/reports",
        "/reports/export"
    );

    // Endpoints accessible only to students.
    private static final Set<String> STUDENT_PATHS = Set.of(
        "/student/dashboard",
        "/profile",
        "/preferences.jsp",
        "/preferences",
        "/allocation-results.jsp",
        "/allocation-results"
    );

    @Override
    public void doFilter(
            ServletRequest req,
            ServletResponse res,
            FilterChain chain
    ) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);

        String role = session == null
                ? null
                : (String) session.getAttribute("role");

        String path = request.getServletPath();

        // 1. Redirect unauthenticated users to login page
        if (role == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        // Initialize CSRF token if missing
        if (session != null && session.getAttribute("csrfToken") == null) {
            session.setAttribute("csrfToken", UUID.randomUUID().toString());
        }

        // 2. Administrator-only routes
        if (ADMIN_PATHS.contains(path)) {
            if (!"ADMIN".equals(role)) {
                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Administrator access required."
                );
                return;
            }
        }

        // 3. Student-only routes
        else if (STUDENT_PATHS.contains(path)) {
            if (!"STUDENT".equals(role)) {
                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Student access required."
                );
                return;
            }
        }

        // 4. Shared routes accessible to both authenticated roles:
        // /dashboard, /dashboard.jsp, /electives, /electives.jsp, /elective-details.jsp
        else if ("/dashboard".equals(path)
                || "/dashboard.jsp".equals(path)
                || "/electives".equals(path)
                || "/electives.jsp".equals(path)
                || "/elective-details.jsp".equals(path)) {

            if (!"STUDENT".equals(role) && !"ADMIN".equals(role)) {
                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid user role."
                );
                return;
            }
        }

        // 5. Default denial for unrecognized routes matched by filter
        else if (!"STUDENT".equals(role) && !"ADMIN".equals(role)) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Access denied."
            );
            return;
        }

        // 6. Prevent browsers from caching protected pages.
        response.setHeader(
            "Cache-Control",
            "no-store, no-cache, must-revalidate"
        );

        chain.doFilter(req, res);
    }
}
