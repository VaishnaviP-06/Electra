
package com.electra.controller;

import com.electra.dao.AllocationDAO;
import com.electra.dao.AllocationFormDAO;
import com.electra.dao.ElectiveDAO;
import com.electra.service.AllocationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/test-allocation-review")
public class AllocationReviewTestServlet extends HttpServlet {

    private AllocationService getService() {
        return new AllocationService();
    }

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain;charset=UTF-8");

        String mode = request.getParameter("mode");
        String formParam = request.getParameter("formId");

        try {
            long formId = Long.parseLong(
                formParam == null ? "3" : formParam
            );

            AllocationService service = getService();

            if ("prepare".equalsIgnoreCase(mode)) {
                service.prepareMinimumEnrolmentReview(formId);
                response.getWriter().println(
                    "RESULT: SUCCESS - Minimum-enrolment review prepared."
                );

            } else if ("review".equalsIgnoreCase(mode)) {
                long electiveId = Long.parseLong(
                    request.getParameter("electiveId")
                );
                long reviewerId = Long.parseLong(
                    request.getParameter("reviewerId")
                );
                String notes = request.getParameter("notes");

                service.recordElectiveReview(
                    formId, electiveId, reviewerId, notes
                );

                response.getWriter().println(
                    "RESULT: SUCCESS - Elective review recorded."
                );

            } else if ("finalize".equalsIgnoreCase(mode)) {
                service.finalizeReviewedAllocation(formId);
                response.getWriter().println(
                    "RESULT: SUCCESS - Allocation finalized; results remain unpublished."
                );

            } else {
                response.getWriter().println(
                    "Use mode=prepare, review, or finalize."
                );
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            response.getWriter().println("RESULT: FAILED");
            response.getWriter().println(e.getMessage());

        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().println("RESULT: SQL ERROR");
            response.getWriter().println(e.getMessage());

        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().println("RESULT: FAILED");
            response.getWriter().println(e.getMessage());
        }
    }
}
