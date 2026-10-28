
package com.electra.dao;

import com.electra.model.AllocationForm;
import com.electra.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AllocationFormDAO {

    public List<AllocationForm> findAll() throws SQLException {

        String sql =
            "SELECT form_id, form_name, category_name, batch_or_cycle, "
            + "opening_date, submission_deadline, form_status, "
            + "allocation_status, review_status, results_published "
            + "FROM allocation_forms ORDER BY form_id";

        List<AllocationForm> forms = new ArrayList<>();

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql);
            ResultSet rs = statement.executeQuery()
        ) {
            while (rs.next()) {
                AllocationForm form = new AllocationForm();

                form.setFormId(rs.getLong("form_id"));
                form.setFormName(rs.getString("form_name"));
                form.setCategoryName(rs.getString("category_name"));
                form.setBatchOrCycle(rs.getString("batch_or_cycle"));
                form.setOpeningDate(rs.getTimestamp("opening_date"));
                form.setSubmissionDeadline(
                    rs.getTimestamp("submission_deadline")
                );
                form.setFormStatus(rs.getString("form_status"));
                form.setAllocationStatus(
                    rs.getString("allocation_status")
                );
                form.setReviewStatus(rs.getString("review_status"));
                form.setResultsPublished(
                    rs.getBoolean("results_published")
                );

                forms.add(form);
            }
        }

        return forms;
    }

    public AllocationForm findById(long formId) throws SQLException {

        String sql =
            "SELECT form_id, form_name, category_name, batch_or_cycle, "
            + "opening_date, submission_deadline, form_status, "
            + "allocation_status, review_status, results_published "
            + "FROM allocation_forms WHERE form_id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, formId);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    AllocationForm form = new AllocationForm();

                    form.setFormId(rs.getLong("form_id"));
                    form.setFormName(rs.getString("form_name"));
                    form.setCategoryName(rs.getString("category_name"));
                    form.setBatchOrCycle(rs.getString("batch_or_cycle"));
                    form.setOpeningDate(rs.getTimestamp("opening_date"));
                    form.setSubmissionDeadline(
                        rs.getTimestamp("submission_deadline")
                    );
                    form.setFormStatus(rs.getString("form_status"));
                    form.setAllocationStatus(
                        rs.getString("allocation_status")
                    );
                    form.setReviewStatus(rs.getString("review_status"));
                    form.setResultsPublished(
                        rs.getBoolean("results_published")
                    );

                    return form;
                }
            }
        }

        return null;
    }
        
    public boolean create(AllocationForm form) throws SQLException {
        validateForm(form);

        String sql = "INSERT INTO allocation_forms " +
                "(form_name, category_name, batch_or_cycle, opening_date, " +
                "submission_deadline, form_status, allocation_status, " +
                "review_status, results_published) " +
                "VALUES (?, ?, ?, ?, ?, 'DRAFT', 'NOT_STARTED', 'NOT_STARTED', FALSE)";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(
                    sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, form.getFormName().trim());
            stmt.setString(2, form.getCategoryName().trim());
            stmt.setString(3, form.getBatchOrCycle().trim());

            if (form.getOpeningDate() != null) {
                stmt.setTimestamp(4, form.getOpeningDate());
            } else {
                stmt.setNull(4, Types.TIMESTAMP);
            }

            if (form.getSubmissionDeadline() != null) {
                stmt.setTimestamp(5, form.getSubmissionDeadline());
            } else {
                stmt.setNull(5, Types.TIMESTAMP);
            }

            if (stmt.executeUpdate() == 0) {
                return false;
            }

            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) {
                    form.setFormId(keys.getLong(1));
                    return true;
                }
            }
        }

        return false;
    }

    public boolean update(AllocationForm form) throws SQLException {
        validateForm(form);

        if (form.getFormId() <= 0) {
            throw new IllegalArgumentException("A valid form ID is required.");
        }

        String sql = "UPDATE allocation_forms SET " +
                "form_name = ?, category_name = ?, batch_or_cycle = ?, " +
                "opening_date = ?, submission_deadline = ? " +
                "WHERE form_id = ?";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, form.getFormName().trim());
            stmt.setString(2, form.getCategoryName().trim());
            stmt.setString(3, form.getBatchOrCycle().trim());

            if (form.getOpeningDate() != null) {
                stmt.setTimestamp(4, form.getOpeningDate());
            } else {
                stmt.setNull(4, Types.TIMESTAMP);
            }

            if (form.getSubmissionDeadline() != null) {
                stmt.setTimestamp(5, form.getSubmissionDeadline());
            } else {
                stmt.setNull(5, Types.TIMESTAMP);
            }

            stmt.setLong(6, form.getFormId());

            return stmt.executeUpdate() > 0;
        }
    }

    public boolean openForm(long formId) throws SQLException {
        if (formId <= 0) {
            throw new IllegalArgumentException("A valid form ID is required.");
        }

        String sql = "UPDATE allocation_forms " +
                "SET form_status = 'OPEN' " +
                "WHERE form_id = ? " +
                "AND form_status IN ('DRAFT', 'CLOSED') " +
                "AND (submission_deadline IS NULL OR submission_deadline >= NOW()) " +
                "AND allocation_status = 'NOT_STARTED' " +
                "AND results_published = FALSE";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, formId);
            return stmt.executeUpdate() > 0;
        }
    }

    
public boolean closeForm(long formId) throws SQLException {
    try (Connection conn = DBConnection.getConnection()) {

        String checkSql =
                "SELECT form_status FROM allocation_forms WHERE form_id = ?";

        try (PreparedStatement check = conn.prepareStatement(checkSql)) {
            check.setLong(1, formId);

            try (ResultSet rs = check.executeQuery()) {
                if (rs.next()) {
                    System.out.println(
                            "Before close: formId=" + formId
                            + ", status=" + rs.getString("form_status")
                    );
                } else {
                    System.out.println("Before close: form not found: " + formId);
                }
            }
        }

        String sql =
                "UPDATE allocation_forms SET form_status = 'CLOSED' " +
                "WHERE form_id = ? AND form_status = 'OPEN'";

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, formId);

            int rowsAffected = stmt.executeUpdate();

            System.out.println(
                    "closeForm(): formId=" + formId
                    + ", rowsAffected=" + rowsAffected
            );

            return rowsAffected > 0;
        }
    }
}


    private void validateForm(AllocationForm form) {
        if (form == null) {
            throw new IllegalArgumentException("Form cannot be null.");
        }

        if (form.getFormName() == null || form.getFormName().isBlank()) {
            throw new IllegalArgumentException("Form name is required.");
        }

        if (form.getCategoryName() == null ||
                form.getCategoryName().isBlank()) {
            throw new IllegalArgumentException("Category name is required.");
        }

        if (form.getBatchOrCycle() == null ||
                form.getBatchOrCycle().isBlank()) {
            throw new IllegalArgumentException("Batch or cycle is required.");
        }

        Timestamp opening = form.getOpeningDate();
        Timestamp deadline = form.getSubmissionDeadline();

        if (opening != null && deadline != null &&
                deadline.before(opening)) {
            throw new IllegalArgumentException(
                "Submission deadline cannot be before the opening date."
            );
        }
    }


}