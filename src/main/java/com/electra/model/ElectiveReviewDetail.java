package com.electra.model;

import java.sql.Timestamp;

/**
 * Encapsulates elective information combined with minimum-enrolment review state
 * and provisional enrolment figures for administrative workflow review.
 */
public class ElectiveReviewDetail {

    private long electiveId;
    private long formId;
    private String electiveCode;
    private String electiveName;
    private int totalSeats;
    private int minStudents;
    private Double minCgpa;
    private boolean active;
    private String enrolmentStatus;
    private String reviewStatus;
    private String reviewNotes;
    private Long reviewedBy;
    private String reviewerUsername;
    private Timestamp reviewedAt;
    private long provisionalEnrolment;

    public ElectiveReviewDetail() {
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

    public String getReviewStatus() {
        return reviewStatus;
    }

    public void setReviewStatus(String reviewStatus) {
        this.reviewStatus = reviewStatus;
    }

    public String getReviewNotes() {
        return reviewNotes;
    }

    public void setReviewNotes(String reviewNotes) {
        this.reviewNotes = reviewNotes;
    }

    public Long getReviewedBy() {
        return reviewedBy;
    }

    public void setReviewedBy(Long reviewedBy) {
        this.reviewedBy = reviewedBy;
    }

    public String getReviewerUsername() {
        return reviewerUsername;
    }

    public void setReviewerUsername(String reviewerUsername) {
        this.reviewerUsername = reviewerUsername;
    }

    public Timestamp getReviewedAt() {
        return reviewedAt;
    }

    public void setReviewedAt(Timestamp reviewedAt) {
        this.reviewedAt = reviewedAt;
    }

    public long getProvisionalEnrolment() {
        return provisionalEnrolment;
    }

    public void setProvisionalEnrolment(long provisionalEnrolment) {
        this.provisionalEnrolment = provisionalEnrolment;
    }

    public boolean isBelowMinimum() {
        return "BELOW_MINIMUM_ENROLMENT".equals(enrolmentStatus);
    }

    public boolean isReviewed() {
        return "REVIEWED".equals(reviewStatus) || "BELOW_MINIMUM_ENROLMENT".equals(reviewStatus);
    }
}
