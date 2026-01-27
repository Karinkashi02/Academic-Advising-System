/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.advising.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;

import java.io.IOException;
import java.sql.*;

/**
 *
 * @author Xander
 */
@WebServlet("/api/advisor/students/add")
public class AddAdviseeServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Auth check
        HttpSession session = request.getSession(false);
        if (session == null || !"advisor".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated as advisor\"}");
            return;
        }

        String advisorIDStr = String.valueOf(session.getAttribute("userID"));
        String studentID = request.getParameter("studentID");
        if (studentID == null || studentID.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Missing studentID\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Atomic update: assign only if not assigned to another advisor
            String updateSql = "UPDATE student SET advisorID = ? WHERE studentID = ? AND (advisorID IS NULL OR advisorID = ?)";
            try (PreparedStatement updatePs = conn.prepareStatement(updateSql)) {
                updatePs.setString(1, advisorIDStr);
                updatePs.setString(2, studentID);
                updatePs.setString(3, advisorIDStr);
                int rows = updatePs.executeUpdate();
                if (rows == 0) {
                    // Check if student exists
                    String checkSql = "SELECT advisorID FROM student WHERE studentID = ?";
                    try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                        checkPs.setString(1, studentID);
                        try (ResultSet rs = checkPs.executeQuery()) {
                            if (!rs.next()) {
                                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                                response.getWriter().write("{\"error\":\"Student not found\"}");
                                return;
                            }
                            Integer currentAdvisorID = rs.getObject("advisorID") != null ? rs.getInt("advisorID") : null;
                            if (currentAdvisorID != null && !currentAdvisorID.toString().equals(advisorIDStr)) {
                                response.setStatus(HttpServletResponse.SC_CONFLICT);
                                JSONObject err = new JSONObject();
                                err.put("error", "Student already assigned to another advisor");
                                err.put("currentAdvisorID", currentAdvisorID);
                                response.getWriter().write(err.toString());
                                return;
                            } else {
                                // Should not happen, but idempotent
                                JSONObject success = new JSONObject();
                                success.put("success", true);
                                success.put("message", "Advisee already assigned to you");
                                response.getWriter().write(success.toString());
                                return;
                            }
                        }
                    }
                }
            }

            // Success
            JSONObject success = new JSONObject();
            success.put("success", true);
            success.put("message", "Advisee added successfully");
            response.getWriter().write(success.toString());

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject err = new JSONObject();
            err.put("error", "Database error");
            err.put("message", e.getMessage());
            response.getWriter().write(err.toString());
        }
    }
}