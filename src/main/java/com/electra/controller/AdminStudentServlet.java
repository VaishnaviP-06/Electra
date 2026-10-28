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
import java.util.List;

@WebServlet(urlPatterns = {"/admin-students", "/admin/students"})
public class AdminStudentServlet extends HttpServlet {

    private final StudentProfileDAO profileDAO = new StudentProfileDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        try {
            List<StudentProfile> students = profileDAO.findAllStudents();
            long totalStudents = students.size();
            long eligibleStudents = students.stream()
                    .filter(s -> s.getCgpa() != null && s.getCgpa().doubleValue() >= 6.0)
                    .count();
            long needsReview = students.stream()
                    .filter(s -> s.getCgpa() == null || s.getCgpa().doubleValue() < 6.0)
                    .count();

            request.setAttribute("students", students);
            request.setAttribute("totalStudents", totalStudents);
            request.setAttribute("eligibleStudents", eligibleStudents);
            request.setAttribute("needsReview", needsReview);
            request.getRequestDispatcher("/admin-students.jsp").forward(request, response);

        } catch (SQLException e) {
            getServletContext().log("AdminStudentServlet: Error fetching students from database", e);
            request.setAttribute("error", "Unable to load student directory records from the database. Please try again later.");
            request.setAttribute("students", List.of());
            request.setAttribute("totalStudents", 0);
            request.setAttribute("eligibleStudents", 0);
            request.setAttribute("needsReview", 0);
            request.getRequestDispatcher("/admin-students.jsp").forward(request, response);
        }
    }
}
