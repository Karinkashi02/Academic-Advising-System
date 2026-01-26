/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.advising.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
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

        // Debug log to help track registration failures
        System.out.println("[RegisterServlet] incoming registration attempt: role=" + role + " username=" + username + " email=" + email + " firstName=" + firstName + " lastName=" + lastName);

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
                                System.out.println("[RegisterServlet] advisor update failed for advisorID=" + advisorID);
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
                // Debug incoming student-only fields
                String studentID = request.getParameter("studentID");
                String program = request.getParameter("program");
                String yearStr = request.getParameter("yearOfStudy");
                String semStr = request.getParameter("semester");
                System.out.println("[RegisterServlet] student fields: studentID=" + studentID + " program=" + program + " year=" + yearStr + " semester=" + semStr + " advisorID=" + advisorID);

                ps.setString(1, studentID);
                ps.setString(2, username);
                ps.setString(3, firstName);
                ps.setString(4, lastName);
                ps.setString(5, email);
                ps.setString(6, password);
                ps.setString(7, program);
                ps.setInt(8, Integer.parseInt(yearStr));
                ps.setInt(9, Integer.parseInt(semStr));

                if (advisorID != null) {
                    ps.setInt(10, advisorID);
                } else {
                    ps.setNull(10, java.sql.Types.INTEGER);
                }

                ps.executeUpdate();
            } else {
                sql = "INSERT INTO advisor (username, firstName, lastName, email, password, phoneNum, department) VALUES (?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);

                String advisorID = request.getParameter("advisorID");
                String phone = request.getParameter("phoneNum");
                String department = request.getParameter("department");

                System.out.println("[RegisterServlet] advisor fields: advisorID=" + advisorID + " phone=" + phone + " dept=" + department);

                ps.setString(1, username);
                ps.setString(2, firstName);
                ps.setString(3, lastName);
                ps.setString(4, email);
                ps.setString(5, password);
                ps.setString(6, phone);
                ps.setString(7, department);
                ps.executeUpdate();
            }
            response.sendRedirect("index.html?reg=success");
        } catch (SQLException e) {
        e.printStackTrace();
        // Send detailed error to browser for debugging
        response.setContentType("text/html");
        PrintWriter out = response.getWriter();
        out.println("<h3>Registration Failed - Debug Info</h3>");
        out.println("<pre>");
        out.println("Error: " + e.getMessage());
        out.println("SQL State: " + e.getSQLState());
        out.println("Error Code: " + e.getErrorCode());
        out.println("</pre>");
        out.close();
    }
    }
}