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
        if (session == null || session.getAttribute("role") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

        String role = (String) session.getAttribute("role");
        String studentID = null;
        
        // If advisor, get studentID from request parameter; if student, get from session
        if ("advisor".equals(role)) {
            studentID = request.getParameter("studentID");
            if (studentID == null || studentID.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"studentID parameter required for advisors\"}");
                return;
            }
        } else if ("student".equals(role)) {
            studentID = String.valueOf(session.getAttribute("userID"));
        } else {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"Invalid role\"}");
            return;
        }

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

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || !"student".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated as student\"}");
            return;
        }

        String studentID = String.valueOf(session.getAttribute("userID"));

        try {
            // Parse JSON body
            StringBuilder sb = new StringBuilder();
            String line;
            try (java.io.BufferedReader reader = request.getReader()) {
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
            }
            JSONObject json = new JSONObject(sb.toString());

            String courseID = json.optString("courseID", "").trim();
            String courseName = json.optString("courseName", "").trim();
            int creditHour = json.optInt("creditHour", 0);
            int semester = json.optInt("semester", 0);
            String program = json.optString("program", "").trim();
            String status = json.optString("status", "ongoing").trim();
            String grade = json.optString("grade", null);
            if (grade != null && grade.trim().isEmpty()) {
                grade = null;
            }

            if (courseID.isEmpty() || courseName.isEmpty() || creditHour <= 0 || semester <= 0) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"error\":\"Missing required fields\"}");
                return;
            }

            try (Connection conn = DBConnection.getConnection()) {
                // First, ensure the course exists in the course table
                String checkCourseSql = "SELECT courseID FROM course WHERE courseID = ?";
                boolean courseExists = false;
                try (PreparedStatement checkPs = conn.prepareStatement(checkCourseSql)) {
                    checkPs.setString(1, courseID);
                    try (ResultSet rs = checkPs.executeQuery()) {
                        courseExists = rs.next();
                    }
                }

                // If course doesn't exist, insert it
                if (!courseExists) {
                    String insertCourseSql = "INSERT INTO course (courseID, name, creditHour, program) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement insertPs = conn.prepareStatement(insertCourseSql)) {
                        insertPs.setString(1, courseID);
                        insertPs.setString(2, courseName);
                        insertPs.setInt(3, creditHour);
                        insertPs.setString(4, program.isEmpty() ? "General" : program);
                        insertPs.executeUpdate();
                    }
                }

                // Now insert into student_progress
                String insertProgressSql = "INSERT INTO student_progress (studentID, courseID, grade, status, semester) VALUES (?, ?, ?, ?, ?)";
                try (PreparedStatement progressPs = conn.prepareStatement(insertProgressSql)) {
                    progressPs.setString(1, studentID);
                    progressPs.setString(2, courseID);
                    progressPs.setString(3, grade);
                    progressPs.setString(4, status);
                    progressPs.setInt(5, semester);
                    progressPs.executeUpdate();
                }

                // Return success
                JSONObject success = new JSONObject();
                success.put("success", true);
                success.put("message", "Course added successfully");
                response.getWriter().write(success.toString());

            } catch (SQLException e) {
                e.printStackTrace();
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                JSONObject err = new JSONObject();
                err.put("error", "Database error: " + e.getMessage());
                response.getWriter().write(err.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject err = new JSONObject();
            err.put("error", "Server error: " + e.getMessage());
            response.getWriter().write(err.toString());
        }
    }
}