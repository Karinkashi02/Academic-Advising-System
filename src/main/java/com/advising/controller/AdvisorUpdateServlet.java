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
@WebServlet("/api/advisor/update")
public class AdvisorUpdateServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("role") == null || !"advisor".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"Not authenticated as advisor\"}");
            return;
        }

        String advisorID = String.valueOf(session.getAttribute("userID"));
        if (advisorID == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\":\"No advisor in session\"}");
            return;
        }

        // read params
        String firstName = nullSafe(request.getParameter("firstName"));
        String lastName = nullSafe(request.getParameter("lastName"));
        String email = nullSafe(request.getParameter("email"));
        String department = nullSafe(request.getParameter("department"));
        String expertise = nullSafe(request.getParameter("expertise"));
        String officeHours = nullSafe(request.getParameter("officeHours"));
        String officeLoc = nullSafe(request.getParameter("officeLoc"));
        String phoneNum = nullSafe(request.getParameter("phoneNum"));
        String password = nullSafe(request.getParameter("password"));

        // basic validation
        if (firstName.isEmpty() || lastName.isEmpty() || email.isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("{\"error\":\"firstName, lastName and email are required\"}");
            return;
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Build dynamic UPDATE to only set provided fields (we require the three above but still update whatever provided)
            StringBuilder sb = new StringBuilder("UPDATE advisor SET firstName = ?, lastName = ?, email = ?");
            if (!department.isEmpty()) sb.append(", department = ?");
            else sb.append(", department = NULL");
            if (!expertise.isEmpty()) sb.append(", expertise = ?");
            else sb.append(", expertise = NULL");
            if (!officeHours.isEmpty()) sb.append(", officeHours = ?");
            else sb.append(", officeHours = NULL");
            if (!officeLoc.isEmpty()) sb.append(", officeLoc = ?");
            else sb.append(", officeLoc = NULL");
            if (!phoneNum.isEmpty()) sb.append(", phoneNum = ?");
            else sb.append(", phoneNum = NULL");
            if (!password.isEmpty()) sb.append(", password = ?");
            // WHERE
            sb.append(" WHERE advisorID = ?");

            try (PreparedStatement ps = conn.prepareStatement(sb.toString())) {
                int idx = 1;
                ps.setString(idx++, firstName);
                ps.setString(idx++, lastName);
                ps.setString(idx++, email);

                if (!department.isEmpty()) { ps.setString(idx++, department); }
                if (!expertise.isEmpty()) { ps.setString(idx++, expertise); }
                if (!officeHours.isEmpty()) { ps.setString(idx++, officeHours); }
                if (!officeLoc.isEmpty()) { ps.setString(idx++, officeLoc); }
                if (!phoneNum.isEmpty()) { ps.setString(idx++, phoneNum); }
                if (!password.isEmpty()) { 
                    // NOTE: storing plaintext password is how the app currently works; consider hashing in production
                    ps.setString(idx++, password);
                }

                ps.setString(idx++, advisorID);

                int updated = ps.executeUpdate();
                if (updated > 0) {
                    JSONObject out = new JSONObject();
                    out.put("success", true);
                    out.put("message", "Profile updated");
                    response.getWriter().write(out.toString());
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    response.getWriter().write("{\"error\":\"Update failed\"}");
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

    private String nullSafe(String s) { return s == null ? "" : s.trim(); }
}