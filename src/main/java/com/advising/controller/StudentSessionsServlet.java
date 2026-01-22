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
import java.sql.Timestamp;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Xander
 */
@WebServlet("/api/student/sessions")
public class StudentSessionsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // List sessions for logged-in student
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession httpSession = request.getSession(false);
        if (httpSession == null || httpSession.getAttribute("role") == null || !"student".equals(httpSession.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

        String studentID = String.valueOf(httpSession.getAttribute("userID"));
        if (studentID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"No user in session\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT s.sessionID, s.title, s.sessionDateTime, s.notes, s.status, s.advisorID, s.studentID, s.cancelReason, " +
                         "a.firstName AS advisorFirst, a.lastName AS advisorLast " +
                         "FROM advising_session s LEFT JOIN advisor a ON s.advisorID = a.advisorID " +
                         "WHERE s.studentID = ? ORDER BY s.sessionDateTime DESC";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentID);
                try (ResultSet rs = ps.executeQuery()) {
                    JSONArray arr = new JSONArray();
                    while (rs.next()) {
                        JSONObject o = new JSONObject();
                        o.put("sessionID", rs.getInt("sessionID"));
                        o.put("title", rs.getString("title"));
                        Timestamp ts = rs.getTimestamp("sessionDateTime");
                        o.put("sessionDateTime", ts != null ? ts.toString().replace(' ', 'T') : JSONObject.NULL);
                        o.put("notes", rs.getString("notes") != null ? rs.getString("notes") : "");
                        o.put("status", rs.getString("status") != null ? rs.getString("status") : "");
                        o.put("advisorID", rs.getObject("advisorID") == null ? JSONObject.NULL : rs.getInt("advisorID"));
                        String af = rs.getString("advisorFirst");
                        String al = rs.getString("advisorLast");
                        String advisorName = ((af == null ? "" : af) + " " + (al == null ? "" : al)).trim();
                        o.put("advisorName", advisorName);
                        o.put("studentID", rs.getString("studentID"));
                        o.put("cancelReason", rs.getString("cancelReason") != null ? rs.getString("cancelReason") : "");
                        arr.put(o);
                    }
                    JSONObject out = new JSONObject();
                    out.put("sessions", arr);
                    response.getWriter().write(out.toString());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Create a new advising session (student)
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession httpSession = request.getSession(false);
        if (httpSession == null || httpSession.getAttribute("role") == null || !"student".equals(httpSession.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

        String studentID = String.valueOf(httpSession.getAttribute("userID"));
        if (studentID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"No user in session\"}");
            return;
        }

        String title = request.getParameter("title");
        String sessionDateTimeRaw = request.getParameter("sessionDateTime");
        String advisorIDParam = request.getParameter("advisorID");
        String notes = request.getParameter("notes");

        if (title == null || title.trim().isEmpty() || sessionDateTimeRaw == null || sessionDateTimeRaw.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Missing required fields\"}");
            return;
        }

        Integer advisorID = null;
        if (advisorIDParam != null && !advisorIDParam.trim().isEmpty()) {
            try {
                advisorID = Integer.parseInt(advisorIDParam);
            } catch (NumberFormatException e) {
                advisorID = null;
            }
        }

        // Normalize sessionDateTime: accept "YYYY-MM-DDTHH:MM" or "YYYY-MM-DD HH:MM[:SS]"
        String normalized = sessionDateTimeRaw.replace('T', ' ');
        Timestamp ts;
        try {
            if (normalized.length() == 16) { // "yyyy-mm-dd hh:mm"
                normalized = normalized + ":00";
            }
            ts = Timestamp.valueOf(normalized);
        } catch (IllegalArgumentException ex) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"Invalid datetime format. Use YYYY-MM-DDTHH:MM or YYYY-MM-DD HH:MM\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO advising_session (title, sessionDateTime, notes, status, advisorID, studentID) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, title);
                ps.setTimestamp(2, ts);
                ps.setString(3, notes);
                ps.setString(4, "pending");
                if (advisorID == null) ps.setNull(5, java.sql.Types.INTEGER); else ps.setInt(5, advisorID);
                ps.setString(6, studentID);
                int inserted = ps.executeUpdate();
                if (inserted > 0) {
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        int newId = -1;
                        if (keys.next()) newId = keys.getInt(1);
                        JSONObject out = new JSONObject();
                        out.put("success", true);
                        out.put("sessionID", newId == -1 ? JSONObject.NULL : newId);
                        response.getWriter().write(out.toString());
                    }
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"error\":\"Insert failed\"}");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace(); // still log to server
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            // Return the SQL message in JSON for debugging (remove this in production)
            JSONObject err = new JSONObject();
            err.put("error", "Database error");
            err.put("message", e.getMessage());
            response.getWriter().write(err.toString());
        }
    }
}