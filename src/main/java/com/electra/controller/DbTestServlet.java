
package com.electra.controller;

import com.electra.util.DBConnection;

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/db-test")
public class DbTestServlet extends HttpServlet {

    @Override
    protected void doGet(
            HttpServletRequest request,
            HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");

        try (
            Connection connection = DBConnection.getConnection();
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery(
                "SELECT COUNT(*) AS total FROM allocation_forms"
            )
        ) {
            resultSet.next();

            response.getWriter().println("Database connection successful!");
            response.getWriter().println(
                "Forms in database: " + resultSet.getInt("total")
            );

        } catch (Exception e) {
            e.printStackTrace();

            response.setContentType("text/plain");
            response.setCharacterEncoding("UTF-8");

            response.getWriter().println("Database connection failed.");
            response.getWriter().println("Error: " + e.getClass().getName());
            response.getWriter().println("Message: " + e.getMessage());
        }
    }
}
