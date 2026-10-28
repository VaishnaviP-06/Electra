package com.electra.service;

import com.electra.dao.AllocationFormDAO;
import com.electra.model.AllocationForm;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.List;

public class AllocationFormService {

    private final AllocationFormDAO formDAO;

    public AllocationFormService() {
        this.formDAO = new AllocationFormDAO();
    }

    public List<AllocationForm> getAllForms() throws SQLException {
        return formDAO.findAll();
    }

    public AllocationForm getFormById(long formId) throws SQLException {
        if (formId <= 0) {
            throw new IllegalArgumentException("Valid form ID is required.");
        }

        AllocationForm form = formDAO.findById(formId);

        if (form == null) {
            throw new IllegalArgumentException("Allocation form not found.");
        }

        return form;
    }

    public boolean createForm(AllocationForm form) throws SQLException {
        validateForm(form);

        if (form.getFormStatus() == null
                || form.getFormStatus().isBlank()) {
            form.setFormStatus("DRAFT");
        }

        return formDAO.create(form);
    }

    public boolean updateForm(AllocationForm form) throws SQLException {
        if (form == null || form.getFormId() <= 0) {
            throw new IllegalArgumentException(
                    "A valid allocation form is required.");
        }

        validateForm(form);
        getFormById(form.getFormId());

        return formDAO.update(form);
    }

    public boolean openForm(long formId) throws SQLException {
        AllocationForm form = getFormById(formId);

        if ("CLOSED".equals(form.getFormStatus())) {
            throw new IllegalArgumentException(
                    "A closed form cannot be reopened through this operation.");
        }

        Timestamp deadline = form.getSubmissionDeadline();

        if (deadline != null
                && new Timestamp(System.currentTimeMillis())
                        .after(deadline)) {
            throw new IllegalArgumentException(
                    "Cannot open a form whose submission deadline has passed.");
        }

        return formDAO.openForm(formId);
    }

    public boolean closeForm(long formId) throws SQLException {
        getFormById(formId);
        return formDAO.closeForm(formId);
    }

    private void validateForm(AllocationForm form) {
        if (form == null) {
            throw new IllegalArgumentException(
                    "Allocation form cannot be null.");
        }

        if (isBlank(form.getFormName())
                || isBlank(form.getCategoryName())
                || isBlank(form.getBatchOrCycle())) {
            throw new IllegalArgumentException(
                    "Form name, category, and batch/cycle are required.");
        }

        Timestamp openingDate = form.getOpeningDate();
        Timestamp deadline = form.getSubmissionDeadline();

        if (openingDate != null && deadline != null
                && deadline.before(openingDate)) {
            throw new IllegalArgumentException(
                    "Submission deadline cannot be before the opening date.");
        }

        String status = form.getFormStatus();

        if (status != null
                && !status.isBlank()
                && !List.of("DRAFT", "OPEN", "CLOSED").contains(status)) {
            throw new IllegalArgumentException(
                    "Form status must be DRAFT, OPEN, or CLOSED.");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}