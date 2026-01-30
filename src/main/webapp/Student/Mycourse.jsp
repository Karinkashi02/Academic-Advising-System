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
    <title>My Courses - Academic Advising & Progress Tracking</title>
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

        /* Sidebar Navigation */
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

        /* Header */
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
        }

        .page-title {
            font-size: 2rem;
            font-weight: 700;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .page-title i {
            color: var(--light-blue);
        }

        /* Profile Area */
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

        /* Dropdown Menu */
        .dropdown-menu {
            position: absolute;
            top: calc(100% + 10px);
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
            z-index: 1100;
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

        /* Backdrop */
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

        /* Courses Page Content */
        .courses-container {
            display: grid;
            grid-template-columns: 1fr;
            gap: 30px;
        }

        /* Filters and Actions Bar */
        .filters-bar {
            background-color: var(--card-white);
            border-radius: 15px;
            padding: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .filter-group {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .filter-select {
            padding: 10px 15px;
            border: 2px solid var(--light-blue);
            border-radius: 8px;
            background: white;
            color: var(--dark-text);
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .filter-select:hover {
            border-color: var(--secondary-blue);
        }

        .search-box {
            display: flex;
            align-items: center;
            background: white;
            border: 2px solid var(--light-blue);
            border-radius: 8px;
            padding: 8px 15px;
            gap: 10px;
        }

        .search-box input {
            border: none;
            outline: none;
            width: 200px;
            font-size: 0.95rem;
            color: var(--dark-text);
        }

        .search-box i {
            color: var(--secondary-blue);
        }

        /* Statistics Cards */
        .stats-cards {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--card-white);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
            display: flex;
            align-items: center;
            gap: 20px;
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-5px);
        }

        .stat-icon {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            color: white;
        }

        .stat-icon.grade {
            background: linear-gradient(135deg, #10b981, #34d399);
        }

        .stat-icon.credits {
            background: linear-gradient(135deg, #3b82f6, #60a5fa);
        }

        .stat-icon.gpa {
            background: linear-gradient(135deg, #8b5cf6, #a78bfa);
        }

        .stat-icon.status {
            background: linear-gradient(135deg, #f59e0b, #fbbf24);
        }

        .stat-content h3 {
            font-size: 2rem;
            font-weight: 800;
            color: var(--primary-blue);
            margin-bottom: 5px;
        }

        .stat-content p {
            color: var(--dark-text);
            opacity: 0.8;
            font-size: 0.9rem;
        }

        /* Course Cards */
        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }

        .course-card {
            background: var(--card-white);
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
            transition: all 0.4s ease;
            position: relative;
            border: 1px solid rgba(147, 197, 253, 0.3);
        }

        .course-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 15px 30px rgba(30, 58, 138, 0.15);
        }

        .course-header {
            padding: 20px;
            background: linear-gradient(135deg, var(--light-blue), var(--secondary-blue));
            color: white;
            position: relative;
        }

        .course-code {
            font-size: 0.9rem;
            opacity: 0.9;
            margin-bottom: 5px;
        }

        .course-name {
            font-size: 1.3rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .course-credits {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.9rem;
            opacity: 0.95;
        }

        .course-status {
            position: absolute;
            top: 20px;
            right: 20px;
        }

        .course-body {
            padding: 20px;
        }

        .course-info {
            display: flex;
            flex-direction: column;
            gap: 15px;
            margin-bottom: 20px;
        }

        .info-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-bottom: 10px;
            border-bottom: 1px solid #f1f5f9;
        }

        .info-label {
            color: var(--dark-text);
            opacity: 0.7;
            font-size: 0.9rem;
        }

        .info-value {
            font-weight: 600;
            color: var(--primary-blue);
        }

        .grade-badge {
            background: linear-gradient(135deg, #10b981, #34d399);
            color: white;
            padding: 6px 15px;
            border-radius: 20px;
            font-weight: 700;
            font-size: 1.1rem;
            display: inline-block;
        }

        .grade-badge.na {
            background: linear-gradient(135deg, #9ca3af, #d1d5db);
        }

        .course-actions {
            display: flex;
            gap: 10px;
            margin-top: 15px;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 0.9rem;
        }

        .btn-outline {
            background: transparent;
            border: 2px solid var(--secondary-blue);
            color: var(--secondary-blue);
            flex: 1;
        }

        .btn-outline:hover {
            background: var(--secondary-blue);
            color: white;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-blue), var(--primary-blue));
            color: white;
            flex: 1;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(59, 130, 246, 0.6);
        }

        /* Detailed Table View */
        .detailed-view {
            background: var(--card-white);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
            margin-bottom: 30px;
            margin-top: 30px;
        }

        .view-title {
            font-size: 1.5rem;
            color: var(--primary-blue);
            margin-bottom: 25px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 12px;
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
        }

        .status-badge {
            padding: 6px 15px;
            border-radius: 20px;
            font-size: 0.85rem;
            font-weight: 700;
            display: inline-block;
        }

        .status-completed {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
        }

        .status-ongoing {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1e40af;
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

        /* Modal for Course Details */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1200;
            align-items: center;
            justify-content: center;
        }

        .modal.show {
            display: flex;
        }

        .modal-content {
            background: white;
            border-radius: 20px;
            width: 90%;
            max-width: 600px;
            max-height: 80vh;
            overflow-y: auto;
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.2);
        }

        .modal-header {
            padding: 25px 30px;
            background: linear-gradient(135deg, var(--light-blue), var(--secondary-blue));
            color: white;
            border-radius: 20px 20px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .modal-title {
            font-size: 1.5rem;
            font-weight: 700;
        }

        .modal-close {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            color: white;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s ease;
        }

        .modal-close:hover {
            background: rgba(255, 255, 255, 0.3);
        }

        .modal-body {
            padding: 30px;
        }

        .modal-section {
            margin-bottom: 25px;
        }

        .modal-section h4 {
            color: var(--primary-blue);
            margin-bottom: 15px;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .modal-section p {
            color: var(--dark-text);
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .modal-info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
        }

        .modal-info-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .modal-label {
            color: var(--dark-text);
            opacity: 0.7;
            font-size: 0.9rem;
        }

        .modal-value {
            font-weight: 600;
            color: var(--primary-blue);
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .stats-cards {
                grid-template-columns: repeat(2, 1fr);
            }

            .course-grid {
                grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            }
        }

        @media (max-width: 992px) {
            .header {
                flex-direction: column;
                align-items: stretch;
                gap: 20px;
            }

            .filters-bar {
                flex-direction: column;
                gap: 15px;
            }

            .filter-group {
                flex-wrap: wrap;
                justify-content: center;
            }

            .search-box {
                width: 100%;
            }

            .search-box input {
                width: 100%;
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
                padding: 15px;
            }

            .stats-cards {
                grid-template-columns: 1fr;
            }

            .course-grid {
                grid-template-columns: 1fr;
            }

            .profile-btn {
                padding: 8px 12px;
            }

            .profile-info {
                display: none;
            }

            .modal-content {
                width: 95%;
                margin: 10px;
            }
        }

        @media (max-width: 576px) {
            .page-title {
                font-size: 1.5rem;
            }

            .tabs-nav {
                flex-wrap: wrap;
                justify-content: center;
            }

            .tab-btn {
                padding: 8px 15px;
                font-size: 0.9rem;
            }

            .modal-info-grid {
                grid-template-columns: 1fr;
            }
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
            <li><a href="Dashboard.jsp"><i class="fas fa-home"></i> <span>Dashboard</span></a></li>
            <li><a href="Mycourse.jsp" class="active"><i class="fas fa-book"></i> <span>My Courses</span></a></li>
            <li><a href="UpdateCourse.jsp"><i class="fas fa-edit"></i> <span>Update Grade</span></a></li>
            <li><a href="AdvisingSessions.jsp"><i class="fas fa-calendar-alt"></i> <span>Advising Sessions</span></a></li>
            <li><a href="Activity.jsp"><i class="fas fa-chart-line"></i> <span>Activity</span></a></li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Header -->
        <header class="header">
            <div class="page-title">
                <i class="fas fa-book-open"></i>
                <span>My Courses</span>
            </div>

            <div class="profile-area">
                <div class="profile-dropdown" id="profileDropdown">
                    <div class="profile-btn" id="profileBtn">
                      <div class="profile-pic" id="profilePic">MA</div>
                      <div class="profile-info">
                        <div class="profile-name" id="profileName">M. Amar Ghazali</div>
                        <div class="profile-role" id="profileRole">Student</div>
                      </div>
                      <i class="fas fa-chevron-down dropdown-icon"></i>
                    </div>

                    <div class="dropdown-menu" id="dropdownMenu">
                      <div class="dropdown-header" id="profileMenuHeader" style="padding:12px 20px; background:#f8fafc; border-bottom:1px solid #e5e7eb; font-weight:600; color:var(--primary-blue);"></div>
                      <a href="Profile.jsp" class="dropdown-item"><i class="fas fa-user-circle"></i> My Profile</a>
                      <a href="#" class="dropdown-item" id="logoutBtn"><i class="fas fa-sign-out-alt"></i> Logout</a>
                    </div>
                </div>
            </div>
        </header>

        <!-- Statistics Cards: these values are updated by JS -->
        <div class="stats-cards">
            <div class="stat-card">
                <div class="stat-icon grade"><i class="fas fa-award"></i></div>
                <div class="stat-content">
                    <h3 id="statCgpa">-</h3>
                    <p>Current CGPA</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon credits"><i class="fas fa-graduation-cap"></i></div>
                <div class="stat-content">
                    <h3 id="statCredits">0</h3>
                    <p>Credits Completed</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon gpa"><i class="fas fa-chart-line"></i></div>
                <div class="stat-content">
                    <h3 id="statLastGpa">-</h3>
                    <p>Last Semester GPA</p>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon status"><i class="fas fa-check-circle"></i></div>
                <div class="stat-content">
                    <h3 id="statStanding">-</h3>
                    <p>Academic Standing</p>
                </div>
            </div>
        </div>

        <!-- Filters and Actions Bar -->
        <div class="filters-bar">
            <div class="filter-group">
                <select class="filter-select" id="semesterFilter">
                    <option value="all">All Semesters</option>
                    <option value="1">Semester 1</option>
                    <option value="2">Semester 2</option>
                    <option value="3">Semester 3</option>
                    <option value="4">Semester 4</option>
                </select>
                <select class="filter-select" id="statusFilter">
                    <option value="all">All Status</option>
                    <option value="completed">Completed</option>
                    <option value="ongoing">Ongoing</option>
                </select>
                <select class="filter-select" id="sortFilter">
                    <option value="name">Sort by Name</option>
                    <option value="code">Sort by Code</option>
                    <option value="semester">Sort by Semester</option>
                    <option value="credits">Sort by Credits</option>
                </select>
            </div>
            <button class="btn btn-primary" id="addCourseBtn" style="margin-left: auto; flex: 0 0 auto; padding: 10px 18px; width: auto; margin-right: 20px;">
                <i class="fas fa-plus"></i> Add Course
            </button>
            <div class="search-box">
                <i class="fas fa-search"></i>
                <input type="text" id="courseSearch" placeholder="Search courses..." >
            </div>
        </div>

        <div class="course-grid" id="courseGrid"></div>

        <!-- Add Course Modal -->
        <div class="modal" id="addCourseModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="modal-title"><i class="fas fa-plus-circle"></i> Add New Course</h2>
                    <button class="modal-close" id="closeAddCourseModal">&times;</button>
                </div>
                <div class="modal-body">
                    <form id="addCourseForm">
                        <div class="modal-section">
                            <div class="modal-info-grid">
                                <div class="modal-info-item">
                                    <label class="modal-label">Course Code *</label>
                                    <input type="text" id="addCourseCode" placeholder="e.g., CS101" required style="padding: 10px; border: 2px solid #93c5fd; border-radius: 8px; font-size: 1rem;">
                                </div>
                                <div class="modal-info-item">
                                    <label class="modal-label">Course Name *</label>
                                    <input type="text" id="addCourseName" placeholder="e.g., Introduction to Programming" required style="padding: 10px; border: 2px solid #93c5fd; border-radius: 8px; font-size: 1rem;">
                                </div>
                                <div class="modal-info-item">
                                    <label class="modal-label">Credit Hours *</label>
                                    <input type="number" id="addCourseCredits" placeholder="e.g., 3" min="1" max="6" required style="padding: 10px; border: 2px solid #93c5fd; border-radius: 8px; font-size: 1rem;">
                                </div>
                                <div class="modal-info-item">
                                    <label class="modal-label">Semester *</label>
                                    <select id="addCourseSemester" required style="padding: 10px; border: 2px solid #93c5fd; border-radius: 8px; font-size: 1rem;">
                                        <option value="">-- Select Semester --</option>
                                        <option value="1">Semester 1</option>
                                        <option value="2">Semester 2</option>
                                        <option value="3">Semester 3</option>
                                        <option value="4">Semester 4</option>
                                        <option value="5">Semester 5</option>
                                        <option value="6">Semester 6</option>
                                        <option value="7">Semester 7</option>
                                    </select>
                                </div>
                                <div class="modal-info-item">
                                    <label class="modal-label">Program</label>
                                    <input type="text" id="addCourseProgram" placeholder="e.g., Computer Science" style="padding: 10px; border: 2px solid #93c5fd; border-radius: 8px; font-size: 1rem;">
                                </div>
                                <div class="modal-info-item">
                                    <label class="modal-label">Status</label>
                                    <select id="addCourseStatus" style="padding: 10px; border: 2px solid #93c5fd; border-radius: 8px; font-size: 1rem;">
                                        <option value="ongoing">Ongoing</option>
                                        <option value="completed">Completed</option>
                                    </select>
                                </div>
                                <div class="modal-info-item">
                                    <label class="modal-label">Grade (if completed)</label>
                                    <select id="addCourseGrade" style="padding: 10px; border: 2px solid #93c5fd; border-radius: 8px; font-size: 1rem;">
                                        <option value="">-- No Grade --</option>
                                        <option value="A+">A+ (4.0)</option>
                                        <option value="A">A (4.0)</option>
                                        <option value="A-">A- (3.7)</option>
                                        <option value="B+">B+ (3.3)</option>
                                        <option value="B">B (3.0)</option>
                                        <option value="B-">B- (2.7)</option>
                                        <option value="C+">C+ (2.3)</option>
                                        <option value="C">C (2.0)</option>
                                        <option value="C-">C- (1.7)</option>
                                        <option value="D+">D+ (1.3)</option>
                                        <option value="D">D (1.0)</option>
                                        <option value="F">F (0.0)</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        <div style="display: flex; gap: 10px; margin-top: 20px;">
                            <button type="submit" class="btn btn-primary" style="flex: 1;">
                                <i class="fas fa-check"></i> Add Course
                            </button>
                            <button type="button" class="btn btn-outline" id="cancelAddCourseBtn" style="flex: 1;">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </div>
                        <div id="addCourseMessage" style="margin-top: 15px; padding: 10px; border-radius: 8px; display: none;"></div>
                    </form>
                </div>
            </div>
        </div>

        <div class="detailed-view">
            <h3 class="view-title"><i class="fas fa-table"></i> All Courses Overview</h3>
            <table id="coursesTable">
                <thead>
                    <tr>
                        <th>Course Code</th>
                        <th>Course Name</th>
                        <th>Credits</th>
                        <th>Semester</th>
                        <th>Program</th>
                        <th>Grade</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody id="coursesTableBody"></tbody>
            </table>
        </div>

        <!-- Footer -->
        <footer>
            <p><strong>Academic Advising & Progress Tracking System</strong> | UiTM Terengganu, Campus Chendering</p>
            <p>© 2025 CSC584 - Enterprise Programming | <i class="fas fa-user-clock"></i> Last login: Dec 10, 2025 14:30 | <i class="fas fa-shield-alt"></i> Secure Connection</p>
        </footer>
    </div>

    <script>
    document.addEventListener('DOMContentLoaded', function() {
        // Determine context path
        function getContextPath() {
            const p = window.location.pathname.split('/').filter(Boolean);
            return p.length ? '/' + p[0] : '';
        }
        const ctx = getContextPath();

        // Helpers
        const q = id => document.getElementById(id);
        function escapeHtml(t){ if (!t) return ''; return String(t).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }

        // Elements
        const statCgpaEl = q('statCgpa');
        const statCreditsEl = q('statCredits');
        const statLastGpaEl = q('statLastGpa');
        const statStandingEl = q('statStanding');

        const courseGrid = q('courseGrid');
        const coursesTableBody = q('coursesTableBody');
        const semesterFilter = q('semesterFilter');
        const statusFilter = q('statusFilter');
        const sortFilter = q('sortFilter');
        const courseSearch = q('courseSearch');

        const profileBtn = q('profileBtn');
        const profileMenu = q('dropdownMenu');
        const profileNameEl = q('profileName');
        const profilePicEl = q('profilePic');
        const profileMenuHeader = q('profileMenuHeader');
        const logoutBtn = q('logoutBtn');

        // state
        let courses = [];
        let student = {}; // from /api/student/me
        let currentGridPage = 0;
        let currentTablePage = 0;
        const itemsPerPage = 6;

        // grade -> point mapping (same as server)
        function gradeToPoint(g) {
            if (!g) return null;
            const grade = String(g).trim().toUpperCase();
            switch(grade){
                case 'A+': return 4.0;
                case 'A': return 4.0;
                case 'A-': return 3.7;
                case 'B+': return 3.3;
                case 'B': return 3.0;
                case 'B-': return 2.7;
                case 'C': return 2.0;
                case 'D': return 1.0;
                case 'F': return 0.0;
                default: return null;
            }
        }

        async function apiGet(path) {
            const res = await fetch(ctx + path, { cache: 'no-store' });
            if (!res.ok) throw new Error('GET ' + path + ' ' + res.status);
            return res.json();
        }

        // load profile from server and update dropdown/avatars
        async function loadProfile() {
            try {
                const res = await fetch(ctx + '/api/student/me', { cache: 'no-store' });
                if (!res.ok) return;
                const json = await res.json();
                student = json || student || {};
                const name = student.name || (student.firstName ? (student.firstName + (student.lastName ? ' ' + student.lastName : '')) : (profileNameEl ? profileNameEl.textContent : ''));
                if (profileNameEl) profileNameEl.textContent = name;
                if (profileMenuHeader) profileMenuHeader.textContent = name;
                if (profilePicEl) {
                    let initials = 'ME';
                    if (student.firstName || student.lastName) initials = ((student.firstName||'').charAt(0) + (student.lastName||'').charAt(0)).toUpperCase();
                    else if (name) {
                        const parts = String(name).trim().split(/\s+/);
                        initials = (parts[0].charAt(0) + (parts.length>1 ? parts[parts.length-1].charAt(0) : '')).toUpperCase();
                    }
                    profilePicEl.textContent = initials || 'ME';
                }
            } catch (e) {
                console.warn('Could not load profile', e);
            }
        }

        // fetch profile and courses and update UI
        async function loadAll() {
            try {
                // fetch student profile (so stats can prefer server values)
                await loadProfile();

                // fetch courses
                try {
                    const cjson = await apiGet('/api/student/courses');
                    courses = cjson.courses || [];
                } catch (e) {
                    console.warn('student/courses fetch failed', e);
                    courses = [];
                }

                // Update stats
                updateStats();

                // Render UI lists
                renderCourseCards(courses);
                renderTable(courses);
            } catch (err) {
                console.error('loadAll', err);
            }
        }

        // compute CGPA if server doesn't provide it (or provided value is zero/unset)
        function computeCgpaFromCourses(list) {
            let totalWeighted = 0;
            let totalCredits = 0;
            list.forEach(c => {
                const g = c.grade;
                const credit = Number(c.creditHour || 0);
                const gp = gradeToPoint(g);
                if (gp !== null && !isNaN(credit) && credit > 0) {
                    totalWeighted += gp * credit;
                    totalCredits += credit;
                }
            });
            if (totalCredits === 0) return null;
            return Math.round((totalWeighted / totalCredits) * 100) / 100;
        }

        // compute credits completed from courses list: only count credits for courses that are actually completed
        function computeCreditsCompleted(list) {
            let sum = 0;
            list.forEach(c => {
                const st = (c.status || '').toLowerCase();
                const grade = (c.grade || '').toUpperCase();
                // Count credit if status is completed OR grade maps to a valid grade point
                if (st === 'completed' || gradeToPoint(grade) !== null) {
                    sum += Number(c.creditHour || 0);
                }
            });
            return sum;
        }

        // compute last semester GPA
        function computeLastSemesterGpa(list, studentSemesterVal) {
            if (!Array.isArray(list) || list.length === 0) return null;
            let currentSem = Number(studentSemesterVal || 0);
            if (!currentSem || isNaN(currentSem)) {
                const sems = list.map(c => Number(c.semester || 0)).filter(n => n > 0);
                if (sems.length === 0) return null;
                const maxSem = Math.max(...sems);
                currentSem = maxSem;
            }
            const lastSem = Math.max(1, currentSem - 1);
            let candidates = list.filter(c => Number(c.semester || 0) === lastSem);
            if (candidates.length === 0 && currentSem > 0) candidates = list.filter(c => Number(c.semester || 0) === currentSem);
            if (candidates.length === 0) return null;
            let totalWeighted = 0; let totalCredits = 0;
            candidates.forEach(c => {
                const gp = gradeToPoint(c.grade);
                const credit = Number(c.creditHour || 0);
                if (gp !== null && !isNaN(credit) && credit > 0) {
                    totalWeighted += gp * credit;
                    totalCredits += credit;
                }
            });
            if (totalCredits === 0) return null;
            return Math.round((totalWeighted / totalCredits) * 100) / 100;
        }

        // determine academic standing
        function deriveAcademicStanding(cgpaVal, studentRemark) {
            if (studentRemark && String(studentRemark).trim() !== '') return String(studentRemark);
            const g = Number(cgpaVal);
            if (!g || isNaN(g)) return 'Not Available';
            if (g >= 3.75) return 'Excellent';
            if (g >= 3.5) return 'Very Good';
            if (g >= 3.0) return 'Good';
            if (g >= 2.0) return 'Satisfactory';
            return 'Probation';
        }

        // update the stat cards in DOM
        function updateStats() {
            // CGPA: prefer server-provided student.cgpa (non-zero), fallback to computed
            let cgpa = (student && (typeof student.cgpa !== 'undefined' && student.cgpa !== null)) ? Number(student.cgpa) : null;
            if ((cgpa === null || isNaN(cgpa) || cgpa === 0) && courses.length > 0) {
                const comp = computeCgpaFromCourses(courses);
                if (comp !== null) cgpa = comp;
            }
            statCgpaEl.textContent = (cgpa === null || isNaN(cgpa) || cgpa === 0) ? '-' : cgpa.toFixed(2);

            // Credits completed: prefer server value if present; else compute
            let credits = (student && (typeof student.creditsCompleted !== 'undefined' && student.creditsCompleted !== null)) ? Number(student.creditsCompleted) : null;
            if (credits === null || isNaN(credits) || credits === 0) {
                credits = computeCreditsCompleted(courses);
            }
            statCreditsEl.textContent = credits || 0;

            // last semester GPA
            let lastGpa = computeLastSemesterGpa(courses, student && student.semester ? student.semester : null);
            statLastGpaEl.textContent = (lastGpa === null) ? '-' : lastGpa.toFixed(2);

            // standing
            const standing = deriveAcademicStanding(cgpa, student && student.remark ? student.remark : null);
            statStandingEl.textContent = standing;
        }

        // render course cards with pagination
        function renderCourseCards(list) {
            courseGrid.innerHTML = '';
            if (!Array.isArray(list) || list.length === 0) {
                courseGrid.innerHTML = `<div style="grid-column: 1 / -1; text-align:center; padding:40px; color:#666">No courses found.</div>`;
                // Remove pagination if no courses
                document.querySelector('.grid-pagination')?.remove();
                return;
            }

            // Calculate pagination
            const totalPages = Math.ceil(list.length / itemsPerPage);
            if (currentGridPage >= totalPages) currentGridPage = Math.max(0, totalPages - 1);
            const start = currentGridPage * itemsPerPage;
            const end = start + itemsPerPage;
            const pageItems = list.slice(start, end);

            // Render page items
            pageItems.forEach(course => {
                const card = document.createElement('div');
                card.className = 'course-card';
                const statusText = course.status ? (course.status.charAt(0).toUpperCase()+course.status.slice(1)) : '';
                // map status to CSS class
                let statusClass = '';
                if (String(statusText).toLowerCase() === 'completed') statusClass = 'status-completed';
                else if (String(statusText).toLowerCase() === 'ongoing') statusClass = 'status-ongoing';

                const gradeHtml = course.grade ? `<span class="grade-badge">\${escapeHtml(course.grade)}</span>` : `<span class="grade-badge na">-</span>`;

                card.innerHTML = `
                    <div class="course-header">
                        <div class="course-code">\${escapeHtml(course.courseID || '')}</div>
                        <div class="course-name">\${escapeHtml(course.courseName || '')}</div>
                        <div class="course-credits"><i class="fas fa-clock"></i> <span>\${escapeHtml(String(course.creditHour || '0'))} Credit Hours</span></div>
                        <div class="course-status"><span class="status-badge \${statusClass}">\${escapeHtml(statusText)}</span></div>
                    </div>
                    <div class="course-body">
                        <div class="course-info">
                            <div class="info-item"><span class="info-label">Semester</span><span class="info-value">Semester \${escapeHtml(String(course.semester || ''))}</span></div>
                            <div class="info-item"><span class="info-label">Program</span><span class="info-value">\${escapeHtml(course.program || '')}</span></div>
                            <div class="info-item"><span class="info-label">\${(String(course.status || '').toLowerCase() === 'completed') ? 'Final Grade' : 'Current Grade'}</span>
                                \${gradeHtml}
                            </div>
                        </div>
                    </div>
                `;
                courseGrid.appendChild(card);
            });

            // Render pagination controls
            document.querySelector('.grid-pagination')?.remove();
            if (totalPages > 1) {
                const paginationDiv = document.createElement('div');
                paginationDiv.className = 'grid-pagination';
                paginationDiv.style = 'display:flex;justify-content:center;gap:10px;margin-top:30px;flex-wrap:wrap;';
                let paginationHtml = `<button id="gridPrevBtn" class="btn btn-outline" style="flex:0 0 auto;" \${currentGridPage === 0 ? 'disabled' : ''}>Prev</button>`;
                for (let i = 0; i < totalPages; i++) {
                    paginationHtml += `<button id="gridPageBtn\${i}" class="btn btn-outline" style="flex:0 0 auto;\${i === currentGridPage ? 'background:var(--secondary-blue);color:white;' : ''}">\${i + 1}</button>`;
                }
                paginationHtml += `<button id="gridNextBtn" class="btn btn-outline" style="flex:0 0 auto;" \${currentGridPage >= totalPages - 1 ? 'disabled' : ''}>Next</button>`;
                paginationDiv.innerHTML = paginationHtml;
                courseGrid.insertAdjacentElement('afterend', paginationDiv);

                // Wire pagination buttons
                document.getElementById('gridPrevBtn')?.addEventListener('click', function() {
                    if (currentGridPage > 0) {
                        currentGridPage--;
                        renderCourseCards(list);
                    }
                });
                document.getElementById('gridNextBtn')?.addEventListener('click', function() {
                    if (currentGridPage < totalPages - 1) {
                        currentGridPage++;
                        renderCourseCards(list);
                    }
                });
                for (let i = 0; i < totalPages; i++) {
                    document.getElementById(`gridPageBtn\${i}`)?.addEventListener('click', function() {
                        currentGridPage = i;
                        renderCourseCards(list);
                    });
                }
            }
        }

        // render table with pagination
        function renderTable(list) {
            coursesTableBody.innerHTML = '';
            if (!Array.isArray(list) || list.length === 0) {
                const row = document.createElement('tr');
                row.innerHTML = `<td colspan="7" style="text-align:center; padding:40px; color:#666">No courses match your filters.</td>`;
                coursesTableBody.appendChild(row);
                // Remove pagination if no courses
                document.querySelector('.table-pagination')?.remove();
                return;
            }

            // Calculate pagination
            const totalPages = Math.ceil(list.length / itemsPerPage);
            if (currentTablePage >= totalPages) currentTablePage = Math.max(0, totalPages - 1);
            const start = currentTablePage * itemsPerPage;
            const end = start + itemsPerPage;
            const pageItems = list.slice(start, end);

            // Render page items
            pageItems.forEach(course => {
                const tr = document.createElement('tr');
                const statusText = course.status ? (course.status.charAt(0).toUpperCase()+course.status.slice(1)) : '';
                let statusClass = '';
                if (String(statusText).toLowerCase() === 'completed') statusClass = 'status-completed';
                else if (String(statusText).toLowerCase() === 'ongoing') statusClass = 'status-ongoing';
                tr.innerHTML = `
                    <td><strong>\${escapeHtml(course.courseID)}</strong></td>
                    <td>\${escapeHtml(course.courseName)}</td>
                    <td>\${escapeHtml(String(course.creditHour || 0))}</td>
                    <td>Semester \${escapeHtml(String(course.semester || ''))}</td>
                    <td>\${escapeHtml(course.program || '')}</td>
                    <td>\${course.grade ? `<span class="grade">\${escapeHtml(course.grade)}</span>` : '-'}</td>
                    <td><span class="status-badge \${statusClass}">\${escapeHtml(statusText)}</span></td>
                `;
                coursesTableBody.appendChild(tr);
            });

            // Render pagination controls
            document.querySelector('.table-pagination')?.remove();
            if (totalPages > 1) {
                const paginationDiv = document.createElement('div');
                paginationDiv.className = 'table-pagination';
                paginationDiv.style = 'display:flex;justify-content:center;gap:10px;margin-top:20px;flex-wrap:wrap;';
                let paginationHtml = `<button id="tablePrevBtn" class="btn btn-outline" style="flex:0 0 auto;" \${currentTablePage === 0 ? 'disabled' : ''}>Prev</button>`;
                for (let i = 0; i < totalPages; i++) {
                    paginationHtml += `<button id="tablePageBtn\${i}" class="btn btn-outline" style="flex:0 0 auto;\${i === currentTablePage ? 'background:var(--secondary-blue);color:white;' : ''}">\${i + 1}</button>`;
                }
                paginationHtml += `<button id="tableNextBtn" class="btn btn-outline" style="flex:0 0 auto;" \${currentTablePage >= totalPages - 1 ? 'disabled' : ''}>Next</button>`;
                paginationDiv.innerHTML = paginationHtml;
                document.querySelector('.detailed-view')?.insertAdjacentElement('afterend', paginationDiv);

                // Wire pagination buttons
                document.getElementById('tablePrevBtn')?.addEventListener('click', function() {
                    if (currentTablePage > 0) {
                        currentTablePage--;
                        renderTable(list);
                    }
                });
                document.getElementById('tableNextBtn')?.addEventListener('click', function() {
                    if (currentTablePage < totalPages - 1) {
                        currentTablePage++;
                        renderTable(list);
                    }
                });
                for (let i = 0; i < totalPages; i++) {
                    document.getElementById(`tablePageBtn\${i}`)?.addEventListener('click', function() {
                        currentTablePage = i;
                        renderTable(list);
                    });
                }
            }
        }

        // Basic filtering (wired to controls)
        function filterAndRender() {
            let list = [...courses];
            const sem = semesterFilter ? semesterFilter.value : 'all';
            const st = statusFilter ? statusFilter.value : 'all';
            const s = courseSearch ? courseSearch.value.trim().toLowerCase() : '';
            const sort = sortFilter ? sortFilter.value : 'name';

            if (sem !== 'all') list = list.filter(c => Number(c.semester) === Number(sem));
            if (st !== 'all') list = list.filter(c => (c.status || '').toLowerCase() === st.toLowerCase());
            if (s) {
                list = list.filter(c => ((c.courseName||'') + ' ' + (c.courseID||'') + ' ' + (c.program||'') + ' ' + (c.grade||'')).toLowerCase().includes(s));
            }

            if (sort === 'name') list.sort((a,b) => (a.courseName||'').localeCompare(b.courseName||''));
            else if (sort === 'code') list.sort((a,b) => (a.courseID||'').localeCompare(b.courseID||''));
            else if (sort === 'semester') list.sort((a,b) => (a.semester||0) - (b.semester||0));
            else if (sort === 'credits') list.sort((a,b) => (b.creditHour||0) - (a.creditHour||0));

            // Reset pagination when filters change
            currentGridPage = 0;
            currentTablePage = 0;

            renderCourseCards(list);
            renderTable(list);
            // update stats as filters change? keep stats global (counts for all courses)
        }

        // Wire events
        if (semesterFilter) semesterFilter.addEventListener('change', filterAndRender);
        if (statusFilter) statusFilter.addEventListener('change', filterAndRender);
        if (sortFilter) sortFilter.addEventListener('change', filterAndRender);
        if (courseSearch) {
            let to;
            courseSearch.addEventListener('input', () => {
                clearTimeout(to);
                to = setTimeout(filterAndRender, 250);
            });
        }

        // Profile dropdown wiring similar to other pages
        if (profileBtn && profileMenu) {
            profileBtn.addEventListener('click', e => { e.stopPropagation(); profileMenu.classList.toggle('show'); profileBtn.classList.toggle('active'); });
            document.addEventListener('click', e => { if (!profileBtn.contains(e.target) && !profileMenu.contains(e.target)) { profileMenu.classList.remove('show'); profileBtn.classList.remove('active'); }});
        }
        if (logoutBtn) logoutBtn.addEventListener('click', e => { e.preventDefault(); window.location.href = ctx + '/logout'; });

        // Add Course Modal handlers
        const addCourseModal = q('addCourseModal');
        const addCourseBtn = q('addCourseBtn');
        const closeAddCourseModal = q('closeAddCourseModal');
        const cancelAddCourseBtn = q('cancelAddCourseBtn');
        const addCourseForm = q('addCourseForm');
        const addCourseMessage = q('addCourseMessage');

        if (addCourseBtn) {
            addCourseBtn.addEventListener('click', () => {
                addCourseForm.reset();
                addCourseMessage.style.display = 'none';
                addCourseModal.classList.add('show');
            });
        }

        if (closeAddCourseModal) {
            closeAddCourseModal.addEventListener('click', () => {
                addCourseModal.classList.remove('show');
            });
        }

        if (cancelAddCourseBtn) {
            cancelAddCourseBtn.addEventListener('click', () => {
                addCourseModal.classList.remove('show');
            });
        }

        // Close modal when clicking outside
        if (addCourseModal) {
            addCourseModal.addEventListener('click', (e) => {
                if (e.target === addCourseModal) {
                    addCourseModal.classList.remove('show');
                }
            });
        }

        // Handle Add Course Form Submission
        if (addCourseForm) {
            addCourseForm.addEventListener('submit', async (e) => {
                e.preventDefault();

                const courseCode = (q('addCourseCode')?.value || '').trim();
                const courseName = (q('addCourseName')?.value || '').trim();
                const credits = (q('addCourseCredits')?.value || '').trim();
                const semester = (q('addCourseSemester')?.value || '').trim();
                const program = (q('addCourseProgram')?.value || '').trim();
                const status = (q('addCourseStatus')?.value || 'ongoing').trim();
                const grade = (q('addCourseGrade')?.value || '').trim();

                if (!courseCode || !courseName || !credits || !semester) {
                    showAddCourseMessage('Please fill in all required fields', 'error');
                    return;
                }

                try {
                    const response = await fetch(ctx + '/api/student/courses', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({
                            courseID: courseCode,
                            courseName: courseName,
                            creditHour: parseInt(credits),
                            semester: parseInt(semester),
                            program: program || '',
                            status: status,
                            grade: grade || null
                        })
                    });

                    const result = await response.json();

                    if (!response.ok || result.error) {
                        showAddCourseMessage('Error adding course: ' + (result.error || 'Unknown error'), 'error');
                        return;
                    }

                    showAddCourseMessage('Course added successfully!', 'success');
                    setTimeout(() => {
                        addCourseModal.classList.remove('show');
                        addCourseForm.reset();
                        loadAll();
                    }, 1500);

                } catch (err) {
                    console.error('Error adding course:', err);
                    showAddCourseMessage('Error adding course: ' + err.message, 'error');
                }
            });
        }

        function showAddCourseMessage(msg, type) {
            addCourseMessage.textContent = msg;
            addCourseMessage.style.display = 'block';
            if (type === 'success') {
                addCourseMessage.style.backgroundColor = '#d1fae5';
                addCourseMessage.style.color = '#065f46';
                addCourseMessage.style.borderLeft = '4px solid #10b981';
            } else {
                addCourseMessage.style.backgroundColor = '#fee2e2';
                addCourseMessage.style.color = '#991b1b';
                addCourseMessage.style.borderLeft = '4px solid #ef4444';
            }
        }

        // initial load
        loadAll();
    });
    </script>
</body>
</html>