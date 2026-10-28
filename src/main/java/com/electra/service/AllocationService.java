package com.electra.service;

import com.electra.dao.AllocationDAO;
import com.electra.dao.AllocationFormDAO;
import com.electra.dao.ElectiveDAO;
import com.electra.model.AllocationCandidate;
import com.electra.model.AllocationForm;
import com.electra.model.AllocationResult;
import com.electra.model.Elective;
import com.electra.model.Preference;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AllocationService {

    private final AllocationDAO allocationDAO;
    private final AllocationFormDAO formDAO;
    private final ElectiveDAO electiveDAO;

    public AllocationService() {
        this.allocationDAO = new AllocationDAO();
        this.formDAO = new AllocationFormDAO();
        this.electiveDAO = new ElectiveDAO();
    }

    public long runInitialAllocation(long formId)
            throws SQLException {

        if (formId <= 0) {
            throw new IllegalArgumentException(
                    "Valid allocation form ID is required.");
        }

        AllocationForm form = formDAO.findById(formId);

        if (form == null) {
            throw new IllegalArgumentException(
                    "Allocation form does not exist.");
        }

        if (!"CLOSED".equals(form.getFormStatus())) {
            throw new IllegalArgumentException(
                    "Close the allocation form before running allocation.");
        }

        if (!"NOT_STARTED".equals(form.getAllocationStatus())) {
            throw new IllegalArgumentException(
                    "Allocation has already started or completed for this form.");
        }

        List<Elective> activeElectives =
                electiveDAO.findActiveByFormId(formId);

        if (activeElectives.isEmpty()) {
            throw new IllegalArgumentException(
                    "This form has no active electives.");
        }

        List<AllocationCandidate> candidates =
                allocationDAO.findSubmittedCandidates(formId);

        if (candidates.isEmpty()) {
            throw new IllegalArgumentException(
                    "No submitted student preferences were found.");
        }

        List<AllocationResult> results =
                calculateAllocation(candidates, activeElectives);

        return allocationDAO.saveAllocationRun(
                formId, "INITIAL", results);
    }

    private List<AllocationResult> calculateAllocation(
            List<AllocationCandidate> candidates,
            List<Elective> electives) {

        // Merit order: CGPA descending, submission time ascending,
        // then roll number ascending.
        candidates.sort(
                Comparator.comparingDouble(
                                AllocationCandidate::getCgpa)
                        .reversed()
                        .thenComparing(
                                AllocationCandidate::getSubmittedAt)
                        .thenComparing(
                                AllocationCandidate::getRollNumber,
                                String.CASE_INSENSITIVE_ORDER));

        Map<Long, Elective> electiveById = new HashMap<>();
        Map<Long, Integer> seatsUsed = new HashMap<>();

        for (Elective elective : electives) {
            electiveById.put(
                    elective.getElectiveId(), elective);
            seatsUsed.put(elective.getElectiveId(), 0);
        }

        List<AllocationResult> results = new ArrayList<>();

        for (AllocationCandidate candidate : candidates) {

            List<Preference> preferences =
                    new ArrayList<>(candidate.getPreferences());

            preferences.sort(
                    Comparator.comparingInt(
                            Preference::getPreferenceRank));

            Elective assignedElective = null;
            int assignedRank = -1;

            for (Preference preference : preferences) {

                Elective elective = electiveById.get(
                        preference.getElectiveId());

                // Ignore inactive electives and electives outside
                // the current form's active-elective list.
                if (elective == null) {
                    continue;
                }

                Double minimumCgpa = elective.getMinCgpa();

                if (minimumCgpa != null
                        && candidate.getCgpa() < minimumCgpa) {
                    continue;
                }

                int used = seatsUsed.get(
                        elective.getElectiveId());

                if (used >= elective.getTotalSeats()) {
                    continue;
                }

                assignedElective = elective;
                assignedRank = preference.getPreferenceRank();

                seatsUsed.put(
                        elective.getElectiveId(), used + 1);

                break;
            }

            if (assignedElective != null) {
                results.add(new AllocationResult(
                        candidate.getStudentId(),
                        assignedElective.getElectiveId(),
                        "PROVISIONAL",
                        "Assigned by merit at preference rank "
                                + assignedRank));
            } else {
                results.add(new AllocationResult(
                        candidate.getStudentId(),
                        null,
                        "NOT_ALLOTTED",
                        "No eligible preference with available seats"));
            }
        }

        return results;
    }

    public void prepareMinimumEnrolmentReview(long formId)
            throws SQLException {

        if (formId <= 0) {
            throw new IllegalArgumentException(
                    "Valid allocation form ID is required.");
        }

        AllocationForm form = formDAO.findById(formId);

        if (form == null) {
            throw new IllegalArgumentException(
                    "Allocation form does not exist.");
        }

        if (!"COMPLETED".equals(form.getAllocationStatus())) {
            throw new IllegalStateException(
                    "Complete initial allocation before reviewing enrolment.");
        }

        if (!"PENDING".equals(form.getReviewStatus())) {
            throw new IllegalStateException(
                    "The form is not awaiting minimum-enrolment review.");
        }

        allocationDAO.prepareMinimumEnrolmentReview(formId);
    }

    public void recordElectiveReview(
            long formId,
            long electiveId,
            long reviewerId,
            String notes) throws SQLException {

        if (formId <= 0 || electiveId <= 0 || reviewerId <= 0) {
            throw new IllegalArgumentException(
                    "Form, elective, and reviewer IDs must be positive.");
        }

        allocationDAO.recordElectiveReview(
                formId, electiveId, reviewerId, notes);
    }

    public void finalizeReviewedAllocation(long formId)
            throws SQLException {

        if (formId <= 0) {
            throw new IllegalArgumentException(
                    "Valid allocation form ID is required.");
        }

        AllocationForm form = formDAO.findById(formId);

        if (form == null) {
            throw new IllegalArgumentException(
                    "Allocation form does not exist.");
        }

        if (!"COMPLETED".equals(form.getAllocationStatus())) {
            throw new IllegalStateException(
                    "Initial allocation has not been completed.");
        }

        if (!"REVIEWED".equals(form.getReviewStatus())) {
            throw new IllegalStateException(
                    "Review every active elective before finalization.");
        }

        allocationDAO.finalizeReviewedAllocation(formId);
    }

}