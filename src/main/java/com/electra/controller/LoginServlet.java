package com.electra.controller;

import com.electra.dao.StudentProfileDAO;
import com.electra.dao.UserDAO;
import com.electra.model.StudentProfile;
import com.electra.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Locale;
import java.util.UUID;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final String DEMO_STUDENT_EMAIL = "student@student.sfit.ac.in";
    private static final String DEMO_ADMIN_EMAIL = "admin@sfit.ac.in";
    private static final String DEMO_PASSWORD = "123456";
    private static final String DEMO_STUDENT_ROLL_NUMBER = "CE055";

    private final UserDAO userDAO = new UserDAO();
    private final StudentProfileDAO profileDAO = new StudentProfileDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String email = request.getParameter("userId");
        String password = request.getParameter("password");
        String requestedRole = request.getParameter("role");
        if (email == null || password == null || requestedRole == null || email.isBlank() || password.isBlank()) {
            request.setAttribute("loginError", "Enter your email, password and account type.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        email = email.trim().toLowerCase(Locale.ROOT);
        String role = requestedRole.trim().toUpperCase(Locale.ROOT);
        boolean studentMatch = "STUDENT".equals(role) && DEMO_STUDENT_EMAIL.equals(email) && DEMO_PASSWORD.equals(password);
        boolean adminMatch = "ADMIN".equals(role) && DEMO_ADMIN_EMAIL.equals(email) && DEMO_PASSWORD.equals(password);
        if (!studentMatch && !adminMatch) {
            request.setAttribute("loginError", "Demo login failed. Check the account type and demo credentials in README.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) oldSession.invalidate();
        HttpSession session = request.getSession(true);
        session.setAttribute("userId", email);
        session.setAttribute("username", studentMatch ? "Demo Student" : "Demo Administrator");
        session.setAttribute("role", role);
        session.setAttribute("csrfToken", UUID.randomUUID().toString());

        if (studentMatch) {
            session.setAttribute("studentRollNumber", DEMO_STUDENT_ROLL_NUMBER);
            try {
                StudentProfile profile = profileDAO.findByStudentRollNumber(DEMO_STUDENT_ROLL_NUMBER);
                if (profile != null) {
                    session.setAttribute("studentId", profile.getStudentId());
                    session.setAttribute("studentName", profile.getFullName());
                } else {
                    session.setAttribute("studentId", 1L);
                    session.setAttribute("studentName", "Demo Student");
                }
            } catch (Exception e) {
                session.setAttribute("studentId", 1L);
                session.setAttribute("studentName", "Demo Student");
            }
        } else if (adminMatch) {
            try {
                User adminUser = userDAO.findByUsername("admin_demo");
                if (adminUser != null && adminUser.isActive()) {
                    session.setAttribute("adminUserId", adminUser.getUserId());
                    session.setAttribute("userDbId", adminUser.getUserId());
                } else {
                    session.setAttribute("adminUserId", 1L);
                    session.setAttribute("userDbId", 1L);
                }
            } catch (Exception e) {
                session.setAttribute("adminUserId", 1L);
                session.setAttribute("userDbId", 1L);
            }
        }
        session.setMaxInactiveInterval(30 * 60);
        response.sendRedirect(request.getContextPath() + (adminMatch ? "/dashboard" : "/dashboard"));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
}
