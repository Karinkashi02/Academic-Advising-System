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
