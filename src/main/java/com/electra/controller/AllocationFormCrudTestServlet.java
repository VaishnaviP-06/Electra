
package com.electra.controller;

import com.electra.dao.AllocationFormDAO;
import com.electra.model.AllocationForm;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/allocation-form-crud-test")
public class AllocationFormCrudTestServlet extends HttpServlet {

    private final AllocationFormDAO formDAO = new AllocationFormDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");

        try {
            // 1. CREATE
            AllocationForm form = new AllocationForm();
            form.setFormName("CRUD TEST " + System.currentTimeMillis());
            form.setCategoryName("TEST");
            form.setBatchOrCycle("TY-CE-TEST");
            form.setOpeningDate(
                java.sql.Timestamp.valueOf(
                    LocalDateTime.now().plusMinutes(1)
                )
            );

            form.setSubmissionDeadline(
                java.sql.Timestamp.valueOf(
                    LocalDateTime.now().plusDays(7)
                )
            );

            boolean created = formDAO.create(form);

            if (!created) {
                response.getWriter().println("CREATE FAILED");
                return;
            }

            long formId = form.getFormId();

            response.getWriter().println(
                    "CREATE PASSED | Form ID: " + formId
            );

            // 2. READ
            AllocationForm fetched = formDAO.findById(formId);

            if (fetched == null) {
                response.getWriter().println("READ FAILED");
                return;
            }

            response.getWriter().println(
                    "READ PASSED | Name: " + fetched.getFormName()
            );

            // 3. UPDATE
            fetched.setFormName("CRUD TEST UPDATED " + formId);
            fetched.setCategoryName("TEST_UPDATED");

            boolean updated = formDAO.update(fetched);

            response.getWriter().println(
                    updated ? "UPDATE PASSED" : "UPDATE FAILED"
            );

            // 4. VERIFY UPDATE
            AllocationForm updatedForm = formDAO.findById(formId);

            if (updatedForm != null
                    && updatedForm.getFormName().equals(
                            "CRUD TEST UPDATED " + formId)
                    && updatedForm.getCategoryName().equals(
                            "TEST_UPDATED")) {
                response.getWriter().println("UPDATE VERIFICATION PASSED");
            } else {
                response.getWriter().println("UPDATE VERIFICATION FAILED");
            }

            // Open the form before attempting to close it
            boolean initiallyOpened = formDAO.openForm(formId);

            response.getWriter().println(
                    initiallyOpened
                            ? "INITIAL OPEN PASSED"
                            : "INITIAL OPEN FAILED"
            );
            
            // 5. CLOSE
            boolean closed = formDAO.closeForm(formId);

            response.getWriter().println(
                    closed ? "CLOSE PASSED" : "CLOSE FAILED"
            );

            // 6. REOPEN
            boolean opened = formDAO.openForm(formId);

            response.getWriter().println(
                    opened ? "REOPEN PASSED" : "REOPEN FAILED"
            );

            // 7. VERIFY FINAL STATUS
            AllocationForm finalForm = formDAO.findById(formId);

            response.getWriter().println(
                    "FINAL STATUS: " + finalForm.getFormStatus()
            );

            response.getWriter().println(
                    "\nTEST FORM ID FOR DATABASE CHECK: " + formId
            );

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            e.printStackTrace(response.getWriter());
        }
    }
}
