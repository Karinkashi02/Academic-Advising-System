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
 * Servlet to provide student performance data for reports
 * @author Xander
 */
@WebServlet("/api/advisor/performance")
public class StudentPerformanceReportServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        // Temporary: Allow requests without session for testing
        String advisorID = "1"; // Default test advisor ID
        if (session != null && session.getAttribute("userID") != null) {
            advisorID = String.valueOf(session.getAttribute("userID"));
        }

        String major = request.getParameter("major");
        String status = request.getParameter("status");

        try (Connection conn = DBConnection.getConnection()) {
            JSONArray students = getStudentPerformance(conn, advisorID, major, status);
            JSONObject result = new JSONObject();
            result.put("students", students);
            response.getWriter().write(result.toString());

        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", "Database error: " + e.getMessage());
            response.getWriter().write(error.toString());
        }
    }

    private JSONArray getStudentPerformance(Connection conn, String advisorID, String major, String statusFilter) throws SQLException {
        JSONArray students = new JSONArray();

        StringBuilder sql = new StringBuilder(
            "SELECT s.studentID, s.firstName, s.lastName, s.program, s.yearOfStudy, s.cgpa " +
            "FROM student s " +
            "WHERE s.advisorID = ?"
        );

        // Apply filters
        if (major != null && !major.isEmpty()) {
            sql.append(" AND s.program = ?");
        }

        sql.append(" ORDER BY s.cgpa DESC, s.firstName ASC");

        try (PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setString(paramIndex++, advisorID);

            if (major != null && !major.isEmpty()) {
                ps.setString(paramIndex++, major);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    double cgpa = rs.getDouble("cgpa");
                    String studentStatus = getAcademicStatus(cgpa);

                    // Apply status filter if specified
                    if (statusFilter != null && !statusFilter.isEmpty()) {
                        if (!studentStatus.equals(statusFilter)) {
                            continue;
                        }
                    }

                    JSONObject student = new JSONObject();
                    student.put("id", rs.getString("studentID"));
                    String fname = rs.getString("firstName");
                    String lname = rs.getString("lastName");
                    String studentName = ((fname == null ? "" : fname) + " " + (lname == null ? "" : lname)).trim();
                    student.put("name", studentName.isEmpty() ? "Unknown" : studentName);
                    student.put("major", rs.getString("program"));
                    student.put("year", getYearLabel(rs.getInt("yearOfStudy")));
                    student.put("cgpa", String.format("%.2f", cgpa));
                    student.put("status", studentStatus);
                    student.put("lastSession", getLastSessionDate(conn, rs.getString("studentID")));
                    student.put("nextDue", getNextSessionDueDate(conn, rs.getString("studentID")));

                    students.put(student);
                }
            }
        }

        return students;
    }

    private String getAcademicStatus(double cgpa) {
        if (cgpa >= 3.5) {
            return "Dean's List";
        } else if (cgpa >= 2.0) {
            return "Pass";
        } else if (cgpa >= 1.0) {
            return "Probation";
        } else {
            return "At Risk";
        }
    }

    private String getYearLabel(int year) {
        switch (year) {
            case 1:
                return "Freshman";
            case 2:
                return "Sophomore";
            case 3:
                return "Junior";
            case 4:
                return "Senior";
            default:
                return "Other";
        }
    }

    private String getLastSessionDate(Connection conn, String studentID) {
        try {
            String sql = "SELECT sessionDateTime FROM advising_session " +
                        "WHERE studentID = ? OR studentID IN (" +
                        "  SELECT studentID FROM session_participant WHERE sessionID IN (" +
                        "    SELECT sessionID FROM advising_session WHERE studentID = ?" +
                        "  )" +
                        ") " +
                        "ORDER BY sessionDateTime DESC LIMIT 1";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentID);
                ps.setString(2, studentID);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Timestamp ts = rs.getTimestamp("sessionDateTime");
                        if (ts != null) {
                            return ts.toString().substring(0, 10);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            // Fall through
        }
        return "No session yet";
    }

    private String getNextSessionDueDate(Connection conn, String studentID) {
        try {
            String sql = "SELECT sessionDateTime FROM advising_session " +
                        "WHERE studentID = ? AND sessionDateTime > CURRENT_TIMESTAMP " +
                        "ORDER BY sessionDateTime ASC LIMIT 1";

            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, studentID);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Timestamp ts = rs.getTimestamp("sessionDateTime");
                        if (ts != null) {
                            return ts.toString().substring(0, 10);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            // Fall through
        }
        return "Not scheduled";
    }
}
