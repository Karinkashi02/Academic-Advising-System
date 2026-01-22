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
@WebServlet("/api/activity/update")
public class UpdateActivityServlet extends HttpServlet {
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

        String idStr = request.getParameter("activityID");
        if (idStr == null) { response.setStatus(HttpServletResponse.SC_BAD_REQUEST); response.getWriter().write("{\"error\":\"activityID required\"}"); return; }
        int activityID;
        try { activityID = Integer.parseInt(idStr); } catch (NumberFormatException e) { response.setStatus(HttpServletResponse.SC_BAD_REQUEST); response.getWriter().write("{\"error\":\"invalid activityID\"}"); return; }

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String dateTimeRaw = request.getParameter("dateTime");
        String location = request.getParameter("location");
        String capacityStr = request.getParameter("capacity");
        String category = request.getParameter("category");

        Timestamp ts = null;
        if (dateTimeRaw != null && !dateTimeRaw.trim().isEmpty()) {
            String normalized = dateTimeRaw.replace('T', ' ');
            if (normalized.length() == 16) normalized = normalized + ":00";
            try { ts = Timestamp.valueOf(normalized); } catch (IllegalArgumentException ex) { ts = null; }
        }

        Integer capacity = null;
        if (capacityStr != null && !capacityStr.trim().isEmpty()) {
            try { capacity = Integer.parseInt(capacityStr); } catch (NumberFormatException ex) { capacity = null; }
        }

        try (Connection conn = DBConnection.getConnection()) {
            // verify owner
            String sel = "SELECT studentID FROM activity WHERE activityID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sel)) {
                ps.setInt(1, activityID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) { response.setStatus(HttpServletResponse.SC_NOT_FOUND); response.getWriter().write("{\"error\":\"Activity not found\"}"); return; }
                    String owner = rs.getString("studentID");
                    if (!String.valueOf(owner).equals(String.valueOf(studentID))) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        response.getWriter().write("{\"error\":\"Not allowed to update\"}");
                        return;
                    }
                }
            }

            String upd = "UPDATE activity SET title = ?, description = ?, dateTime = ?, location = ?, capacity = ?, category = ? WHERE activityID = ?";
            try (PreparedStatement ps = conn.prepareStatement(upd)) {
                ps.setString(1, title);
                ps.setString(2, description);
                if (ts == null) ps.setNull(3, Types.TIMESTAMP); else ps.setTimestamp(3, ts);
                ps.setString(4, location);
                if (capacity == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, capacity);
                ps.setString(6, category);
                ps.setInt(7, activityID);
                ps.executeUpdate();
                JSONObject out = new JSONObject();
                out.put("success", true);
                response.getWriter().write(out.toString());
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}