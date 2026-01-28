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
import java.time.LocalDate;
import java.time.YearMonth;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Servlet to provide report statistics and analytics data
 * @author Xander
 */
@WebServlet("/api/advisor/report")
public class AdvisorReportServlet extends HttpServlet {
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

        String reportType = request.getParameter("type");

        if (reportType == null || reportType.isEmpty()) {
            reportType = "summary";
        }

        try (Connection conn = DBConnection.getConnection()) {
            JSONObject result = new JSONObject();

            switch (reportType) {
                case "summary":
                    result = getSummaryStats(conn, advisorID);
                    break;
                case "academic-status":
                    result = getAcademicStatusDistribution(conn, advisorID);
                    break;
                case "monthly-sessions":
                    result = getMonthlySessionsData(conn, advisorID);
                    break;
                case "session-types":
                    result = getSessionTypesDistribution(conn, advisorID);
                    break;
                default:
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    result.put("error", "Invalid report type");
            }

            response.getWriter().write(result.toString());

        } catch (SQLException e) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject error = new JSONObject();
            error.put("error", "Database error: " + e.getMessage());
            response.getWriter().write(error.toString());
        }
    }

    private JSONObject getSummaryStats(Connection conn, String advisorID) throws SQLException {
        JSONObject result = new JSONObject();

        // Total students
        String studentsSql = "SELECT COUNT(*) as count FROM student WHERE advisorID = ?";
        try (PreparedStatement ps = conn.prepareStatement(studentsSql)) {
            ps.setString(1, advisorID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result.put("totalStudents", rs.getInt("count"));
                }
            }
        }

        // Total sessions this year
        String sessionsSql = "SELECT COUNT(*) as count FROM advising_session WHERE advisorID = ? AND YEAR(sessionDateTime) = YEAR(CURRENT_DATE)";
        try (PreparedStatement ps = conn.prepareStatement(sessionsSql)) {
            ps.setString(1, advisorID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    result.put("sessionsCompleted", rs.getInt("count"));
                }
            }
        }

        // Average CGPA
        String cgpaSql = "SELECT AVG(cgpa) as avg_cgpa FROM student WHERE advisorID = ?";
        try (PreparedStatement ps = conn.prepareStatement(cgpaSql)) {
            ps.setString(1, advisorID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double avgCgpa = rs.getDouble("avg_cgpa");
                    result.put("avgCGPA", Math.round(avgCgpa * 100.0) / 100.0);
                }
            }
        }

        // Calculate projected graduation rate
        String gradSql = "SELECT COUNT(*) as count FROM student WHERE advisorID = ? AND yearOfStudy >= 3";
        try (PreparedStatement ps = conn.prepareStatement(gradSql)) {
            ps.setString(1, advisorID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int seniorCount = rs.getInt("count");
                    int totalCount = result.optInt("totalStudents", 1);
                    int graduationRate = totalCount > 0 ? (seniorCount * 100) / totalCount : 0;
                    result.put("graduationRate", graduationRate + "%");
                }
            }
        }

        return result;
    }

    private JSONObject getAcademicStatusDistribution(Connection conn, String advisorID) throws SQLException {
        JSONObject result = new JSONObject();
        JSONArray statuses = new JSONArray();

        // Define academic status based on CGPA
        String sql = "SELECT " +
                   "  SUM(CASE WHEN cgpa >= 3.5 THEN 1 ELSE 0 END) as deans_list, " +
                   "  SUM(CASE WHEN cgpa >= 2.0 AND cgpa < 3.5 THEN 1 ELSE 0 END) as pass, " +
                   "  SUM(CASE WHEN cgpa >= 1.0 AND cgpa < 2.0 THEN 1 ELSE 0 END) as probation, " +
                   "  SUM(CASE WHEN cgpa < 1.0 THEN 1 ELSE 0 END) as at_risk " +
                   "FROM student WHERE advisorID = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, advisorID);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    JSONObject deansList = new JSONObject();
                    deansList.put("name", "Dean's List");
                    deansList.put("value", rs.getInt("deans_list"));
                    deansList.put("color", "#27ae60");
                    statuses.put(deansList);

                    JSONObject pass = new JSONObject();
                    pass.put("name", "Pass");
                    pass.put("value", rs.getInt("pass"));
                    pass.put("color", "#3498db");
                    statuses.put(pass);

                    JSONObject probation = new JSONObject();
                    probation.put("name", "Probation");
                    probation.put("value", rs.getInt("probation"));
                    probation.put("color", "#f39c12");
                    statuses.put(probation);

                    JSONObject atRisk = new JSONObject();
                    atRisk.put("name", "At Risk");
                    atRisk.put("value", rs.getInt("at_risk"));
                    atRisk.put("color", "#e74c3c");
                    statuses.put(atRisk);
                }
            }
        }

        result.put("data", statuses);
        return result;
    }

    private JSONObject getMonthlySessionsData(Connection conn, String advisorID) throws SQLException {
        JSONObject result = new JSONObject();
        JSONArray months = new JSONArray();

        // Get last 6 months of sessions
        String[] colors = {"#3498db", "#2ecc71", "#e67e22", "#9b59b6", "#1abc9c", "#e74c3c"};
        String[] monthNames = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

        for (int i = 5; i >= 0; i--) {
            YearMonth ym = YearMonth.now().minusMonths(i);
            int month = ym.getMonthValue();
            int year = ym.getYear();

            String countSql = "SELECT COUNT(*) as count FROM advising_session " +
                            "WHERE advisorID = ? AND MONTH(sessionDateTime) = ? AND YEAR(sessionDateTime) = ?";

            try (PreparedStatement ps = conn.prepareStatement(countSql)) {
                ps.setString(1, advisorID);
                ps.setInt(2, month);
                ps.setInt(3, year);

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        JSONObject monthData = new JSONObject();
                        // Use the actual month name for the calculated YearMonth (month is 1-12)
                        monthData.put("month", monthNames[month - 1]);
                        monthData.put("value", rs.getInt("count"));
                        monthData.put("color", colors[5 - i]);
                        months.put(monthData);
                    }
                }
            }
        }

        result.put("data", months);
        return result;
    }

    private JSONObject getSessionTypesDistribution(Connection conn, String advisorID) throws SQLException {
        JSONObject result = new JSONObject();
        JSONArray types = new JSONArray();

        String sql = "SELECT sessionType, COUNT(*) as count FROM advising_session " +
                   "WHERE advisorID = ? GROUP BY sessionType ORDER BY count DESC";

        String[] colors = {"#3498db", "#2ecc71", "#e67e22", "#9b59b6"};
        int colorIndex = 0;

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, advisorID);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    JSONObject type = new JSONObject();
                    type.put("name", rs.getString("sessionType"));
                    type.put("value", rs.getInt("count"));
                    type.put("color", colors[colorIndex % colors.length]);
                    types.put(type);
                    colorIndex++;
                }
            }
        }

        result.put("data", types);
        return result;
    }
}
