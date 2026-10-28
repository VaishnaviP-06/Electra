package com.electra.controller;

import com.electra.dao.AllocationDAO;
import com.electra.dao.UserDAO;
import com.electra.model.AllocationForm;
import com.electra.model.ElectiveReviewDetail;
import com.electra.model.User;
import com.electra.service.AllocationFormService;
import com.electra.service.AllocationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(urlPatterns = {"/admin-allocations", "/admin/allocation"})
public class AdminAllocationServlet extends HttpServlet {

    private final AllocationService allocationService;
    private final AllocationFormService formService;
    private final AllocationDAO allocationDAO;
    private final UserDAO userDAO;

    public AdminAllocationServlet() {
        this.allocationService = new AllocationService();
        this.formService = new AllocationFormService();
        this.allocationDAO = new AllocationDAO();
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrator access required.");
            return;
        }

        // Transfer flash messages from session to request
        if (session.getAttribute("adminSuccess") != null) {
            request.setAttribute("adminSuccess", session.getAttribute("adminSuccess"));
            session.removeAttribute("adminSuccess");
        }
        if (session.getAttribute("adminError") != null) {
            request.setAttribute("adminError", session.getAttribute("adminError"));
            session.removeAttribute("adminError");
        }

        try {
            List<AllocationForm> forms = formService.getAllForms();
            request.setAttribute("forms", forms);

            String formIdParam = request.getParameter("formId");
            if (formIdParam != null && !formIdParam.isBlank()) {
                try {
                    long formId = Long.parseLong(formIdParam);
                    AllocationForm selectedForm = formService.getFormById(formId);

                    if (selectedForm != null) {
                        request.setAttribute("selectedForm", selectedForm);

                        List<ElectiveReviewDetail> reviewDetails =
                                allocationService.getElectiveReviewDetails(formId);
                        request.setAttribute("reviewDetails", reviewDetails);

                        boolean hasPrepared = allocationService.hasPreparedReviews(formId);
                        request.setAttribute("hasPreparedReviews", hasPrepared);

                        int candidateCount = 0;
                        try {
                            candidateCount = allocationDAO.findSubmittedCandidates(formId).size();
                        } catch (Exception ignored) {
                        }
                        request.setAttribute("candidateCount", candidateCount);

                        // Workflow condition helpers
                        boolean canClose = "OPEN".equals(selectedForm.getFormStatus());
                        boolean canRunAllocation = "CLOSED".equals(selectedForm.getFormStatus())
                                && "NOT_STARTED".equals(selectedForm.getAllocationStatus())
                                && candidateCount > 0;
                        boolean canPrepareReview = "COMPLETED".equals(selectedForm.getAllocationStatus())
                                && "PENDING".equals(selectedForm.getReviewStatus())
                                && !hasPrepared;
                        boolean canReview = "COMPLETED".equals(selectedForm.getAllocationStatus())
                                && "PENDING".equals(selectedForm.getReviewStatus())
                                && hasPrepared;
                        boolean canFinalize = "COMPLETED".equals(selectedForm.getAllocationStatus())
                                && "REVIEWED".equals(selectedForm.getReviewStatus())
                                && !selectedForm.isResultsPublished();
                        boolean canPublish = "COMPLETED".equals(selectedForm.getAllocationStatus())
                                && "REVIEWED".equals(selectedForm.getReviewStatus())
                                && !selectedForm.isResultsPublished();

                        request.setAttribute("canClose", canClose);
                        request.setAttribute("canRunAllocation", canRunAllocation);
                        request.setAttribute("canPrepareReview", canPrepareReview);
                        request.setAttribute("canReview", canReview);
                        request.setAttribute("canFinalize", canFinalize);
                        request.setAttribute("canPublish", canPublish);
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("adminError", "Invalid form ID format.");
                }
            }

            request.getRequestDispatcher("/admin-allocations.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("adminError", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/admin-allocations.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession(false);

        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Administrator access required.");
            return;
        }

        // CSRF Token validation
        String sessionCsrf = (String) session.getAttribute("csrfToken");
        String paramCsrf = request.getParameter("csrfToken");
        if (sessionCsrf == null || !sessionCsrf.equals(paramCsrf)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Security validation failed (CSRF token invalid).");
            return;
        }

        // Derive reviewer ID from authenticated session, never from user parameter
        long reviewerId = getAuthenticatedReviewerId(session);

        String action = request.getParameter("action");
        String formIdParam = request.getParameter("formId");
        long formId = 0;
        if (formIdParam != null && !formIdParam.isBlank()) {
            try {
                formId = Long.parseLong(formIdParam);
            } catch (NumberFormatException ignored) {
            }
        }

        try {
            if ("closeForm".equals(action)) {
                if (formId <= 0) throw new IllegalArgumentException("Valid form ID is required.");
                formService.closeForm(formId);
                session.setAttribute("adminSuccess", "Allocation form #" + formId + " closed successfully. Initial allocation can now be run.");
                response.sendRedirect(request.getContextPath() + "/admin-allocations?formId=" + formId);

            } else if ("runAllocation".equals(action)) {
                if (formId <= 0) throw new IllegalArgumentException("Valid form ID is required.");
                long runId = allocationService.runInitialAllocation(formId);
                session.setAttribute("adminSuccess", "Initial provisional allocation completed successfully (Run #" + runId + "). Next step: prepare minimum-enrolment review.");
                response.sendRedirect(request.getContextPath() + "/admin-allocations?formId=" + formId);

            } else if ("prepareReview".equals(action)) {
                if (formId <= 0) throw new IllegalArgumentException("Valid form ID is required.");
                allocationService.prepareMinimumEnrolmentReview(formId);
                session.setAttribute("adminSuccess", "Minimum-enrolment review prepared. Please review each active elective below.");
                response.sendRedirect(request.getContextPath() + "/admin-allocations?formId=" + formId);

            } else if ("reviewElective".equals(action)) {
                if (formId <= 0) throw new IllegalArgumentException("Valid form ID is required.");
                String electiveIdParam = request.getParameter("electiveId");
                if (electiveIdParam == null || electiveIdParam.isBlank()) {
                    throw new IllegalArgumentException("Valid elective ID is required.");
                }
                long electiveId = Long.parseLong(electiveIdParam);
                String notes = request.getParameter("notes");
                if (notes != null) {
                    notes = notes.trim();
                }

                allocationService.recordElectiveReview(formId, electiveId, reviewerId, notes);
                session.setAttribute("adminSuccess", "Review for elective #" + electiveId + " submitted successfully.");
                response.sendRedirect(request.getContextPath() + "/admin-allocations?formId=" + formId);

            } else if ("finalize".equals(action)) {
                if (formId <= 0) throw new IllegalArgumentException("Valid form ID is required.");
                allocationService.finalizeReviewedAllocation(formId);
                session.setAttribute("adminSuccess", "Allocation finalized successfully. Allocations to under-enrolled electives marked NOT_ALLOTTED. Results remain unpublished.");
                response.sendRedirect(request.getContextPath() + "/admin-allocations?formId=" + formId);

            } else if ("publishResults".equals(action)) {
                if (formId <= 0) throw new IllegalArgumentException("Valid form ID is required.");
                formService.publishResults(formId);
                session.setAttribute("adminSuccess", "Allocation results published! Students can now view their official allocations.");
                response.sendRedirect(request.getContextPath() + "/admin-allocations?formId=" + formId);

            } else if ("createForm".equals(action)) {
                String formName = request.getParameter("formName");
                String categoryName = request.getParameter("categoryName");
                String batchOrCycle = request.getParameter("batchOrCycle");
                String openingDateStr = request.getParameter("openingDate");
                String submissionDeadlineStr = request.getParameter("submissionDeadline");

                AllocationForm newForm = new AllocationForm();
                newForm.setFormName(formName);
                newForm.setCategoryName(categoryName);
                newForm.setBatchOrCycle(batchOrCycle);

                if (openingDateStr != null && !openingDateStr.isBlank()) {
                    LocalDateTime openLdt = LocalDateTime.parse(openingDateStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                    newForm.setOpeningDate(Timestamp.valueOf(openLdt));
                }
                if (submissionDeadlineStr != null && !submissionDeadlineStr.isBlank()) {
                    LocalDateTime deadLdt = LocalDateTime.parse(submissionDeadlineStr, DateTimeFormatter.ISO_LOCAL_DATE_TIME);
                    newForm.setSubmissionDeadline(Timestamp.valueOf(deadLdt));
                }

                newForm.setFormStatus("DRAFT");
                boolean created = formService.createForm(newForm);
                if (created) {
                    session.setAttribute("adminSuccess", "Allocation form \"" + newForm.getFormName() + "\" created successfully as DRAFT.");
                    response.sendRedirect(request.getContextPath() + "/admin-allocations?formId=" + newForm.getFormId());
                } else {
                    session.setAttribute("adminError", "Could not create allocation form.");
                    response.sendRedirect(request.getContextPath() + "/admin-allocations");
                }

            } else {
                session.setAttribute("adminError", "Unknown allocation action: " + action);
                response.sendRedirect(request.getContextPath() + "/admin-allocations" + (formId > 0 ? "?formId=" + formId : ""));
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            session.setAttribute("adminError", e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin-allocations" + (formId > 0 ? "?formId=" + formId : ""));
        } catch (SQLException e) {
            session.setAttribute("adminError", "Database error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin-allocations" + (formId > 0 ? "?formId=" + formId : ""));
        } catch (Exception e) {
            session.setAttribute("adminError", "Unexpected error: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/admin-allocations" + (formId > 0 ? "?formId=" + formId : ""));
        }
    }

    private long getAuthenticatedReviewerId(HttpSession session) {
        Object sessionReviewerId = session.getAttribute("adminUserId");
        if (sessionReviewerId instanceof Long) {
            return (Long) sessionReviewerId;
        } else if (sessionReviewerId instanceof Number) {
            return ((Number) sessionReviewerId).longValue();
        }

        try {
            User adminUser = userDAO.findByUsername("admin_demo");
            if (adminUser != null && adminUser.isActive()) {
                session.setAttribute("adminUserId", adminUser.getUserId());
                return adminUser.getUserId();
            }
        } catch (SQLException ignored) {
        }

        // Safe fallback to first active admin
        session.setAttribute("adminUserId", 1L);
        return 1L;
    }
}
