package com.electra.controller;

import com.electra.model.AllocationForm;
import com.electra.model.Elective;
import com.electra.service.AllocationFormService;
import com.electra.service.ElectiveService;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/test-service-layer")
public class ServiceLayerTestServlet extends HttpServlet {

    private final AllocationFormService formService =
            new AllocationFormService();

    private final ElectiveService electiveService =
            new ElectiveService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        response.setContentType("text/plain;charset=UTF-8");

        try {
            String mode = request.getParameter("mode");
            if (mode == null) {
                mode = "forms";
            }

            switch (mode) {
                case "forms": {
                    List<AllocationForm> forms =
                            formService.getAllForms();

                    response.getWriter().println("RESULT: PASSED");
                    response.getWriter().println(
                            "Forms retrieved: " + forms.size());

                    for (AllocationForm form : forms) {
                        response.getWriter().println(
                                form.getFormId() + " | "
                                + form.getFormName() + " | "
                                + form.getFormStatus());
                    }
                    break;
                }

                case "form": {
                    long formId = Long.parseLong(
                            request.getParameter("formId"));

                    AllocationForm form =
                            formService.getFormById(formId);

                    response.getWriter().println("RESULT: PASSED");
                    response.getWriter().println(
                            "Form: " + form.getFormName());
                    response.getWriter().println(
                            "Status: " + form.getFormStatus());
                    break;
                }

                case "electives": {
                    long formId = Long.parseLong(
                            request.getParameter("formId"));

                    List<Elective> electives =
                            electiveService.getActiveElectives(formId);

                    response.getWriter().println("RESULT: PASSED");
                    response.getWriter().println(
                            "Active electives: " + electives.size());

                    for (Elective elective : electives) {
                        response.getWriter().println(
                                elective.getElectiveId() + " | "
                                + elective.getElectiveCode() + " | "
                                + elective.getElectiveName());
                    }
                    break;
                }

                case "elective": {
                    long formId = Long.parseLong(
                            request.getParameter("formId"));
                    long electiveId = Long.parseLong(
                            request.getParameter("electiveId"));

                    Elective elective = electiveService.getElective(
                            electiveId, formId);

                    response.getWriter().println("RESULT: PASSED");
                    response.getWriter().println(
                            "Elective: " + elective.getElectiveName());
                    response.getWriter().println(
                            "Form ID: " + elective.getFormId());
                    break;
                }

                case "invalid-form":
                    formService.getFormById(-1);
                    response.getWriter().println(
                            "TEST FAILED: Invalid form ID was accepted.");
                    break;

                case "invalid-elective":
                    electiveService.getElective(-1, 1);
                    response.getWriter().println(
                            "TEST FAILED: Invalid elective ID was accepted.");
                    break;

                default:
                    throw new IllegalArgumentException(
                            "Unknown mode: " + mode);
            }

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().println("REQUEST REJECTED");
            response.getWriter().println(
                    e.getClass().getSimpleName() + ": "
                    + e.getMessage());
        }
    }
}