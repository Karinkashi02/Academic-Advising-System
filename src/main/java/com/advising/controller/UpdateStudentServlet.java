/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.advising.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;
import org.json.JSONObject;

/**
 *
 * @author Xander
 */
@WebServlet("/api/student/update")
public class UpdateStudentServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"student".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

        String studentID = String.valueOf(session.getAttribute("userID"));
        if (studentID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"No user in session\"}");
            return;
        }

        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String phoneNum = request.getParameter("phoneNum");
        String password = request.getParameter("password"); // optional

        if (firstName == null) firstName = "";
        if (lastName == null) lastName = "";
        if (email == null) email = "";
        if (phoneNum == null) phoneNum = "";

        try (Connection conn = DBConnection.getConnection()) {
            // Check which optional columns exist
            boolean hasPhone = columnExists(conn, null, null, "STUDENT", "PHONENUM"); // uppercase for Derby
            boolean hasPassword = columnExists(conn, null, null, "STUDENT", "PASSWORD");

            StringBuilder sql = new StringBuilder("UPDATE student SET firstName = ?, lastName = ?, email = ?");
            if (hasPhone) sql.append(", phoneNum = ?");
            if (password != null && !password.trim().isEmpty() && hasPassword) sql.append(", password = ?");
            sql.append(" WHERE studentID = ?");

            try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
                int idx = 1;
                ps.setString(idx++, firstName);
                ps.setString(idx++, lastName);
                ps.setString(idx++, email);
                if (hasPhone) {
                    ps.setString(idx++, phoneNum);
                }
                if (password != null && !password.trim().isEmpty() && hasPassword) {
                    ps.setString(idx++, password); // plaintext for now
                }
                ps.setString(idx++, studentID);

                int updated = ps.executeUpdate();
                if (updated > 0) {
                    JSONObject json = new JSONObject();
                    json.put("success", true);
                    json.put("message", "Profile updated");
                    response.getWriter().write(json.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"error\":\"Update failed\"}");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject err = new JSONObject();
            err.put("error", "Database error");
            err.put("message", e.getMessage());
            response.getWriter().write(err.toString());
        }
    }

    private boolean columnExists(Connection conn, String catalog, String schemaPattern, String tableName, String columnName) {
        try (ResultSet rs = conn.getMetaData().getColumns(catalog, schemaPattern, tableName, columnName)) {
            return rs.next();
        } catch (SQLException e) {
            // if metadata check fails, return false (be defensive)
            e.printStackTrace();
            return false;
        }
    }
}