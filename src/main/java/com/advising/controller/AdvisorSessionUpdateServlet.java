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
@WebServlet("/api/advisor/session/update")
public class AdvisorSessionUpdateServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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
            response.getWriter().write("{\"error\":\"No advisor in session\"}");
            return;
        }

        String sessionIdStr = request.getParameter("sessionID");
        String action = request.getParameter("action");

        if (sessionIdStr == null || sessionIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"sessionID required\"}");
            return;
        }

        // Default action if not specified
        if (action == null || action.trim().isEmpty()) {
            action = "update";
        }

        int sessionID;
        try { sessionID = Integer.parseInt(sessionIdStr); } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"invalid sessionID\"}");
            return;
        }

        action = action.trim().toLowerCase();

        try (Connection conn = DBConnection.getConnection()) {
            // Verify session exists and owned by this advisor
            String sel = "SELECT advisorID, status FROM advising_session WHERE sessionID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sel)) {
                ps.setInt(1, sessionID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"error\":\"Session not found\"}");
                        return;
                    }
                    String owner = rs.getString("advisorID");
                    if (!String.valueOf(owner).equals(String.valueOf(advisorID))) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        response.getWriter().write("{\"error\":\"Not allowed to modify this session\"}");
                        return;
                    }
                }
            }

            // Handle different actions
            if ("update".equals(action)) {
                // Handle session editing with multiple students
                String title = request.getParameter("title");
                String sessionType = request.getParameter("sessionType");
                String sessionDateTime = request.getParameter("sessionDateTime");
                String meetLink = request.getParameter("meetLink");
                String location = request.getParameter("location");
                String notes = request.getParameter("notes");
                String studentsParam = request.getParameter("students");
                
                if (title == null || title.trim().isEmpty() || sessionType == null || sessionType.trim().isEmpty() || sessionDateTime == null || sessionDateTime.trim().isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    response.getWriter().write("{\"error\":\"title, sessionType, and sessionDateTime are required\"}");
                    return;
                }
                
                try {
                    // Normalize sessionDateTime: convert "YYYY-MM-DDTHH:MM:SS" to "YYYY-MM-DD HH:MM:SS"
                    String normalizedDateTime = sessionDateTime.trim().replace('T', ' ');
                    
                    // Update advising_session table
                    String upd = "UPDATE advising_session SET title = ?, sessionType = ?, sessionDateTime = ?, meetLink = ?, location = ?, notes = ? WHERE sessionID = ?";
                    try (PreparedStatement ps = conn.prepareStatement(upd)) {
                        ps.setString(1, title.trim());
                        ps.setString(2, sessionType.trim());
                        ps.setString(3, normalizedDateTime);
                        ps.setString(4, meetLink != null ? meetLink.trim() : null);
                        ps.setString(5, location != null ? location.trim() : null);
                        ps.setString(6, notes != null ? notes.trim() : "");
                        ps.setInt(7, sessionID);
                        ps.executeUpdate();
                    }
                    
                    // Update session_participant table with selected students
                    if (studentsParam != null && !studentsParam.trim().isEmpty()) {
                        String[] studentIds = studentsParam.split(",");
                        
                        // Delete old participants
                        String delSql = "DELETE FROM session_participant WHERE sessionID = ?";
                        try (PreparedStatement ps = conn.prepareStatement(delSql)) {
                            ps.setInt(1, sessionID);
                            ps.executeUpdate();
                        }
                        
                        // Insert new participants
                        String insSql = "INSERT INTO session_participant (sessionID, studentID) VALUES (?, ?)";
                        try (PreparedStatement ps = conn.prepareStatement(insSql)) {
                            for (String studentId : studentIds) {
                                String trimmedId = studentId.trim();
                                if (!trimmedId.isEmpty()) {
                                    ps.setInt(1, sessionID);
                                    ps.setString(2, trimmedId);
                                    ps.addBatch();
                                }
                            }
                            ps.executeBatch();
                        }
                    }
                    
                    response.getWriter().write("{\"success\":true, \"message\":\"Session updated successfully\"}");
                } catch (SQLException e) {
                    e.printStackTrace();
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"error\":\"Database error: " + e.getMessage() + "\"}");
                }
            } else if ("accept".equals(action)) {
                String meetLink = request.getParameter("meetLink");
                String upd = "UPDATE advising_session SET status = ?, meetLink = ? WHERE sessionID = ?";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setString(1, "confirmed");
                    ps.setString(2, meetLink != null ? meetLink.trim() : null);
                    ps.setInt(3, sessionID);
                    int updated = ps.executeUpdate();
                    if (updated > 0) {
                        response.getWriter().write("{\"success\":true, \"message\":\"Session confirmed\"}");
                        return;
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        response.getWriter().write("{\"error\":\"Update failed\"}");
                        return;
                    }
                }
            } else if ("deny".equals(action) || "reject".equals(action)) {
                String reason = request.getParameter("reason");
                String upd = "UPDATE advising_session SET status = ?, cancelReason = ? WHERE sessionID = ?";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setString(1, "cancelled");
                    ps.setString(2, reason != null ? reason : "");
                    ps.setInt(3, sessionID);
                    int updated = ps.executeUpdate();
                    if (updated > 0) {
                        response.getWriter().write("{\"success\":true, \"message\":\"Session cancelled\"}");
                        return;
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        response.getWriter().write("{\"error\":\"Update failed\"}");
                        return;
                    }
                }
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Unknown action\"}");
                return;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}