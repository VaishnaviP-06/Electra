
package com.electra.service;

import com.electra.dao.AllocationFormDAO;
import com.electra.dao.ElectiveDAO;
import com.electra.dao.PreferenceDAO;
import com.electra.dao.PreferenceSubmissionDAO;
import com.electra.model.AllocationForm;
import com.electra.model.Elective;
import com.electra.model.Preference;
import com.electra.model.PreferenceSubmission;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class PreferenceSubmissionService {

    private final PreferenceSubmissionDAO submissionDAO;
    private final PreferenceDAO preferenceDAO;
    private final ElectiveDAO electiveDAO;
    private final AllocationFormDAO formDAO;

    public PreferenceSubmissionService() {
        this.submissionDAO = new PreferenceSubmissionDAO();
        this.preferenceDAO = new PreferenceDAO();
        this.electiveDAO = new ElectiveDAO();
        this.formDAO = new AllocationFormDAO();
    }

    public PreferenceSubmission getSubmission(
            long studentId, long formId) throws SQLException {

        validateIds(studentId, formId);
        return submissionDAO.findByStudentAndForm(studentId, formId);
    }

    public List<Preference> getPreferences(
            long studentId, long formId) throws SQLException {

        validateIds(studentId, formId);

        PreferenceSubmission submission =
                submissionDAO.findByStudentAndForm(studentId, formId);

        if (submission == null) {
            return List.of();
        }

        // The student is identified by studentId + formId,
        // never by an arbitrary submission ID supplied by the client.
        return preferenceDAO.findBySubmissionId(
                submission.getSubmissionId());
    }

    public PreferenceSubmission saveDraft(
            long studentId,
            long formId,
            List<Preference> preferences) throws SQLException {

        validateIds(studentId, formId);
        validatePreferenceList(preferences);
        ensureFormAcceptingPreferences(formId);

        PreferenceSubmission submission =
        getOrCreateSubmission(studentId, formId);

        if ("SUBMITTED".equals(submission.getSubmissionStatus())) {
            throw new IllegalArgumentException(
                    "Submitted preferences cannot be edited.");
        }

        preferenceDAO.replacePreferences(
                submission.getSubmissionId(), preferences);

        return submissionDAO.findById(
                submission.getSubmissionId());
    }

    public PreferenceSubmission submitPreferences(
            long studentId,
            long formId,
            List<Preference> preferences) throws SQLException {

        validateIds(studentId, formId);
        validatePreferenceList(preferences);
        ensureFormAcceptingPreferences(formId);

        List<Elective> activeElectives =
                electiveDAO.findActiveByFormId(formId);

        if (activeElectives.isEmpty()) {
            throw new IllegalArgumentException(
                    "This form has no active electives to rank.");
        }

        // A final submission must rank every active elective exactly once.
        Set<Long> requiredElectiveIds = new HashSet<>();

        for (Elective elective : activeElectives) {
            requiredElectiveIds.add(elective.getElectiveId());
        }

        Set<Long> selectedElectiveIds = new HashSet<>();
        Set<Integer> selectedRanks = new HashSet<>();

        for (Preference preference : preferences) {
            selectedElectiveIds.add(preference.getElectiveId());
            selectedRanks.add(preference.getPreferenceRank());
        }

        if (selectedElectiveIds.size() != preferences.size()
                || !selectedElectiveIds.equals(requiredElectiveIds)) {
            throw new IllegalArgumentException(
                    "Rank every active elective exactly once before submitting.");
        }

        // Require ranks 1, 2, 3, ... with no gaps.
        if (selectedRanks.size() != activeElectives.size()) {
            throw new IllegalArgumentException(
                    "Each elective must have a unique preference rank.");
        }

        for (int rank = 1; rank <= activeElectives.size(); rank++) {
            if (!selectedRanks.contains(rank)) {
                throw new IllegalArgumentException(
                        "Preference ranks must be consecutive, starting at 1.");
            }
        }

        PreferenceSubmission submission =
                getOrCreateSubmission(studentId, formId);
        
                // Do not allow an already-submitted ranking to be changed.
        if ("SUBMITTED".equals(submission.getSubmissionStatus())) {
            throw new IllegalArgumentException(
                    "Preferences have already been submitted and cannot be changed.");
        }

        // The DAO validates the form window and elective ownership again
        // inside its transaction before replacing the saved list.
        preferenceDAO.replacePreferences(
                submission.getSubmissionId(), preferences);

        if ("DRAFT".equals(submission.getSubmissionStatus())) {
            boolean updated = submissionDAO.markSubmitted(
                    submission.getSubmissionId());

            if (!updated) {
                throw new SQLException(
                        "Could not mark the preference submission as submitted.");
            }
        }

        PreferenceSubmission result = submissionDAO.findById(
                submission.getSubmissionId());

        if (result == null
                || !"SUBMITTED".equals(result.getSubmissionStatus())) {
            throw new SQLException(
                    "Submission status could not be verified.");
        }

        return result;
    }

    private PreferenceSubmission getOrCreateSubmission(
            long studentId, long formId) throws SQLException {

        PreferenceSubmission submission =
                submissionDAO.findByStudentAndForm(studentId, formId);

        if (submission == null) {
            submission = submissionDAO.createDraft(studentId, formId);
        }

        return submission;
    }

    private void ensureFormAcceptingPreferences(long formId)
            throws SQLException {

        AllocationForm form = formDAO.findById(formId);

        if (form == null) {
            throw new IllegalArgumentException(
                    "Allocation form does not exist.");
        }

        if (!"OPEN".equals(form.getFormStatus())) {
            throw new IllegalArgumentException(
                    "This allocation form is not open.");
        }

        LocalDateTime now = LocalDateTime.now();
        Timestamp openingTimestamp = form.getOpeningDate();
        LocalDateTime openingDate = openingTimestamp == null
                ? null
                : openingTimestamp.toLocalDateTime();

        if (openingDate != null && now.isBefore(openingDate)) {
            throw new IllegalArgumentException(
                    "The preference submission window has not opened yet.");
        }

        Timestamp deadline = form.getSubmissionDeadline();

        if (deadline != null
                && now.isAfter(deadline.toLocalDateTime())) {
            throw new IllegalArgumentException(
                    "The preference submission deadline has passed.");
        }
    }

    private void validateIds(long studentId, long formId) {
        if (studentId <= 0 || formId <= 0) {
            throw new IllegalArgumentException(
                    "Valid student and form IDs are required.");
        }
    }

    private void validatePreferenceList(List<Preference> preferences) {
        if (preferences == null) {
            throw new IllegalArgumentException(
                    "Preference list cannot be null.");
        }

        for (Preference preference : preferences) {
            if (preference == null) {
                throw new IllegalArgumentException(
                        "Preference list cannot contain null entries.");
            }
        }
    }
}
