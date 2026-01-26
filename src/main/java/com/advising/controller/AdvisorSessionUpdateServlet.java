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
        String reason = request.getParameter("reason");

        if (sessionIdStr == null || sessionIdStr.trim().isEmpty() || action == null || action.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"sessionID and action required\"}");
            return;
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

            if ("accept".equals(action)) {
                String upd = "UPDATE advising_session SET status = ? WHERE sessionID = ?";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setString(1, "confirmed");
                    ps.setInt(2, sessionID);
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
                String upd = "UPDATE advising_session SET status = ?, cancelReason = ? WHERE sessionID = ?";
                try (PreparedStatement ps = conn.prepareStatement(upd)) {
                    ps.setString(1, "denied");
                    ps.setString(2, reason != null ? reason : "");
                    ps.setInt(3, sessionID);
                    int updated = ps.executeUpdate();
                    if (updated > 0) {
                        response.getWriter().write("{\"success\":true, \"message\":\"Session denied\"}");
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