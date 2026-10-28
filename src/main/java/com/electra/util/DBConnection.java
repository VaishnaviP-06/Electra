
package com.electra.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnection {

    private static final String URL =
        "jdbc:mysql://localhost:3306/electra_db"
        + "?useSSL=false"
        + "&serverTimezone=UTC"
        + "&allowPublicKeyRetrieval=true";

    private static final String USER =
        System.getenv().getOrDefault("ELECTRA_DB_USER", "root");

    private static final String PASSWORD =
        System.getenv().getOrDefault("ELECTRA_DB_PASSWORD", "12345");

    private DBConnection() {
        // Utility class: prevent object creation.
    }

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException(
                "MySQL Connector/J is not visible to the application", e
            );
        }

        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
