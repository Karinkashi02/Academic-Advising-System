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
        if (session != null && "student".equals(session.getAttribute("role"))) {
            currentStudent = String.valueOf(session.getAttribute("userID"));
        }

        try (Connection conn = DBConnection.getConnection()) {
            // exclude activities that are archived
            // IMPORTANT:
            // - Completed activities (past) should only be returned to students who joined them.
            // - Other students (or anonymous) will not receive completed activities in the list.
            String sql = "SELECT a.activityID, a.title, a.description, a.dateTime, a.location, a.capacity, a.category, " +
                         "a.host, a.points, a.status, a.points_awarded, a.studentID AS ownerID, s.firstName AS ownerFirst, s.lastName AS ownerLast, " +
                         "(SELECT COUNT(*) FROM activity_registration ar WHERE ar.activityID = a.activityID) AS participantCount, " +
                         "CASE WHEN ? IS NOT NULL AND EXISTS (SELECT 1 FROM activity_registration ar2 WHERE ar2.activityID = a.activityID AND ar2.studentID = ?) THEN 1 ELSE 0 END AS joined " +
                         "FROM activity a LEFT JOIN student s ON a.studentID = s.studentID " +
                         "WHERE COALESCE(a.status, '') <> 'archived' " +
                         // allow completed activities only when current student is a registrant for that activity
                         "AND (COALESCE(a.status,'') <> 'completed' OR (? IS NOT NULL AND EXISTS (SELECT 1 FROM activity_registration ar3 WHERE ar3.activityID = a.activityID AND ar3.studentID = ?))) " +
                         "ORDER BY a.dateTime DESC";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                // parameter order:
                // 1,2 -> used for joined CASE WHEN
                // 3,4 -> used for WHERE allow completed only for registrants
                if (currentStudent != null) {
                    ps.setString(1, currentStudent);
                    ps.setString(2, currentStudent);
                    ps.setString(3, currentStudent);
                    ps.setString(4, currentStudent);
                } else {
                    ps.setNull(1, Types.VARCHAR);
                    ps.setNull(2, Types.VARCHAR);
                    ps.setNull(3, Types.VARCHAR);
                    ps.setNull(4, Types.VARCHAR);
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
                        o.put("host", rs.getString("host") != null ? rs.getString("host") : JSONObject.NULL);
                        o.put("points", rs.getObject("points") == null ? 0 : rs.getInt("points"));
                        o.put("status", rs.getString("status") != null ? rs.getString("status") : "");
                        o.put("points_awarded", rs.getBoolean("points_awarded"));
                        String ownerFirst = rs.getString("ownerFirst");
                        String ownerLast = rs.getString("ownerLast");
                        String ownerName = ((ownerFirst == null ? "" : ownerFirst) + " " + (ownerLast == null ? "" : ownerLast)).trim();
                        o.put("ownerID", rs.getString("ownerID"));
                        o.put("ownerName", ownerName.length() > 0 ? ownerName : JSONObject.NULL);
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