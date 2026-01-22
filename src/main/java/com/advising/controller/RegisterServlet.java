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

/**
 *
 * @author Xander
 */

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String role = request.getParameter("role");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");

        try (Connection conn = DBConnection.getConnection()) {
            String sql;
            if ("student".equals(role)) {
                String advisorIDParam = request.getParameter("advisorID");
                Integer advisorID = null;

                // Check if advisor was selected
                if (advisorIDParam != null && !advisorIDParam.trim().isEmpty()) {
                    try {
                        advisorID = Integer.parseInt(advisorIDParam);

                        // Update advisor's student count
                        String updateAdvisorSQL = "UPDATE advisor SET numSTD = numSTD + 1 WHERE advisorID = ? AND numSTD < maxSTD";
                        try (PreparedStatement updateStmt = conn.prepareStatement(updateAdvisorSQL)) {
                            updateStmt.setInt(1, advisorID);
                            int rowsUpdated = updateStmt.executeUpdate();

                            if (rowsUpdated == 0) {
                                // Advisor is full or doesn't exist
                                response.sendRedirect("index.html?error=advisor_full");
                                return;
                            }
                        }
                    } catch (NumberFormatException e) {
                        // Invalid advisor ID, treat as no advisor selected
                        advisorID = null;
                    }
                }

                sql = "INSERT INTO student (studentID, username, firstName, lastName, email, password, program, yearOfStudy, semester, advisorID) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, request.getParameter("studentID"));
                ps.setString(2, username);
                ps.setString(3, firstName);
                ps.setString(4, lastName);
                ps.setString(5, email);
                ps.setString(6, password);
                ps.setString(7, request.getParameter("program"));
                ps.setInt(8, Integer.parseInt(request.getParameter("yearOfStudy")));
                ps.setInt(9, Integer.parseInt(request.getParameter("semester")));

                if (advisorID != null) {
                    ps.setInt(10, advisorID);
                } else {
                    ps.setNull(10, java.sql.Types.INTEGER);
                }

                ps.executeUpdate();
            } else {
                sql = "INSERT INTO advisor (advisorID, username, firstName, lastName, email, password, phoneNum, department) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, request.getParameter("advisorID"));
                ps.setString(2, username);
                ps.setString(3, firstName);
                ps.setString(4, lastName);
                ps.setString(5, email);
                ps.setString(6, password);
                ps.setString(7, request.getParameter("phoneNum"));
                ps.setString(8, request.getParameter("department"));
                ps.executeUpdate();
            }
            response.sendRedirect("index.html?reg=success");
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.html?error=reg_failed");
        }
    }
}