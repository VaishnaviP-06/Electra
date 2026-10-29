package com.electra.controller;

import com.electra.dao.StudentProfileDAO;
import com.electra.dao.UserDAO;
import com.electra.model.StudentProfile;
import com.electra.model.User;
import com.electra.util.BCrypt;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Locale;
import java.util.UUID;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final StudentProfileDAO profileDAO = new StudentProfileDAO();

    private static final String GENERIC_LOGIN_ERROR = "Invalid credentials or account inactive.";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String identifier = request.getParameter("userId");
        String password = request.getParameter("password");
        String requestedRole = request.getParameter("role");

        if (identifier == null || password == null || requestedRole == null
                || identifier.isBlank() || password.isBlank()) {
            request.setAttribute("loginError", "Please enter your identifier, password, and account type.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        identifier = identifier.trim();
        String role = requestedRole.trim().toUpperCase(Locale.ROOT);

        if (!"STUDENT".equals(role) && !"ADMIN".equals(role)) {
            request.setAttribute("loginError", GENERIC_LOGIN_ERROR);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Password policy: minimum 8 characters, maximum 72 (BCrypt limit)
        if (password.length() < 8 || password.length() > 72) {
            request.setAttribute("loginError", GENERIC_LOGIN_ERROR);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        try {
            User user = null;
            StudentProfile studentProfile = null;

            if ("ADMIN".equals(role)) {
                user = userDAO.findByUsername(identifier);
            } else {
                user = userDAO.findStudentUserByIdentifier(identifier);
            }

            // Verify user exists, matches role, is active, and password matches
            if (user == null || !role.equals(user.getRole()) || !user.isActive()) {
                request.setAttribute("loginError", GENERIC_LOGIN_ERROR);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            if (!BCrypt.checkpw(password, user.getPasswordHash())) {
                request.setAttribute("loginError", GENERIC_LOGIN_ERROR);
                request.getRequestDispatcher("/login.jsp").forward(request, response);
                return;
            }

            if ("STUDENT".equals(role)) {
                studentProfile = profileDAO.findByUserId(user.getUserId());
                if (studentProfile == null) {
                    request.setAttribute("loginError", GENERIC_LOGIN_ERROR);
                    request.getRequestDispatcher("/login.jsp").forward(request, response);
                    return;
                }
            }

            // Session fixation protection: invalidate existing session and create new one
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }
            HttpSession session = request.getSession(true);

            // Populate consistent session attributes
            session.setAttribute("role", role);
            session.setAttribute("csrfToken", UUID.randomUUID().toString());

            if ("STUDENT".equals(role)) {
                session.setAttribute("userId", user.getUsername());
                session.setAttribute("username", studentProfile.getFullName());
                session.setAttribute("userDbId", user.getUserId());
                session.setAttribute("studentId", studentProfile.getStudentId());
                session.setAttribute("studentName", studentProfile.getFullName());
                session.setAttribute("studentRollNumber", studentProfile.getRollNumber());
            } else {
                session.setAttribute("userId", user.getUsername());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("userDbId", user.getUserId());
                session.setAttribute("adminUserId", user.getUserId());
            }

            session.setMaxInactiveInterval(30 * 60);
            response.sendRedirect(request.getContextPath() + "/dashboard");

        } catch (SQLException e) {
            getServletContext().log("LoginServlet: Database error during authentication", e);
            request.setAttribute("loginError", "An unexpected system error occurred. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}
