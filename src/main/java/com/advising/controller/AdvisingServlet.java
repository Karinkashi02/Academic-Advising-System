package com.advising.controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet(name = "AdvisingServlet", value = "/submit-advising")
public class AdvisingServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //Get credentials from Render Environment
        String dbUrl = "jdbc:mysql://" + System.getenv("DB_HOST") + ":" + System.getenv("DB_PORT") + "/" + System.getenv("DB_NAME");
        String user = System.getenv("DB_USER");
        String pass = System.getenv("DB_PASSWORD");

        try {
            //Load the driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            //Connect and Execute
            try (Connection conn = DriverManager.getConnection(dbUrl, user, pass)) {
                //Your SQL logic goes here!
                System.out.println("Database Connected Successfully!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}