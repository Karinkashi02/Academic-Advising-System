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
import java.time.*;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Xander
 */
@WebServlet("/api/advisor/dashboard")
public class AdvisorDashboardServlet extends HttpServlet {

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
            response.getWriter().write("{\"error\":\"No advisor in session\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            JSONObject out = new JSONObject();

            // total advisees
            String sqlTotal = "SELECT COUNT(*) AS cnt FROM student WHERE advisorID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlTotal)) {
                ps.setString(1, advisorID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out.put("totalAdvisees", rs.getInt("cnt"));
                    else out.put("totalAdvisees", 0);
                }
            }

            // upcoming sessions (future & confirmed only)
            String sqlUpcoming = "SELECT COUNT(*) AS cnt FROM advising_session WHERE advisorID = ? AND sessionDateTime > ? AND COALESCE(status,'') = 'confirmed'";
            try (PreparedStatement ps = conn.prepareStatement(sqlUpcoming)) {
                ps.setString(1, advisorID);
                ps.setTimestamp(2, Timestamp.from(Instant.now()));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out.put("upcomingSessions", rs.getInt("cnt"));
                    else out.put("upcomingSessions", 0);
                }
            }

            // sessions this month (exclude cancelled/denied)
            LocalDate now = LocalDate.now();
            LocalDate firstOfMonth = now.withDayOfMonth(1);
            LocalDate firstOfNextMonth = firstOfMonth.plusMonths(1);
            Timestamp tsStart = Timestamp.valueOf(firstOfMonth.atStartOfDay());
            Timestamp tsEnd = Timestamp.valueOf(firstOfNextMonth.atStartOfDay());

            String sqlMonth = "SELECT COUNT(*) AS cnt FROM advising_session WHERE advisorID = ? AND sessionDateTime >= ? AND sessionDateTime < ? AND COALESCE(status,'') NOT IN ('cancelled','denied')";
            try (PreparedStatement ps = conn.prepareStatement(sqlMonth)) {
                ps.setString(1, advisorID);
                ps.setTimestamp(2, tsStart);
                ps.setTimestamp(3, tsEnd);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) out.put("sessionsThisMonth", rs.getInt("cnt"));
                    else out.put("sessionsThisMonth", 0);
                }
            }

            // average CGPA of advisees (null-safe)
            String sqlAvg = "SELECT AVG(cgpa) AS avgcg FROM student WHERE advisorID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sqlAvg)) {
                ps.setString(1, advisorID);
                try (ResultSet rs = ps.executeQuery()) {
                    double avg = 0.0;
                    if (rs.next()) {
                        avg = rs.getDouble("avgcg");
                        if (rs.wasNull()) avg = 0.0;
                    }
                    // round to 2 decimals
                    avg = Math.round(avg * 100.0) / 100.0;
                    out.put("avgCgpa", avg);
                }
            }

            // recent sessions (latest 6) excluding cancelled/denied and only past confirmed/completed for "meetings"
            String sqlRecent = "SELECT s.sessionID, s.title, s.status, s.sessionDateTime, s.studentID, st.firstName, st.lastName, s.cancelReason " +
                               "FROM advising_session s LEFT JOIN student st ON s.studentID = st.studentID " +
                               "WHERE s.advisorID = ? AND s.sessionDateTime <= ? AND COALESCE(s.status,'') IN ('confirmed','completed') ORDER BY s.sessionDateTime DESC FETCH FIRST 6 ROWS ONLY";
            try (PreparedStatement ps = conn.prepareStatement(sqlRecent)) {
                ps.setString(1, advisorID);
                ps.setTimestamp(2, Timestamp.from(Instant.now()));
                try (ResultSet rs = ps.executeQuery()) {
                    JSONArray arr = new JSONArray();
                    int limit = 6;
                    while (rs.next() && limit-- > 0) {
                        JSONObject s = new JSONObject();
                        s.put("sessionID", rs.getInt("sessionID"));
                        s.put("title", rs.getString("title"));
                        Timestamp tst = rs.getTimestamp("sessionDateTime");
                        s.put("sessionDateTime", tst != null ? tst.toString().replace(' ', 'T') : JSONObject.NULL);
                        s.put("status", rs.getString("status") != null ? rs.getString("status") : "");
                        String stFirst = rs.getString("firstName");
                        String stLast = rs.getString("lastName");
                        String studentName = ((stFirst == null ? "" : stFirst) + " " + (stLast == null ? "" : stLast)).trim();
                        s.put("studentID", rs.getString("studentID"));
                        s.put("studentName", studentName.length() > 0 ? studentName : JSONObject.NULL);
                        s.put("cancelReason", rs.getString("cancelReason") != null ? rs.getString("cancelReason") : "");
                        arr.put(s);
                    }
                    out.put("recentSessions", arr);
                }
            }

            // advisees (top 10 by last name)
            String sqlAdvisees = "SELECT studentID, firstName, lastName, cgpa, creditscompleted FROM student WHERE advisorID = ? ORDER BY lastName FETCH FIRST 10 ROWS ONLY";
            try (PreparedStatement ps = conn.prepareStatement(sqlAdvisees)) {
                ps.setString(1, advisorID);
                try (ResultSet rs = ps.executeQuery()) {
                    JSONArray arr = new JSONArray();
                    while (rs.next()) {
                        JSONObject st = new JSONObject();
                        st.put("studentID", rs.getString("studentID"));
                        String fn = rs.getString("firstName");
                        String ln = rs.getString("lastName");
                        st.put("name", ((fn==null?"":fn) + " " + (ln==null?"":ln)).trim());
                        double cg = rs.getDouble("cgpa");
                        if (rs.wasNull()) st.put("cgpa", JSONObject.NULL); else st.put("cgpa", Math.round(cg*100.0)/100.0);
                        int credits = rs.getInt("creditscompleted");
                        if (rs.wasNull()) st.put("creditsCompleted", JSONObject.NULL); else st.put("creditsCompleted", credits);
                        arr.put(st);
                    }
                    out.put("advisees", arr);
                }
            }

            response.getWriter().write(out.toString());
            return;

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}