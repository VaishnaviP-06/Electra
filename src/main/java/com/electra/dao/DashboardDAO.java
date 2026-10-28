package com.electra.dao;

import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DashboardDAO {

    public static class StudentDashboardData {
        private int availableElectivesCount;
        private int preferenceCount;
        private String allocationStatus;
        private String allocationCaption;
        private String allocatedElectiveName;

        public int getAvailableElectivesCount() {
            return availableElectivesCount;
        }

        public void setAvailableElectivesCount(int availableElectivesCount) {
            this.availableElectivesCount = availableElectivesCount;
        }

        public int getPreferenceCount() {
            return preferenceCount;
        }

        public void setPreferenceCount(int preferenceCount) {
            this.preferenceCount = preferenceCount;
        }

        public String getAllocationStatus() {
            return allocationStatus;
        }

        public void setAllocationStatus(String allocationStatus) {
            this.allocationStatus = allocationStatus;
        }

        public String getAllocationCaption() {
            return allocationCaption;
        }

        public void setAllocationCaption(String allocationCaption) {
            this.allocationCaption = allocationCaption;
        }

        public String getAllocatedElectiveName() {
            return allocatedElectiveName;
        }

        public void setAllocatedElectiveName(String allocatedElectiveName) {
            this.allocatedElectiveName = allocatedElectiveName;
        }
    }

    public static class AdminDashboardData {
        private int totalElectives;
        private int totalSeats;
        private int totalStudents;
        private int totalForms;

        public int getTotalElectives() {
            return totalElectives;
        }

        public void setTotalElectives(int totalElectives) {
            this.totalElectives = totalElectives;
        }

        public int getTotalSeats() {
            return totalSeats;
        }

        public void setTotalSeats(int totalSeats) {
            this.totalSeats = totalSeats;
        }

        public int getTotalStudents() {
            return totalStudents;
        }

        public void setTotalStudents(int totalStudents) {
            this.totalStudents = totalStudents;
        }

        public int getTotalForms() {
            return totalForms;
        }

        public void setTotalForms(int totalForms) {
            this.totalForms = totalForms;
        }
    }

    public StudentDashboardData getStudentDashboardData(long studentId) throws SQLException {
        StudentDashboardData data = new StudentDashboardData();

        // 1. Available active electives
        String electivesSql = "SELECT COUNT(*) FROM electives WHERE is_active = 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(electivesSql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                data.setAvailableElectivesCount(rs.getInt(1));
            }
        }

        // 2. Preferences submitted count
        String prefSql = "SELECT COUNT(*) FROM preference_submissions WHERE student_id = ? AND submission_status = 'SUBMITTED'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(prefSql)) {
            stmt.setLong(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    data.setPreferenceCount(rs.getInt(1));
                }
            }
        }

        // 3. Allocation status for published forms
        String allocSql =
            "SELECT a.allocation_status, a.allocation_reason, e.elective_code, e.elective_name, f.results_published " +
            "FROM allocations a " +
            "JOIN allocation_forms f ON f.form_id = a.form_id " +
            "LEFT JOIN electives e ON e.elective_id = a.elective_id " +
            "WHERE a.student_id = ? AND a.allocation_run_id = ( " +
            "    SELECT MAX(ar.allocation_run_id) FROM allocation_runs ar WHERE ar.form_id = a.form_id AND ar.run_status = 'COMPLETED' " +
            ") " +
            "ORDER BY f.results_published DESC, a.allocation_id DESC LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(allocSql)) {
            stmt.setLong(1, studentId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    boolean published = rs.getBoolean("results_published");
                    String status = rs.getString("allocation_status");
                    String elective = rs.getString("elective_name");

                    if (published) {
                        if ("ALLOCATED".equals(status)) {
                            data.setAllocationStatus("Allocated");
                            data.setAllocationCaption(elective != null ? elective : "Assigned Elective");
                            data.setAllocatedElectiveName(elective);
                        } else if ("NOT_ALLOTTED".equals(status)) {
                            data.setAllocationStatus("Not Allotted");
                            data.setAllocationCaption("Check allocation results for details");
                        } else {
                            data.setAllocationStatus(status);
                            data.setAllocationCaption("Allocation completed");
                        }
                    } else {
                        data.setAllocationStatus("Pending");
                        data.setAllocationCaption("Final results not published");
                    }
                } else {
                    data.setAllocationStatus("Pending");
                    data.setAllocationCaption("Allocation not published");
                }
            }
        }

        return data;
    }

    public AdminDashboardData getAdminDashboardData() throws SQLException {
        AdminDashboardData data = new AdminDashboardData();

        String sql =
            "SELECT " +
            "    (SELECT COUNT(*) FROM electives WHERE is_active = 1) AS total_electives, " +
            "    (SELECT COALESCE(SUM(total_seats), 0) FROM electives WHERE is_active = 1) AS total_seats, " +
            "    (SELECT COUNT(*) FROM students) AS total_students, " +
            "    (SELECT COUNT(*) FROM allocation_forms) AS total_forms";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                data.setTotalElectives(rs.getInt("total_electives"));
                data.setTotalSeats(rs.getInt("total_seats"));
                data.setTotalStudents(rs.getInt("total_students"));
                data.setTotalForms(rs.getInt("total_forms"));
            }
        }

        return data;
    }
}
