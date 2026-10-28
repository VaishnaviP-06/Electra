
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


    public boolean create(Elective elective) throws Exception {
        validate(elective);

        String sql = 
            "INSERT INTO electives"
            +"(form_id, elective_code, elective_name, syllabus,"
            +"faculty_name, total_seats, min_students, min_cgpa,"
            +"is_active)"
            +"VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (java.sql.Connection con =
                    com.electra.util.DBConnection.getConnection();
            java.sql.PreparedStatement ps =
                    con.prepareStatement(sql)) {

            ps.setLong(1, elective.getFormId());
            ps.setString(2, elective.getElectiveCode());
            ps.setString(3, elective.getElectiveName());
            ps.setString(4, elective.getSyllabus());
            ps.setString(5, elective.getFacultyName());
            ps.setInt(6, elective.getTotalSeats());
            ps.setInt(7, elective.getMinStudents());

            if (elective.getMinCgpa() == null) {
                ps.setNull(8, java.sql.Types.DOUBLE);
            } else {
                ps.setDouble(8, elective.getMinCgpa());
            }

            ps.setBoolean(9, elective.isActive());

            return ps.executeUpdate() == 1;
        }
    }

    public boolean update(Elective elective) throws Exception {
        validate(elective);

        String sql = "UPDATE electives SET elective_code = ?,elective_name = ?,"
                +"syllabus = ?, faculty_name = ?, total_seats = ?, min_students = ?,"
                +"min_cgpa = ? WHERE elective_id = ? AND form_id = ?";

        try (java.sql.Connection con =
                    com.electra.util.DBConnection.getConnection();
            java.sql.PreparedStatement ps =
                    con.prepareStatement(sql)) {

            ps.setString(1, elective.getElectiveCode());
            ps.setString(2, elective.getElectiveName());
            ps.setString(3, elective.getSyllabus());
            ps.setString(4, elective.getFacultyName());
            ps.setInt(5, elective.getTotalSeats());
            ps.setInt(6, elective.getMinStudents());

            if (elective.getMinCgpa() == null) {
                ps.setNull(7, java.sql.Types.DOUBLE);
            } else {
                ps.setDouble(7, elective.getMinCgpa());
            }

            ps.setLong(8, elective.getElectiveId());
            ps.setLong(9, elective.getFormId());

            return ps.executeUpdate() == 1;
        }
    }

    
    public boolean deactivate(long electiveId, long formId) throws SQLException {
        String sql = "UPDATE electives SET is_active = FALSE " +
                    "WHERE elective_id = ? AND form_id = ?";

        try (Connection conn = DBConnection.getConnection();
            PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, electiveId);
            stmt.setLong(2, formId);

            return stmt.executeUpdate() > 0;
        }
    }


    private void validate(Elective elective) {
        if (elective == null) {
            throw new IllegalArgumentException(
                "Elective cannot be null."
            );
        }

        if (elective.getFormId() <= 0) {
            throw new IllegalArgumentException(
                "A valid form ID is required."
            );
        }

        if (elective.getElectiveCode() == null
                || elective.getElectiveCode().isBlank()) {
            throw new IllegalArgumentException(
                "Elective code is required."
            );
        }

        if (elective.getElectiveName() == null
                || elective.getElectiveName().isBlank()) {
            throw new IllegalArgumentException(
                "Elective name is required."
            );
        }

        if (elective.getTotalSeats() <= 0) {
            throw new IllegalArgumentException(
                "Total seats must be greater than zero."
            );
        }

        if (elective.getMinStudents() < 0
                || elective.getMinStudents() > elective.getTotalSeats()) {
            throw new IllegalArgumentException(
                "Minimum students must be between zero and total seats."
            );
        }

        Double minCgpa = elective.getMinCgpa();

        if (minCgpa != null
                && (!Double.isFinite(minCgpa)
                    || minCgpa < 0 || minCgpa > 10)) {
            throw new IllegalArgumentException(
                "Minimum CGPA must be between 0 and 10."
            );
        }
    }
}