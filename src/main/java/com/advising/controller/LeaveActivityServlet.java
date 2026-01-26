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
@WebServlet("/api/activity/leave")
public class LeaveActivityServlet extends HttpServlet {
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

        String aid = request.getParameter("activityID");
        if (aid == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"activityID required\"}");
            return;
        }
        int activityID;
        try { activityID = Integer.parseInt(aid); } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"invalid activityID\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // check activity date/time and status
            String sel = "SELECT dateTime, status FROM activity WHERE activityID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sel)) {
                ps.setInt(1, activityID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"error\":\"Activity not found\"}");
                        return;
                    }
                    Timestamp ts = rs.getTimestamp("dateTime");
                    String status = rs.getString("status");
                    if (status != null && "completed".equalsIgnoreCase(status)) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.getWriter().write("{\"error\":\"Cannot leave a completed activity\"}");
                        return;
                    }
                    if (ts != null) {
                        long diff = ts.getTime() - System.currentTimeMillis();
                        long oneDay = 24L * 60L * 60L * 1000L;
                        if (diff <= 0) {
                            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                            response.getWriter().write("{\"error\":\"Cannot leave a past activity\"}");
                            return;
                        }
                        if (diff <= oneDay) {
                            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                            response.getWriter().write("{\"error\":\"Cannot leave an activity within 24 hours of start\"}");
                            return;
                        }
                    }
                }
            }

            // remove registration
            String del = "DELETE FROM activity_registration WHERE activityID = ? AND studentID = ?";
            try (PreparedStatement ps = conn.prepareStatement(del)) {
                ps.setInt(1, activityID);
                ps.setString(2, studentID);
                int affected = ps.executeUpdate();
                JSONObject out = new JSONObject();
                out.put("success", true);
                out.put("removed", affected > 0);
                response.getWriter().write(out.toString());
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}