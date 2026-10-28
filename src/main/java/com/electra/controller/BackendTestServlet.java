
package com.electra.controller;

import com.electra.dao.AllocationFormDAO;
import com.electra.dao.ElectiveDAO;
import com.electra.dao.UserDAO;
import com.electra.model.AllocationForm;
import com.electra.model.Elective;
import com.electra.model.User;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/backend-test")
public class BackendTestServlet extends HttpServlet {

    private final AllocationFormDAO formDAO = new AllocationFormDAO();
    private final ElectiveDAO electiveDAO = new ElectiveDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");

        try {
            List<AllocationForm> forms = formDAO.findAll();

            response.getWriter().println("=== FORMS ===");

            for (AllocationForm form : forms) {
                response.getWriter().println(
                    form.getFormId() + " | "
                    + form.getFormName() + " | "
                    + form.getFormStatus()
                );

                List<Elective> electives =
                    electiveDAO.findActiveByFormId(form.getFormId());

                for (Elective elective : electives) {
                    response.getWriter().println(
                        "    " + elective.getElectiveCode()
                        + " | " + elective.getElectiveName()
                        + " | Seats: " + elective.getTotalSeats()
                    );
                }
            }

            User admin = userDAO.findByUsername("admin_demo");

            response.getWriter().println("\n=== USER DAO ===");
            response.getWriter().println(
                admin != null
                    ? "Admin demo user found: " + admin.getUsername()
                    : "Admin demo user not found"
            );

            response.getWriter().println("\nDAO TEST COMPLETED");

        } catch (SQLException e) {
            getServletContext().log("Backend DAO test failed", e);

            response.setStatus(
                HttpServletResponse.SC_INTERNAL_SERVER_ERROR
            );

            response.getWriter().println(
                "DAO test failed. Check the Tomcat logs."
            );
        }
    }
}
