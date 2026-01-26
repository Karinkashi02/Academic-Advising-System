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
@WebServlet("/api/student/grade")
public class UpdateGradeServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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

        String progressIdStr = request.getParameter("progressID");
        String grade = request.getParameter("grade");

        if (progressIdStr == null || progressIdStr.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"progressID required\"}");
            return;
        }

        int progressID;
        try {
            progressID = Integer.parseInt(progressIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"invalid progressID\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Verify ownership
            String checkSql = "SELECT studentID FROM student_progress WHERE progressID = ?";
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, progressID);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (!rs.next()) {
                        response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                        response.getWriter().write("{\"error\":\"Progress not found\"}");
                        return;
                    }
                    String owner = rs.getString("studentID");
                    if (!String.valueOf(owner).equals(String.valueOf(studentID))) {
                        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        response.getWriter().write("{\"error\":\"Not allowed to update this record\"}");
                        return;
                    }
                }
            }

            // Update grade and maybe status
            String newStatus = (grade != null && !grade.trim().isEmpty()) ? "Completed" : "Ongoing";
            String updateSql = "UPDATE student_progress SET grade = ?, status = ? WHERE progressID = ?";
            try (PreparedStatement upPs = conn.prepareStatement(updateSql)) {
                if (grade == null || grade.trim().isEmpty()) {
                    upPs.setNull(1, java.sql.Types.VARCHAR);
                } else {
                    upPs.setString(1, grade.trim());
                }
                upPs.setString(2, newStatus);
                upPs.setInt(3, progressID);
                int updated = upPs.executeUpdate();
                if (updated > 0) {
                    JSONObject json = new JSONObject();
                    json.put("success", true);
                    json.put("message", "Grade updated");
                    response.getWriter().write(json.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"error\":\"Update failed\"}");
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\":\"Database error\"}");
        }
    }
}