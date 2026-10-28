
package com.electra.dao;

import com.electra.model.Preference;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class PreferenceDAO {

    /**
     * Retrieves all preferences for a submission,
     * ordered by the student's preference rank.
     */
    public List<Preference> findBySubmissionId(long submissionId)
            throws SQLException {

        String sql =
                "SELECT preference_id, submission_id, form_id, " +
                "elective_id, preference_rank " +
                "FROM student_preferences " +
                "WHERE submission_id = ? " +
                "ORDER BY preference_rank ASC";

        List<Preference> preferences = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, submissionId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    preferences.add(mapPreference(rs));
                }
            }
        }

        return preferences;
    }

    /**
     * Replaces the complete preference list in one transaction.
     * Every elective must be active and belong to the submission's form.
     */
    public void replacePreferences(
            long submissionId,
            List<Preference> preferences) throws SQLException {

        if (submissionId <= 0) {
            throw new IllegalArgumentException(
                    "Submission ID must be positive.");
        }

        if (preferences == null) {
            throw new IllegalArgumentException(
                    "Preference list cannot be null.");
        }

        // Validate ranks and elective IDs before opening the transaction.
        Set<Long> electiveIds = new HashSet<>();
        Set<Integer> ranks = new HashSet<>();

        for (Preference preference : preferences) {

            if (preference == null) {
                throw new IllegalArgumentException(
                        "Preference list cannot contain null entries.");
            }

            if (preference.getElectiveId() <= 0) {
                throw new IllegalArgumentException(
                        "Elective ID must be positive.");
            }

            if (preference.getPreferenceRank() <= 0) {
                throw new IllegalArgumentException(
                        "Preference ranks must be positive.");
            }

            if (!electiveIds.add(preference.getElectiveId())) {
                throw new IllegalArgumentException(
                        "The same elective cannot be selected twice.");
            }

            if (!ranks.add(preference.getPreferenceRank())) {
                throw new IllegalArgumentException(
                        "Preference ranks must be unique.");
            }
        }

        try (Connection conn = DBConnection.getConnection()) {

            boolean originalAutoCommit = conn.getAutoCommit();

            try {
                conn.setAutoCommit(false);

                long formId;
                String submissionStatus;

                // Lock and validate the submission and its form.
                String submissionSql =
                        "SELECT ps.form_id, ps.submission_status " +
                        "FROM preference_submissions ps " +
                        "JOIN allocation_forms af " +
                        "ON af.form_id = ps.form_id " +
                        "WHERE ps.submission_id = ? " +
                        "AND af.form_status = 'OPEN' " +
                        "AND (af.opening_date IS NULL " +
                        "OR af.opening_date <= CURRENT_TIMESTAMP) " +
                        "AND (af.submission_deadline IS NULL " +
                        "OR af.submission_deadline >= CURRENT_TIMESTAMP) " +
                        "FOR UPDATE";

                try (PreparedStatement stmt =
                             conn.prepareStatement(submissionSql)) {

                    stmt.setLong(1, submissionId);

                    try (ResultSet rs = stmt.executeQuery()) {
                        if (!rs.next()) {
                            throw new SQLException(
                                    "Submission not found, or its form " +
                                    "is not currently accepting preferences.");
                        }

                        formId = rs.getLong("form_id");
                        submissionStatus =
                                rs.getString("submission_status");
                    }
                }

                if (!"DRAFT".equals(submissionStatus)
                        && !"SUBMITTED".equals(submissionStatus)) {
                    throw new SQLException(
                            "Invalid submission status.");
                }

                // Validate every elective before deleting existing choices.
                String electiveSql =
                        "SELECT elective_id FROM electives " +
                        "WHERE elective_id = ? " +
                        "AND form_id = ? AND is_active = TRUE " +
                        "FOR UPDATE";

                try (PreparedStatement stmt =
                             conn.prepareStatement(electiveSql)) {

                    for (Preference preference : preferences) {

                        stmt.setLong(
                                1, preference.getElectiveId());
                        stmt.setLong(2, formId);

                        try (ResultSet rs = stmt.executeQuery()) {
                            if (!rs.next()) {
                                throw new SQLException(
                                        "Elective ID " +
                                        preference.getElectiveId() +
                                        " is inactive or does not belong " +
                                        "to this form.");
                            }
                        }
                    }
                }

                // Delete the old list only after all validations pass.
                String deleteSql =
                        "DELETE FROM student_preferences " +
                        "WHERE submission_id = ?";

                try (PreparedStatement stmt =
                             conn.prepareStatement(deleteSql)) {

                    stmt.setLong(1, submissionId);
                    stmt.executeUpdate();
                }

                // Insert the complete replacement list.
                String insertSql =
                        "INSERT INTO student_preferences " +
                        "(submission_id, form_id, elective_id, " +
                        "preference_rank) VALUES (?, ?, ?, ?)";

                try (PreparedStatement stmt =
                             conn.prepareStatement(insertSql)) {

                    for (Preference preference : preferences) {

                        stmt.setLong(1, submissionId);
                        stmt.setLong(2, formId);
                        stmt.setLong(
                                3, preference.getElectiveId());
                        stmt.setInt(
                                4, preference.getPreferenceRank());

                        stmt.addBatch();
                    }

                    if (!preferences.isEmpty()) {
                        stmt.executeBatch();
                    }
                }

                conn.commit();

            } catch (SQLException | RuntimeException e) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
                throw e;

            } finally {
                try {
                    conn.setAutoCommit(originalAutoCommit);
                } catch (SQLException resetError) {
                    // Closing the connection below will release it.
                    // Report reset failures rather than silently ignoring them.
                    throw resetError;
                }
            }
        }
    }

    private Preference mapPreference(ResultSet rs)
            throws SQLException {

        Preference preference = new Preference();

        preference.setPreferenceId(
                rs.getLong("preference_id"));
        preference.setSubmissionId(
                rs.getLong("submission_id"));
        preference.setFormId(
                rs.getLong("form_id"));
        preference.setElectiveId(
                rs.getLong("elective_id"));
        preference.setPreferenceRank(
                rs.getInt("preference_rank"));

        return preference;
    }
}
