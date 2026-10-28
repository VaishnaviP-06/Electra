package com.electra.dao;

import com.electra.model.StudentProfile;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class StudentProfileDAO {

    public StudentProfile findByStudentRollNumber(String rollNumber)
            throws SQLException {

        String sql =
            "SELECT s.student_id, "
            + "COALESCE(p.full_name, s.student_name) AS full_name, "
            + "COALESCE(p.email, s.email) AS email, "
            + "COALESCE(p.roll_number, s.roll_number) AS roll_number, "
            + "p.department, p.academic_year, "
            + "COALESCE(p.cgpa, s.cgpa) AS cgpa "
            + "FROM students s "
            + "LEFT JOIN student_profile p ON p.student_id = s.student_id "
            + "WHERE s.roll_number = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, rollNumber);

            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }

                StudentProfile profile = new StudentProfile();
                profile.setStudentId(rs.getLong("student_id"));
                profile.setFullName(rs.getString("full_name"));
                profile.setEmail(rs.getString("email"));
                profile.setRollNumber(rs.getString("roll_number"));
                profile.setDepartment(rs.getString("department"));
                profile.setAcademicYear(rs.getString("academic_year"));
                profile.setCgpa(rs.getBigDecimal("cgpa"));
                return profile;
            }
        }
    }

    public void save(StudentProfile profile) throws SQLException {

        String sql =
            "INSERT INTO student_profile "
            + "(student_id, full_name, email, roll_number, department, "
            + "academic_year, cgpa) "
            + "VALUES (?, ?, ?, ?, ?, ?, ?) "
            + "ON DUPLICATE KEY UPDATE "
            + "full_name = VALUES(full_name), "
            + "email = VALUES(email), "
            + "roll_number = VALUES(roll_number), "
            + "department = VALUES(department), "
            + "academic_year = VALUES(academic_year), "
            + "cgpa = VALUES(cgpa)";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, profile.getStudentId());
            statement.setString(2, profile.getFullName());
            statement.setString(3, profile.getEmail());
            statement.setString(4, profile.getRollNumber());
            statement.setString(5, profile.getDepartment());
            statement.setString(6, profile.getAcademicYear());
            statement.setBigDecimal(7, profile.getCgpa());
            statement.executeUpdate();
        }
    }
}
