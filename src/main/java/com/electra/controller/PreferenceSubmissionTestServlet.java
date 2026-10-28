
package com.electra.controller;

import com.electra.dao.PreferenceSubmissionDAO;
import com.electra.model.PreferenceSubmission;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

@WebServlet("/test-preference-submission")
public class PreferenceSubmissionTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        response.setContentType("text/plain;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            PreferenceSubmissionDAO dao = new PreferenceSubmissionDAO();

            long studentId = 1;
            long formId = 1;

            try {
                // 1. Check whether a submission already exists.
                PreferenceSubmission existing =
                        dao.findByStudentAndForm(studentId, formId);

                if (existing != null) {
                    out.println("TEST STOPPED: A submission already exists.");
                    out.println("Submission ID: " + existing.getSubmissionId());
                    out.println("Status: " + existing.getSubmissionStatus());
                    out.println("No existing data was modified.");
                    return;
                }

                // 2. Create a draft.
                PreferenceSubmission draft =
                        dao.createDraft(studentId, formId);

                out.println("CREATE DRAFT: "
                        + ("DRAFT".equals(draft.getSubmissionStatus())
                        ? "PASSED" : "FAILED"));
                out.println("Submission ID: " + draft.getSubmissionId());

                // 3. Read it back.
                PreferenceSubmission fetched =
                        dao.findByStudentAndForm(studentId, formId);

                out.println("READ SUBMISSION: "
                        + (fetched != null
                        && fetched.getSubmissionId() == draft.getSubmissionId()
                        ? "PASSED" : "FAILED"));

                // 4. Mark it submitted.
                boolean submitted =
                        dao.markSubmitted(draft.getSubmissionId());

                PreferenceSubmission updated =
                        dao.findById(draft.getSubmissionId());

                out.println("MARK SUBMITTED: "
                        + (submitted
                        && updated != null
                        && "SUBMITTED".equals(updated.getSubmissionStatus())
                        ? "PASSED" : "FAILED"));

                // 5. Attempt to create a duplicate.
                boolean duplicateRejected = false;

                try {
                    dao.createDraft(studentId, formId);
                } catch (SQLException e) {
                    duplicateRejected = true;
                }

                out.println("DUPLICATE PREVENTION: "
                        + (duplicateRejected ? "PASSED" : "FAILED"));

                out.println("FINAL STATUS: "
                        + (updated == null
                        ? "NOT FOUND" : updated.getSubmissionStatus()));

            } catch (SQLException e) {
                out.println("DATABASE TEST FAILED");
                out.println("Error: " + e.getMessage());
                log("Preference submission DAO test failed", e);
            }
        }
    }
}
