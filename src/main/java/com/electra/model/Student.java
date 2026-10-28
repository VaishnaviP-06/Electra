
package com.electra.model;

public class Student {

    private long studentId;
    private long userId;
    private String rollNumber;
    private String studentName;
    private double cgpa;
    private String email;
    private String batchOrCycle;

    public Student() {
    }

    public long getStudentId() {
        return studentId;
    }

    public void setStudentId(long studentId) {
        this.studentId = studentId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getRollNumber() {
        return rollNumber;
    }

    public void setRollNumber(String rollNumber) {
        this.rollNumber = rollNumber;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public double getCgpa() {
        return cgpa;
    }

    public void setCgpa(double cgpa) {
        this.cgpa = cgpa;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getBatchOrCycle() {
        return batchOrCycle;
    }

    public void setBatchOrCycle(String batchOrCycle) {
        this.batchOrCycle = batchOrCycle;
    }
}
