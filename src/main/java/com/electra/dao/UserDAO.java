package com.electra.dao;

import com.electra.model.User;
import com.electra.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public User findByUsername(String username) throws SQLException {
        String sql =
            "SELECT user_id, username, password_hash, role, is_active "
            + "FROM users WHERE username = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, username);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }

        return null;
    }

    public User findById(long userId) throws SQLException {
        String sql =
            "SELECT user_id, username, password_hash, role, is_active "
            + "FROM users WHERE user_id = ?";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setLong(1, userId);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }

        return null;
    }

    /**
     * Resolves a user by student identifier (email, roll number, or username).
     * Returns the associated User entity if found.
     */
    public User findStudentUserByIdentifier(String identifier) throws SQLException {
        String sql =
            "SELECT u.user_id, u.username, u.password_hash, u.role, u.is_active "
            + "FROM users u "
            + "LEFT JOIN students s ON u.user_id = s.user_id "
            + "WHERE u.role = 'STUDENT' AND ("
            + "   LOWER(u.username) = LOWER(?) "
            + "   OR LOWER(s.roll_number) = LOWER(?) "
            + "   OR LOWER(s.email) = LOWER(?)"
            + ")";

        try (
            Connection connection = DBConnection.getConnection();
            PreparedStatement statement = connection.prepareStatement(sql)
        ) {
            statement.setString(1, identifier);
            statement.setString(2, identifier);
            statement.setString(3, identifier);

            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return mapUser(rs);
                }
            }
        }

        return null;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getLong("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setRole(rs.getString("role"));
        user.setActive(rs.getBoolean("is_active"));
        return user;
    }
}
