package com.electra.model;

import java.math.BigDecimal;

public class StudentProfile {

    private long studentId;
    private String fullName;
    private String email;
    private String rollNumber;
    private String department;
    private String academicYear;
    private BigDecimal cgpa;

    public long getStudentId() {
        return studentId;
    }

    public void setStudentId(long studentId) {
        this.studentId = studentId;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRollNumber() {
        return rollNumber;
    }

    public void setRollNumber(String rollNumber) {
        this.rollNumber = rollNumber;
    }

    public String getDepartment() {
        return department;
    }

    public void setDepartment(String department) {
        this.department = department;
    }

    public String getAcademicYear() {
        return academicYear;
    }

    public void setAcademicYear(String academicYear) {
        this.academicYear = academicYear;
    }

    public BigDecimal getCgpa() {
        return cgpa;
    }

    public void setCgpa(BigDecimal cgpa) {
        this.cgpa = cgpa;
    }

    public String getInitials() {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "ST";
        }

        String[] parts = fullName.trim().split("\\s+");
        StringBuilder initials = new StringBuilder();
        initials.append(Character.toUpperCase(parts[0].charAt(0)));

        if (parts.length > 1) {
            initials.append(Character.toUpperCase(
                parts[parts.length - 1].charAt(0)
            ));
        }

        return initials.toString();
    }
}
