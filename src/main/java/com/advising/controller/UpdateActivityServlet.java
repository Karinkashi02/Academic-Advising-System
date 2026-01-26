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
        if (session == null || session.getAttribute("role") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

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
        String pointsStr = request.getParameter("points");
        String host = request.getParameter("host");
        String status = request.getParameter("status");

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

        Integer points = null;
        if (pointsStr != null && !pointsStr.trim().isEmpty()) {
            try { points = Integer.parseInt(pointsStr); } catch (NumberFormatException ex) { points = null; }
        }

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // verify owner if needed (optional): allow only owner or admin to update
                String sel = "SELECT studentID, status, points, points_awarded FROM activity WHERE activityID = ?";
                String currentOwner = null;
                String oldStatus = null;
                int oldPoints = 0;
                boolean oldPointsAwarded = false;
                try (PreparedStatement ps = conn.prepareStatement(sel)) {
                    ps.setInt(1, activityID);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (!rs.next()) {
                            conn.rollback();
                            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                            response.getWriter().write("{\"error\":\"Activity not found\"}");
                            return;
                        }
                        currentOwner = rs.getString("studentID");
                        oldStatus = rs.getString("status");
                        oldPoints = rs.getObject("points") == null ? 0 : rs.getInt("points");
                        try { oldPointsAwarded = rs.getBoolean("points_awarded"); } catch (SQLException ex) { oldPointsAwarded = rs.getInt("points_awarded") != 0; }
                    }
                }

                // Build update for fields provided
                String upd = "UPDATE activity SET title = COALESCE(?, title), description = COALESCE(?, description), dateTime = COALESCE(?, dateTime), location = COALESCE(?, location), capacity = COALESCE(?, capacity), category = COALESCE(?, category), host = COALESCE(?, host), points = COALESCE(?, points), status = COALESCE(?, status) WHERE activityID = ?";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setString(1, title);
                    ps.setString(2, description);
                    if (ts == null) ps.setNull(3, Types.TIMESTAMP); else ps.setTimestamp(3, ts);
                    ps.setString(4, location);
                    if (capacity == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, capacity);
                    ps.setString(6, category);
                    ps.setString(7, host);
                    if (points == null) ps.setNull(8, Types.INTEGER); else ps.setInt(8, points);
                    ps.setString(9, status);
                    ps.setInt(10, activityID);
                    ps.executeUpdate();
                }

                // If transitioning to completed (oldStatus != completed, new status = completed)
                if (status != null && "completed".equalsIgnoreCase(status) && (oldStatus == null || !"completed".equalsIgnoreCase(oldStatus))) {
                    int awardPoints = (points != null) ? points : oldPoints;
                    if (awardPoints > 0 && !oldPointsAwarded) {
                        // award points to participants
                        String selParticipants = "SELECT studentID FROM activity_registration WHERE activityID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(selParticipants)) {
                            ps.setInt(1, activityID);
                            try (ResultSet rs = ps.executeQuery()) {
                                String updStudent = "UPDATE student SET co_curricular_points = COALESCE(co_curricular_points,0) + ? WHERE studentID = ?";
                                try (PreparedStatement ups = conn.prepareStatement(updStudent)) {
                                    while (rs.next()) {
                                        String studentID = rs.getString("studentID");
                                        ups.setInt(1, awardPoints);
                                        ups.setString(2, studentID);
                                        ups.addBatch();
                                    }
                                    ups.executeBatch();
                                }
                            }
                        }
                        // mark points_awarded = true
                        String mark = "UPDATE activity SET points_awarded = TRUE WHERE activityID = ?";
                        try (PreparedStatement ps2 = conn.prepareStatement(mark)) {
                            ps2.setInt(1, activityID);
                            ps2.executeUpdate();
                        }
                        // mark per-registration awarded = true (requires activity_registration.awarded boolean column)
                        try (PreparedStatement ps3 = conn.prepareStatement("UPDATE activity_registration SET awarded = TRUE WHERE activityID = ?")) {
                            ps3.setInt(1, activityID);
                            ps3.executeUpdate();
                        } catch (SQLException ex) {
                            // if the awarded column doesn't exist, we ignore (but you should add the column)
                            System.err.println("Warning: couldn't set activity_registration.awarded (column missing?) " + ex.getMessage());
                        }
                    }
                }

                conn.commit();
                JSONObject out = new JSONObject();
                out.put("success", true);
                response.getWriter().write(out.toString());
            } catch (SQLException e) {
                conn.rollback();
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.getWriter().write("{\"error\":\"Database error\"}");
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database connection error\"}");
        }
    }
}