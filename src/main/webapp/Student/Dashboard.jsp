<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Session check for student role
    if (session.getAttribute("role") == null || !"student".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/index.jsp?error=unauthorized");
        return;
    }
    
    // Get URL parameters for error/success messages
    String error = request.getParameter("error");
    String success = request.getParameter("success");
    String message = request.getParameter("message");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Dashboard - Academic Advising & Progress Tracking</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --primary-blue: #1e3a8a;
            --secondary-blue: #0ea5e9;
            --light-blue: #93c5fd;
            --background-blue: #f0f9ff;
            --dark-text: #1e293b;
            --accent-blue: #3b82f6;
            --card-white: #ffffff;
            --sidebar-width: 250px;
            --header-height: 80px;
            --gradient-blue: linear-gradient(135deg, #1e3a8a, #3b82f6);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        body {
            background-color: var(--background-blue);
            color: var(--dark-text);
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Navigation - Cleaner */
        .sidebar {
            width: var(--sidebar-width);
            background: var(--gradient-blue);
            color: white;
            height: 100vh;
            position: fixed;
            padding-top: 20px;
            box-shadow: 3px 0 20px rgba(30, 58, 138, 0.2);
            z-index: 100;
        }

        .logo-container {
            text-align: center;
            padding: 25px 10px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.15);
            margin-bottom: 30px;
        }

        .logo {
            width: 60px;
            height: 60px;
            background: white;
            border-radius: 12px;
            margin: 0 auto 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            color: var(--primary-blue);
            font-weight: bold;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .logo-container h2 {
            font-size: 1.4rem;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .logo-container p {
            font-size: 0.85rem;
            opacity: 0.9;
            color: var(--light-blue);
        }

        .nav-links {
            list-style: none;
            padding: 0 20px;
        }

        .nav-links li {
            margin-bottom: 8px;
        }

        .nav-links a {
            color: white;
            text-decoration: none;
            display: flex;
            align-items: center;
            padding: 14px 15px;
            border-radius: 12px;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .nav-links a:before {
            content: '';
            position: absolute;
            left: -100%;
            top: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
            transition: left 0.7s;
        }

        .nav-links a:hover:before {
            left: 100%;
        }

        .nav-links a:hover, .nav-links a.active {
            background-color: rgba(255, 255, 255, 0.15);
            transform: translateX(8px);
            box-shadow: -3px 0 10px rgba(255, 255, 255, 0.1);
        }

        .nav-links i {
            margin-right: 15px;
            font-size: 1.2rem;
            width: 24px;
            text-align: center;
        }

        /* Main Content Area */
        .main-content {
            flex: 1;
            margin-left: var(--sidebar-width);
            padding: 20px;
        }

        /* Enhanced Header with Profile - FIXED: Removed overflow: hidden */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--gradient-blue);
            padding: 15px 30px;
            border-radius: 15px;
            box-shadow: 0 6px 20px rgba(30, 58, 138, 0.25);
            margin-bottom: 30px;
            color: white;
            position: relative;
            /* REMOVED: overflow: hidden */
        }

        .header:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: url("data:image/svg+xml,%3Csvg width='100' height='100' viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M11 18c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm48 25c3.866 0 7-3.134 7-7s-3.134-7-7-7-7 3.134-7 7 3.134 7 7 7zm-43-7c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm63 31c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM34 90c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zm56-76c1.657 0 3-1.343 3-3s-1.343-3-3-3-3 1.343-3 3 1.343 3 3 3zM12 86c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm28-65c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm23-11c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-6 60c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm29 22c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zM32 63c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm57-13c2.76 0 5-2.24 5-5s-2.24-5-5-5-5 2.24-5 5 2.24 5 5 5zm-9-21c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM60 91c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM35 41c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2zM12 60c1.105 0 2-.895 2-2s-.895-2-2-2-2 .895-2 2 .895 2 2 2z' fill='%23ffffff' fill-opacity='0.05' fill-rule='evenodd'/%3E%3C/svg%3E");
        }

        .student-info h1 {
            font-size: 1.8rem;
            margin-bottom: 8px;
            font-weight: 700;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .student-info p {
            opacity: 0.95;
            font-size: 0.95rem;
        }

        .stats-bar {
            display: flex;
            gap: 35px;
            background: rgba(255, 255, 255, 0.15);
            padding: 15px 25px;
            border-radius: 12px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .stat-item {
            text-align: center;
            position: relative;
        }

        .stat-item:not(:last-child):after {
            content: '';
            position: absolute;
            right: -18px;
            top: 50%;
            transform: translateY(-50%);
            width: 1px;
            height: 30px;
            background: rgba(255, 255, 255, 0.3);
        }

        .stat-value {
            font-size: 1.8rem;
            font-weight: 800;
            margin-bottom: 5px;
            color: white;
        }

        .stat-label {
            font-size: 0.85rem;
            opacity: 0.9;
        }

        /* Profile Area in Header - FIXED FOR CLICK */
        .profile-area {
            display: flex;
            align-items: center;
            gap: 20px;
            position: relative;
        }

        .notification {
            position: relative;
            cursor: pointer;
            background: rgba(255, 255, 255, 0.2);
            width: 45px;
            height: 45px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .notification:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: scale(1.1);
        }

        .notification-badge {
            position: absolute;
            top: -5px;
            right: -5px;
            background-color: #ef4444;
            color: white;
            border-radius: 50%;
            width: 22px;
            height: 22px;
            font-size: 0.8rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            box-shadow: 0 3px 8px rgba(0, 0, 0, 0.2);
        }

        .profile-dropdown {
            position: relative;
            cursor: pointer;
        }

        .profile-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            background: rgba(255, 255, 255, 0.2);
            padding: 10px 18px;
            border-radius: 50px;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.3);
            cursor: pointer;
            white-space: nowrap;
        }

        .profile-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            border-color: rgba(255, 255, 255, 0.5);
        }

        .profile-btn.active {
            background: rgba(255, 255, 255, 0.35);
            border-color: rgba(255, 255, 255, 0.7);
        }

        .profile-pic {
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: linear-gradient(135deg, #f0f9ff, var(--light-blue));
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: var(--primary-blue);
            font-size: 1.1rem;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.15);
            flex-shrink: 0;
        }

        /* FIXED: Profile info text layout */
        .profile-info {
            text-align: left;
            display: flex;
            flex-direction: column;
            gap: 2px;
            min-width: 100px;
        }

        .profile-name {
            font-weight: 600;
            font-size: 0.95rem;
            line-height: 1.2;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .profile-role {
            font-size: 0.8rem;
            opacity: 0.9;
            line-height: 1.2;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .dropdown-icon {
            font-size: 0.9rem;
            transition: transform 0.3s ease;
            flex-shrink: 0;
        }

        .profile-btn.active .dropdown-icon {
            transform: rotate(180deg);
        }

        /* DROPDOWN MENU - FIXED TO APPEAR OUTSIDE */
        .dropdown-menu {
            position: absolute;
            top: calc(100% + 10px); /* Position outside header */
            right: 0;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            min-width: 220px;
            margin-top: 5px;
            opacity: 0;
            visibility: hidden;
            transform: translateY(-10px);
            transition: all 0.3s ease;
            z-index: 1100; /* Higher z-index */
            overflow: hidden;
            border: 1px solid #e5e7eb;
        }

        .dropdown-menu.show {
            opacity: 1;
            visibility: visible;
            transform: translateY(0);
        }

        .dropdown-menu a {
            display: flex;
            align-items: center;
            padding: 15px 20px;
            color: var(--dark-text);
            text-decoration: none;
            transition: all 0.2s ease;
            border-bottom: 1px solid #f1f5f9;
        }

        .dropdown-menu a:last-child {
            border-bottom: none;
            color: #ef4444;
        }

        .dropdown-menu a:hover {
            background-color: #f8fafc;
            padding-left: 25px;
        }

        .dropdown-menu i {
            margin-right: 12px;
            color: var(--secondary-blue);
            width: 20px;
        }

        /* Close dropdown when clicking outside */
        .dropdown-backdrop {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1099;
            display: none;
        }

        .dropdown-backdrop.active {
            display: block;
        }

        /* Enhanced Dashboard Widgets */
        .dashboard-widgets {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
            margin-bottom: 30px;
        }

        .widget {
            background-color: var(--card-white);
            border-radius: 18px;
            padding: 25px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            transition: all 0.4s ease;
            position: relative;
            overflow: hidden;
            border: 1px solid rgba(147, 197, 253, 0.3);
        }

        .widget:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 35px rgba(30, 58, 138, 0.15);
        }

        .widget:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 5px;
            background: linear-gradient(to right, var(--primary-blue), var(--accent-blue));
        }

        .widget-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .widget-title {
            font-size: 1.4rem;
            color: var(--primary-blue);
            font-weight: 700;
            position: relative;
            padding-left: 15px;
        }

        .widget-title:before {
            content: '';
            position: absolute;
            left: 0;
            top: 50%;
            transform: translateY(-50%);
            width: 5px;
            height: 70%;
            background: var(--secondary-blue);
            border-radius: 3px;
        }

        .widget-icon {
            background: linear-gradient(135deg, var(--light-blue), var(--secondary-blue));
            color: white;
            width: 50px;
            height: 50px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.4rem;
            box-shadow: 0 5px 15px rgba(14, 165, 233, 0.3);
        }

        /* Academic Summary Widget */
        .academic-summary {
            border-top: none;
        }

        .summary-items {
            display: flex;
            justify-content: space-between;
            margin-bottom: 25px;
        }

        .summary-item {
            text-align: center;
            padding: 15px;
            border-radius: 12px;
            background: linear-gradient(135deg, #f8fafc, #f0f9ff);
            flex: 1;
            margin: 0 8px;
            transition: all 0.3s ease;
        }

        .summary-item:hover {
            background: linear-gradient(135deg, #f0f9ff, #e0f2fe);
            transform: scale(1.05);
        }

        .summary-item h3 {
            font-size: 2.2rem;
            color: var(--primary-blue);
            margin-bottom: 5px;
            font-weight: 800;
        }

        .progress-container {
            margin-top: 15px;
            padding: 20px;
            background: #f8fafc;
            border-radius: 12px;
        }

        .progress-bar {
            height: 12px;
            background-color: #e5e7eb;
            border-radius: 6px;
            overflow: hidden;
            position: relative;
        }

        .progress-fill {
            height: 100%;
            background: linear-gradient(to right, var(--primary-blue), var(--accent-blue));
            width: 60%;
            border-radius: 6px;
            position: relative;
            animation: progressAnimation 2s ease-out;
        }

        @keyframes progressAnimation {
            from { width: 0; }
            to { width: 60%; }
        }

        .progress-fill:after {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.4), transparent);
            animation: shimmer 2s infinite;
        }

        @keyframes shimmer {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        .progress-label {
            display: flex;
            justify-content: space-between;
            margin-top: 10px;
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--dark-text);
        }

        /* Upcoming Sessions Widget */
        .upcoming-sessions {
            border-top: none;
        }

        .session-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px;
            border-radius: 12px;
            background: #f8fafc;
            margin-bottom: 15px;
            border-left: 5px solid var(--secondary-blue);
            transition: all 0.3s ease;
        }

        .session-item:hover {
            background: #f0f9ff;
            transform: translateX(5px);
        }

        .session-info h4 {
            color: var(--primary-blue);
            margin-bottom: 8px;
            font-size: 1.1rem;
        }

        .session-date {
            color: var(--dark-text);
            opacity: 0.7;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .session-status {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 700;
            box-shadow: 0 3px 8px rgba(6, 95, 70, 0.15);
        }

        .btn {
            padding: 10px 22px;
            border-radius: 10px;
            border: none;
            cursor: pointer;
            font-weight: 700;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-blue), var(--primary-blue));
            color: white;
            box-shadow: 0 5px 15px rgba(59, 130, 246, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 8px 20px rgba(59, 130, 246, 0.6);
        }

        /* Recent Activity Widget */
        .recent-activity {
            border-top: none;
            grid-column: span 2;
        }

        .activity-list {
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .activity-item {
            display: flex;
            align-items: center;
            padding: 18px;
            background: #f8fafc;
            border-radius: 12px;
            border-left: 5px solid var(--secondary-blue);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .activity-item:hover {
            background: #f0f9ff;
            transform: translateX(8px);
        }

        .activity-item:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 3px;
            height: 100%;
            background: var(--secondary-blue);
        }

        .activity-icon {
            background: linear-gradient(135deg, var(--light-blue), var(--secondary-blue));
            color: white;
            width: 45px;
            height: 45px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 18px;
            font-size: 1.2rem;
            box-shadow: 0 5px 15px rgba(14, 165, 233, 0.3);
            flex-shrink: 0;
        }

        .activity-content h4 {
            margin-bottom: 6px;
            color: var(--dark-text);
            font-size: 1.05rem;
        }

        .activity-content p {
            color: var(--dark-text);
            opacity: 0.8;
            font-size: 0.95rem;
            margin-bottom: 5px;
        }

        .activity-time {
            color: var(--dark-text);
            opacity: 0.6;
            font-size: 0.85rem;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* Quick Actions Widget */
        .quick-actions {
            border-top: none;
            grid-column: span 2;
        }

        .action-buttons {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }

        .action-btn {
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-blue));
            color: white;
            border: none;
            padding: 25px 15px;
            border-radius: 15px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.4s ease;
            box-shadow: 0 8px 20px rgba(30, 58, 138, 0.25);
            position: relative;
            overflow: hidden;
        }

        .action-btn:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(transparent, rgba(255, 255, 255, 0.1), transparent);
            transform: translateX(-100%);
        }

        .action-btn:hover:before {
            animation: shine 1s;
        }

        @keyframes shine {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(100%); }
        }

        .action-btn:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 30px rgba(30, 58, 138, 0.35);
        }

        .action-btn i {
            font-size: 2.2rem;
            margin-bottom: 12px;
        }

        .action-btn span {
            font-weight: 600;
            font-size: 1rem;
        }

        /* Enhanced Tables */
        .table-container {
            background-color: var(--card-white);
            border-radius: 18px;
            padding: 30px;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            margin-bottom: 30px;
            border: 1px solid rgba(147, 197, 253, 0.3);
        }

        .table-title {
            font-size: 1.5rem;
            color: var(--primary-blue);
            margin-bottom: 25px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .table-title i {
            color: var(--secondary-blue);
        }

        table {
            width: 100%;
            border-collapse: separate;
            border-spacing: 0;
        }

        th {
            background: linear-gradient(135deg, #f1f5f9, #e0f2fe);
            color: var(--primary-blue);
            padding: 18px 15px;
            text-align: left;
            font-weight: 700;
            font-size: 0.95rem;
            border-bottom: 2px solid var(--light-blue);
        }

        th:first-child {
            border-radius: 10px 0 0 0;
        }

        th:last-child {
            border-radius: 0 10px 0 0;
        }

        td {
            padding: 18px 15px;
            border-bottom: 1px solid #f1f5f9;
            transition: all 0.3s ease;
        }

        tr:hover td {
            background-color: #f8fafc;
            transform: scale(1.01);
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
        }

        tr:last-child td:first-child {
            border-radius: 0 0 0 10px;
        }

        tr:last-child td:last-child {
            border-radius: 0 0 10px 0;
        }

        .grade {
            font-weight: 800;
            color: var(--primary-blue);
            font-size: 1.1rem;
        }

        /* Footer */
        footer {
            text-align: center;
            padding: 25px;
            color: var(--dark-text);
            opacity: 0.7;
            font-size: 0.9rem;
            background: #f8fafc;
            border-radius: 15px;
            margin-top: 20px;
            border: 1px solid rgba(147, 197, 253, 0.3);
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .dashboard-widgets {
                grid-template-columns: 1fr;
            }
            
            .recent-activity, .quick-actions {
                grid-column: span 1;
            }
            
            .action-buttons {
                grid-template-columns: repeat(2, 1fr);
            }
        }

        @media (max-width: 992px) {
            .header {
                flex-direction: column;
                align-items: stretch;
                gap: 20px;
            }
            
            .stats-bar {
                justify-content: space-around;
                flex-wrap: wrap;
            }
            
            .profile-area {
                justify-content: flex-end;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 80px;
            }
            
            .logo-container h2, .logo-container p {
                display: none;
            }
            
            .nav-links a span {
                display: none;
            }
            
            .nav-links i {
                margin-right: 0;
                font-size: 1.4rem;
            }
            
            .main-content {
                margin-left: 80px;
            }
            
            .profile-btn {
                padding: 8px 12px;
            }
            
            .profile-info {
                display: none;
            }
            
            .action-buttons {
                grid-template-columns: 1fr;
            }
            
            .summary-items {
                flex-direction: column;
                gap: 15px;
            }
        }

        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .widget, .table-container {
            animation: fadeIn 0.6s ease-out;
        }
    </style>
</head>
<body>
    <!-- Backdrop for closing dropdown when clicking outside -->
    <div class="dropdown-backdrop" id="dropdownBackdrop"></div>

    <!-- Sidebar Navigation -->
    <nav class="sidebar">
        <div class="logo-container">
            <div class="logo">U</div>
            <h2>Academic Advising</h2>
            <p>Student Portal</p>
        </div>
        <ul class="nav-links">
            <li><a href="Dashboard.jsp" class="active"><i class="fas fa-home"></i> <span>Dashboard</span></a></li>
            <li><a href="Mycourse.jsp"><i class="fas fa-book"></i> <span>My Courses</span></a></li>
            <li><a href="UpdateCourse.jsp"><i class="fas fa-edit"></i> <span>Update Grade</span></a></li>
            <li><a href="AdvisingSessions.jsp"><i class="fas fa-calendar-alt"></i> <span>Advising Sessions</span></a></li>
            <li><a href="Activity.jsp"><i class="fas fa-chart-line"></i> <span>Activity</span></a></li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Enhanced Header with Profile -->
        <header class="header">
            <div class="student-info">
                <h1 id="welcomeName">Welcome Back</h1>
                <p id="studentMeta"><i class="fas fa-id-card"></i> &nbsp; | <i class="fas fa-calendar"></i> &nbsp; | <i class="fas fa-graduation-cap"></i></p>
            </div>

            <div class="stats-bar" aria-live="polite">
                <div class="stat-item">
                    <div class="stat-value" id="cgpaValue">-</div>
                    <div class="stat-label">CGPA</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value" id="creditsValue">0</div>
                    <div class="stat-label">Credits</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value" id="standingValue">-</div>
                    <div class="stat-label">Standing</div>
                </div>
                <div class="stat-item">
                    <div class="stat-value" id="sessionsValue">0</div>
                    <div class="stat-label">Sessions</div>
                </div>
            </div>

            <div class="profile-area">
                <div class="notification" id="notificationBtn" title="Notifications">
                    <i class="fas fa-bell"></i>
                    <span class="notification-badge" id="notificationCount">0</span>
                </div>
                <div id="notificationDropdown" style="position: absolute; top: calc(100% + 10px); right: 0; background: white; border-radius: 12px; box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2); min-width: 380px; max-width: 400px; opacity: 0; visibility: hidden; transform: translateY(-10px); transition: all 0.3s ease; z-index: 1100; border: 1px solid #e5e7eb; display: none; overflow: visible;">
                    <div style="padding: 15px 20px; background: linear-gradient(135deg, #1e3a8a, #3b82f6); color: white; font-weight: 600; border-bottom: 1px solid #e5e7eb; position: sticky; top: 0; z-index: 2;">
                        <i class="fas fa-bell"></i> Upcoming Sessions
                    </div>
                    <div id="notificationSessionsList" style="max-height: 432px; overflow-y: auto;">
                        <!-- Sessions populated by JS -->
                    </div>
                </div>
                <div class="profile-dropdown" id="profileDropdown">
                  <div class="profile-btn" id="profileBtn">
                    <div class="profile-pic" id="profilePic">ME</div>
                    <div class="profile-info">
                      <div class="profile-name" id="profileName">Student</div>
                      <div class="profile-role" id="profileRole">Student</div>
                    </div>
                    <i class="fas fa-chevron-down dropdown-icon"></i>
                  </div>

                  <div class="dropdown-menu" id="dropdownMenu">
                    <a href="Profile.jsp" class="dropdown-item"><i class="fas fa-user-circle"></i> My Profile</a>
                    <a href="#" class="dropdown-item" id="logoutBtn"><i class="fas fa-sign-out-alt"></i> Logout</a>
                  </div>
                </div>
            </div>
        </header>

        <!-- Dashboard Widgets -->
        <div class="dashboard-widgets">
            <!-- Academic Summary Widget -->
            <div class="widget academic-summary" role="region" aria-label="Academic summary">
                <div class="widget-header">
                    <h3 class="widget-title">Academic Summary</h3>
                    <div class="widget-icon">
                        <i class="fas fa-graduation-cap"></i>
                    </div>
                </div>
                <div class="summary-items">
                    <div class="summary-item">
                        <h3 id="summaryCgpa">-</h3>
                        <p>CGPA</p>
                        <small id="summaryCgpaNote"></small>
                    </div>
                    <div class="summary-item">
                        <h3 id="summaryCredits">0</h3>
                        <p>Credits</p>
                        <small id="summaryCreditsNote"></small>
                    </div>
                    <div class="summary-item">
                        <h3 id="summaryStanding">-</h3>
                        <p>Standing</p>
                        <small id="summaryStandingNote"></small>
                    </div>
                </div>
                <div class="progress-container" aria-hidden="false">
                    <p><strong>Degree Progress</strong></p>
                    <div class="progress-bar" aria-hidden="true">
                        <div class="progress-fill" id="degreeProgressFill" style="width:0%"></div>
                    </div>
                    <div class="progress-label">
                        <span id="progressCompleted">Semester 0 of 7</span>
                        <span id="progressRemaining">7 Semesters Remaining</span>
                    </div>
                </div>
            </div>

            <!-- Upcoming Sessions Widget -->
            <div class="widget upcoming-sessions" aria-label="Upcoming sessions">
                <div class="widget-header">
                    <h3 class="widget-title">Upcoming Sessions</h3>
                    <div class="widget-icon">
                        <i class="fas fa-calendar-check"></i>
                    </div>
                </div>
                <div id="upcomingSessionsList" aria-live="polite">
                    <!-- sessions populated by JS -->
                </div>
            </div>

            <!-- Recent Activity Widget -->
            <div class="widget recent-activity" aria-label="Recent activity">
                <div class="widget-header">
                    <h3 class="widget-title">Recent Activity</h3>
                    <div class="widget-icon">
                        <i class="fas fa-history"></i>
                    </div>
                </div>
                <div class="activity-list" id="recentActivityList">
                    <!-- items populated by JS -->
                </div>
            </div>
        </div>

        <!-- My Courses Table -->
        <div class="table-container" aria-label="My current courses">
            <h3 class="table-title"><i class="fas fa-book-open"></i> My Current Courses</h3>
            <table>
                <thead>
                    <tr>
                        <th>Course Code</th>
                        <th>Course Name</th>
                        <th>Credits</th>
                        <th>Grade</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody id="coursesTableBody">
                    <!-- populated by JS -->
                </tbody>
            </table>
        </div>

        <!-- Footer -->
        <footer>
            <p><strong>Academic Advising & Progress Tracking System</strong> | UiTM Terengganu, Campus Chendering</p>
            <p>© 2025 CSC584 - Enterprise Programming | <i class="fas fa-user-clock"></i> Last login: <span id="lastLogin">—</span></p>
        </footer>
    </div>

    <script>
    (function () {
      // Determine context path used by other pages in this project
      function getContextPath() {
        const p = window.location.pathname.split('/').filter(Boolean);
        return p.length ? '/' + p[0] : '';
      }
      const ctx = getContextPath();

      // Pagination state
      let currentCoursesPage = 0;
      const coursesPerPage = 6;
      let allCourses = [];

      // Helpers
      const q = id => document.getElementById(id);
            function getNotifKey(s) {
                if (!s) return 0;
                if (s.createdAt) {
                    const t = Date.parse(s.createdAt);
                    return isNaN(t) ? 0 : t;
                }
                if (s.sessionID) {
                    const n = Number(s.sessionID);
                    return isNaN(n) ? 0 : n;
                }
                return 0;
            }
      function escapeHtml(t){ if (!t) return ''; return String(t).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
      function fmtDate(ts) { try { const d = new Date(String(ts).replace(' ', 'T')); return isNaN(d.getTime()) ? '' : d.toLocaleString(); } catch(e){ return ''; } }

      async function apiGet(path) {
        const res = await fetch(ctx + path, { cache: 'no-store' });
        if (!res.ok) {
          if (res.status === 401) {
            window.location.href = (ctx || '/') + 'index.html';
            throw new Error('Not authenticated');
          }
          throw new Error('GET ' + path + ' returned ' + res.status);
        }
        return res.json();
      }

            // Notification badge updater: compute unseen upcoming sessions vs last seen key
            async function updateNotificationBadge() {
                try {
                    const json = await apiGet('/api/student/sessions');
                    const sessions = json.sessions || [];
                    const now = new Date();
                    const upcomingAll = sessions.filter(s => {
                        const ts = s.sessionDateTime ? new Date(String(s.sessionDateTime).replace(' ', 'T')) : null;
                        return ts && ts > now;
                    });
                    // determine latest key among upcoming
                    let latestKey = 0;
                    const keys = upcomingAll.map(getNotifKey).filter(k => k > 0);
                    if (keys.length) latestKey = Math.max(...keys);

                    const lastSeen = Number(localStorage.getItem('notifLastSeen') || 0);
                    const unseen = upcomingAll.filter(s => getNotifKey(s) > lastSeen).length;
                    q('notificationCount').textContent = unseen;
                } catch (err) {
                    // ignore badge update failures
                }
            }

      // Profile
      async function loadProfile() {
        try {
          const data = await apiGet('/api/student/me');
          const name = data.name || (data.firstName ? data.firstName + (data.lastName ? ' ' + data.lastName : '') : 'Student');
          q('welcomeName').textContent = 'Welcome back, ' + name + '!';
          q('profileName').textContent = name;
          q('profilePic').textContent = ( (data.firstName || '').charAt(0) + (data.lastName || '').charAt(0) || 'ME' ).toUpperCase();
          q('profileRole').textContent = 'Student';
          q('studentMeta').textContent = `Student ID: \${data.studentID || ''} | Semester: \${data.semester || ''} | \${data.program || ''}`;

          // Stats: prefer server values
          const cgpa = (typeof data.cgpa !== 'undefined' && data.cgpa !== null) ? Number(data.cgpa) : null;
          const credits = (typeof data.creditsCompleted !== 'undefined' && data.creditsCompleted !== null) ? Number(data.creditsCompleted) : null;
          const points = (typeof data.co_curricular_points !== 'undefined' && data.co_curricular_points !== null) ? Number(data.co_curricular_points) : 0;

          if (cgpa !== null && !isNaN(cgpa) && cgpa !== 0) {
            q('cgpaValue').textContent = cgpa.toFixed(2);
            q('summaryCgpa').textContent = cgpa.toFixed(2);
            q('summaryCgpaNote').textContent = '';
          } else {
            q('cgpaValue').textContent = '-';
            q('summaryCgpa').textContent = '-';
          }

          if (credits !== null && !isNaN(credits)) {
            q('creditsValue').textContent = credits;
            q('summaryCredits').textContent = credits;
          } else {
            q('creditsValue').textContent = 0;
            q('summaryCredits').textContent = 0;
          }

          // Update semester progress labels
          const semesterNum = Number(data.semester) || 0;
          q('progressCompleted').textContent = `Semester \${semesterNum} of 7`;
          q('progressRemaining').textContent = `\${Math.max(0, 7 - semesterNum)} Semesters Remaining`;

          q('statPoints') && (q('statPoints').textContent = points);

          // Standing: if remark set use it; otherwise derive from cgpa
          let standing = 'Not Available';
          if (data.remark && String(data.remark).trim() !== '') standing = data.remark;
          else if (cgpa !== null && !isNaN(cgpa)) {
            if (cgpa >= 3.75) standing = 'Excellent';
            else if (cgpa >= 3.5) standing = 'Very Good';
            else if (cgpa >= 3.0) standing = 'Good';
            else if (cgpa >= 2.0) standing = 'Satisfactory';
            else standing = 'Probation';
          }
          q('standingValue').textContent = standing;
          q('summaryStanding').textContent = standing;

          // Degree Progress: scale based on semester (graduates at semester 7)
          const semesterNumDeg = Number(data.semester) || 0;
          const degreeProgress = Math.min((semesterNumDeg / 7) * 100, 100);
          q('degreeProgressFill') && (q('degreeProgressFill').style.width = degreeProgress + '%');
          
          // Check if graduated (semester >= 7)
          if (semesterNumDeg >= 7) {
            const progressLabel = q('progressCompleted');
            const progressRemaining = q('progressRemaining');
            if (progressLabel) progressLabel.textContent = '🎓 Graduating';
            if (progressRemaining) progressRemaining.textContent = '0 Semesters Remaining';
          }

        } catch (err) {
          console.warn('loadProfile', err);
        }
      }

      // Courses - with pagination
      async function renderCoursesTable(rows) {
        const tbody = q('coursesTableBody');
        tbody.innerHTML = '';
        if (rows.length === 0) {
          tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:#666;padding:24px">No courses found.</td></tr>';
          return;
        }

        // Calculate pagination
        const totalPages = Math.ceil(rows.length / coursesPerPage);
        if (currentCoursesPage >= totalPages) currentCoursesPage = Math.max(0, totalPages - 1);
        const start = currentCoursesPage * coursesPerPage;
        const end = start + coursesPerPage;
        const pageRows = rows.slice(start, end);

        // Render page items
        pageRows.forEach(c => {
          const tr = document.createElement('tr');
          const gradeHtml = c.grade ? `<span class="grade">\${escapeHtml(c.grade)}</span>` : '-';
          const statusText = c.status ? escapeHtml(c.status) : '-';
          tr.innerHTML = `
            <td><strong>\${escapeHtml(c.courseID)}</strong></td>
            <td>\${escapeHtml(c.courseName)}</td>
            <td>\${escapeHtml(String(c.creditHour || 0))}</td>
            <td>\${gradeHtml}</td>
            <td>\${statusText}</td>
          `;
          tbody.appendChild(tr);
        });

        // Render pagination controls
        document.querySelector('.courses-pagination')?.remove();
        if (totalPages > 1) {
          const tableContainer = q('coursesTableBody').parentElement.parentElement;
          const paginationDiv = document.createElement('div');
          paginationDiv.className = 'courses-pagination';
          paginationDiv.style = 'display:flex;justify-content:center;gap:10px;margin-top:20px;flex-wrap:wrap;';
          let paginationHtml = `<button id="coursesPrevBtn" style="flex:0 0 auto;padding:8px 15px;border:2px solid #0ea5e9;background:transparent;color:#0ea5e9;border-radius:8px;cursor:pointer;font-weight:600;" \${currentCoursesPage === 0 ? 'disabled' : ''}>Prev</button>`;
          for (let i = 0; i < totalPages; i++) {
            paginationHtml += `<button id="coursesPageBtn\${i}" style="flex:0 0 auto;padding:8px 15px;border:2px solid #0ea5e9;background:\${i === currentCoursesPage ? '#0ea5e9' : 'transparent'};color:\${i === currentCoursesPage ? 'white' : '#0ea5e9'};border-radius:8px;cursor:pointer;font-weight:600;">\${i + 1}</button>`;
          }
          paginationHtml += `<button id="coursesNextBtn" style="flex:0 0 auto;padding:8px 15px;border:2px solid #0ea5e9;background:transparent;color:#0ea5e9;border-radius:8px;cursor:pointer;font-weight:600;" \${currentCoursesPage >= totalPages - 1 ? 'disabled' : ''}>Next</button>`;
          paginationDiv.innerHTML = paginationHtml;
          tableContainer.insertAdjacentElement('afterend', paginationDiv);

          // Wire pagination buttons
          document.getElementById('coursesPrevBtn')?.addEventListener('click', function() {
            if (currentCoursesPage > 0) {
              currentCoursesPage--;
              renderCoursesTable(allCourses);
            }
          });
          document.getElementById('coursesNextBtn')?.addEventListener('click', function() {
            if (currentCoursesPage < totalPages - 1) {
              currentCoursesPage++;
              renderCoursesTable(allCourses);
            }
          });
          for (let i = 0; i < totalPages; i++) {
            document.getElementById(`coursesPageBtn\${i}`)?.addEventListener('click', function() {
              currentCoursesPage = i;
              renderCoursesTable(allCourses);
            });
          }
        }
      }

      async function loadCourses() {
        try {
          const json = await apiGet('/api/student/courses');
          const rows = json.courses || [];
          allCourses = rows;
          currentCoursesPage = 0;
          renderCoursesTable(rows);

          // recompute simple stats if server didn't return them
          // compute CGPA & credits from returned list if not available
          try {
            let totalWeighted = 0, totalCredits = 0, creditsCompleted = 0;
            const gradeMap = { 'A+':4.0,'A':4.0,'A-':3.7,'B+':3.3,'B':3.0,'B-':2.7,'C':2.0,'D':1.0,'F':0.0 };
            rows.forEach(c => {
              const gp = (c.grade && gradeMap[c.grade]) ? gradeMap[c.grade] : null;
              const credit = Number(c.creditHour || 0);
              if (gp !== null && !isNaN(credit) && credit > 0) { totalWeighted += gp * credit; totalCredits += credit; }
              if ((c.status && c.status.toLowerCase() === 'completed') || (c.grade && c.grade.toUpperCase() !== 'NT' && c.grade !== null)) creditsCompleted += credit;
            });
            if (totalCredits > 0) {
              const cgpa = Math.round((totalWeighted / totalCredits) * 100) / 100;
              if ((!q('cgpaValue').textContent || q('cgpaValue').textContent === '-' ) && cgpa) {
                q('cgpaValue').textContent = cgpa.toFixed(2);
                q('summaryCgpa').textContent = cgpa.toFixed(2);
              }
            }
            if ((!q('creditsValue').textContent || Number(q('creditsValue').textContent) === 0) && creditsCompleted > 0) {
              q('creditsValue').textContent = creditsCompleted;
              q('summaryCredits').textContent = creditsCompleted;
            }
          } catch(e){/* ignore */}
        } catch (err) {
          console.warn('loadCourses', err);
          const tbody = q('coursesTableBody');
          tbody.innerHTML = '<tr><td colspan="7" style="text-align:center;color:#666;padding:24px">Unable to load courses.</td></tr>';
        }
      }

      // Sessions
      async function loadSessions() {
        try {
          const json = await apiGet('/api/student/sessions');
          const sessions = json.sessions || [];
          // counts
          let upcoming = 0, completed = 0, pending = 0, cancelled = 0;
          const now = Date.now();
          sessions.forEach(s => {
            const st = (s.status || '').toLowerCase();
            if (st === 'completed') completed++;
            else if (st === 'pending' || st === 'cancel_requested') pending++;
            else if (st === 'cancelled') cancelled++;
            else if (st === 'confirmed') {
              const ts = s.sessionDateTime ? new Date(String(s.sessionDateTime).replace(' ', 'T')).getTime() : 0;
              if (ts && ts > now) upcoming++;
            }
          });

          q('upcomingCount') && (q('upcomingCount').textContent = upcoming);
          q('completedCount') && (q('completedCount').textContent = completed);
          q('pendingCount') && (q('pendingCount').textContent = pending);
          q('cancelledCount') && (q('cancelledCount').textContent = cancelled);

          // also update sessionsValue stat
          q('sessionsValue') && (q('sessionsValue').textContent = sessions.length);

          // Render upcoming sessions (show next 3)
                    const upcomingList = q('upcomingSessionsList');
                    upcomingList.innerHTML = '';
                    const nowDate = new Date();
                    const filteredAll = (sessions || []).filter(s => {
                        const st = (s.status || '').toLowerCase();
                        const ts = s.sessionDateTime ? new Date(String(s.sessionDateTime).replace(' ', 'T')) : null;
                        return ts && ts > nowDate && (st === 'confirmed' || st === 'pending' || st === 'cancel_requested');
                    }).sort((a,b) => new Date(String(a.sessionDateTime).replace(' ', 'T')) - new Date(String(b.sessionDateTime).replace(' ', 'T')));

                    // show only the next 3 sessions in the dashboard widget (no scrolling)
                    upcomingList.style.maxHeight = '';
                    upcomingList.style.overflowY = 'visible';

                    const toDisplay = filteredAll.slice(0,3);

                    if (toDisplay.length === 0) {
                        upcomingList.innerHTML = '<div style="padding:12px;color:#666">No upcoming sessions.</div>';
                    } else {
                        toDisplay.forEach(s => {
              const ts = s.sessionDateTime ? new Date(String(s.sessionDateTime).replace(' ', 'T')) : null;
              const card = document.createElement('div');
              card.className = 'session-item';
              const advisorName = s.advisorName || '';
              const dateStr = ts ? ts.toLocaleDateString() : '';
              const timeStr = ts ? ts.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'}) : '';
              card.innerHTML = `
                <div class="session-info">
                  <h4>\${escapeHtml(s.title || '(no title)')}</h4>
                  <p class="session-date"><i class="far fa-calendar"></i> \${escapeHtml(dateStr)} &nbsp; <i class="far fa-clock"></i> \${escapeHtml(timeStr)}</p>
                  <p style="color:#64748b;font-size:0.9rem;margin-top:6px">\${escapeHtml(advisorName)} \${s.sessionType ? ` • \${escapeHtml(s.sessionType)}` : ''}</p>
                </div>
                <div style="text-align:right;">
                  <div class="session-status" style="margin-bottom:8px">\${escapeHtml((s.status||'').charAt(0).toUpperCase() + (s.status||'').slice(1))}</div>
                  <button class="btn btn-outline btn-sm view-session" data-id="\${escapeHtml(String(s.sessionID||''))}">View</button>
                </div>
              `;
              upcomingList.appendChild(card);
            });
            // bind view buttons
            upcomingList.querySelectorAll('.view-session').forEach(b => b.addEventListener('click', function() {
              const id = this.dataset.id;
              // reuse previous "notes" modal in other pages: here we just redirect to sessions page with anchor
              window.location.href = ctx + '/Student/AdvisingSessions.html';
            }));
          }

        } catch (err) {
          console.warn('loadSessions', err);
          const upcomingList = q('upcomingSessionsList');
          upcomingList.innerHTML = '<div style="padding:12px;color:#666">Unable to load sessions.</div>';
        }
      }

      // Activities (recent)
      async function loadActivities() {
        try {
          const json = await apiGet('/api/activities');
          const acts = json.activities || [];
          if (!Array.isArray(acts) || acts.length === 0) {
            q('recentActivityList').innerHTML = '<div style="padding:12px;color:#666">No recent activity.</div>';
            return;
          }

          // pick recent activities relevant to the student: joined or owned, and limit 3 by datetime order
          const recent = acts.slice().sort((a,b) => new Date(b.dateTime||0) - new Date(a.dateTime||0)).filter(a => a.joined || (a.ownerID && a.ownerID === String(q('profileName').dataset?.userId || ''))).slice(0,3);

          const list = q('recentActivityList');
          list.innerHTML = '';
          // fallback: if no joined/owned, show latest activities
          const source = (recent.length > 0) ? recent : acts.slice(0,3);

          source.forEach(a => {
            const dt = a.dateTime ? fmtDate(a.dateTime) : '';
            const item = document.createElement('div');
            item.className = 'activity-item';
            item.innerHTML = `
              <div class="activity-icon"><i class="fas fa-running"></i></div>
              <div style="flex:1">
                <div class="activity-content">
                  <h4>\${escapeHtml(a.title || '(no title)')}</h4>
                  <p>\${escapeHtml((a.description || '').substring(0,120))}\${(a.description || '').length>120 ? '...' : ''}</p>
                  <div class="activity-time"><i class="far fa-calendar"></i>&nbsp; \${escapeHtml(dt)}</div>
                </div>
              </div>
              <div style="min-width:110px;text-align:right">
                <div style="font-weight:700;color:#1e3a8a">\${a.points ? (a.points + ' pts') : '0 pts'}</div>
                <div style="margin-top:8px">\${a.joined ? '<span style="color:#059669;font-weight:700">Joined</span>' : (a.ownerID ? '<span style="color:#1e40af">Organized</span>' : '')}</div>
              </div>
            `;
            list.appendChild(item);
          });

        } catch (err) {
          console.warn('loadActivities', err);
          q('recentActivityList').innerHTML = '<div style="padding:12px;color:#666">Unable to load recent activity.</div>';
        }
      }

      // Profile dropdown & logout wiring
      function wireUI() {
        const profileBtn = q('profileBtn');
        const dropdownMenu = q('dropdownMenu');
        const dropdownBackdrop = q('dropdownBackdrop');
        const logoutBtn = q('logoutBtn');

        if (profileBtn && dropdownMenu) {
          profileBtn.addEventListener('click', function(e){ e.stopPropagation(); dropdownMenu.classList.toggle('show'); profileBtn.classList.toggle('active'); dropdownBackdrop.classList.toggle('active'); });
          document.addEventListener('click', function(e){ if (!profileBtn.contains(e.target) && !dropdownMenu.contains(e.target)) { dropdownMenu.classList.remove('show'); profileBtn.classList.remove('active'); dropdownBackdrop.classList.remove('active'); }});
          document.addEventListener('keydown', function(e){ if (e.key === 'Escape') { dropdownMenu.classList.remove('show'); profileBtn.classList.remove('active'); dropdownBackdrop.classList.remove('active'); }});
        }
        if (logoutBtn) {
          logoutBtn.addEventListener('click', function(e){ e.preventDefault(); if (!confirm('Log out?')) return; window.location.href = ctx + '/logout'; });
        }

                const notif = q('notificationBtn');
                const notifDropdown = q('notificationDropdown');
                const notifList = q('notificationSessionsList');
                if (notif && notifDropdown && notifList) {
                    notif.addEventListener('click', async function(e){
                        e.stopPropagation();
                        // toggle dropdown
                        const isVisible = notifDropdown.style.display === 'block';
                        document.querySelectorAll('#notificationDropdown').forEach(d => { d.style.display = 'none'; d.style.opacity = '0'; d.style.visibility = 'hidden'; });
                        if (isVisible) {
                            notifDropdown.style.display = 'none'; notifDropdown.style.opacity = '0'; notifDropdown.style.visibility = 'hidden';
                            return;
                        }
                        // fetch sessions and show recent ones by creation (if available) or sessionDateTime desc
                        notifList.innerHTML = '<div style="padding:12px;color:#666">Loading...</div>';
                        notifDropdown.style.display = 'block'; notifDropdown.style.opacity = '1'; notifDropdown.style.visibility = 'visible';
                        try {
                            const json = await apiGet('/api/student/sessions');
                            const sessions = json.sessions || [];
                            // Sort by createdAt if present, otherwise by sessionID desc (assumes newer have larger IDs)
                            sessions.sort((a,b) => {
                                const ta = a.createdAt ? new Date(a.createdAt).getTime() : (a.sessionID ? Number(a.sessionID) : 0);
                                const tb = b.createdAt ? new Date(b.createdAt).getTime() : (b.sessionID ? Number(b.sessionID) : 0);
                                return tb - ta;
                            });
                            // only upcoming sessions (sessionDateTime in future)
                            const now = new Date();
                            const upcomingAll = sessions.filter(s => {
                                const ts = s.sessionDateTime ? new Date(String(s.sessionDateTime).replace(' ', 'T')) : null;
                                return ts && ts > now;
                            });

                            // make container show up to 6 items height and scroll beyond
                            notifList.style.maxHeight = '432px';
                            notifList.style.overflowY = 'auto';

                            // compute unseen count before marking seen
                            const lastSeen = Number(localStorage.getItem('notifLastSeen') || 0);
                            const latestKey = upcomingAll.map(getNotifKey).reduce((a,b)=>Math.max(a,b),0);
                            const unseen = upcomingAll.filter(s => getNotifKey(s) > lastSeen).length;
                            q('notificationCount').textContent = unseen;

                            if (upcomingAll.length === 0) {
                                notifList.innerHTML = '<div style="padding:12px;color:#666">No upcoming sessions.</div>';
                            } else {
                                notifList.innerHTML = '';
                                upcomingAll.forEach(s => {
                                    const ts = s.sessionDateTime ? new Date(String(s.sessionDateTime).replace(' ', 'T')) : null;
                                    const dateStr = ts ? ts.toLocaleDateString() : '';
                                    const timeStr = ts ? ts.toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'}) : '';
                                    const item = document.createElement('div');
                                    item.style = 'padding:12px 16px;border-bottom:1px solid #f1f5f9;display:flex;justify-content:space-between;align-items:center;gap:10px;';
                                    item.innerHTML = `<div style="flex:1"><div style="font-weight:600;color:#1e3a8a">\${escapeHtml(s.title||'(no title)')}</div><div style="color:#64748b;font-size:0.9rem">\${escapeHtml(dateStr)} • \${escapeHtml(timeStr)}\${s.sessionType? ' • '+escapeHtml(s.sessionType):''}</div></div><div style="flex-shrink:0"><button class="btn btn-outline" style="padding:6px 10px;flex:0 0 auto;" data-id="\${escapeHtml(String(s.sessionID||''))}">View</button></div>`;
                                    notifList.appendChild(item);
                                });

                                // bind view buttons
                                notifList.querySelectorAll('button[data-id]').forEach(b => b.addEventListener('click', function(){
                                    const id = this.dataset.id;
                                    window.location.href = ctx + '/Student/AdvisingSessions.html';
                                }));
                            }
                                                        // mark these as seen now (store latest key)
                                                        if (latestKey && latestKey > 0) {
                                                            localStorage.setItem('notifLastSeen', String(latestKey));
                                                        }
                                                        q('notificationCount').textContent = 0;
                        } catch (err) {
                            console.warn('notif fetch', err);
                            notifList.innerHTML = '<div style="padding:12px;color:#666">Unable to load notifications.</div>';
                        }
                    });

                    // close when clicking outside
                    document.addEventListener('click', function(e){ if (!notif.contains(e.target) && !notifDropdown.contains(e.target)) { notifDropdown.style.display='none'; notifDropdown.style.opacity='0'; notifDropdown.style.visibility='hidden'; } });
                }

        q('requestSessionBtn') && q('requestSessionBtn').addEventListener('click', function(){ window.location.href = ctx + '/Student/AdvisingSessions.html'; });
        q('viewCoursesBtn') && q('viewCoursesBtn').addEventListener('click', function(){ window.location.href = ctx + '/Student/Mycourse.html'; });
      }

      // initialize
            async function init() {
                wireUI();
                // load concurrently
                await Promise.allSettled([ loadProfile(), loadCourses(), loadSessions(), loadActivities(), updateNotificationBadge() ]);
            }

      // run on load
      init();

    // refresh periodically (every 90s)
    setInterval(function(){ loadSessions().catch(()=>{}); loadActivities().catch(()=>{}); updateNotificationBadge().catch(()=>{}); }, 90_000);
    })();
    </script>
</body>
</html>