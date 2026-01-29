/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.advising.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.sql.*;


/**
 *
 * @author Xander
 */
@WebServlet(urlPatterns = {"/api/students", "/api/students/search"})
public class AdvisorStdSearchServlet extends HttpServlet {

    private static final int MAX_RESULTS = 500;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        // Basic auth/session check - mirror other API servlets' behavior
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated\"}");
            return;
        }

        String q = request.getParameter("q");
        String limitParam = request.getParameter("limit");
        int limit = MAX_RESULTS;
        if (limitParam != null) {
            try { limit = Math.min(MAX_RESULTS, Integer.parseInt(limitParam)); } catch (NumberFormatException ignored) {}
        }

        // Build SQL
        // Select advisorID too so client can see whether student is already assigned
        // JOIN with advisor table to get advisor's name
        String baseSql = "SELECT s.studentID, s.firstName, s.lastName, s.email, s.program, s.yearOfStudy, s.semester, s.phoneNum, s.cgpa, s.creditscompleted, s.co_curricular_points, s.advisorID, s.remark, " +
                "COALESCE(a.firstName, '') as advisorFirstName, COALESCE(a.lastName, '') as advisorLastName " +
                "FROM student s " +
                "LEFT JOIN advisor a ON s.advisorID = a.advisorID";

        String where = "";
        if (q != null && q.trim().length() > 0) {
            // Use case-insensitive search; use CONCAT for full-name match
                where = " WHERE (" +
                    "LOWER(s.studentID) LIKE ? OR " +
                    "LOWER(s.firstName) LIKE ? OR " +
                    "LOWER(s.lastName) LIKE ? OR " +
                    // Use SQL string concatenation (||) which is Derby-compatible
                    "LOWER(COALESCE(s.firstName,'') || ' ' || COALESCE(s.lastName,'')) LIKE ? OR " +
                    "LOWER(s.email) LIKE ? OR " +
                    "LOWER(s.program) LIKE ?" +
                    ")";
        }

        // Derby does not support LIMIT; use FETCH FIRST ... ROWS ONLY
        String orderLimit = " ORDER BY s.lastName, s.firstName FETCH FIRST ? ROWS ONLY";

        String sql = baseSql + where + orderLimit;

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            int idx = 1;
            if (where.length() > 0) {
                String p = "%" + q.trim().toLowerCase() + "%";
                // bind same pattern to each LIKE parameter
                ps.setString(idx++, p);
                ps.setString(idx++, p);
                ps.setString(idx++, p);
                ps.setString(idx++, p);
                ps.setString(idx++, p);
                ps.setString(idx++, p);
            }
            ps.setInt(idx, limit);

            try (ResultSet rs = ps.executeQuery()) {
                JSONArray arr = new JSONArray();
                while (rs.next()) {
                    JSONObject st = new JSONObject();
                    String sid = rs.getString("studentID");
                    st.put("studentID", sid != null ? sid : JSONObject.NULL);
                    String fn = rs.getString("firstName");
                    String ln = rs.getString("lastName");
                    String name = ((fn == null ? "" : fn) + " " + (ln == null ? "" : ln)).trim();
                    st.put("firstName", fn != null ? fn : JSONObject.NULL);
                    st.put("lastName", ln != null ? ln : JSONObject.NULL);
                    st.put("name", name.length() > 0 ? name : (sid != null ? sid : JSONObject.NULL));
                    st.put("email", rs.getString("email") != null ? rs.getString("email") : "");
                    st.put("program", rs.getString("program") != null ? rs.getString("program") : "");
                    // numeric / nullable fields
                    st.put("yearOfStudy", rs.getObject("yearOfStudy") == null ? JSONObject.NULL : rs.getInt("yearOfStudy"));
                    st.put("semester", rs.getObject("semester") == null ? JSONObject.NULL : rs.getInt("semester"));
                    st.put("phoneNum", rs.getString("phoneNum") != null ? rs.getString("phoneNum") : "");
                    st.put("cgpa", rs.getObject("cgpa") == null ? JSONObject.NULL : rs.getDouble("cgpa"));
                    st.put("creditsCompleted", rs.getObject("creditscompleted") == null ? JSONObject.NULL : rs.getInt("creditscompleted"));
                    st.put("co_curricular_points", rs.getObject("co_curricular_points") == null ? JSONObject.NULL : rs.getInt("co_curricular_points"));
                    st.put("remark", rs.getString("remark") != null ? rs.getString("remark") : "");
                    // advisor assignment info
                    Object adv = rs.getObject("advisorID");
                    st.put("advisorID", adv == null ? JSONObject.NULL : String.valueOf(adv));
                    // advisor name (from JOIN)
                    String advisorFirstName = rs.getString("advisorFirstName");
                    String advisorLastName = rs.getString("advisorLastName");
                    String advisorName = ((advisorFirstName == null ? "" : advisorFirstName) + " " + (advisorLastName == null ? "" : advisorLastName)).trim();
                    st.put("advisorName", advisorName.length() > 0 ? advisorName : "Not Assigned");
                    arr.put(st);
                }
                JSONObject out = new JSONObject();
                out.put("students", arr);
                response.getWriter().write(out.toString());
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            // Include message to aid debugging in development
            JSONObject err = new JSONObject();
            err.put("error", "Database error");
            err.put("message", e.getMessage());
            response.getWriter().write(err.toString());
        }
    }
}