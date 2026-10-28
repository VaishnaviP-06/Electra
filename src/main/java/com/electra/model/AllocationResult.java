package com.electra.model;

public class AllocationResult {

    private long studentId;
    private Long electiveId;
    private String allocationStatus;
    private String allocationReason;

    public AllocationResult(
            long studentId,
            Long electiveId,
            String allocationStatus,
            String allocationReason) {
        this.studentId = studentId;
        this.electiveId = electiveId;
        this.allocationStatus = allocationStatus;
        this.allocationReason = allocationReason;
    }

    public long getStudentId() {
        return studentId;
    }

    public Long getElectiveId() {
        return electiveId;
    }

    public String getAllocationStatus() {
        return allocationStatus;
    }

    public String getAllocationReason() {
        return allocationReason;
    }
}