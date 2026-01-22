/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.advising.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import java.io.*;
import java.sql.*;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 *
 * @author Xander
 */

@WebServlet("/api/advisors/available")
public class GetAdvisorsServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "SELECT advisorID, firstName, lastName, department, expertise, " +
                        "officeHours, officeLoc, numSTD, maxSTD " +
                        "FROM advisor ORDER BY lastName, firstName";
            
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();
            
            JSONArray advisorsArray = new JSONArray();
            
            while (rs.next()) {
                JSONObject advisor = new JSONObject();
                int numSTD = rs.getInt("numSTD");
                int maxSTD = rs.getInt("maxSTD");
                boolean isAvailable = numSTD < maxSTD;
                
                advisor.put("advisorID", rs.getInt("advisorID"));
                advisor.put("name", rs.getString("firstName") + " " + rs.getString("lastName"));
                advisor.put("department", rs.getString("department"));
                advisor.put("expertise", rs.getString("expertise"));
                advisor.put("officeHours", rs.getString("officeHours"));
                advisor.put("officeLocation", rs.getString("officeLoc"));
                advisor.put("numStudents", numSTD);
                advisor.put("maxStudents", maxSTD);
                advisor.put("availableSlots", maxSTD - numSTD);
                advisor.put("available", isAvailable);
                advisor.put("status", isAvailable ? "Available" : "Full");
                
                advisorsArray.put(advisor);
            }
            
            JSONObject responseJson = new JSONObject();
            responseJson.put("advisors", advisorsArray);
            
            response.getWriter().write(responseJson.toString());
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"error\": \"Database error\"}");
        }
    }
}