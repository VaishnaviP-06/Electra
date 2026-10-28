package com.electra.controller;

import com.electra.dao.ReportDAO;
import com.electra.dao.ReportDAO.ReportSummary;
import com.electra.model.AllocationForm;
import com.electra.model.ReportRow;
import com.electra.service.AllocationFormService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(urlPatterns = {"/reports", "/reports/export", "/admin/reports"})
public class ReportServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();
    private final AllocationFormService formService = new AllocationFormService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || !"ADMIN".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String path = request.getServletPath();
        String formIdParam = request.getParameter("formId");
        Long formId = null;
        if (formIdParam != null && !formIdParam.isBlank()) {
            try {
                formId = Long.parseLong(formIdParam);
            } catch (NumberFormatException ignored) {
            }
        }

        if ("/reports/export".equals(path) || "exportXml".equals(request.getParameter("action"))) {
            handleXmlExport(request, response, formId);
            return;
        }

        try {
            List<AllocationForm> forms = formService.getAllForms();
            request.setAttribute("forms", forms);
            request.setAttribute("selectedFormId", formId);

            ReportSummary summary = reportDAO.getReportSummary(formId);
            List<ReportRow> rows = reportDAO.getReportRows(formId);

            request.setAttribute("reportSummary", summary);
            request.setAttribute("reportRows", rows);

            request.getRequestDispatcher("/reports.jsp").forward(request, response);

        } catch (SQLException e) {
            getServletContext().log("ReportServlet: DB Error loading report data", e);
            request.setAttribute("error", "Unable to load allocation report data from the database.");
            request.setAttribute("reportSummary", new ReportSummary());
            request.setAttribute("reportRows", List.of());
            request.getRequestDispatcher("/reports.jsp").forward(request, response);
        }
    }

    private void handleXmlExport(HttpServletRequest request, HttpServletResponse response, Long formId)
            throws IOException {

        response.setContentType("application/xml;charset=UTF-8");
        response.setCharacterEncoding("UTF-8");

        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));
        String filename = "electra_report_" + (formId != null ? "form" + formId + "_" : "all_") + timestamp + ".xml";
        response.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");

        try {
            ReportSummary summary = reportDAO.getReportSummary(formId);
            List<ReportRow> rows = reportDAO.getReportRows(formId);

            PrintWriter out = response.getWriter();
            out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
            out.println("<electra-allocation-report>");
            out.println("  <generated-at>" + escapeXml(LocalDateTime.now().toString()) + "</generated-at>");
            out.println("  <filter-form-id>" + (formId != null ? formId : "ALL") + "</filter-form-id>");
            out.println("  <summary>");
            out.println("    <total-submissions>" + summary.getTotalSubmissions() + "</total-submissions>");
            out.println("    <seats-allocated>" + summary.getTotalSeatsAllocated() + "</seats-allocated>");
            out.println("    <below-minimum-enrolment-electives>" + summary.getBelowMinEnrolmentCount() + "</below-minimum-enrolment-electives>");
            out.println("  </summary>");
            out.println("  <electives>");

            for (ReportRow row : rows) {
                out.println("    <elective>");
                out.println("      <code>" + escapeXml(row.getElectiveCode()) + "</code>");
                out.println("      <name>" + escapeXml(row.getElectiveName()) + "</name>");
                out.println("      <capacity>" + row.getCapacity() + "</capacity>");
                out.println("      <allocated>" + row.getAllocatedCount() + "</allocated>");
                out.println("      <utilisation>" + escapeXml(row.getUtilisation()) + "</utilisation>");
                out.println("      <enrolment-status>" + escapeXml(row.getEnrolmentStatus()) + "</enrolment-status>");
                out.println("    </elective>");
            }

            out.println("  </electives>");
            out.println("</electra-allocation-report>");
            out.flush();

        } catch (SQLException e) {
            getServletContext().log("ReportServlet: Error generating XML report", e);
            response.reset();
            response.setContentType("text/plain;charset=UTF-8");
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println("An error occurred while generating the XML report. Please contact the administrator.");
        }
    }

    private String escapeXml(String text) {
        if (text == null) {
            return "";
        }
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;")
                   .replace("'", "&apos;");
    }
}
