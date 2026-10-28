
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

@WebFilter(urlPatterns = {
    "/dashboard.jsp",
    "/profile",
    "/preferences.jsp",
    "/allocation-results.jsp",
    "/electives.jsp",
    "/elective-details.jsp",
    "/admin.jsp",
    "/admin-electives.jsp",
    "/admin-students.jsp",
    "/admin-allocations.jsp",
    "/reports.jsp"
})
public class AuthFilter implements Filter {

    // Pages accessible only to administrators.
    private static final Set<String> ADMIN_PATHS = Set.of(
        "/admin.jsp",
        "/admin-electives.jsp",
        "/admin-students.jsp",
        "/admin-allocations.jsp",
        "/reports.jsp"
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

        // 1. Redirect users who are not logged in.
        if (role == null) {
            response.sendRedirect(
                request.getContextPath() + "/login.jsp"
            );
            return;
        }

        // 2. Only administrators can access admin-only pages.
        if (ADMIN_PATHS.contains(path)) {

            if (!"ADMIN".equals(role)) {
                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Administrator access required."
                );
                return;
            }
        }

        // 3. Both students and administrators can access Dashboard.
        else if ("/dashboard.jsp".equals(path)) {

            if (!"STUDENT".equals(role)
                    && !"ADMIN".equals(role)) {

                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid user role."
                );
                return;
            }
        }

        // 4. Both students and administrators can view electives.
        else if ("/electives.jsp".equals(path)) {

            if (!"STUDENT".equals(role)
                    && !"ADMIN".equals(role)) {

                response.sendError(
                    HttpServletResponse.SC_FORBIDDEN,
                    "Invalid user role."
                );
                return;
            }
        }

        // 5. Other protected pages are student-only.
        else if (!"STUDENT".equals(role)) {

            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Student access required."
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