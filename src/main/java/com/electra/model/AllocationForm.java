
package com.electra.model;

import java.sql.Timestamp;

public class AllocationForm {

    private long formId;
    private String formName;
    private String categoryName;
    private String batchOrCycle;
    private Timestamp openingDate;
    private Timestamp submissionDeadline;
    private String formStatus;
    private String allocationStatus;
    private String reviewStatus;
    private boolean resultsPublished;

    public AllocationForm() {
    }

    public long getFormId() {
        return formId;
    }

    public void setFormId(long formId) {
        this.formId = formId;
    }

    public String getFormName() {
        return formName;
    }

    public void setFormName(String formName) {
        this.formName = formName;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getBatchOrCycle() {
        return batchOrCycle;
    }

    public void setBatchOrCycle(String batchOrCycle) {
        this.batchOrCycle = batchOrCycle;
    }

    public Timestamp getOpeningDate() {
        return openingDate;
    }

    public void setOpeningDate(Timestamp openingDate) {
        this.openingDate = openingDate;
    }

    public Timestamp getSubmissionDeadline() {
        return submissionDeadline;
    }

    public void setSubmissionDeadline(Timestamp submissionDeadline) {
        this.submissionDeadline = submissionDeadline;
    }

    public String getFormStatus() {
        return formStatus;
    }

    public void setFormStatus(String formStatus) {
        this.formStatus = formStatus;
    }

    public String getAllocationStatus() {
        return allocationStatus;
    }

    public void setAllocationStatus(String allocationStatus) {
        this.allocationStatus = allocationStatus;
    }

    public String getReviewStatus() {
        return reviewStatus;
    }

    public void setReviewStatus(String reviewStatus) {
        this.reviewStatus = reviewStatus;
    }

    public boolean isResultsPublished() {
        return resultsPublished;
    }

    public void setResultsPublished(boolean resultsPublished) {
        this.resultsPublished = resultsPublished;
    }
}
