
package com.electra.controller;

import com.electra.dao.PreferenceDAO;
import com.electra.dao.PreferenceSubmissionDAO;
import com.electra.model.Preference;
import com.electra.model.PreferenceSubmission;
import com.electra.util.DBConnection;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/test-preferences")
public class PreferenceTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws IOException {

        response.setContentType("text/plain;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            PreferenceDAO preferenceDAO = new PreferenceDAO();
            PreferenceSubmissionDAO submissionDAO =
                    new PreferenceSubmissionDAO();

            long studentId = 2;
            long formId = 1;

            try {
                // 1. Create a draft for CE056.
                PreferenceSubmission existing =
                        submissionDAO.findByStudentAndForm(
                                studentId, formId);

                if (existing != null) {
                    out.println("TEST STOPPED: Submission already exists.");
                    out.println("Submission ID: "
                            + existing.getSubmissionId());
                    out.println("Status: "
                            + existing.getSubmissionStatus());
                    out.println("No existing data was modified.");
                    return;
                }

                PreferenceSubmission submission =
                        submissionDAO.createDraft(studentId, formId);

                long submissionId = submission.getSubmissionId();

                out.println("CREATE DRAFT: "
                        + ("DRAFT".equals(
                                submission.getSubmissionStatus())
                        ? "PASSED" : "FAILED"));
                out.println("Submission ID: " + submissionId);

                // 2. Save three ranked preferences.
                List<Preference> initial = new ArrayList<>();
                initial.add(makePreference(1, 1));
                initial.add(makePreference(2, 2));
                initial.add(makePreference(3, 3));

                preferenceDAO.replacePreferences(
                        submissionId, initial);

                List<Preference> saved =
                        preferenceDAO.findBySubmissionId(submissionId);

                out.println("SAVE THREE PREFERENCES: "
                        + (saved.size() == 3
                        && saved.get(0).getElectiveId() == 1
                        && saved.get(0).getPreferenceRank() == 1
                        && saved.get(1).getElectiveId() == 2
                        && saved.get(1).getPreferenceRank() == 2
                        && saved.get(2).getElectiveId() == 3
                        && saved.get(2).getPreferenceRank() == 3
                        ? "PASSED" : "FAILED"));

                // 3. Replace the list with a different valid order.
                List<Preference> replacement = new ArrayList<>();
                replacement.add(makePreference(3, 1));
                replacement.add(makePreference(1, 2));

                preferenceDAO.replacePreferences(
                        submissionId, replacement);

                List<Preference> replaced =
                        preferenceDAO.findBySubmissionId(submissionId);

                out.println("REPLACE PREFERENCES: "
                        + (replaced.size() == 2
                        && replaced.get(0).getElectiveId() == 3
                        && replaced.get(0).getPreferenceRank() == 1
                        && replaced.get(1).getElectiveId() == 1
                        && replaced.get(1).getPreferenceRank() == 2
                        ? "PASSED" : "FAILED"));

                // 4. Reject duplicate ranks before writing.
                boolean duplicateRankRejected = false;

                try {
                    List<Preference> invalid = new ArrayList<>();
                    invalid.add(makePreference(1, 1));
                    invalid.add(makePreference(2, 1));

                    preferenceDAO.replacePreferences(
                            submissionId, invalid);

                } catch (IllegalArgumentException e) {
                    duplicateRankRejected = true;
                }

                out.println("DUPLICATE RANK REJECTED: "
                        + (duplicateRankRejected
                        ? "PASSED" : "FAILED"));

                // 5. Reject duplicate electives before writing.
                boolean duplicateElectiveRejected = false;

                try {
                    List<Preference> invalid = new ArrayList<>();
                    invalid.add(makePreference(1, 1));
                    invalid.add(makePreference(1, 2));

                    preferenceDAO.replacePreferences(
                            submissionId, invalid);

                } catch (IllegalArgumentException e) {
                    duplicateElectiveRejected = true;
                }

                out.println("DUPLICATE ELECTIVE REJECTED: "
                        + (duplicateElectiveRejected
                        ? "PASSED" : "FAILED"));

                // 6. Reject an inactive elective.
                boolean inactiveRejected = false;

                try {
                    List<Preference> invalid = new ArrayList<>();
                    invalid.add(makePreference(1, 1));
                    invalid.add(makePreference(7, 2));

                    preferenceDAO.replacePreferences(
                            submissionId, invalid);

                } catch (SQLException e) {
                    inactiveRejected = true;
                }

                out.println("INACTIVE ELECTIVE REJECTED: "
                        + (inactiveRejected
                        ? "PASSED" : "FAILED"));

                // 7. Find an active elective from a different form.
                long otherFormElectiveId =
                        findActiveElectiveFromAnotherForm(formId);

                boolean otherFormRejected = false;

                if (otherFormElectiveId > 0) {
                    try {
                        List<Preference> invalid = new ArrayList<>();
                        invalid.add(makePreference(
                                otherFormElectiveId, 1));

                        preferenceDAO.replacePreferences(
                                submissionId, invalid);

                    } catch (SQLException e) {
                        otherFormRejected = true;
                    }

                    out.println("OTHER-FORM ELECTIVE REJECTED: "
                            + (otherFormRejected
                            ? "PASSED" : "FAILED"));
                } else {
                    out.println("OTHER-FORM ELECTIVE TEST: SKIPPED "
                            + "(no active elective found in another form)");
                }

                // 8. Verify failed operations preserved the valid list.
                List<Preference> finalList =
                        preferenceDAO.findBySubmissionId(submissionId);

                boolean preserved =
                        finalList.size() == 2
                        && finalList.get(0).getElectiveId() == 3
                        && finalList.get(0).getPreferenceRank() == 1
                        && finalList.get(1).getElectiveId() == 1
                        && finalList.get(1).getPreferenceRank() == 2;

                out.println("VALID LIST PRESERVED: "
                        + (preserved ? "PASSED" : "FAILED"));

                out.println("FINAL SAVED PREFERENCES:");

                for (Preference preference : finalList) {
                    out.println("Rank "
                            + preference.getPreferenceRank()
                            + " -> Elective ID "
                            + preference.getElectiveId());
                }

            } catch (Exception e) {
                out.println("TEST ERROR: " + e.getMessage());
                log("Preference DAO test failed", e);
            }
        }
    }

    private Preference makePreference(long electiveId, int rank) {
        Preference preference = new Preference();
        preference.setElectiveId(electiveId);
        preference.setPreferenceRank(rank);
        return preference;
    }

    private long findActiveElectiveFromAnotherForm(long formId)
            throws SQLException {

        String sql = "SELECT elective_id FROM electives " +
                     "WHERE form_id <> ? AND is_active = TRUE " +
                     "LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, formId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("elective_id");
                }
            }
        }

        return -1;
    }
}
