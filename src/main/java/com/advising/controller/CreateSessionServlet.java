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
@WebServlet("/api/sessions/create")
public class CreateSessionServlet extends HttpServlet {

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

        String advisorID = String.valueOf(session.getAttribute("userID"));

        // Parse JSON body
        JSONObject json = new JSONObject(request.getReader().lines().reduce("", (a, b) -> a + b));
        String studentID = json.optString("studentID", "").trim();
        String title = json.optString("title", "").trim();
        String sessionDate = json.optString("sessionDate", "").trim();
        String sessionTime = json.optString("sessionTime", "").trim();
        String notes = json.optString("notes", "").trim();
        String meetLink = json.optString("meetLink", "").trim();
        String sessionType = json.optString("sessionType", "").trim();

        if (studentID.isEmpty() || title.isEmpty() || sessionDate.isEmpty() || sessionTime.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Missing required fields\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Check if student is assigned to this advisor
            String checkSql = "SELECT advisorID FROM student WHERE studentID = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setString(1, studentID);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"error\":\"Student not found\"}");
                        return;
                    }
                    String assignedAdvisor = rs.getString("advisorID");
                    if (assignedAdvisor == null || !assignedAdvisor.equals(advisorID)) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        response.getWriter().write("{\"error\":\"Student not assigned to you\"}");
                        return;
                    }
                }
            }

            // Insert session
            String sessionDateTime = sessionDate + " " + sessionTime + ":00"; // Assume HH:MM format, add seconds
            String insertSql = "INSERT INTO advising_session (title, sessionDateTime, notes, meetLink, sessionType, status, advisorID, studentID) VALUES (?, ?, ?, ?, ?, 'scheduled', ?, ?)";
            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setString(1, title);
                insertPs.setString(2, sessionDateTime);
                insertPs.setString(3, notes);
                insertPs.setString(4, meetLink);
                insertPs.setString(5, sessionType);
                insertPs.setString(6, advisorID);
                insertPs.setString(7, studentID);
                insertPs.executeUpdate();
            }

            // Success
            JSONObject success = new JSONObject();
            success.put("success", true);
            success.put("message", "Session created successfully");
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