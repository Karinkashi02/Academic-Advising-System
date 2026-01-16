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

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        
        System.out.println("Login attempt: email=" + email + ", role=" + role);
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            if (conn == null) {
                response.sendRedirect("index.html?error=db_connection_failed");
                return; // Stop execution here
            }
            
            if ("student".equals(role)) {
                // Check student credentials
                String sql = "SELECT * FROM student WHERE email = ? AND password = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, email);
                pstmt.setString(2, password); // In production, use hashed passwords
                
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    Student student = new Student();
                    student.setStudentID(rs.getString("studentID"));
                    student.setName(rs.getString("name"));
                    student.setEmail(rs.getString("email"));
                    student.setProgram(rs.getString("program"));
                    student.setYearOfStudy(rs.getInt("yearOfStudy"));
                    student.setSemester(rs.getInt("semester"));
                    student.setRemark(rs.getString("remark"));
                    student.setAdvisorID(rs.getString("advisorID"));
                    
                    // Store student in session
                    HttpSession session = request.getSession();
                    session.setAttribute("user", student);
                    session.setAttribute("role", "student");
                    session.setMaxInactiveInterval(30 * 60); // 30 minutes
                    
                    // Redirect to dashboard
                    response.sendRedirect("Student/Dashboard.html");
                } else {
                    request.setAttribute("error", "Invalid email or password for student");
                    request.getRequestDispatcher("index.html").forward(request, response);
                }
                
            } else if ("advisor".equals(role)) {
                // Check advisor credentials
                String sql = "SELECT * FROM advisor WHERE email = ? AND password = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, email);
                pstmt.setString(2, password);
                
                rs = pstmt.executeQuery();
                
                if (rs.next()) {
                    Advisor advisor = new Advisor();
                    advisor.setAdvisorID(rs.getString("advisorID"));
                    advisor.setName(rs.getString("name"));
                    advisor.setEmail(rs.getString("email"));
                    advisor.setDepartment(rs.getString("department"));
                    advisor.setExpertise(rs.getString("expertise"));
                    advisor.setOfficeHours(rs.getString("officeHours"));
                    advisor.setOfficeLoc(rs.getString("officeLoc"));
                    
                    // Store advisor in session
                    HttpSession session = request.getSession();
                    session.setAttribute("user", advisor);
                    session.setAttribute("role", "advisor");
                    session.setMaxInactiveInterval(30 * 60);
                    
                    // Redirect to advisor dashboard
                    response.sendRedirect("Advisor/advisor_dashboard.html");
                } else {
                    request.setAttribute("error", "Invalid email or password for advisor");
                    request.getRequestDispatcher("index.html").forward(request, response);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("index.html").forward(request, response);
        } finally {
            // Close resources
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            // Don't close connection here - it's managed by DBConnection class
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect("index.html");
    }
}
