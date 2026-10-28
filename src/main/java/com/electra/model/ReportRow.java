package com.electra.model;

public class ReportRow {
    private String electiveCode;
    private String electiveName;
    private int capacity;
    private int allocatedCount;
    private String enrolmentStatus;

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

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public int getAllocatedCount() {
        return allocatedCount;
    }

    public void setAllocatedCount(int allocatedCount) {
        this.allocatedCount = allocatedCount;
    }

    public String getEnrolmentStatus() {
        return enrolmentStatus;
    }

    public void setEnrolmentStatus(String enrolmentStatus) {
        this.enrolmentStatus = enrolmentStatus;
    }

    public String getUtilisation() {
        if (capacity <= 0) {
            return "0%";
        }
        double pct = (double) allocatedCount / capacity * 100.0;
        return String.format("%.1f%%", pct);
    }
}
