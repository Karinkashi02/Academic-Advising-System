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
@WebServlet("/api/student/sessions/cancel")
public class CancelSessionServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        String sessionIdStr = request.getParameter("sessionID");
        String reason = request.getParameter("reason");

        if (sessionIdStr == null || sessionIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"sessionID required\"}");
            return;
        }

        int sessionID;
        try {
            sessionID = Integer.parseInt(sessionIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"invalid sessionID\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // verify ownership and current status
            String sel = "SELECT status, studentID FROM advising_session WHERE sessionID = ?";
            try (PreparedStatement selPs = conn.prepareStatement(sel)) {
                selPs.setInt(1, sessionID);
                try (ResultSet rs = selPs.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"error\":\"Session not found\"}");
                        return;
                    }
                    String owner = rs.getString("studentID");
                    if (!String.valueOf(owner).equals(String.valueOf(studentID))) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        response.getWriter().write("{\"error\":\"Not allowed to cancel this session\"}");
                        return;
                    }
                    String status = rs.getString("status");
                    if ("pending".equalsIgnoreCase(status)) {
                        // direct cancel
                        String upd = "UPDATE advising_session SET status = ?, cancelReason = ? WHERE sessionID = ?";
                        try (PreparedStatement up = conn.prepareStatement(upd)) {
                            up.setString(1, "cancelled");
                            up.setString(2, reason != null ? reason : "");
                            up.setInt(3, sessionID);
                            up.executeUpdate();
                            response.getWriter().write("{\"success\":true, \"message\":\"Session cancelled\"}");
                            return;
                        }
                    } else if ("confirmed".equalsIgnoreCase(status)) {
                        // set cancel request for advisor to confirm
                        String upd = "UPDATE advising_session SET status = ?, cancelReason = ? WHERE sessionID = ?";
                        try (PreparedStatement up = conn.prepareStatement(upd)) {
                            up.setString(1, "cancel_requested");
                            up.setString(2, reason != null ? reason : "");
                            up.setInt(3, sessionID);
                            up.executeUpdate();
                            response.getWriter().write("{\"success\":true, \"message\":\"Cancel request submitted; advisor will be notified\"}");
                            return;
                        }
                    } else {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        response.getWriter().write("{\"error\":\"Cannot cancel session with status: " + status + "\"}");
                        return;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}