package com.electra.controller;

import com.electra.dao.AllocationDAO;
import com.electra.model.StudentAllocationView;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/allocation-results", "/student/allocation-results"})
public class StudentAllocationServlet extends HttpServlet {

    private final AllocationDAO allocationDAO = new AllocationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"STUDENT".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Resolve studentId from session (set by LoginServlet)
        Long studentId = (Long) session.getAttribute("studentId");
        if (studentId == null) {
            // Fallback: no student profile found
            request.setAttribute("allocationViews", List.of());
            request.setAttribute("hasSubmissions", false);
            request.setAttribute("hasPublishedResults", false);
            request.setAttribute("errorMessage",
                "Your student profile could not be found. Please contact the administrator.");
            request.getRequestDispatcher("/allocation-results.jsp").forward(request, response);
            return;
        }

        try {
            List<StudentAllocationView> views = allocationDAO.findStudentAllocations(studentId);

            boolean hasSubmissions = views.stream()
                .anyMatch(v -> v.getSubmissionStatus() != null);
            boolean hasPublishedResults = views.stream()
                .anyMatch(v -> v.isResultsPublished() && v.getAllocationStatus() != null);

            request.setAttribute("allocationViews", views);
            request.setAttribute("hasSubmissions", hasSubmissions);
            request.setAttribute("hasPublishedResults", hasPublishedResults);

        } catch (SQLException e) {
            getServletContext().log("StudentAllocationServlet: DB error for student " + studentId, e);
            request.setAttribute("allocationViews", List.of());
            request.setAttribute("hasSubmissions", false);
            request.setAttribute("hasPublishedResults", false);
            request.setAttribute("errorMessage",
                "An error occurred while loading your allocation results. Please try again later.");
        }

        request.getRequestDispatcher("/allocation-results.jsp").forward(request, response);
    }
}
