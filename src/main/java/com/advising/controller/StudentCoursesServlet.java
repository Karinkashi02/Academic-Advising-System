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
@WebServlet("/api/student/courses")
public class StudentCoursesServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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
        if (studentID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"No user in session\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT sp.progressID, sp.grade, sp.status, sp.semester, " +
                         "c.program AS program, sp.courseID, " +
                         "c.name AS courseName, c.creditHour " +
                         "FROM student_progress sp " +
                         "JOIN course c ON sp.courseID = c.courseID " +
                         "WHERE sp.studentID = ? " +
                         "ORDER BY sp.semester, sp.progressID";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentID);
                try (ResultSet rs = ps.executeQuery()) {
                    JSONArray arr = new JSONArray();
                    while (rs.next()) {
                        JSONObject o = new JSONObject();
                        o.put("progressID", rs.getInt("progressID"));
                        o.put("courseID", rs.getString("courseID"));
                        o.put("courseName", rs.getString("courseName"));
                        o.put("creditHour", rs.getInt("creditHour"));
                        String grade = rs.getString("grade");
                        o.put("grade", grade != null ? grade : JSONObject.NULL);
                        o.put("status", rs.getString("status"));
                        o.put("semester", rs.getInt("semester"));
                        o.put("program", rs.getString("program"));
                        arr.put(o);
                    }
                    JSONObject out = new JSONObject();
                    out.put("courses", arr);
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