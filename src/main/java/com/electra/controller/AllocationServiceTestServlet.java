package com.electra.controller;

import com.electra.service.AllocationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/test-allocation-service")
public class AllocationServiceTestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");

        try {
            String formIdParam = request.getParameter("formId");

            if (formIdParam == null || formIdParam.isBlank()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().println("Missing formId parameter.");
                return;
            }

            long formId = Long.parseLong(formIdParam);

            AllocationService service = new AllocationService();
            long runId = service.runInitialAllocation(formId);

            response.getWriter().println("RESULT: SUCCESS");
            response.getWriter().println("Form ID: " + formId);
            response.getWriter().println("Allocation Run ID: " + runId);

        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().println("formId must be a valid number.");

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().println("RESULT: FAILED");
            response.getWriter().println("Reason: " + e.getMessage());
        }
    }
}