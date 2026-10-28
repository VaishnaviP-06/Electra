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
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebServlet("/profile")
public class StudentProfileServlet extends HttpServlet {

    private static final Set<String> DEPARTMENTS = new HashSet<>(
        Arrays.asList("CMPN", "INFT", "EXTC", "ECS")
    );

    private static final Set<String> ACADEMIC_YEARS = new HashSet<>(
        Arrays.asList("Second Year", "Third Year", "Final Year")
    );

    private final StudentProfileDAO profileDAO = new StudentProfileDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        String rollNumber = getStudentRollNumber(request, response);
        if (rollNumber == null) {
            return;
        }

        try {
            StudentProfile profile =
                profileDAO.findByStudentRollNumber(rollNumber);

            if (profile == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "The student record linked to this account was not found."
                );
                return;
            }

            request.setAttribute("profile", profile);
            if ("saved".equals(request.getParameter("status"))) {
                request.setAttribute("message", "Profile saved successfully.");
                request.setAttribute("messageType", "success");
            }
        } catch (SQLException e) {
            getServletContext().log("Could not load student profile", e);
            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );
            request.setAttribute(
                "message",
                "Unable to load your profile from the database."
            );
            request.setAttribute("messageType", "danger");
        }

        request.getRequestDispatcher(
            "/WEB-INF/views/profile.jsp"
        ).forward(request, response);
    }

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String rollNumber = getStudentRollNumber(request, response);
        if (rollNumber == null) {
            return;
        }

        StudentProfile profile = new StudentProfile();
        profile.setFullName(trim(request.getParameter("fullName")));
        profile.setEmail(trim(request.getParameter("email")));
        profile.setRollNumber(trim(request.getParameter("rollNumber")));
        profile.setDepartment(trim(request.getParameter("department")));
        profile.setAcademicYear(trim(request.getParameter("academicYear")));

        String cgpaValue = trim(request.getParameter("cgpa"));
        request.setAttribute("cgpaValue", cgpaValue);
        String validationError = validate(profile, cgpaValue);
        if (validationError != null) {
            showFormError(request, response, profile, validationError);
            return;
        }

        profile.setCgpa(new BigDecimal(cgpaValue));

        try {
            StudentProfile student =
                profileDAO.findByStudentRollNumber(rollNumber);

            if (student == null) {
                response.sendError(
                    HttpServletResponse.SC_NOT_FOUND,
                    "The student record linked to this account was not found."
                );
                return;
            }

            profile.setStudentId(student.getStudentId());
            profileDAO.save(profile);
            response.sendRedirect(
                request.getContextPath() + "/profile?status=saved"
            );
        } catch (SQLException e) {
            getServletContext().log("Could not save student profile", e);
            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );
            showFormError(
                request,
                response,
                profile,
                "Unable to save your profile to the database."
            );
        }
    }

    private String getStudentRollNumber(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"STUDENT".equals(
                session.getAttribute("role"))) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "Student access required."
            );
            return null;
        }

        Object rollNumber = session.getAttribute("studentRollNumber");
        if (!(rollNumber instanceof String)
                || ((String) rollNumber).trim().isEmpty()) {
            response.sendError(
                HttpServletResponse.SC_FORBIDDEN,
                "No student record is linked to this account."
            );
            return null;
        }

        return (String) rollNumber;
    }

    private String validate(StudentProfile profile, String cgpaValue) {
        if (profile.getFullName().length() < 2
                || profile.getFullName().length() > 100) {
            return "Enter a full name between 2 and 100 characters.";
        }

        if (profile.getEmail().length() > 150
                || !profile.getEmail().matches(
                    "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Enter a valid email address.";
        }

        if (profile.getRollNumber().isEmpty()
                || profile.getRollNumber().length() > 30) {
            return "Enter a roll number between 1 and 30 characters.";
        }

        if (!DEPARTMENTS.contains(profile.getDepartment())) {
            return "Select a valid department.";
        }

        if (!ACADEMIC_YEARS.contains(profile.getAcademicYear())) {
            return "Select a valid academic year.";
        }

        try {
            BigDecimal cgpa = new BigDecimal(cgpaValue);
            if (cgpa.compareTo(BigDecimal.ZERO) < 0
                    || cgpa.compareTo(BigDecimal.TEN) > 0
                    || cgpa.scale() > 2) {
                return "CGPA must be between 0 and 10 with up to 2 decimals.";
            }
        } catch (NumberFormatException e) {
            return "Enter a valid CGPA.";
        }

        return null;
    }

    private void showFormError(
            HttpServletRequest request,
            HttpServletResponse response,
            StudentProfile profile,
            String message) throws ServletException, IOException {

        request.setAttribute("profile", profile);
        request.setAttribute("message", message);
        request.setAttribute("messageType", "danger");
        request.getRequestDispatcher(
            "/WEB-INF/views/profile.jsp"
        ).forward(request, response);
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
