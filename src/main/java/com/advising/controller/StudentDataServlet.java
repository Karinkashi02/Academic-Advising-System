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

@WebServlet("/api/student/me")
public class StudentDataServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

        String role = (String) session.getAttribute("role");
        Object userIdObj = session.getAttribute("userID");
        if (role == null || userIdObj == null || !"student".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"Not authorized or not a student\"}");
            return;
        }

        String userID = String.valueOf(userIdObj);

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT * FROM student WHERE studentID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, userID);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"error\":\"Student not found\"}");
                        return;
                    }

                    ResultSetMetaData md = rs.getMetaData();
                    JSONObject json = new JSONObject();

                    json.put("studentID", safeGetString(rs, md, "studentID", ""));
                    String firstName = safeGetString(rs, md, "firstName", "");
                    String lastName = safeGetString(rs, md, "lastName", "");
                    json.put("firstName", firstName);
                    json.put("lastName", lastName);
                    json.put("name", (firstName + " " + lastName).trim());
                    json.put("username", safeGetString(rs, md, "username", ""));
                    json.put("email", safeGetString(rs, md, "email", ""));
                    json.put("program", safeGetString(rs, md, "program", ""));
                    json.put("remark", safeGetString(rs, md, "remark", ""));
                    json.put("yearOfStudy", safeGetInt(rs, md, "yearOfStudy", 0));
                    json.put("semester", safeGetInt(rs, md, "semester", 0));

                    Integer advisorID = safeGetNullableInt(rs, md, "advisorID");
                    if (advisorID == null) json.put("advisorID", JSONObject.NULL); else json.put("advisorID", advisorID);

                    json.put("phoneNum", safeGetString(rs, md, "phoneNum", ""));

                    // Prefer stored values if present
                    Double storedCgpa = null;
                    try {
                        if (hasColumn(md, "cgpa")) {
                            double cg = rs.getDouble("cgpa");
                            if (!rs.wasNull()) storedCgpa = cg;
                        }
                    } catch (SQLException e) { /* ignore */ }

                    Integer storedCredits = null;
                    try {
                        if (hasColumn(md, "creditscompleted")) {
                            int cc = rs.getInt("creditscompleted");
                            if (!rs.wasNull()) storedCredits = cc;
                        }
                    } catch (SQLException e) { /* ignore */ }

                    Integer storedPoints = null;
                    try {
                        if (hasColumn(md, "co_curricular_points")) {
                            int pts = rs.getInt("co_curricular_points");
                            if (!rs.wasNull()) storedPoints = pts;
                        }
                    } catch (SQLException e) { /* ignore */ }

                    // Compute CGPA & creditsCompleted on-the-fly (as fallback)
                    double cgpa = 0.0;
                    int creditsCompleted = 0;
                    String gradeSql = "SELECT sp.grade, c.creditHour " +
                                      "FROM student_progress sp " +
                                      "JOIN course c ON sp.courseID = c.courseID " +
                                      "WHERE sp.studentID = ? AND sp.grade IS NOT NULL";
                    try (PreparedStatement gPs = conn.prepareStatement(gradeSql)) {
                        gPs.setString(1, userID);
                        try (ResultSet gRs = gPs.executeQuery()) {
                            double totalWeighted = 0.0;
                            int totalCredits = 0;
                            while (gRs.next()) {
                                String grade = gRs.getString("grade");
                                int credit = gRs.getInt("creditHour");
                                Double gp = letterGradeToPoint(grade);
                                if (gp != null) {
                                    totalWeighted += gp * credit;
                                    totalCredits += credit;
                                }
                                // Count creditsCompleted if grade not NT and not null
                                if (grade != null && !grade.trim().equalsIgnoreCase("NT")) {
                                    creditsCompleted += credit;
                                }
                            }
                            if (totalCredits > 0) {
                                cgpa = totalWeighted / totalCredits;
                                cgpa = Math.round(cgpa * 100.0) / 100.0;
                            } else {
                                cgpa = 0.0;
                            }
                        }
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }

                    // Prefer stored DB values, but update DB if stored values are missing or zero (helps keep DB in sync)
                    boolean wroteBack = false;
                    try {
                        if ((storedCgpa == null || storedCgpa == 0.0) || (storedCredits == null || storedCredits == 0)) {
                            String updateSql = "UPDATE student SET cgpa = ?, creditscompleted = ? WHERE studentID = ?";
                            try (PreparedStatement ups = conn.prepareStatement(updateSql)) {
                                ups.setDouble(1, cgpa);
                                ups.setInt(2, creditsCompleted);
                                ups.setString(3, userID);
                                ups.executeUpdate();
                                wroteBack = true;
                            }
                        }
                    } catch (SQLException ex) {
                        // If update fails, log but don't break response
                        ex.printStackTrace();
                    }

                    // Final JSON values: prefer DB stored values when present (non-null)
                    if (storedCgpa != null && !Double.isNaN(storedCgpa)) json.put("cgpa", storedCgpa);
                    else json.put("cgpa", cgpa);

                    if (storedCredits != null) json.put("creditsCompleted", storedCredits);
                    else json.put("creditsCompleted", creditsCompleted);

                    // co-curricular points
                    if (storedPoints != null) json.put("co_curricular_points", storedPoints);
                    else {
                        // fallback: compute sum of points from completed activities (if you want)
                        try {
                            String ptsSql = "SELECT SUM(a.points) AS total FROM activity a JOIN activity_registration ar ON a.activityID = ar.activityID WHERE ar.studentID = ? AND a.status = 'completed'";
                            try (PreparedStatement pps = conn.prepareStatement(ptsSql)) {
                                pps.setString(1, userID);
                                try (ResultSet prs = pps.executeQuery()) {
                                    if (prs.next()) {
                                        int total = prs.getInt("total");
                                        if (prs.wasNull()) total = 0;
                                        json.put("co_curricular_points", total);
                                    } else json.put("co_curricular_points", 0);
                                }
                            }
                        } catch (SQLException e) {
                            json.put("co_curricular_points", 0);
                        }
                    }

                    // advisor name lookup (defensive)
                    if (advisorID != null) {
                        String aSql = "SELECT firstName, lastName FROM advisor WHERE advisorID = ?";
                        try (PreparedStatement aPs = conn.prepareStatement(aSql)) {
                            aPs.setInt(1, advisorID);
                            try (ResultSet aRs = aPs.executeQuery()) {
                                if (aRs.next()) {
                                    String an = (aRs.getString("firstName") == null ? "" : aRs.getString("firstName")) +
                                                " " +
                                                (aRs.getString("lastName") == null ? "" : aRs.getString("lastName"));
                                    json.put("advisorName", an.trim());
                                } else {
                                    json.put("advisorName", "");
                                }
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                            json.put("advisorName", "");
                        }
                    } else {
                        json.put("advisorName", "");
                    }

                    // convenience: include userID (front-end uses profile.userID)
                    json.put("userID", userID);

                    response.getWriter().write(json.toString());
                    return;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JSONObject err = new JSONObject();
            err.put("error", "Database error");
            err.put("message", e.getMessage());
            response.getWriter().write(err.toString());
        }
    }

    // Helper: check if a column exists and return its String value or default
    private String safeGetString(ResultSet rs, ResultSetMetaData md, String columnName, String def) {
        try {
            if (hasColumn(md, columnName)) {
                String v = rs.getString(columnName);
                return v != null ? v : def;
            }
        } catch (SQLException e) { /* ignore */ }
        return def;
    }

    private int safeGetInt(ResultSet rs, ResultSetMetaData md, String columnName, int def) {
        try {
            if (hasColumn(md, columnName)) {
                int v = rs.getInt(columnName);
                if (rs.wasNull()) return def;
                return v;
            }
        } catch (SQLException e) { /* ignore */ }
        return def;
    }

    private Integer safeGetNullableInt(ResultSet rs, ResultSetMetaData md, String columnName) {
        try {
            if (hasColumn(md, columnName)) {
                int v = rs.getInt(columnName);
                if (rs.wasNull()) return null;
                return Integer.valueOf(v);
            }
        } catch (SQLException e) { /* ignore */ }
        return null;
    }

    private boolean hasColumn(ResultSetMetaData md, String columnName) throws SQLException {
        int cols = md.getColumnCount();
        for (int i = 1; i <= cols; i++) {
            if (columnName.equalsIgnoreCase(md.getColumnName(i))) return true;
        }
        return false;
    }

    private static Double letterGradeToPoint(String g) {
        if (g == null) return null;
        String grade = g.trim().toUpperCase();
        switch (grade) {
            case "A+": return 4.0;
            case "A":  return 4.0;
            case "A-": return 3.7;
            case "B+": return 3.3;
            case "B":  return 3.0;
            case "B-": return 2.7;
            case "C":  return 2.0;
            case "D":  return 1.0;
            case "F":  return 0.0;
            default: return null;
        }
    }
}