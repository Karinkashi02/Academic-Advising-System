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
import java.util.Calendar;
import org.json.JSONArray;
import org.json.JSONObject;


/**
 *
 * @author Xander
 */
 @WebServlet("/api/advisor/me")
 public class AdvisorDataServlet extends HttpServlet {
     @Override
     protected void doGet(HttpServletRequest request, HttpServletResponse response)
             throws ServletException, IOException {
         response.setContentType("application/json");
         response.setCharacterEncoding("UTF-8");

         HttpSession session = request.getSession(false);
         if (session == null || session.getAttribute("role") == null ||
             !"advisor".equals(session.getAttribute("role"))) {
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
             JSONObject out = new JSONObject();

             // advisor info
             String advSql = "SELECT advisorID, firstName, lastName, email, department, expertise, officeHours, officeLoc, phoneNum, numSTD, maxSTD FROM advisor WHERE advisorID = ?";
             try (PreparedStatement aps = conn.prepareStatement(advSql)) {
                 aps.setString(1, advisorID);
                 try (ResultSet rs = aps.executeQuery()) {
                     if (rs.next()) {
                         JSONObject adv = new JSONObject();
                         adv.put("advisorID", rs.getInt("advisorID"));
                         adv.put("firstName", rs.getString("firstName"));
                         adv.put("lastName", rs.getString("lastName"));
                         adv.put("email", rs.getString("email"));
                         adv.put("department", rs.getString("department"));
                         adv.put("expertise", rs.getString("expertise"));
                         adv.put("officeHours", rs.getString("officeHours"));
                         adv.put("officeLoc", rs.getString("officeLoc"));
                         adv.put("phoneNum", rs.getString("phoneNum"));
                         adv.put("numSTD", rs.getObject("numSTD") == null ? JSONObject.NULL : rs.getInt("numSTD"));
                         adv.put("maxSTD", rs.getObject("maxSTD") == null ? JSONObject.NULL : rs.getInt("maxSTD"));
                         out.put("advisor", adv);
                     }
                 }
             }

             // total students under this advisor
             String totStdSql = "SELECT COUNT(*) AS cnt FROM student WHERE advisorID = ?";
             try (PreparedStatement ps = conn.prepareStatement(totStdSql)) {
                 ps.setString(1, advisorID);
                 try (ResultSet rs = ps.executeQuery()) {
                     if (rs.next()) out.put("totalStudents", rs.getInt("cnt"));
                     else out.put("totalStudents", 0);
                 }
             }

             // today's sessions count (start of today -> start of next day) -- only confirmed
             Calendar cal = Calendar.getInstance();
             cal.set(Calendar.HOUR_OF_DAY, 0); cal.set(Calendar.MINUTE, 0); cal.set(Calendar.SECOND, 0); cal.set(Calendar.MILLISECOND, 0);
             Timestamp startOfDay = new Timestamp(cal.getTimeInMillis());
             cal.add(Calendar.DAY_OF_MONTH, 1);
             Timestamp startOfNextDay = new Timestamp(cal.getTimeInMillis());

             String todaySql = "SELECT COUNT(*) AS cnt FROM advising_session WHERE advisorID = ? AND sessionDateTime >= ? AND sessionDateTime < ? AND COALESCE(status,'') = 'confirmed'";
             try (PreparedStatement ps = conn.prepareStatement(todaySql)) {
                 ps.setString(1, advisorID);
                 ps.setTimestamp(2, startOfDay);
                 ps.setTimestamp(3, startOfNextDay);
                 try (ResultSet rs = ps.executeQuery()) {
                     if (rs.next()) out.put("todaysSessions", rs.getInt("cnt"));
                     else out.put("todaysSessions", 0);
                 }
             }

             // upcomingSessions (next 30 days) -- only confirmed
             cal = Calendar.getInstance();
             Timestamp now = new Timestamp(cal.getTimeInMillis());
             cal.add(Calendar.DAY_OF_MONTH, 30);
             Timestamp in30 = new Timestamp(cal.getTimeInMillis());
             String upcomingSql = "SELECT COUNT(*) AS cnt FROM advising_session WHERE advisorID = ? AND sessionDateTime >= ? AND sessionDateTime <= ? AND COALESCE(status,'') = 'confirmed'";
             try (PreparedStatement ps = conn.prepareStatement(upcomingSql)) {
                 ps.setString(1, advisorID);
                 ps.setTimestamp(2, now);
                 ps.setTimestamp(3, in30);
                 try (ResultSet rs = ps.executeQuery()) {
                     if (rs.next()) out.put("upcomingSessions", rs.getInt("cnt")); else out.put("upcomingSessions", 0);
                 }
             }

             // sessions this year excluding cancelled/denied
             Calendar yearStart = Calendar.getInstance();
             yearStart.set(Calendar.MONTH, Calendar.JANUARY);
             yearStart.set(Calendar.DAY_OF_MONTH, 1);
             yearStart.set(Calendar.HOUR_OF_DAY, 0); yearStart.set(Calendar.MINUTE, 0); yearStart.set(Calendar.SECOND, 0); yearStart.set(Calendar.MILLISECOND, 0);
             Timestamp startOfYear = new Timestamp(yearStart.getTimeInMillis());
             Calendar nextYear = (Calendar) yearStart.clone();
             nextYear.add(Calendar.YEAR, 1);
             Timestamp startOfNextYear = new Timestamp(nextYear.getTimeInMillis());
             String sessionsYearSql = "SELECT COUNT(*) AS cnt FROM advising_session WHERE advisorID = ? AND sessionDateTime >= ? AND sessionDateTime < ? AND COALESCE(status,'') NOT IN ('cancelled','denied')";
             try (PreparedStatement ps = conn.prepareStatement(sessionsYearSql)) {
                 ps.setString(1, advisorID);
                 ps.setTimestamp(2, startOfYear);
                 ps.setTimestamp(3, startOfNextYear);
                 try (ResultSet rs = ps.executeQuery()) {
                     if (rs.next()) out.put("sessionsThisYear", rs.getInt("cnt")); else out.put("sessionsThisYear", 0);
                 }
             }

             // average advisee cgpa
             String avgCgpaSql = "SELECT AVG(cgpa) AS avgc FROM student WHERE advisorID = ? AND cgpa IS NOT NULL";
             try (PreparedStatement ps = conn.prepareStatement(avgCgpaSql)) {
                 ps.setString(1, advisorID);
                 try (ResultSet rs = ps.executeQuery()) {
                     if (rs.next()) {
                         double avg = rs.getDouble("avgc");
                         if (rs.wasNull()) out.put("averageAdviseeCgpa", JSONObject.NULL);
                         else out.put("averageAdviseeCgpa", Math.round(avg * 100.0) / 100.0);
                     } else out.put("averageAdviseeCgpa", JSONObject.NULL);
                 }
             }

             // graduatingSoon: heuristics -> yearOfStudy >= 4 OR creditscompleted >= 80 (adjust per your curriculum)
             String gradSql = "SELECT COUNT(*) AS cnt FROM student WHERE advisorID = ? AND (yearOfStudy >= 4 OR creditscompleted >= 80)";
             try (PreparedStatement ps = conn.prepareStatement(gradSql)) {
                 ps.setString(1, advisorID);
                 try (ResultSet rs = ps.executeQuery()) {
                     if (rs.next()) out.put("graduatingSoon", rs.getInt("cnt")); else out.put("graduatingSoon", 0);
                 }
             }

             // recent sessions list (most recent 6) -> only past sessions that have been confirmed or completed
             String recentSql = "SELECT s.sessionID, s.title, s.sessionDateTime, s.status, s.studentID, st.firstName AS sFirst, st.lastName AS sLast, s.cancelReason " +
                                "FROM advising_session s LEFT JOIN student st ON s.studentID = st.studentID " +
                                "WHERE s.advisorID = ? AND s.sessionDateTime <= ? AND COALESCE(s.status,'') IN ('confirmed','completed') ORDER BY s.sessionDateTime DESC FETCH FIRST 6 ROWS ONLY";
             try (PreparedStatement ps = conn.prepareStatement(recentSql)) {
                 ps.setString(1, advisorID);
                 ps.setTimestamp(2, now);
                 try (ResultSet rs = ps.executeQuery()) {
                     JSONArray arr = new JSONArray();
                     while (rs.next()) {
                         JSONObject o = new JSONObject();
                         o.put("sessionID", rs.getInt("sessionID"));
                         o.put("title", rs.getString("title"));
                         Timestamp ts = rs.getTimestamp("sessionDateTime");
                         o.put("sessionDateTime", ts != null ? ts.toString().replace(' ', 'T') : JSONObject.NULL);
                         o.put("status", rs.getString("status"));
                         String sFirst = rs.getString("sFirst");
                         String sLast = rs.getString("sLast");
                         String studentName = ((sFirst == null ? "" : sFirst) + " " + (sLast == null ? "" : sLast)).trim();
                         o.put("studentID", rs.getString("studentID"));
                         o.put("studentName", studentName.length() > 0 ? studentName : JSONObject.NULL);
                         o.put("cancelReason", rs.getString("cancelReason") != null ? rs.getString("cancelReason") : "");
                         arr.put(o);
                     }
                     out.put("recentSessions", arr);
                 }
             }

             response.getWriter().write(out.toString());
         } catch (SQLException e) {
             e.printStackTrace();
             response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
             response.getWriter().write("{\"error\":\"Database error\"}");
         }
     }
 }