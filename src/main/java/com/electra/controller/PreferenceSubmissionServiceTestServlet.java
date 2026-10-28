
package com.electra.controller;

import com.electra.model.Preference;
import com.electra.model.PreferenceSubmission;
import com.electra.service.PreferenceSubmissionService;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/test-preference-service")
public class PreferenceSubmissionServiceTestServlet extends HttpServlet {

    private final PreferenceSubmissionService service =
            new PreferenceSubmissionService();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response) throws IOException {

        response.setContentType("text/plain;charset=UTF-8");

        try {
            long studentId =
                    Long.parseLong(request.getParameter("studentId"));
            long formId =
                    Long.parseLong(request.getParameter("formId"));

            String mode = request.getParameter("mode");
            String rawPreferences = request.getParameter("preferences");

            List<Preference> preferences = new ArrayList<>();

            if (rawPreferences != null && !rawPreferences.isBlank()) {
                for (String item : rawPreferences.split(",")) {
                    String[] parts = item.trim().split(":");

                    if (parts.length != 2) {
                        throw new IllegalArgumentException(
                                "Use electiveId:rank,electiveId:rank");
                    }

                    Preference preference = new Preference();
                    preference.setElectiveId(
                            Long.parseLong(parts[0].trim()));
                    preference.setPreferenceRank(
                            Integer.parseInt(parts[1].trim()));

                    preferences.add(preference);
                }
            }

            PreferenceSubmission result;

            if ("submit".equalsIgnoreCase(mode)) {
                result = service.submitPreferences(
                        studentId, formId, preferences);
            } else if ("draft".equalsIgnoreCase(mode)) {
                result = service.saveDraft(
                        studentId, formId, preferences);
            } else {
                throw new IllegalArgumentException(
                        "Mode must be draft or submit.");
            }

            response.getWriter().println("RESULT: PASSED");
            response.getWriter().println(
                    "Submission ID: " + result.getSubmissionId());
            response.getWriter().println(
                    "Status: " + result.getSubmissionStatus());
            response.getWriter().println(
                    "Submitted at: " + result.getSubmittedAt());

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().println("RESULT: FAILED");
            response.getWriter().println(
                    e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }
}
