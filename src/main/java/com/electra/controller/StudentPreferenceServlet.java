package com.electra.controller;

import com.electra.dao.StudentProfileDAO;
import com.electra.model.AllocationForm;
import com.electra.model.Elective;
import com.electra.model.Preference;
import com.electra.model.PreferenceSubmission;
import com.electra.model.StudentProfile;
import com.electra.service.AllocationFormService;
import com.electra.service.ElectiveService;
import com.electra.service.PreferenceSubmissionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/preferences", "/student/preferences"})
public class StudentPreferenceServlet extends HttpServlet {

    private final PreferenceSubmissionService submissionService;
    private final AllocationFormService formService;
    private final ElectiveService electiveService;
    private final StudentProfileDAO profileDAO;

    public StudentPreferenceServlet() {
        this.submissionService = new PreferenceSubmissionService();
        this.formService = new AllocationFormService();
        this.electiveService = new ElectiveService();
        this.profileDAO = new StudentProfileDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"STUDENT".equals(session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Student access required.");
            return;
        }

        Long studentId = resolveStudentId(session);
        if (studentId == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "No student profile is linked to this session.");
            return;
        }

        // Flash messages
        if (session.getAttribute("preferenceSuccess") != null) {
            request.setAttribute("preferenceSuccess", session.getAttribute("preferenceSuccess"));
            session.removeAttribute("preferenceSuccess");
        }
        if (session.getAttribute("preferenceError") != null) {
            request.setAttribute("preferenceError", session.getAttribute("preferenceError"));
            session.removeAttribute("preferenceError");
        }

        try {
            List<AllocationForm> allForms = formService.getAllForms();
            List<AllocationForm> openForms = new ArrayList<>();
            for (AllocationForm f : allForms) {
                if ("OPEN".equals(f.getFormStatus())) {
                    openForms.add(f);
                }
            }
            request.setAttribute("openForms", openForms);

            AllocationForm selectedForm = null;
            String formIdParam = request.getParameter("formId");

            if (formIdParam != null && !formIdParam.isBlank()) {
                try {
                    long fid = Long.parseLong(formIdParam);
                    for (AllocationForm f : allForms) {
                        if (f.getFormId() == fid) {
                            selectedForm = f;
                            break;
                        }
                    }
                } catch (NumberFormatException ignored) {
                }
            }

            if (selectedForm == null && !openForms.isEmpty()) {
                selectedForm = openForms.get(0);
            } else if (selectedForm == null && !allForms.isEmpty()) {
                selectedForm = allForms.get(0);
            }

            if (selectedForm != null) {
                request.setAttribute("selectedForm", selectedForm);

                List<Elective> electives = electiveService.getActiveElectives(selectedForm.getFormId());
                request.setAttribute("activeElectives", electives);

                PreferenceSubmission submission =
                        submissionService.getSubmission(studentId, selectedForm.getFormId());
                request.setAttribute("submission", submission);

                List<Preference> savedPreferences = List.of();
                if (submission != null) {
                    savedPreferences = submissionService.getPreferences(studentId, selectedForm.getFormId());
                }
                request.setAttribute("savedPreferences", savedPreferences);

                boolean isSubmitted = submission != null && "SUBMITTED".equals(submission.getSubmissionStatus());
                boolean isDraft = submission != null && "DRAFT".equals(submission.getSubmissionStatus());
                request.setAttribute("isSubmitted", isSubmitted);
                request.setAttribute("isDraft", isDraft);
            }

            request.getRequestDispatcher("/preferences.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("preferenceError", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/preferences.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || !"STUDENT".equals(session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Student access required.");
            return;
        }

        // CSRF validation
        String sessionCsrf = (String) session.getAttribute("csrfToken");
        String paramCsrf = request.getParameter("csrfToken");
        if (sessionCsrf == null || !sessionCsrf.equals(paramCsrf)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Security validation failed (CSRF token invalid).");
            return;
        }

        Long studentId = resolveStudentId(session);
        if (studentId == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "No student profile is linked to this session.");
            return;
        }
        String formIdParam = request.getParameter("formId");
        String action = request.getParameter("action");

        long formId;
        try {
            formId = Long.parseLong(formIdParam);
        } catch (Exception e) {
            session.setAttribute("preferenceError", "Valid allocation form is required.");
            response.sendRedirect(request.getContextPath() + "/preferences");
            return;
        }

        try {
            List<Elective> electives = electiveService.getActiveElectives(formId);
            List<Preference> preferences = new ArrayList<>();

            for (int rank = 1; rank <= electives.size(); rank++) {
                String val = request.getParameter("rank_" + rank);
                if (val != null && !val.isBlank()) {
                    long electiveId = Long.parseLong(val);
                    Preference pref = new Preference();
                    pref.setFormId(formId);
                    pref.setElectiveId(electiveId);
                    pref.setPreferenceRank(rank);
                    preferences.add(pref);
                }
            }

            if ("saveDraft".equals(action)) {
                submissionService.saveDraft(studentId, formId, preferences);
                session.setAttribute("preferenceSuccess", "Draft choices saved successfully. Remember to submit before the deadline.");
                response.sendRedirect(request.getContextPath() + "/preferences?formId=" + formId);

            } else if ("submit".equals(action)) {
                submissionService.submitPreferences(studentId, formId, preferences);
                session.setAttribute("preferenceSuccess", "Your elective rankings have been submitted and locked for merit allocation.");
                response.sendRedirect(request.getContextPath() + "/preferences?formId=" + formId);

            } else {
                session.setAttribute("preferenceError", "Unknown preference action.");
                response.sendRedirect(request.getContextPath() + "/preferences?formId=" + formId);
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("preferenceError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/preferences?formId=" + formId);
        } catch (SQLException e) {
            session.setAttribute("preferenceError", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/preferences?formId=" + formId);
        } catch (Exception e) {
            session.setAttribute("preferenceError", "An unexpected error occurred: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/preferences?formId=" + formId);
        }
    }

    private Long resolveStudentId(HttpSession session) {
        Object sid = session.getAttribute("studentId");
        if (sid instanceof Long) {
            return (Long) sid;
        } else if (sid instanceof Number) {
            return ((Number) sid).longValue();
        }

        String roll = (String) session.getAttribute("studentRollNumber");
        if (roll != null && !roll.isBlank()) {
            try {
                StudentProfile p = profileDAO.findByStudentRollNumber(roll);
                if (p != null) {
                    session.setAttribute("studentId", p.getStudentId());
                    return p.getStudentId();
                }
            } catch (SQLException ignored) {
            }
        }

        return null;
    }
}
