
package com.electra.dao;

import com.electra.model.AllocationForm;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
}
