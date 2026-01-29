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
            // Get all sessions created by this advisor AND pending sessions requested to this advisor
            String sessionsSql = "SELECT s.sessionID, s.title, s.sessionDateTime, s.notes, s.status, s.advisorID, s.cancelReason, s.sessionType, s.meetLink, s.location " +
                                 "FROM advising_session s " +
                                 "WHERE s.advisorID = ? OR (s.status = 'pending' AND s.advisorID = ?) " +
                                 "ORDER BY s.sessionDateTime DESC";
            
            JSONArray arr = new JSONArray();
            try (PreparedStatement ps = conn.prepareStatement(sessionsSql)) {
                ps.setString(1, advisorID);
                ps.setString(2, advisorID);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        int sessionID = rs.getInt("sessionID");
                        JSONObject o = new JSONObject();
                        o.put("sessionID", sessionID);
                        o.put("title", rs.getString("title"));
                        Timestamp ts = rs.getTimestamp("sessionDateTime");
                        o.put("sessionDateTime", ts != null ? ts.toString().replace(' ', 'T') : JSONObject.NULL);
                        o.put("notes", rs.getString("notes") != null ? rs.getString("notes") : "");
                        o.put("status", rs.getString("status") != null ? rs.getString("status") : "");
                        o.put("sessionType", rs.getString("sessionType") != null ? rs.getString("sessionType") : "");
                        o.put("meetlink", rs.getString("meetLink") != null ? rs.getString("meetLink") : "");
                        o.put("location", rs.getString("location") != null ? rs.getString("location") : "");
                        o.put("cancelReason", rs.getString("cancelReason") != null ? rs.getString("cancelReason") : "");
                        
                        // Get all students for this session from the junction table
                        String studentsSql = "SELECT st.studentID, st.firstName, st.lastName " +
                                           "FROM session_participant sp " +
                                           "JOIN student st ON sp.studentID = st.studentID " +
                                           "WHERE sp.sessionID = ? " +
                                           "ORDER BY st.firstName, st.lastName";
                        JSONArray students = new JSONArray();
                        try (PreparedStatement studentsPs = conn.prepareStatement(studentsSql)) {
                            studentsPs.setInt(1, sessionID);
                            try (ResultSet studentRs = studentsPs.executeQuery()) {
                                while (studentRs.next()) {
                                    JSONObject student = new JSONObject();
                                    student.put("studentID", studentRs.getString("studentID"));
                                    String fname = studentRs.getString("firstName");
                                    String lname = studentRs.getString("lastName");
                                    String studentName = ((fname == null ? "" : fname) + " " + (lname == null ? "" : lname)).trim();
                                    student.put("studentName", studentName.length() > 0 ? studentName : "Unknown Student");
                                    students.put(student);
                                }
                            }
                        }
                        o.put("students", students);
                        
                        // For backward compatibility, also include first student as main student
                        if (students.length() > 0) {
                            o.put("studentID", students.getJSONObject(0).getString("studentID"));
                            o.put("studentName", students.getJSONObject(0).getString("studentName"));
                        }
                        arr.put(o);
                    }
                }
            }
            JSONObject out = new JSONObject();
            out.put("sessions", arr);
            response.getWriter().write(out.toString());
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}