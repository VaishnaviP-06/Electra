package com.electra.controller;

import com.electra.dao.AllocationFormDAO;
import com.electra.dao.ElectiveDAO;
import com.electra.model.AllocationForm;
import com.electra.model.Elective;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/elective-crud-test")
public class ElectiveCrudTestServlet extends HttpServlet {

    @Override
    protected void doPost(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");

        try {
            AllocationFormDAO formDAO = new AllocationFormDAO();
            ElectiveDAO electiveDAO = new ElectiveDAO();

            List<AllocationForm> forms = formDAO.findAll();

            if (forms.isEmpty()) {
                response.getWriter().println(
                    "FAILED: No allocation form exists."
                );
                return;
            }

            long formId = forms.get(0).getFormId();

            String code = "CRUD-TEST-" + System.currentTimeMillis();

            // 1. CREATE
            Elective elective = new Elective();
            elective.setFormId(formId);
            elective.setElectiveCode(code);
            elective.setElectiveName("Temporary CRUD Test");
            elective.setSyllabus("Temporary test syllabus");
            elective.setFacultyName("Test Faculty");
            elective.setTotalSeats(30);
            elective.setMinStudents(5);
            elective.setMinCgpa(null);
            elective.setActive(true);

            boolean created = electiveDAO.create(elective);

            if (!created) {
                throw new Exception("Elective creation failed.");
            }

            response.getWriter().println(
                "PASS: CREATE - " + code
            );

            // Retrieve the inserted elective to obtain its ID.
            List<Elective> electives =
                    electiveDAO.findActiveByFormId(formId);

            Elective saved = null;

            for (Elective item : electives) {
                if (code.equals(item.getElectiveCode())) {
                    saved = item;
                    break;
                }
            }

            if (saved == null) {
                throw new Exception(
                    "Created elective could not be retrieved."
                );
            }

            // 2. UPDATE
            saved.setElectiveName("Updated CRUD Test");

            boolean updated = electiveDAO.update(saved);

            if (!updated) {
                throw new Exception("Elective update failed.");
            }

            response.getWriter().println(
                "PASS: UPDATE - " + saved.getElectiveName()
            );

            // 3. DEACTIVATE
            boolean deactivated = electiveDAO.deactivate(
                    saved.getElectiveId(),
                    formId
            );

            if (!deactivated) {
                throw new Exception("Elective deactivation failed.");
            }

            response.getWriter().println(
                "PASS: DEACTIVATE - " + code
            );

            response.getWriter().println(
                "\nAll three CRUD operations passed."
            );

            response.getWriter().println(
                "Test record ID: " + saved.getElectiveId()
            );

        } catch (Exception e) {
            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            response.getWriter().println(
                "CRUD TEST FAILED: " + e.getMessage()
            );

            e.printStackTrace();
        }
    }
}