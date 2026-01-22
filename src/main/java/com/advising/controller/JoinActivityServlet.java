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
@WebServlet("/api/activity/join")
public class JoinActivityServlet extends HttpServlet {
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

        String activityIdStr = request.getParameter("activityID");
        if (activityIdStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"activityID required\"}");
            return;
        }
        int activityID;
        try { activityID = Integer.parseInt(activityIdStr); } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"invalid activityID\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // check capacity and current count
            String sel = "SELECT capacity FROM activity WHERE activityID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sel)) {
                ps.setInt(1, activityID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"error\":\"Activity not found\"}");
                        return;
                    }
                    Integer capacity = rs.getObject("capacity") == null ? null : rs.getInt("capacity");
                    // get current count
                    String cntSql = "SELECT COUNT(*) AS cnt FROM activity_registration WHERE activityID = ?";
                    try (PreparedStatement cps = conn.prepareStatement(cntSql)) {
                        cps.setInt(1, activityID);
                        try (ResultSet crs = cps.executeQuery()) {
                            crs.next();
                            int cnt = crs.getInt("cnt");
                            if (capacity != null && cnt >= capacity) {
                                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                                response.getWriter().write("{\"error\":\"Activity is full\"}");
                                return;
                            }
                        }
                    }
                }
            }

            // insert registration if not exists
            String ins = "INSERT INTO activity_registration (activityID, studentID) VALUES (?, ?)";
            try (PreparedStatement ips = conn.prepareStatement(ins)) {
                ips.setInt(1, activityID);
                ips.setString(2, studentID);
                try {
                    ips.executeUpdate();
                } catch (SQLException ex) {
                    // possible duplicate PK -> already joined
                    response.setStatus(HttpServletResponse.SC_CONFLICT);
                    response.getWriter().write("{\"error\":\"Already joined\"}");
                    return;
                }
            }

            JSONObject out = new JSONObject();
            out.put("success", true);
            response.getWriter().write(out.toString());
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}