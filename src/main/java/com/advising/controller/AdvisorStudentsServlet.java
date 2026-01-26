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
@WebServlet("/api/advisor/students")
public class AdvisorStudentsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"advisor".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

        String advisorID = String.valueOf(session.getAttribute("userID"));
        if (advisorID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"No user in session\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT studentID, firstName, lastName, email, program, yearOfStudy, semester, phoneNum, cgpa, creditscompleted, co_curricular_points " +
                         "FROM student WHERE advisorID = ? ORDER BY lastName, firstName";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, advisorID);
                try (ResultSet rs = ps.executeQuery()) {
                    JSONArray arr = new JSONArray();
                    while (rs.next()) {
                        JSONObject s = new JSONObject();
                        s.put("studentID", rs.getString("studentID"));
                        s.put("firstName", rs.getString("firstName"));
                        s.put("lastName", rs.getString("lastName"));
                        s.put("name", ((rs.getString("firstName")==null?"":rs.getString("firstName")) + " " + (rs.getString("lastName")==null?"":rs.getString("lastName"))).trim());
                        s.put("email", rs.getString("email"));
                        s.put("program", rs.getString("program"));
                        s.put("yearOfStudy", rs.getObject("yearOfStudy") == null ? JSONObject.NULL : rs.getInt("yearOfStudy"));
                        s.put("semester", rs.getObject("semester") == null ? JSONObject.NULL : rs.getInt("semester"));
                        s.put("phoneNum", rs.getString("phoneNum") != null ? rs.getString("phoneNum") : "");
                        s.put("cgpa", rs.getObject("cgpa") == null ? JSONObject.NULL : rs.getDouble("cgpa"));
                        s.put("creditsCompleted", rs.getObject("creditscompleted") == null ? JSONObject.NULL : rs.getInt("creditscompleted"));
                        s.put("co_curricular_points", rs.getObject("co_curricular_points") == null ? JSONObject.NULL : rs.getInt("co_curricular_points"));
                        arr.put(s);
                    }
                    JSONObject out = new JSONObject();
                    out.put("students", arr);
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