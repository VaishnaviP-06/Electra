package com.electra.controller;

import com.electra.dao.DashboardDAO;
import com.electra.dao.DashboardDAO.AdminDashboardData;
import com.electra.dao.DashboardDAO.StudentDashboardData;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(urlPatterns = {"/dashboard", "/student/dashboard", "/admin/dashboard"})
public class DashboardServlet extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");

        try {
            if ("ADMIN".equals(role)) {
                AdminDashboardData adminData = dashboardDAO.getAdminDashboardData();
                request.setAttribute("adminData", adminData);
                request.getRequestDispatcher("/admin.jsp").forward(request, response);
                return;
            } else if ("STUDENT".equals(role)) {
                Long studentId = (Long) session.getAttribute("studentId");
                if (studentId == null) {
                    studentId = 1L; // Fallback
                }

                StudentDashboardData studentData = dashboardDAO.getStudentDashboardData(studentId);
                request.setAttribute("studentData", studentData);
                request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
                return;
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }

        } catch (SQLException e) {
            getServletContext().log("DashboardServlet: DB Error loading dashboard metrics", e);
            if ("ADMIN".equals(role)) {
                request.setAttribute("adminData", new AdminDashboardData());
                request.getRequestDispatcher("/admin.jsp").forward(request, response);
            } else {
                request.setAttribute("studentData", new StudentDashboardData());
                request.getRequestDispatcher("/dashboard.jsp").forward(request, response);
            }
        }
    }
}
