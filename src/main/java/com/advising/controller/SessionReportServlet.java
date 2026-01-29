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
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet to provide session analytics data for reports
 * @author Xander
 */
@WebServlet("/api/advisor/sessions-report")
public class SessionReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        // Temporary: Allow requests without session for testing
        String advisorID = "1"; // Default test advisor ID
        if (session != null && session.getAttribute("userID") != null) {
            advisorID = String.valueOf(session.getAttribute("userID"));
        }

        String reportType = request.getParameter("type");

        if (reportType == null || reportType.isEmpty()) {
            reportType = "pending";
        }

        try (Connection conn = DBConnection.getConnection()) {
            JSONObject result = new JSONObject();

            switch (reportType) {
                case "pending":
                    result = getPendingSessions(conn, advisorID);
                    break;
                case "all":
                    result = getAllSessions(conn, advisorID);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.put("error", "Invalid report type");
            }

            response.getWriter().write(result.toString());

        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", "Database error: " + e.getMessage());
            response.getWriter().write(error.toString());
        }
    }

    private JSONObject getPendingSessions(Connection conn, String advisorID) throws SQLException {
        JSONObject result = new JSONObject();
        JSONArray sessions = new JSONArray();

        String sql = "SELECT s.sessionID, s.title, s.sessionDateTime, s.status, s.sessionType, s.studentID " +
                   "FROM advising_session s " +
                   "WHERE s.advisorID = ? AND (s.status = 'Pending' OR s.status = 'confirmed') " +
                   "AND s.sessionDateTime > CURRENT_TIMESTAMP " +
                   "ORDER BY s.sessionDateTime ASC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, advisorID);

            try (ResultSet rs = ps.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    count++;
                    JSONObject sessionObj = new JSONObject();
                    sessionObj.put("no", count);
                    
                    sessionObj.put("sessionID", rs.getInt("sessionID"));
                    sessionObj.put("title", rs.getString("title"));
                    sessionObj.put("type", rs.getString("sessionType"));

                    Timestamp ts = rs.getTimestamp("sessionDateTime");
                    if (ts != null) {
                        sessionObj.put("scheduled", formatSessionDateTime(ts));
                    } else {
                        sessionObj.put("scheduled", "Not scheduled");
                    }

                    sessionObj.put("status", rs.getString("status"));

                    sessions.put(sessionObj);
                }
            }
        }

        result.put("sessions", sessions);
        result.put("total", sessions.length());
        return result;
    }


    private JSONObject getAllSessions(Connection conn, String advisorID) throws SQLException {
        JSONObject result = new JSONObject();
        JSONArray sessions = new JSONArray();

        String sql = "SELECT s.sessionID, s.title, s.sessionDateTime, s.status, s.sessionType, " +
                   "st.studentID, st.firstName, st.lastName " +
                   "FROM advising_session s " +
                   "LEFT JOIN student st ON s.studentID = st.studentID " +
                   "WHERE s.advisorID = ? " +
                   "ORDER BY s.sessionDateTime DESC";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, advisorID);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    JSONObject sessionObj = new JSONObject();
                    sessionObj.put("sessionID", rs.getInt("sessionID"));
                    sessionObj.put("title", rs.getString("title"));

                    String fname = rs.getString("firstName");
                    String lname = rs.getString("lastName");
                    String studentName = ((fname == null ? "" : fname) + " " + (lname == null ? "" : lname)).trim();
                    sessionObj.put("student", studentName.isEmpty() ? "Unknown" : studentName);
                    sessionObj.put("type", rs.getString("sessionType"));

                    Timestamp ts = rs.getTimestamp("sessionDateTime");
                    if (ts != null) {
                        sessionObj.put("scheduled", formatSessionDateTime(ts));
                    } else {
                        sessionObj.put("scheduled", "Not scheduled");
                    }

                    sessionObj.put("status", rs.getString("status"));

                    sessions.put(sessionObj);
                }
            }
        }

        result.put("sessions", sessions);
        result.put("total", sessions.length());
        return result;
    }

    private String formatSessionDateTime(Timestamp ts) {
        if (ts == null) return "";

        String dateStr = ts.toString();
        String date = dateStr.substring(0, 10);
        String time = dateStr.substring(11, 16);

        // Simple date formatting - could be enhanced
        String[] parts = date.split("-");
        int month = Integer.parseInt(parts[1]);
        int day = Integer.parseInt(parts[2]);

        String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                            "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

        return monthNames[month - 1] + " " + day + ", " + time;
    }
}
