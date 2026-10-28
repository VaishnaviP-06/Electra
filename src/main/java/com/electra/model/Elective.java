
package com.electra.model;

public class Elective {

    private long electiveId;
    private long formId;
    private String electiveCode;
    private String electiveName;
    private String syllabus;
    private String facultyName;
    private int totalSeats;
    private int minStudents;
    private Double minCgpa;
    private boolean active;
    private String enrolmentStatus;

    public Elective() {
    }

    public long getElectiveId() {
        return electiveId;
    }

    public void setElectiveId(long electiveId) {
        this.electiveId = electiveId;
    }

    public long getFormId() {
        return formId;
    }

    public void setFormId(long formId) {
        this.formId = formId;
    }

    public String getElectiveCode() {
        return electiveCode;
    }

    public void setElectiveCode(String electiveCode) {
        this.electiveCode = electiveCode;
    }

    public String getElectiveName() {
        return electiveName;
    }

    public void setElectiveName(String electiveName) {
        this.electiveName = electiveName;
    }

    public String getSyllabus() {
        return syllabus;
    }

    public void setSyllabus(String syllabus) {
        this.syllabus = syllabus;
    }

    public String getFacultyName() {
        return facultyName;
    }

    public void setFacultyName(String facultyName) {
        this.facultyName = facultyName;
    }

    public int getTotalSeats() {
        return totalSeats;
    }

    public void setTotalSeats(int totalSeats) {
        this.totalSeats = totalSeats;
    }

    public int getMinStudents() {
        return minStudents;
    }

    public void setMinStudents(int minStudents) {
        this.minStudents = minStudents;
    }

    public Double getMinCgpa() {
        return minCgpa;
    }

    public void setMinCgpa(Double minCgpa) {
        this.minCgpa = minCgpa;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public String getEnrolmentStatus() {
        return enrolmentStatus;
    }

    public void setEnrolmentStatus(String enrolmentStatus) {
        this.enrolmentStatus = enrolmentStatus;
    }
}
