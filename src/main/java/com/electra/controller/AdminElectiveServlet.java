package com.electra.controller;

import com.electra.model.AllocationForm;
import com.electra.model.Elective;
import com.electra.service.AllocationFormService;
import com.electra.service.ElectiveService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet(urlPatterns = {"/admin-electives", "/admin/electives"})
public class AdminElectiveServlet extends HttpServlet {

    private final ElectiveService electiveService;
    private final AllocationFormService formService;

    public AdminElectiveServlet() {
        this.electiveService = new ElectiveService();
        this.formService = new AllocationFormService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Pull flash messages from session
        if (session.getAttribute("adminElectiveSuccess") != null) {
            request.setAttribute("adminElectiveSuccess", session.getAttribute("adminElectiveSuccess"));
            session.removeAttribute("adminElectiveSuccess");
        }
        if (session.getAttribute("adminElectiveError") != null) {
            request.setAttribute("adminElectiveError", session.getAttribute("adminElectiveError"));
            session.removeAttribute("adminElectiveError");
        }

        try {
            List<AllocationForm> forms = formService.getAllForms();
            request.setAttribute("forms", forms);

            String formIdParam = request.getParameter("formId");
            List<Elective> electives;
            AllocationForm selectedForm = null;

            if (formIdParam != null && !formIdParam.isBlank()) {
                try {
                    long fid = Long.parseLong(formIdParam);
                    for (AllocationForm f : forms) {
                        if (f.getFormId() == fid) {
                            selectedForm = f;
                            break;
                        }
                    }
                    if (selectedForm != null) {
                        electives = electiveService.getAllElectives(fid);
                    } else {
                        electives = electiveService.getAllElectives();
                    }
                } catch (NumberFormatException e) {
                    electives = electiveService.getAllElectives();
                }
            } else {
                electives = electiveService.getAllElectives();
            }

            request.setAttribute("selectedForm", selectedForm);
            request.setAttribute("electives", electives);
            request.getRequestDispatcher("/admin-electives.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("adminElectiveError", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/admin-electives.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required.");
            return;
        }

        // CSRF Check
        String sessionCsrf = (String) session.getAttribute("csrfToken");
        String paramCsrf = request.getParameter("csrfToken");
        if (sessionCsrf == null || !sessionCsrf.equals(paramCsrf)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Security validation failed (CSRF token invalid).");
            return;
        }

        String action = request.getParameter("action");
        String formIdParam = request.getParameter("formId");

        try {
            if ("create".equals(action)) {
                String code = request.getParameter("electiveCode");
                String name = request.getParameter("electiveName");
                String syllabus = request.getParameter("syllabus");
                String faculty = request.getParameter("facultyName");
                int totalSeats = Integer.parseInt(request.getParameter("totalSeats"));
                String minStudentsParam = request.getParameter("minStudents");
                int minStudents = (minStudentsParam != null && !minStudentsParam.isBlank())
                        ? Integer.parseInt(minStudentsParam) : 1;

                String minCgpaParam = request.getParameter("minCgpa");
                Double minCgpa = (minCgpaParam != null && !minCgpaParam.isBlank())
                        ? Double.parseDouble(minCgpaParam) : null;

                long formId = Long.parseLong(formIdParam);

                Elective elective = new Elective();
                elective.setFormId(formId);
                elective.setElectiveCode(code != null ? code.trim() : null);
                elective.setElectiveName(name != null ? name.trim() : null);
                elective.setSyllabus(syllabus != null ? syllabus.trim() : null);
                elective.setFacultyName(faculty != null ? faculty.trim() : null);
                elective.setTotalSeats(totalSeats);
                elective.setMinStudents(minStudents);
                elective.setMinCgpa(minCgpa);
                elective.setActive(true);

                electiveService.createElective(elective);
                session.setAttribute("adminElectiveSuccess", "Elective " + elective.getElectiveCode() + " created successfully.");
                response.sendRedirect(request.getContextPath() + "/admin-electives?formId=" + formId);

            } else if ("toggleActive".equals(action)) {
                long electiveId = Long.parseLong(request.getParameter("electiveId"));
                long formId = Long.parseLong(formIdParam);
                boolean currentlyActive = Boolean.parseBoolean(request.getParameter("currentlyActive"));

                if (currentlyActive) {
                    electiveService.deactivateElective(electiveId, formId);
                    session.setAttribute("adminElectiveSuccess", "Elective deactivated.");
                } else {
                    electiveService.activateElective(electiveId, formId);
                    session.setAttribute("adminElectiveSuccess", "Elective activated.");
                }
                response.sendRedirect(request.getContextPath() + "/admin-electives?formId=" + formId);

            } else {
                session.setAttribute("adminElectiveError", "Unknown action: " + action);
                response.sendRedirect(request.getContextPath() + "/admin-electives");
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("adminElectiveError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin-electives" + (formIdParam != null ? "?formId=" + formIdParam : ""));
        } catch (SQLException e) {
            session.setAttribute("adminElectiveError", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin-electives" + (formIdParam != null ? "?formId=" + formIdParam : ""));
        } catch (Exception e) {
            session.setAttribute("adminElectiveError", "Unexpected error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin-electives");
        }
    }
}
