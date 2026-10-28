package com.electra.dao;

import com.electra.model.AllocationCandidate;
import com.electra.model.AllocationResult;
import com.electra.model.ElectiveReviewDetail;
import com.electra.model.StudentAllocationView;
import com.electra.model.Preference;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AllocationDAO {

    public List<AllocationCandidate> findSubmittedCandidates(
            long formId) throws SQLException {

        String sql =
                "SELECT ps.submission_id, s.student_id, s.roll_number, " +
                "s.cgpa, ps.submitted_at, sp.elective_id, " +
                "sp.preference_rank " +
                "FROM preference_submissions ps " +
                "JOIN students s ON s.student_id = ps.student_id " +
                "LEFT JOIN student_preferences sp " +
                "ON sp.submission_id = ps.submission_id " +
                "AND sp.form_id = ps.form_id " +
                "WHERE ps.form_id = ? " +
                "AND ps.submission_status = 'SUBMITTED' " +
                "ORDER BY s.cgpa DESC, ps.submitted_at ASC, " +
                "s.roll_number ASC, sp.preference_rank ASC";

        Map<Long, AllocationCandidate> candidates =
                new LinkedHashMap<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, formId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    long studentId = rs.getLong("student_id");

                    AllocationCandidate candidate =
                            candidates.get(studentId);

                    if (candidate == null) {
                        candidate = new AllocationCandidate();
                        candidate.setStudentId(studentId);
                        candidate.setRollNumber(
                                rs.getString("roll_number"));
                        candidate.setCgpa(rs.getDouble("cgpa"));
                        candidate.setSubmittedAt(
                                rs.getTimestamp("submitted_at"));

                        candidates.put(studentId, candidate);
                    }

                    long electiveId = rs.getLong("elective_id");

                    if (!rs.wasNull()) {
                        Preference preference = new Preference();
                        preference.setSubmissionId(
                                rs.getLong("submission_id"));
                        preference.setFormId(formId);
                        preference.setElectiveId(electiveId);
                        preference.setPreferenceRank(
                                rs.getInt("preference_rank"));

                        candidate.getPreferences().add(preference);
                    }
                }
            }
        }

        return new ArrayList<>(candidates.values());
    }

    public long saveAllocationRun(
            long formId,
            String runType,
            List<AllocationResult> results) throws SQLException {

        if (!"INITIAL".equals(runType)
                && !"RERUN".equals(runType)) {
            throw new IllegalArgumentException(
                    "Run type must be INITIAL or RERUN.");
        }

        String createRunSql =
                "INSERT INTO allocation_runs " +
                "(form_id, run_status, run_type) " +
                "VALUES (?, 'RUNNING', ?)";

        String insertAllocationSql =
                "INSERT INTO allocations " +
                "(allocation_run_id, form_id, student_id, elective_id, " +
                "allocation_status, allocation_reason) " +
                "VALUES (?, ?, ?, ?, ?, ?)";

        String updateRunSql =
                "UPDATE allocation_runs " +
                "SET run_status = 'COMPLETED' " +
                "WHERE allocation_run_id = ?";

        String updateFormSql =
                "UPDATE allocation_forms " +
                "SET allocation_status = 'COMPLETED', " +
                "review_status = 'PENDING' " +
                "WHERE form_id = ?";

        String resetElectivesSql =
                "UPDATE electives SET enrolment_status = 'PENDING' " +
                "WHERE form_id = ? AND is_active = 1";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            long runId;

            try (PreparedStatement stmt = conn.prepareStatement(
                    createRunSql, Statement.RETURN_GENERATED_KEYS)) {

                stmt.setLong(1, formId);
                stmt.setString(2, runType);
                stmt.executeUpdate();

                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new SQLException(
                                "Could not create allocation run.");
                    }

                    runId = keys.getLong(1);
                }
            }

            try (PreparedStatement stmt =
                    conn.prepareStatement(insertAllocationSql)) {

                for (AllocationResult result : results) {
                    stmt.setLong(1, runId);
                    stmt.setLong(2, formId);
                    stmt.setLong(3, result.getStudentId());

                    if (result.getElectiveId() == null) {
                        stmt.setNull(4, Types.BIGINT);
                    } else {
                        stmt.setLong(4, result.getElectiveId());
                    }

                    stmt.setString(
                            5, result.getAllocationStatus());
                    stmt.setString(
                            6, result.getAllocationReason());

                    stmt.addBatch();
                }

                stmt.executeBatch();
            }

            try (PreparedStatement stmt =
                    conn.prepareStatement(resetElectivesSql)) {
                stmt.setLong(1, formId);
                stmt.executeUpdate();
            }

            try (PreparedStatement stmt =
                    conn.prepareStatement(updateFormSql)) {
                stmt.setLong(1, formId);

                if (stmt.executeUpdate() != 1) {
                    throw new SQLException(
                            "Allocation form could not be updated.");
                }
            }

            try (PreparedStatement stmt =
                    conn.prepareStatement(updateRunSql)) {
                stmt.setLong(1, runId);

                if (stmt.executeUpdate() != 1) {
                    throw new SQLException(
                            "Allocation run could not be completed.");
                }
            }

            conn.commit();
            return runId;

        } catch (SQLException | RuntimeException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
            }

            throw e;

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                    // Do not hide the original database error.
                }
            }
        }
    }

    public void prepareMinimumEnrolmentReview(long formId)
            throws SQLException {

        String lockFormSql =
                "SELECT allocation_status, review_status, results_published " +
                "FROM allocation_forms WHERE form_id = ? FOR UPDATE";

        String latestRunSql =
                "SELECT allocation_run_id FROM allocation_runs " +
                "WHERE form_id = ? AND run_status = 'COMPLETED' " +
                "ORDER BY allocation_run_id DESC LIMIT 1";

        String reviewCountSql =
                "SELECT COUNT(*) FROM elective_form_reviews WHERE form_id = ?";

        String electivesSql =
                "SELECT e.elective_id, e.min_students, " +
                "COUNT(a.allocation_id) AS enrolled " +
                "FROM electives e " +
                "LEFT JOIN allocations a " +
                "ON a.form_id = e.form_id " +
                "AND a.elective_id = e.elective_id " +
                "AND a.allocation_run_id = ? " +
                "AND a.allocation_status = 'PROVISIONAL' " +
                "WHERE e.form_id = ? AND e.is_active = 1 " +
                "GROUP BY e.elective_id, e.min_students " +
                "ORDER BY e.elective_id";

        String updateElectiveSql =
                "UPDATE electives SET enrolment_status = ? " +
                "WHERE form_id = ? AND elective_id = ?";

        String insertReviewSql =
                "INSERT INTO elective_form_reviews " +
                "(form_id, elective_id, review_status, review_notes) " +
                "VALUES (?, ?, 'PENDING', ?)";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement stmt =
                        conn.prepareStatement(lockFormSql)) {
                stmt.setLong(1, formId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalArgumentException(
                                "Allocation form does not exist.");
                    }

                    if (!"COMPLETED".equals(
                            rs.getString("allocation_status"))) {
                        throw new IllegalStateException(
                                "Initial allocation must be completed first.");
                    }

                    if (!"PENDING".equals(
                            rs.getString("review_status"))) {
                        throw new IllegalStateException(
                                "The form is not awaiting minimum-enrolment review.");
                    }

                    if (rs.getBoolean("results_published")) {
                        throw new IllegalStateException(
                                "Published results cannot be reviewed again.");
                    }
                }
            }

            try (PreparedStatement stmt =
                        conn.prepareStatement(reviewCountSql)) {
                stmt.setLong(1, formId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next() && rs.getLong(1) > 0) {
                        throw new IllegalStateException(
                                "Minimum-enrolment review records already exist.");
                    }
                }
            }

            long runId;

            try (PreparedStatement stmt =
                        conn.prepareStatement(latestRunSql)) {
                stmt.setLong(1, formId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException(
                                "No completed allocation run was found.");
                    }
                    runId = rs.getLong("allocation_run_id");
                }
            }

            int electiveCount = 0;

            try (PreparedStatement query =
                        conn.prepareStatement(electivesSql);
                PreparedStatement update =
                        conn.prepareStatement(updateElectiveSql);
                PreparedStatement insert =
                        conn.prepareStatement(insertReviewSql)) {

                query.setLong(1, runId);
                query.setLong(2, formId);

                try (ResultSet rs = query.executeQuery()) {
                    while (rs.next()) {
                        electiveCount++;

                        long electiveId = rs.getLong("elective_id");
                        int minimum = rs.getInt("min_students");
                        long enrolled = rs.getLong("enrolled");

                        boolean belowMinimum = enrolled < minimum;

                        update.setString(
                                1, belowMinimum
                                        ? "BELOW_MINIMUM_ENROLMENT"
                                        : "OK");
                        update.setLong(2, formId);
                        update.setLong(3, electiveId);
                        update.executeUpdate();

                        String notes =
                                "System check: enrolled " + enrolled
                                + "; minimum required " + minimum + ".";

                        insert.setLong(1, formId);
                        insert.setLong(2, electiveId);
                        insert.setString(3, notes);
                        insert.executeUpdate();
                    }
                }
            }

            if (electiveCount == 0) {
                throw new IllegalStateException(
                        "No active electives were found for review.");
            }

            conn.commit();

        } catch (SQLException | RuntimeException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
            }
            throw e;

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                    // Preserve the original error.
                }
            }
        }
    }

    public void recordElectiveReview(
            long formId,
            long electiveId,
            long reviewerId,
            String notes) throws SQLException {

        String lockFormSql =
                "SELECT allocation_status, review_status, results_published " +
                "FROM allocation_forms WHERE form_id = ? FOR UPDATE";

        String adminSql =
                "SELECT COUNT(*) FROM users " +
                "WHERE user_id = ? AND UPPER(role) = 'ADMIN' AND is_active = 1";

        String reviewSql =
                "SELECT r.review_status, e.enrolment_status " +
                "FROM elective_form_reviews r " +
                "JOIN electives e ON e.form_id = r.form_id " +
                "AND e.elective_id = r.elective_id " +
                "WHERE r.form_id = ? AND r.elective_id = ? " +
                "FOR UPDATE";

        String updateReviewSql =
                "UPDATE elective_form_reviews " +
                "SET review_status = ?, " +
                "review_notes = CASE " +
                "WHEN ? IS NULL OR TRIM(?) = '' THEN review_notes " +
                "ELSE CONCAT(LEFT(COALESCE(review_notes, ''), 250), " +
                "' Admin: ', LEFT(?, 230)) END, " +
                "reviewed_by = ?, reviewed_at = CURRENT_TIMESTAMP " +
                "WHERE form_id = ? AND elective_id = ? " +
                "AND review_status = 'PENDING'";

        String updateFormSql =
                "UPDATE allocation_forms SET review_status = ? " +
                "WHERE form_id = ?";

        if (formId <= 0 || electiveId <= 0 || reviewerId <= 0) {
            throw new IllegalArgumentException(
                    "Form, elective, and reviewer IDs must be positive.");
        }

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement stmt =
                        conn.prepareStatement(lockFormSql)) {
                stmt.setLong(1, formId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalArgumentException(
                                "Allocation form does not exist.");
                    }

                    if (!"COMPLETED".equals(
                            rs.getString("allocation_status"))
                            || !"PENDING".equals(
                            rs.getString("review_status"))
                            || rs.getBoolean("results_published")) {
                        throw new IllegalStateException(
                                "The form is not ready for elective review.");
                    }
                }
            }

            try (PreparedStatement stmt =
                        conn.prepareStatement(adminSql)) {
                stmt.setLong(1, reviewerId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next() || rs.getLong(1) != 1) {
                        throw new IllegalArgumentException(
                                "An active admin account is required to review.");
                    }
                }
            }

            String electiveStatus;
            String reviewStatus;

            try (PreparedStatement stmt =
                        conn.prepareStatement(reviewSql)) {
                stmt.setLong(1, formId);
                stmt.setLong(2, electiveId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalArgumentException(
                                "No review record exists for this elective.");
                    }

                    if (!"PENDING".equals(
                            rs.getString("review_status"))) {
                        throw new IllegalStateException(
                                "This elective has already been reviewed.");
                    }

                    electiveStatus = rs.getString("enrolment_status");
                }
            }

            if ("BELOW_MINIMUM_ENROLMENT".equals(electiveStatus)
                    && (notes == null || notes.isBlank())) {
                throw new IllegalArgumentException(
                        "Add a review note for an under-enrolled elective.");
            }

            if (!"OK".equals(electiveStatus)
                    && !"BELOW_MINIMUM_ENROLMENT".equals(electiveStatus)) {
                throw new IllegalStateException(
                        "Elective enrolment status has not been calculated.");
            }

            reviewStatus = "BELOW_MINIMUM_ENROLMENT".equals(electiveStatus)
                    ? "BELOW_MINIMUM_ENROLMENT"
                    : "REVIEWED";

            try (PreparedStatement stmt =
                        conn.prepareStatement(updateReviewSql)) {
                stmt.setString(1, reviewStatus);
                stmt.setString(2, notes);
                stmt.setString(3, notes);
                stmt.setString(4, notes);
                stmt.setLong(5, reviewerId);
                stmt.setLong(6, formId);
                stmt.setLong(7, electiveId);

                if (stmt.executeUpdate() != 1) {
                    throw new SQLException(
                            "Could not save the elective review.");
                }
            }

            String pendingSql =
                    "SELECT COUNT(*) FROM elective_form_reviews " +
                    "WHERE form_id = ? AND review_status = 'PENDING'";

            long pendingCount;

            try (PreparedStatement stmt =
                        conn.prepareStatement(pendingSql)) {
                stmt.setLong(1, formId);

                try (ResultSet rs = stmt.executeQuery()) {
                    rs.next();
                    pendingCount = rs.getLong(1);
                }
            }

            try (PreparedStatement stmt =
                        conn.prepareStatement(updateFormSql)) {
                stmt.setString(
                        1, pendingCount == 0 ? "REVIEWED" : "PENDING");
                stmt.setLong(2, formId);
                stmt.executeUpdate();
            }

            conn.commit();

        } catch (SQLException | RuntimeException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
            }
            throw e;

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                    // Preserve the original error.
                }
            }
        }
    }

    public void finalizeReviewedAllocation(long formId)
            throws SQLException {

        String lockFormSql =
                "SELECT allocation_status, review_status, results_published " +
                "FROM allocation_forms WHERE form_id = ? FOR UPDATE";

        String latestRunSql =
                "SELECT allocation_run_id FROM allocation_runs " +
                "WHERE form_id = ? AND run_status = 'COMPLETED' " +
                "ORDER BY allocation_run_id DESC LIMIT 1";

        String pendingSql =
                "SELECT COUNT(*) FROM elective_form_reviews " +
                "WHERE form_id = ? " +
                "AND (review_status = 'PENDING' OR reviewed_at IS NULL)";

        String finalizeSql =
                "UPDATE allocations a " +
                "JOIN electives e ON e.form_id = a.form_id " +
                "AND e.elective_id = a.elective_id " +
                "SET a.allocation_status = CASE " +
                "WHEN e.enrolment_status = 'BELOW_MINIMUM_ENROLMENT' " +
                "THEN 'NOT_ALLOTTED' ELSE 'ALLOCATED' END, " +
                "a.allocation_reason = CASE " +
                "WHEN e.enrolment_status = 'BELOW_MINIMUM_ENROLMENT' " +
                "THEN 'Elective did not meet minimum enrolment after review' " +
                "ELSE a.allocation_reason END " +
                "WHERE a.form_id = ? AND a.allocation_run_id = ? " +
                "AND a.allocation_status = 'PROVISIONAL' " +
                "AND a.elective_id IS NOT NULL";

        Connection conn = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            try (PreparedStatement stmt =
                        conn.prepareStatement(lockFormSql)) {
                stmt.setLong(1, formId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalArgumentException(
                                "Allocation form does not exist.");
                    }

                    if (!"COMPLETED".equals(
                            rs.getString("allocation_status"))
                            || !"REVIEWED".equals(
                            rs.getString("review_status"))
                            || rs.getBoolean("results_published")) {
                        throw new IllegalStateException(
                                "All elective reviews must be completed before finalization.");
                    }
                }
            }

            try (PreparedStatement stmt =
                        conn.prepareStatement(pendingSql)) {
                stmt.setLong(1, formId);

                try (ResultSet rs = stmt.executeQuery()) {
                    rs.next();

                    if (rs.getLong(1) != 0) {
                        throw new IllegalStateException(
                                "Some elective reviews are still pending.");
                    }
                }
            }

            long runId;

            try (PreparedStatement stmt =
                        conn.prepareStatement(latestRunSql)) {
                stmt.setLong(1, formId);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (!rs.next()) {
                        throw new IllegalStateException(
                                "No completed allocation run was found.");
                    }
                    runId = rs.getLong("allocation_run_id");
                }
            }

            try (PreparedStatement stmt =
                        conn.prepareStatement(finalizeSql)) {
                stmt.setLong(1, formId);
                stmt.setLong(2, runId);
                stmt.executeUpdate();
            }

            conn.commit();

        } catch (SQLException | RuntimeException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
            }
            throw e;

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException ignored) {
                    // Preserve the original error.
                }
            }
        }
    }


    public boolean hasPreparedReviews(long formId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM elective_form_reviews WHERE form_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, formId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getLong(1) > 0;
            }
        }
    }

    public List<ElectiveReviewDetail> findElectiveReviewDetails(long formId) throws SQLException {
        String sql =
            "SELECT " +
            "    e.elective_id, " +
            "    e.form_id, " +
            "    e.elective_code, " +
            "    e.elective_name, " +
            "    e.total_seats, " +
            "    e.min_students, " +
            "    e.min_cgpa, " +
            "    e.is_active, " +
            "    e.enrolment_status, " +
            "    COALESCE(r.review_status, 'NOT_PREPARED') AS review_status, " +
            "    r.review_notes, " +
            "    r.reviewed_by, " +
            "    u.username AS reviewer_username, " +
            "    r.reviewed_at, " +
            "    (SELECT COUNT(*) FROM allocations a " +
            "     WHERE a.form_id = e.form_id " +
            "       AND a.elective_id = e.elective_id " +
            "       AND a.allocation_run_id = ( " +
            "           SELECT MAX(ar2.allocation_run_id) FROM allocation_runs ar2 " +
            "           WHERE ar2.form_id = e.form_id AND ar2.run_status = 'COMPLETED' " +
            "       ) " +
            "    ) AS provisional_enrolment " +
            "FROM electives e " +
            "LEFT JOIN elective_form_reviews r ON r.form_id = e.form_id AND r.elective_id = e.elective_id " +
            "LEFT JOIN users u ON u.user_id = r.reviewed_by " +
            "WHERE e.form_id = ? AND e.is_active = 1 " +
            "ORDER BY e.elective_code";

        List<ElectiveReviewDetail> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, formId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ElectiveReviewDetail detail = new ElectiveReviewDetail();
                    detail.setElectiveId(rs.getLong("elective_id"));
                    detail.setFormId(rs.getLong("form_id"));
                    detail.setElectiveCode(rs.getString("elective_code"));
                    detail.setElectiveName(rs.getString("elective_name"));
                    detail.setTotalSeats(rs.getInt("total_seats"));
                    detail.setMinStudents(rs.getInt("min_students"));

                    double minCgpa = rs.getDouble("min_cgpa");
                    detail.setMinCgpa(rs.wasNull() ? null : minCgpa);

                    detail.setActive(rs.getBoolean("is_active"));
                    detail.setEnrolmentStatus(rs.getString("enrolment_status"));
                    detail.setReviewStatus(rs.getString("review_status"));
                    detail.setReviewNotes(rs.getString("review_notes"));

                    long reviewerId = rs.getLong("reviewed_by");
                    detail.setReviewedBy(rs.wasNull() ? null : reviewerId);

                    detail.setReviewerUsername(rs.getString("reviewer_username"));
                    detail.setReviewedAt(rs.getTimestamp("reviewed_at"));
                    detail.setProvisionalEnrolment(rs.getLong("provisional_enrolment"));

                    list.add(detail);
                }
            }
        }
        return list;
    }

    public List<StudentAllocationView> findStudentAllocations(long studentId) throws SQLException {
        String sql =
            "SELECT f.form_id, f.form_name, f.results_published, " +
            "       ps.submission_status, ps.submitted_at, " +
            "       a.allocation_status, a.allocation_reason, " +
            "       e.elective_code, e.elective_name, e.faculty_name " +
            "FROM allocation_forms f " +
            "LEFT JOIN preference_submissions ps ON ps.form_id = f.form_id AND ps.student_id = ? " +
            "LEFT JOIN allocations a ON a.form_id = f.form_id AND a.student_id = ? " +
            "          AND a.allocation_run_id = (SELECT MAX(ar.allocation_run_id) FROM allocation_runs ar WHERE ar.form_id = f.form_id AND ar.run_status = 'COMPLETED') " +
            "LEFT JOIN electives e ON e.elective_id = a.elective_id AND e.form_id = a.form_id " +
            "WHERE ps.submission_status IS NOT NULL OR a.allocation_id IS NOT NULL OR f.form_status = 'OPEN' " +
            "ORDER BY f.form_id";

        List<StudentAllocationView> views = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, studentId);
            stmt.setLong(2, studentId);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    StudentAllocationView view = new StudentAllocationView();
                    view.setFormId(rs.getLong("form_id"));
                    view.setFormName(rs.getString("form_name"));
                    view.setResultsPublished(rs.getBoolean("results_published"));
                    view.setSubmissionStatus(rs.getString("submission_status"));
                    view.setSubmittedAt(rs.getTimestamp("submitted_at"));
                    view.setAllocationStatus(rs.getString("allocation_status"));
                    view.setAllocationReason(rs.getString("allocation_reason"));
                    view.setElectiveCode(rs.getString("elective_code"));
                    view.setElectiveName(rs.getString("elective_name"));
                    view.setFacultyName(rs.getString("faculty_name"));
                    views.add(view);
                }
            }
        }
        return views;
    }
}