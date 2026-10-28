package com.electra.dao;

import com.electra.model.ReportRow;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class ReportDAO {

    public static class ReportSummary {
        private int totalSubmissions;
        private int totalSeatsAllocated;
        private int belowMinEnrolmentCount;

        public int getTotalSubmissions() {
            return totalSubmissions;
        }

        public void setTotalSubmissions(int totalSubmissions) {
            this.totalSubmissions = totalSubmissions;
        }

        public int getTotalSeatsAllocated() {
            return totalSeatsAllocated;
        }

        public void setTotalSeatsAllocated(int totalSeatsAllocated) {
            this.totalSeatsAllocated = totalSeatsAllocated;
        }

        public int getBelowMinEnrolmentCount() {
            return belowMinEnrolmentCount;
        }

        public void setBelowMinEnrolmentCount(int belowMinEnrolmentCount) {
            this.belowMinEnrolmentCount = belowMinEnrolmentCount;
        }
    }

    public ReportSummary getReportSummary(Long formId) throws SQLException {
        ReportSummary summary = new ReportSummary();

        // 1. Total Submissions
        String subSql = (formId != null && formId > 0)
                ? "SELECT COUNT(*) FROM preference_submissions WHERE form_id = ? AND submission_status = 'SUBMITTED'"
                : "SELECT COUNT(*) FROM preference_submissions WHERE submission_status = 'SUBMITTED'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(subSql)) {
            if (formId != null && formId > 0) {
                stmt.setLong(1, formId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    summary.setTotalSubmissions(rs.getInt(1));
                }
            }
        }

        // 2. Seats Allocated
        String allocSql = (formId != null && formId > 0)
                ? "SELECT COUNT(*) FROM allocations WHERE form_id = ? AND allocation_status IN ('PROVISIONAL', 'ALLOCATED')"
                : "SELECT COUNT(*) FROM allocations WHERE allocation_status IN ('PROVISIONAL', 'ALLOCATED')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(allocSql)) {
            if (formId != null && formId > 0) {
                stmt.setLong(1, formId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    summary.setTotalSeatsAllocated(rs.getInt(1));
                }
            }
        }

        // 3. Below Minimum Enrolment
        String lowSql = (formId != null && formId > 0)
                ? "SELECT COUNT(*) FROM electives WHERE form_id = ? AND enrolment_status = 'BELOW_MINIMUM_ENROLMENT'"
                : "SELECT COUNT(*) FROM electives WHERE enrolment_status = 'BELOW_MINIMUM_ENROLMENT'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(lowSql)) {
            if (formId != null && formId > 0) {
                stmt.setLong(1, formId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    summary.setBelowMinEnrolmentCount(rs.getInt(1));
                }
            }
        }

        return summary;
    }

    public List<ReportRow> getReportRows(Long formId) throws SQLException {
        String sql =
            "SELECT e.elective_code, e.elective_name, e.total_seats, e.enrolment_status, " +
            "       (SELECT COUNT(*) FROM allocations a " +
            "        WHERE a.form_id = e.form_id AND a.elective_id = e.elective_id " +
            "          AND a.allocation_status IN ('PROVISIONAL', 'ALLOCATED') " +
            "          AND a.allocation_run_id = ( " +
            "              SELECT MAX(ar.allocation_run_id) FROM allocation_runs ar " +
            "              WHERE ar.form_id = e.form_id AND ar.run_status = 'COMPLETED' " +
            "          ) " +
            "       ) AS allocated_count " +
            "FROM electives e " +
            ((formId != null && formId > 0) ? "WHERE e.form_id = ? " : "") +
            "ORDER BY e.form_id, e.elective_code";

        List<ReportRow> rows = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            if (formId != null && formId > 0) {
                stmt.setLong(1, formId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ReportRow row = new ReportRow();
                    row.setElectiveCode(rs.getString("elective_code"));
                    row.setElectiveName(rs.getString("elective_name"));
                    row.setCapacity(rs.getInt("total_seats"));
                    row.setAllocatedCount(rs.getInt("allocated_count"));
                    row.setEnrolmentStatus(rs.getString("enrolment_status"));
                    rows.add(row);
                }
            }
        }
        return rows;
    }
}
