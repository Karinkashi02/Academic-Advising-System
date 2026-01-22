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
@WebServlet("/api/activities")
public class ActivitiesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        String currentStudent = null;
        if (session != null && session.getAttribute("role") != null && "student".equals(session.getAttribute("role"))) {
            currentStudent = String.valueOf(session.getAttribute("userID"));
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT a.activityID, a.title, a.description, a.dateTime, a.location, a.capacity, a.category, a.studentID AS ownerID, " +
                         "(SELECT COUNT(*) FROM activity_registration ar WHERE ar.activityID = a.activityID) AS participantCount, " +
                         "CASE WHEN ? IS NOT NULL AND EXISTS (SELECT 1 FROM activity_registration ar2 WHERE ar2.activityID = a.activityID AND ar2.studentID = ?) THEN 1 ELSE 0 END AS joined " +
                         "FROM activity a ORDER BY a.dateTime DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                // set both params to currentStudent (may be null)
                if (currentStudent != null) {
                    ps.setString(1, currentStudent);
                    ps.setString(2, currentStudent);
                } else {
                    ps.setNull(1, Types.VARCHAR);
                    ps.setNull(2, Types.VARCHAR);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    JSONArray arr = new JSONArray();
                    while (rs.next()) {
                        JSONObject o = new JSONObject();
                        o.put("activityID", rs.getInt("activityID"));
                        o.put("title", rs.getString("title"));
                        o.put("description", rs.getString("description") != null ? rs.getString("description") : "");
                        Timestamp ts = rs.getTimestamp("dateTime");
                        o.put("dateTime", ts != null ? ts.toString().replace(' ', 'T') : JSONObject.NULL);
                        o.put("location", rs.getString("location") != null ? rs.getString("location") : "");
                        o.put("capacity", rs.getObject("capacity") == null ? JSONObject.NULL : rs.getInt("capacity"));
                        o.put("category", rs.getString("category") != null ? rs.getString("category") : "");
                        o.put("ownerID", rs.getString("ownerID"));
                        o.put("participantCount", rs.getInt("participantCount"));
                        o.put("joined", rs.getInt("joined") == 1);
                        arr.put(o);
                    }
                    JSONObject out = new JSONObject();
                    out.put("activities", arr);
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