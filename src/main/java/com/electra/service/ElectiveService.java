package com.electra.service;

import com.electra.dao.AllocationFormDAO;
import com.electra.dao.ElectiveDAO;
import com.electra.model.AllocationForm;
import com.electra.model.Elective;

import java.sql.SQLException;
import java.util.List;

public class ElectiveService {

    private final ElectiveDAO electiveDAO;
    private final AllocationFormDAO formDAO;

    public ElectiveService() {
        this.electiveDAO = new ElectiveDAO();
        this.formDAO = new AllocationFormDAO();
    }

    public List<Elective> getActiveElectives(long formId)
            throws SQLException {

        validateFormExists(formId);
        return electiveDAO.findActiveByFormId(formId);
    }

    public Elective getElective(long electiveId, long formId)
            throws SQLException {

        validateIds(electiveId, formId);

        Elective elective =
                electiveDAO.findByIdAndFormId(electiveId, formId);

        if (elective == null) {
            throw new IllegalArgumentException(
                    "Elective not found in the specified form.");
        }

        return elective;
    }

    public boolean createElective(Elective elective)
            throws SQLException {

        validateElective(elective);
        validateFormExists(elective.getFormId());

        return electiveDAO.create(elective);
    }

    public boolean updateElective(Elective elective)
            throws SQLException {

        validateElective(elective);

        if (elective.getElectiveId() <= 0) {
            throw new IllegalArgumentException(
                    "Valid elective ID is required.");
        }

        validateFormExists(elective.getFormId());

        getElective(
                elective.getElectiveId(),
                elective.getFormId());

        return electiveDAO.update(elective);
    }

    public boolean deactivateElective(long electiveId, long formId)
            throws SQLException {

        getElective(electiveId, formId);

        return electiveDAO.deactivate(electiveId, formId);
    }

    private void validateFormExists(long formId) throws SQLException {
        if (formId <= 0) {
            throw new IllegalArgumentException(
                    "Valid form ID is required.");
        }

        AllocationForm form = formDAO.findById(formId);

        if (form == null) {
            throw new IllegalArgumentException(
                    "Allocation form does not exist.");
        }
    }

    private void validateIds(long electiveId, long formId) {
        if (electiveId <= 0 || formId <= 0) {
            throw new IllegalArgumentException(
                    "Valid elective and form IDs are required.");
        }
    }

    private void validateElective(Elective elective) {
        if (elective == null) {
            throw new IllegalArgumentException(
                    "Elective cannot be null.");
        }

        if (elective.getFormId() <= 0) {
            throw new IllegalArgumentException(
                    "Valid form ID is required.");
        }

        if (isBlank(elective.getElectiveCode())
                || isBlank(elective.getElectiveName())) {
            throw new IllegalArgumentException(
                    "Elective code and name are required.");
        }

        if (elective.getTotalSeats() <= 0) {
            throw new IllegalArgumentException(
                    "Total seats must be greater than zero.");
        }

        if (elective.getMinStudents() < 0
                || elective.getMinStudents() > elective.getTotalSeats()) {
            throw new IllegalArgumentException(
                    "Minimum students must be between zero and total seats.");
        }

        Double minCgpa = elective.getMinCgpa();

        if (minCgpa != null && (minCgpa < 0 || minCgpa > 10)) {
            throw new IllegalArgumentException(
                    "Minimum CGPA must be between 0 and 10.");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}