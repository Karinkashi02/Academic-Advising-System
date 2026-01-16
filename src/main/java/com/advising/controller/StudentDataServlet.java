/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

/**
 *
 * @author Xander
 */
package com.advising.controller;

import com.advising.model.Student;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

@WebServlet("/api/student/me")
public class StudentDataServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        if (session == null || session.getAttribute("user") == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.write("{\"error\": \"Not authenticated\"}");
            return;
        }
        
        Student student = (Student) session.getAttribute("user");
        
        // Fetch additional data from database
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            conn = DBConnection.getConnection();
            
            // Get student's CGPA and total credits
            String sql = "SELECT " +
                        "COALESCE(AVG(grade), 0) as cgpa, " +
                        "SUM(c.credits) as total_credits " +
                        "FROM enrollment e " +
                        "JOIN course c ON e.courseCode = c.courseCode " +
                        "WHERE e.studentID = ? AND e.grade IS NOT NULL";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, student.getStudentID());
            rs = pstmt.executeQuery();
            
            double cgpa = 0.0;
            int totalCredits = 0;
            
            if (rs.next()) {
                cgpa = rs.getDouble("cgpa");
                totalCredits = rs.getInt("total_credits");
            }
            
            // Get advisor name if exists
            String advisorName = null;
            if (student.getAdvisorID() != null) {
                sql = "SELECT name FROM advisor WHERE advisorID = ?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, student.getAdvisorID());
                rs = pstmt.executeQuery();
                if (rs.next()) {
                    advisorName = rs.getString("name");
                }
            }
            
            // Create JSON response
            String json = String.format(
                "{\"studentID\": \"%s\", " +
                "\"name\": \"%s\", " +
                "\"email\": \"%s\", " +
                "\"program\": \"%s\", " +
                "\"yearOfStudy\": %d, " +
                "\"semester\": %d, " +
                "\"remark\": \"%s\", " +
                "\"advisorID\": \"%s\", " +
                "\"advisorName\": \"%s\", " +
                "\"cgpa\": %.2f, " +
                "\"creditsCompleted\": %d}",
                student.getStudentID(),
                student.getName(),
                student.getEmail(),
                student.getProgram(),
                student.getYearOfStudy(),
                student.getSemester(),
                student.getRemark() != null ? student.getRemark() : "",
                student.getAdvisorID() != null ? student.getAdvisorID() : "",
                advisorName != null ? advisorName : "",
                cgpa,
                totalCredits
            );
            
            out.write(json);
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.write("{\"error\": \"Database error: " + e.getMessage() + "\"}");
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    }
}
