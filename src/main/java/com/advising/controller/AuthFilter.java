/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */

/**
 *
 * @author Xander
 */
package com.advising.controller;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);
        
        String requestURI = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        
        // Allow access to login page and static resources
        if (requestURI.endsWith("index.html") || 
            requestURI.endsWith("login") ||
            requestURI.contains("/css/") ||
            requestURI.contains("/js/") ||
            requestURI.contains("/images/") ||
            requestURI.endsWith(".css") ||
            requestURI.endsWith(".js") ||
            requestURI.endsWith(".jpg") ||
            requestURI.endsWith(".png")) {
            chain.doFilter(request, response);
            return;
        }
        
        // Check if user is logged in
        boolean loggedIn = session != null && session.getAttribute("user") != null;
        
        if (!loggedIn) {
            // Redirect to login if not authenticated
            httpResponse.sendRedirect(contextPath + "/index.html");
            return;
        }
        
        // Check role-based access
        String role = (String) session.getAttribute("role");
        
        if (requestURI.contains("/Student/") && !"student".equals(role)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        if (requestURI.contains("/Advisor/") && !"advisor".equals(role)) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}
    
    @Override
    public void destroy() {}
}