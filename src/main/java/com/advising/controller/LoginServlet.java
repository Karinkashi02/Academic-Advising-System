/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.advising.controller;

/**
 *
 * @author Xander
 */

import com.advising.model.Student;
import com.advising.model.Advisor;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/LoginServlet")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username"); // Changed to username as per your form
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        try (Connection conn = DBConnection.getConnection()) {
            String sql = (role.equals("student")) ? 
                "SELECT * FROM student WHERE username = ? AND password = ?" : 
                "SELECT * FROM advisor WHERE username = ? AND password = ?";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("role", role);
                session.setAttribute("userID", (role.equals("student")) ? rs.getString("studentID") : rs.getString("advisorID"));

                // Redirect to your specific paths
                if (role.equals("student")) {
                    response.sendRedirect("Student/Dashboard.jsp");
                } else {
                    response.sendRedirect("Advisor/advisor_dashboard.jsp");
                }
            } else {
                response.sendRedirect("index.jsp?error=invalid");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("index.jsp?error=db_error");
        }
    }
}