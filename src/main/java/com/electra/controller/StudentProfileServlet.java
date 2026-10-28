package com.electra.controller;

import com.electra.dao.StudentProfileDAO;
import com.electra.model.StudentProfile;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/profile")
public class StudentProfileServlet extends HttpServlet {

    private final StudentProfileDAO profileDAO = new StudentProfileDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"STUDENT".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Strictly derive the student identity from the authenticated session
        Long sessionStudentId = (Long) session.getAttribute("studentId");
        String sessionRollNumber = (String) session.getAttribute("studentRollNumber");

        if (sessionStudentId == null && sessionRollNumber == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "No student profile is linked to this session.");
            return;
        }

        try {
            StudentProfile profile = null;
            if (sessionStudentId != null) {
                profile = profileDAO.findByStudentId(sessionStudentId);
            }
            if (profile == null && sessionRollNumber != null) {
                profile = profileDAO.findByStudentRollNumber(sessionRollNumber);
            }

            if (profile == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Student profile record not found.");
                return;
            }

            request.setAttribute("profile", profile);

        } catch (SQLException e) {
            getServletContext().log("StudentProfileServlet: DB error fetching student profile", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("message", "Unable to load student profile from database.");
            request.setAttribute("messageType", "danger");
        }

        request.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // The student profile is strictly view-only per academic policy.
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED, "Student profile updates are not permitted.");
    }
}
