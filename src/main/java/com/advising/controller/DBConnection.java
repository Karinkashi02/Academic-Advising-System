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
    // Standard Derby URL for NetBeans
    private static final String URL = "jdbc:derby://localhost:1527/Academic_Advising";
    private static final String USER = "app"; // Default Derby user
    private static final String PASS = "app"; // Default Derby password

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("org.apache.derby.jdbc.ClientDriver");
            return DriverManager.getConnection(URL, USER, PASS);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Derby Driver not found", e);
        }
    }
}