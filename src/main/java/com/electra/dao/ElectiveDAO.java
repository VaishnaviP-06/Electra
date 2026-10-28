
package com.electra.dao;

import com.electra.model.Elective;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ElectiveDAO {

    public List<Elective> findActiveByFormId(long formId)
            throws SQLException {

        String sql =
            "SELECT elective_id, form_id, elective_code, elective_name, "
            + "syllabus, faculty_name, total_seats, min_students, "
            + "min_cgpa, is_active, enrolment_status "
            + "FROM electives "
            + "WHERE form_id = ? AND is_active = TRUE "
            + "ORDER BY elective_code";

        List<Elective> electives = new ArrayList<>();

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, formId);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    electives.add(mapRow(rs));
                }
            }
        }

        return electives;
    }

    public Elective findByIdAndFormId(
            long electiveId, long formId) throws SQLException {

        String sql =
            "SELECT elective_id, form_id, elective_code, elective_name, "
            + "syllabus, faculty_name, total_seats, min_students, "
            + "min_cgpa, is_active, enrolment_status "
            + "FROM electives WHERE elective_id = ? AND form_id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, electiveId);
            statement.setLong(2, formId);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }

        return null;
    }

    private Elective mapRow(ResultSet rs) throws SQLException {

        Elective elective = new Elective();

        elective.setElectiveId(rs.getLong("elective_id"));
        elective.setFormId(rs.getLong("form_id"));
        elective.setElectiveCode(rs.getString("elective_code"));
        elective.setElectiveName(rs.getString("elective_name"));
        elective.setSyllabus(rs.getString("syllabus"));
        elective.setFacultyName(rs.getString("faculty_name"));
        elective.setTotalSeats(rs.getInt("total_seats"));
        elective.setMinStudents(rs.getInt("min_students"));

        double minCgpa = rs.getDouble("min_cgpa");
        elective.setMinCgpa(
            rs.wasNull() ? null : minCgpa
        );

        elective.setActive(rs.getBoolean("is_active"));
        elective.setEnrolmentStatus(rs.getString("enrolment_status"));

        return elective;
    }
}
