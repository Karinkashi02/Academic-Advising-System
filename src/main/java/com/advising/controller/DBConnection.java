/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.advising.controller;

/**
 *
 * @author Xander
 */

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static Connection connection = null;
    
    public static Connection getConnection() {
        if (connection == null) {
            try {
                // Correct the URL format (Note: replace 24715 with your actual Aiven port)
                // Added ?useSSL=true which is usually required for cloud providers
                String url = "jdbc:mysql://mysql-acdm2-amarghazali7135-8a18.h.aivencloud.com:21488/defaultdb?useSSL=true&trustServerCertificate=true";
                String username = "avnadmin";
                String password = "AVNS_Jg4MY0Br57oWD46H8Eb"; // Use the real password string

                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, username, password);
                System.out.println("Database connected successfully!");

            } catch (ClassNotFoundException | SQLException e) {
                // This will print the exact reason (e.g., "Access denied" or "Communications link failure")
                System.err.println("CRITICAL ERROR: " + e.getMessage()); 
                e.printStackTrace();
                connection = null; 
            }
        }
        return connection;
    }
    
    public static void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                connection = null;
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}