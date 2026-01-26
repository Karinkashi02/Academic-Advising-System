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
 *
 * @author Xander
 */
@WebServlet("/api/advisor/sessions")
public class AdvisorSessionsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"advisor".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated as advisor\"}");
            return;
        }

        String advisorID = String.valueOf(session.getAttribute("userID"));
        if (advisorID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"No user in session\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT s.sessionID, s.title, s.sessionDateTime, s.notes, s.status, s.advisorID, s.studentID, s.cancelReason, st.firstName, st.lastName, s.sessionType " +
                         "FROM advising_session s LEFT JOIN student st ON s.studentID = st.studentID " +
                         "WHERE s.advisorID = ? ORDER BY s.sessionDateTime DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, advisorID);
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
                        o.put("sessionType", rs.getString("sessionType") != null ? rs.getString("sessionType") : "");
                        String fname = rs.getString("firstName");
                        String lname = rs.getString("lastName");
                        String studentName = ((fname == null ? "" : fname) + " " + (lname == null ? "" : lname)).trim();
                        o.put("studentID", rs.getString("studentID"));
                        o.put("studentName", studentName.length() > 0 ? studentName : JSONObject.NULL);
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
}