
package com.electra.dao;

import com.electra.model.PreferenceSubmission;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class PreferenceSubmissionDAO {

    public PreferenceSubmission findByStudentAndForm(
            long studentId, long formId) throws SQLException {

        String sql = "SELECT submission_id, student_id, form_id, " +
                     "submitted_at, submission_status " +
                     "FROM preference_submissions " +
                     "WHERE student_id = ? AND form_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, studentId);
            stmt.setLong(2, formId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapSubmission(rs);
                }
            }
        }

        return null;
    }

    public PreferenceSubmission findById(long submissionId)
            throws SQLException {

        String sql = "SELECT submission_id, student_id, form_id, " +
                     "submitted_at, submission_status " +
                     "FROM preference_submissions " +
                     "WHERE submission_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, submissionId);

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapSubmission(rs);
                }
            }
        }

        return null;
    }

    public PreferenceSubmission createDraft(long studentId, long formId)
            throws SQLException {

        String sql = "INSERT INTO preference_submissions " +
                     "(student_id, form_id, submission_status) " +
                     "VALUES (?, ?, 'DRAFT')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(
                     sql, PreparedStatement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, studentId);
            stmt.setLong(2, formId);

            int rows = stmt.executeUpdate();

            if (rows == 0) {
                throw new SQLException("Creating draft failed.");
            }

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    return findById(keys.getLong(1));
                }
            }
        }

        throw new SQLException("Draft created, but its ID could not be retrieved.");
    }

    public boolean markSubmitted(long submissionId) throws SQLException {

        String sql = "UPDATE preference_submissions " +
                    "SET submission_status = 'SUBMITTED', " +
                    "submitted_at = CURRENT_TIMESTAMP " +
                    "WHERE submission_id = ? " +
                    "AND submission_status = 'DRAFT'";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, submissionId);
            return stmt.executeUpdate() > 0;
        }
    }

    private PreferenceSubmission mapSubmission(ResultSet rs)
            throws SQLException {

        PreferenceSubmission submission = new PreferenceSubmission();

        submission.setSubmissionId(rs.getLong("submission_id"));
        submission.setStudentId(rs.getLong("student_id"));
        submission.setFormId(rs.getLong("form_id"));
        submission.setSubmittedAt(rs.getTimestamp("submitted_at"));
        submission.setSubmissionStatus(rs.getString("submission_status"));

        return submission;
    }
}
