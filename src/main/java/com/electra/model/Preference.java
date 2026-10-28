
package com.electra.model;

public class Preference {

    private long preferenceId;
    private long submissionId;
    private long formId;
    private long electiveId;
    private int preferenceRank;

    public Preference() {
    }

    public long getPreferenceId() {
        return preferenceId;
    }

    public void setPreferenceId(long preferenceId) {
        this.preferenceId = preferenceId;
    }

    public long getSubmissionId() {
        return submissionId;
    }

    public void setSubmissionId(long submissionId) {
        this.submissionId = submissionId;
    }

    public long getFormId() {
        return formId;
    }

    public void setFormId(long formId) {
        this.formId = formId;
    }

    public long getElectiveId() {
        return electiveId;
    }

    public void setElectiveId(long electiveId) {
        this.electiveId = electiveId;
    }

    public int getPreferenceRank() {
        return preferenceRank;
    }

    public void setPreferenceRank(int preferenceRank) {
        this.preferenceRank = preferenceRank;
    }
}
