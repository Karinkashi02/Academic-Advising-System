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
@WebServlet("/api/advisor/student/update")
public class AdvisorUpdateSTDServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
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
        if (!"advisor".equals(role)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.getWriter().write("{\"error\":\"Only advisors can update student remarks\"}");
            return;
        }

        String studentID = request.getParameter("studentID");
        String remark = request.getParameter("remark");
        String notes = request.getParameter("notes");

        if (studentID == null || studentID.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"studentID is required\"}");
            return;
        }

        if (remark == null) remark = "";
        if (notes == null) notes = "";

        try (Connection conn = DBConnection.getConnection()) {
            String sql = "UPDATE student SET remark = ? WHERE studentID = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, remark);
                ps.setString(2, studentID);
                int updated = ps.executeUpdate();

                if (updated > 0) {
                    JSONObject json = new JSONObject();
                    json.put("success", true);
                    json.put("message", "Student remark updated successfully");
                    json.put("studentID", studentID);
                    json.put("remark", remark);
                    response.getWriter().write(json.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                    response.getWriter().write("{\"error\":\"Student not found\"}");
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
}
