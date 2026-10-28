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

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = {"/electives"})
public class StudentElectiveServlet extends HttpServlet {

    private final ElectiveService electiveService;
    private final AllocationFormService formService;

    public StudentElectiveServlet() {
        this.electiveService = new ElectiveService();
        this.formService = new AllocationFormService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            List<AllocationForm> allForms = formService.getAllForms();
            request.setAttribute("forms", allForms);

            String formIdParam = request.getParameter("formId");
            List<Elective> electives = new ArrayList<>();
            AllocationForm selectedForm = null;

            if (formIdParam != null && !formIdParam.isBlank()) {
                try {
                    long formId = Long.parseLong(formIdParam);
                    for (AllocationForm f : allForms) {
                        if (f.getFormId() == formId) {
                            selectedForm = f;
                            break;
                        }
                    }
                    if (selectedForm != null) {
                        electives = electiveService.getActiveElectives(formId);
                    }
                } catch (NumberFormatException ignored) {
                }
            }

            if (selectedForm == null) {
                // Default: collect electives from all open forms (or first available form)
                for (AllocationForm f : allForms) {
                    if ("OPEN".equals(f.getFormStatus())) {
                        electives.addAll(electiveService.getActiveElectives(f.getFormId()));
                    }
                }
                if (electives.isEmpty() && !allForms.isEmpty()) {
                    selectedForm = allForms.get(0);
                    electives = electiveService.getActiveElectives(selectedForm.getFormId());
                }
            }

            request.setAttribute("selectedForm", selectedForm);
            request.setAttribute("electives", electives);
            request.getRequestDispatcher("/electives.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/electives.jsp").forward(request, response);
        }
    }
}
