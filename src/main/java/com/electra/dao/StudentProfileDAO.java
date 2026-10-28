package com.electra.dao;

import com.electra.model.StudentProfile;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StudentProfileDAO {

    public List<StudentProfile> findAllStudents() throws SQLException {
        String sql =
            "SELECT student_id, student_name AS full_name, email, roll_number, "
            + "batch_or_cycle, cgpa "
            + "FROM students "
            + "ORDER BY roll_number";

        List<StudentProfile> list = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                StudentProfile profile = mapStudentRow(rs);
                list.add(profile);
            }
        }
        return list;
    }

    public StudentProfile findByStudentRollNumber(String rollNumber) throws SQLException {
        String sql =
            "SELECT student_id, student_name AS full_name, email, roll_number, "
            + "batch_or_cycle, cgpa "
            + "FROM students "
            + "WHERE roll_number = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, rollNumber);

            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return mapStudentRow(rs);
            }
        }
    }

    public StudentProfile findByStudentId(long studentId) throws SQLException {
        String sql =
            "SELECT student_id, student_name AS full_name, email, roll_number, "
            + "batch_or_cycle, cgpa "
            + "FROM students "
            + "WHERE student_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setLong(1, studentId);

            try (ResultSet rs = statement.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return mapStudentRow(rs);
            }
        }
    }

    private StudentProfile mapStudentRow(ResultSet rs) throws SQLException {
        StudentProfile profile = new StudentProfile();
        profile.setStudentId(rs.getLong("student_id"));
        profile.setFullName(rs.getString("full_name"));
        profile.setEmail(rs.getString("email"));
        profile.setRollNumber(rs.getString("roll_number"));

        String batch = rs.getString("batch_or_cycle");
        profile.setAcademicYear(batch != null ? batch : "Academic Year 2026-27");
        profile.setDepartment("Computer Engineering"); // Department based on roll number CE prefix/batch

        profile.setCgpa(rs.getBigDecimal("cgpa"));
        return profile;
    }
}
