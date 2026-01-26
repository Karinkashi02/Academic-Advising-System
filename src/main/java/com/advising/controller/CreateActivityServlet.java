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
@WebServlet("/api/activity/create")
public class CreateActivityServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json"); response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"student".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }
        String studentID = String.valueOf(session.getAttribute("userID"));

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String dateTimeRaw = request.getParameter("dateTime");
        String location = request.getParameter("location");
        String capacityStr = request.getParameter("capacity");
        String category = request.getParameter("category");
        String pointsStr = request.getParameter("points");
        String host = request.getParameter("host");

        if (title == null || title.trim().isEmpty() || dateTimeRaw == null || dateTimeRaw.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"title and dateTime required\"}");
            return;
        }

        String normalized = dateTimeRaw.replace('T', ' ');
        if (normalized.length() == 16) normalized = normalized + ":00";
        Timestamp ts;
        try { ts = Timestamp.valueOf(normalized); } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid datetime format\"}");
            return;
        }

        Integer capacity = null;
        if (capacityStr != null && !capacityStr.trim().isEmpty()) {
            try { capacity = Integer.parseInt(capacityStr); } catch (NumberFormatException ex) { capacity = null; }
        }

        Integer points = null;
        if (pointsStr != null && !pointsStr.trim().isEmpty()) {
            try { points = Integer.parseInt(pointsStr); } catch (NumberFormatException ex) { points = null; }
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO activity (title, description, dateTime, location, capacity, category, host, points, studentID, status, points_awarded) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, title);
                ps.setString(2, description);
                ps.setTimestamp(3, ts);
                ps.setString(4, location);
                if (capacity == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, capacity);
                ps.setString(6, category);
                ps.setString(7, host);
                if (points == null) ps.setNull(8, Types.INTEGER); else ps.setInt(8, points);
                ps.setString(9, studentID);
                ps.setString(10, "upcoming");
                ps.setBoolean(11, false);
                int inserted = ps.executeUpdate();
                if (inserted > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        int id = -1;
                        if (keys.next()) id = keys.getInt(1);
                        JSONObject out = new JSONObject();
                        out.put("success", true);
                        out.put("activityID", id == -1 ? JSONObject.NULL : id);
                        response.getWriter().write(out.toString());
                        return;
                    }
                }
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"Insert failed\"}");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}