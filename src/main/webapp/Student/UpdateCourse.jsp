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
    <title>Update Grade - Academic Advising & Progress Tracking</title>
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
            --success-green: #10b981;
            --warning-orange: #f59e0b;
            --error-red: #ef4444;
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

        /* Profile Area - Updated to match Activity.html */
        .profile-area {
            display: flex;
            align-items: center;
            gap: 20px;
            position: relative;
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

        /* Profile dropdown menu - Updated to match Activity.html */
        .profile-dropdown-menu {
            position: absolute;
            top: 100%;
            right: 0;
            width: 220px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.15);
            margin-top: 10px;
            z-index: 1000;
            display: none;
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }

        .profile-dropdown-menu.show {
            display: block;
        }

        .profile-dropdown-menu a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 15px 20px;
            color: var(--dark-text);
            text-decoration: none;
            transition: all 0.3s ease;
            border-bottom: 1px solid #f1f5f9;
        }

        .profile-dropdown-menu a:hover {
            background: #f8fafc;
            color: var(--primary-blue);
        }

        .profile-dropdown-menu a:last-child {
            border-bottom: none;
            color: var(--error-red);
        }

        .profile-dropdown-menu a i {
            width: 20px;
            text-align: center;
        }

        .profile-dropdown-menu .dropdown-header {
            padding: 15px 20px;
            background: #f8fafc;
            border-bottom: 1px solid #e2e8f0;
            font-weight: 600;
            color: var(--primary-blue);
        }

        /* Add rotation to dropdown icon when menu is open */
        .profile-dropdown.active .dropdown-icon {
            transform: rotate(180deg);
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

        /* Update Grade Container */
        .update-grade-container {
            max-width: 800px;
            margin: 0 auto;
        }

        /* Course Selection Section */
        .course-selection {
            background: var(--card-white);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
            margin-bottom: 30px;
        }

        .selection-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
        }

        .section-title {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-blue);
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .course-selector {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .form-label {
            font-weight: 600;
            color: var(--primary-blue);
            font-size: 0.95rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-label i {
            color: var(--secondary-blue);
        }

        .form-control, .form-select {
            padding: 12px 15px;
            border: 2px solid var(--light-blue);
            border-radius: 8px;
            background: white;
            color: var(--dark-text);
            font-size: 1rem;
            transition: all 0.3s ease;
        }

        .form-control:focus, .form-select:focus {
            outline: none;
            border-color: var(--secondary-blue);
            box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.1);
        }

        .btn {
            padding: 12px 24px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-size: 0.95rem;
        }

        .btn-primary {
            background: linear-gradient(135deg, var(--accent-blue), var(--primary-blue));
            color: white;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.4);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(59, 130, 246, 0.6);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6b7280, #9ca3af);
            color: white;
            box-shadow: 0 4px 12px rgba(107, 114, 128, 0.4);
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(107, 114, 128, 0.6);
        }

        .btn-outline {
            background: transparent;
            border: 2px solid var(--secondary-blue);
            color: var(--secondary-blue);
        }

        .btn-outline:hover {
            background: var(--secondary-blue);
            color: white;
        }

        .btn-success {
            background: linear-gradient(135deg, var(--success-green), #34d399);
            color: white;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.4);
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(16, 185, 129, 0.6);
        }

        /* Grade Update Form */
        .grade-form {
            background: var(--card-white);
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
            margin-bottom: 30px;
            display: none;
        }

        .grade-form.active {
            display: block;
            animation: fadeIn 0.5s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .course-info-card {
            background: linear-gradient(135deg, #f8fafc, #e0f2fe);
            border-radius: 12px;
            padding: 25px;
            border-left: 5px solid var(--secondary-blue);
            margin-bottom: 30px;
        }

        .info-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .course-code {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--primary-blue);
        }

        .course-name {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--dark-text);
            margin-bottom: 20px;
        }

        .info-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
        }

        .info-item {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .info-label {
            font-size: 0.85rem;
            color: var(--dark-text);
            opacity: 0.7;
        }

        .info-value {
            font-weight: 600;
            color: var(--primary-blue);
        }

        /* Grade Input Section */
        .grade-input-section {
            background: white;
            border-radius: 12px;
            padding: 25px;
            border: 2px solid var(--light-blue);
            margin-bottom: 30px;
        }

        .grade-input-title {
            font-size: 1.2rem;
            font-weight: 700;
            color: var(--primary-blue);
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .current-grade-display {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 25px;
            padding: 15px;
            background: #f8fafc;
            border-radius: 10px;
        }

        .current-grade-label {
            font-weight: 600;
            color: var(--dark-text);
        }

        .current-grade-value {
            font-size: 1.4rem;
            font-weight: 800;
            color: var(--primary-blue);
            min-width: 50px;
            text-align: center;
        }

        .grade-a-plus {
            color: #10b981;
        }
        
        .grade-a {
            color: #34d399;
        }
        
        .grade-a-minus {
            color: #6ee7b7;
        }
        
        .grade-b-plus {
            color: #3b82f6;
        }
        
        .grade-b {
            color: #60a5fa;
        }
        
        .grade-b-minus {
            color: #93c5fd;
        }
        
        .grade-c {
            color: #f59e0b;
        }
        
        .grade-f {
            color: #ef4444;
        }

        .grade-not-taken {
            color: #9ca3af;
        }

        .no-grade {
            color: #9ca3af;
            font-style: italic;
        }

        .grade-options {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 12px;
            margin-bottom: 20px;
        }

        .grade-option {
            padding: 15px 10px;
            border: 2px solid var(--light-blue);
            border-radius: 8px;
            background: white;
            text-align: center;
            font-weight: 800;
            font-size: 1.1rem;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .grade-option:hover {
            border-color: var(--secondary-blue);
            background: var(--background-blue);
            transform: translateY(-3px);
        }

        .grade-option.selected {
            background: var(--primary-blue);
            color: white;
            border-color: var(--primary-blue);
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(30, 58, 138, 0.2);
        }

        .grade-option[data-grade="A+"] {
            border-color: #10b981;
            color: #10b981;
        }
        
        .grade-option[data-grade="A"] {
            border-color: #34d399;
            color: #34d399;
        }
        
        .grade-option[data-grade="A-"] {
            border-color: #6ee7b7;
            color: #6ee7b7;
        }
        
        .grade-option[data-grade="B+"] {
            border-color: #3b82f6;
            color: #3b82f6;
        }
        
        .grade-option[data-grade="B"] {
            border-color: #60a5fa;
            color: #60a5fa;
        }
        
        .grade-option[data-grade="B-"] {
            border-color: #93c5fd;
            color: #93c5fd;
        }
        
        .grade-option[data-grade="C"] {
            border-color: #f59e0b;
            color: #f59e0b;
        }
        
        .grade-option[data-grade="F"] {
            border-color: #ef4444;
            color: #ef4444;
        }
        
        .grade-option[data-grade="NT"] {
            border-color: #9ca3af;
            color: #9ca3af;
        }

        .grade-option[data-grade=""] {
            border-color: #9ca3af;
            color: #9ca3af;
        }

        .grade-option.selected[data-grade="A+"] {
            background: #10b981;
            color: white;
        }
        
        .grade-option.selected[data-grade="A"] {
            background: #34d399;
            color: white;
        }
        
        .grade-option.selected[data-grade="A-"] {
            background: #6ee7b7;
            color: white;
        }
        
        .grade-option.selected[data-grade="B+"] {
            background: #3b82f6;
            color: white;
        }
        
        .grade-option.selected[data-grade="B"] {
            background: #60a5fa;
            color: white;
        }
        
        .grade-option.selected[data-grade="B-"] {
            background: #93c5fd;
            color: white;
        }
        
        .grade-option.selected[data-grade="C"] {
            background: #f59e0b;
            color: white;
        }
        
        .grade-option.selected[data-grade="F"] {
            background: #ef4444;
            color: white;
        }
        
        .grade-option.selected[data-grade="NT"] {
            background: #9ca3af;
            color: white;
        }

        .grade-description {
            margin-top: 15px;
            padding: 12px;
            background: #f8fafc;
            border-radius: 8px;
            font-size: 0.9rem;
            color: var(--dark-text);
            display: none;
        }

        .grade-description.show {
            display: block;
            animation: fadeIn 0.3s ease;
        }

        /* Form Actions */
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            padding-top: 25px;
            border-top: 2px solid #f1f5f9;
            margin-top: 30px;
        }

        /* Status Messages */
        .status-message {
            padding: 15px 20px;
            border-radius: 10px;
            margin-bottom: 25px;
            display: none;
            align-items: center;
            gap: 15px;
            animation: fadeIn 0.5s ease;
        }

        .status-message.show {
            display: flex;
        }

        .status-message.success {
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            color: #065f46;
            border-left: 5px solid var(--success-green);
        }

        .status-message.error {
            background: linear-gradient(135deg, #fee2e2, #fecaca);
            color: #7f1d1d;
            border-left: 5px solid var(--error-red);
        }

        .status-message.warning {
            background: linear-gradient(135deg, #fef3c7, #fde68a);
            color: #92400e;
            border-left: 5px solid var(--warning-orange);
        }

        .status-message.info {
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            color: #1e40af;
            border-left: 5px solid var(--accent-blue);
        }

        /* Grade Scale Info */
        .grade-scale-info {
            background: linear-gradient(135deg, #f8fafc, #e0f2fe);
            border-radius: 10px;
            padding: 15px;
            margin-top: 20px;
            font-size: 0.85rem;
            color: var(--dark-text);
        }

        .grade-scale-info h4 {
            color: var(--primary-blue);
            margin-bottom: 10px;
            font-size: 0.9rem;
        }

        .grade-scale-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
        }

        .scale-item {
            display: flex;
            justify-content: space-between;
            padding: 5px 0;
            border-bottom: 1px solid #e5e7eb;
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
            .info-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .grade-options {
                grid-template-columns: repeat(3, 1fr);
            }
        }

        @media (max-width: 992px) {
            .header {
                flex-direction: column;
                align-items: stretch;
                gap: 20px;
            }
            
            .course-selector {
                grid-template-columns: 1fr;
            }
            
            .selection-header {
                flex-direction: column;
                gap: 15px;
                align-items: flex-start;
            }
            
            .grade-options {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .grade-scale-grid {
                grid-template-columns: 1fr;
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
            
            .form-actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
            
            .profile-btn {
                padding: 8px 12px;
            }
            
            .profile-info {
                display: none;
            }
        }

        @media (max-width: 576px) {
            .page-title {
                font-size: 1.5rem;
            }
            
            .section-title {
                font-size: 1.3rem;
            }
            
            .info-grid {
                grid-template-columns: 1fr;
            }
            
            .grade-options {
                grid-template-columns: 1fr;
            }
            
            .status-message {
                flex-direction: column;
                text-align: center;
                gap: 10px;
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
            <li><a href="Mycourse.jsp"><i class="fas fa-book"></i> <span>My Courses</span></a></li>
            <li><a href="UpdateCourse.jsp" class="active"><i class="fas fa-edit"></i> <span>Update Grade</span></a></li>
            <li><a href="AdvisingSessions.jsp"><i class="fas fa-calendar-alt"></i> <span>Advising Sessions</span></a></li>
            <li><a href="Activity.jsp"><i class="fas fa-chart-line"></i> <span>Activity</span></a></li>
        </ul>
    </nav>

    <!-- Main Content -->
    <div class="main-content">
        <!-- Header -->
        <header class="header">
            <div class="page-title">
                <i class="fas fa-edit"></i>
                <span>Update Course Grade</span>
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

                  <div class="profile-dropdown-menu" id="profileMenu">
                    <div class="dropdown-header" id="profileMenuHeader">Student</div>
                    <a href="Profile.jsp"><i class="fas fa-user-circle"></i> My Profile</a>
                    <a href="#" id="logoutBtn"><i class="fas fa-sign-out-alt"></i> Logout</a>
                  </div>
                </div>
            </div>
        </header>

        <!-- Status Message Container -->
        <div id="statusMessage" class="status-message">
            <i class="fas fa-info-circle"></i>
            <span id="statusText">Message will appear here</span>
        </div>

        <!-- Update Grade Container -->
        <div class="update-grade-container">
            <!-- Course Selection Section -->
            <div class="course-selection">
                <div class="selection-header">
                    <h3 class="section-title"><i class="fas fa-search"></i> Select Course to Update Grade</h3>
                    <button class="btn btn-outline" id="viewAllCoursesBtn">
                        <i class="fas fa-list"></i> View All My Courses
                    </button>
                </div>
                
                <div class="course-selector">
                    <div class="form-group">
                        <label class="form-label" for="courseFilter"><i class="fas fa-filter"></i> Filter by Status</label>
                        <select class="form-select" id="courseFilter">
                            <option value="all">All Courses</option>
                            <option value="Ongoing">Ongoing Courses</option>
                            <option value="Completed">Completed Courses</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="courseSelect"><i class="fas fa-book"></i> Select Course</label>
                        <select class="form-select" id="courseSelect">
                            <option value="">-- Select a course --</option>
                        </select>
                    </div>
                </div>
                
                <div class="form-actions">
                    <button class="btn btn-primary" id="loadCourseBtn">
                        <i class="fas fa-arrow-circle-right"></i> Load Course
                    </button>
                </div>
            </div>

            <!-- Grade Update Form (this container will be reused for single-course and multi-course views) -->
            <div class="grade-form" id="gradeForm">
                <!-- Original single-course content is preserved so we can restore it -->
                <div id="singleCourseInner">
                    <!-- Course Information Card -->
                    <div class="course-info-card" id="courseInfoCard">
                        <div class="info-header">
                            <div class="course-code" id="courseCode">CSC584</div>
                            <div class="status-badge" id="courseStatusBadge"></div>
                        </div>
                        <div class="course-name" id="courseName">Enterprise Programming</div>
                        <div class="info-grid">
                            <div class="info-item">
                                <span class="info-label">Credit Hours</span>
                                <span class="info-value" id="courseCredits">4</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Semester</span>
                                <span class="info-value" id="courseSemester">Semester 1</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Program</span>
                                <span class="info-value" id="courseProgram">Computer Science</span>
                            </div>
                            <div class="info-item">
                                <span class="info-label">Current Status</span>
                                <span class="info-value" id="courseStatus">Completed</span>
                            </div>
                        </div>
                    </div>

                    <!-- Grade Input Section -->
                    <div class="grade-input-section" id="singleGradeSection">
                        <h3 class="grade-input-title">
                            <i class="fas fa-award"></i>
                            Update Final Grade
                        </h3>

                        <div class="current-grade-display">
                            <span class="current-grade-label">Current Grade:</span>
                            <span class="current-grade-value" id="currentGradeDisplay">-</span>
                        </div>

                        <div class="grade-options" id="gradeOptions">
                            <div class="grade-option" data-grade="A+" data-description="Excellent: 85-100%">A+</div>
                            <div class="grade-option" data-grade="A" data-description="Excellent: 80-84%">A</div>
                            <div class="grade-option" data-grade="A-" data-description="Very Good: 75-79%">A-</div>
                            <div class="grade-option" data-grade="B+" data-description="Good: 70-74%">B+</div>
                            <div class="grade-option" data-grade="B" data-description="Good: 65-69%">B</div>
                            <div class="grade-option" data-grade="B-" data-description="Satisfactory: 60-64%">B-</div>
                            <div class="grade-option" data-grade="C" data-description="Pass: 50-59%">C</div>
                            <div class="grade-option" data-grade="F" data-description="Fail: Below 50%">F</div>
                            <div class="grade-option" data-grade="NT" data-description="Not Taken: Course not taken">NT</div>
                            <div class="grade-option" data-grade="" data-description="No grade assigned">None</div>
                        </div>

                        <div class="grade-description" id="gradeDescription">
                            Select a grade to see its description
                        </div>
                    </div>

                    <!-- Form Actions -->
                    <div class="form-actions" id="singleFormActions">
                        <button type="button" class="btn btn-secondary" id="cancelBtn">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                        <button type="button" class="btn btn-success" id="updateGradeBtn">
                            <i class="fas fa-save"></i> Update Grade
                        </button>
                    </div>
                </div>

                <!-- Container used when showing all courses (populated by JS) -->
                <div id="multiCourseInner" style="display:none;">
                    <!-- JS will generate a list of mini forms here when multi-view is active -->
                </div>
            </div>
        </div>

        <!-- Footer -->
        <footer>
            <p><strong>Academic Advising & Progress Tracking System</strong> | UiTM Terengganu, Campus Chendering</p>
            <p>© 2025 CSC584 - Enterprise Programming | <i class="fas fa-user-clock"></i> Last login: Dec 10, 2025 14:30 | <i class="fas fa-shield-alt"></i> Secure Connection</p>
        </footer>
    </div>

    <script>
    document.addEventListener('DOMContentLoaded', function() {
        const ctx = (function() {
            const p = window.location.pathname.split('/').filter(Boolean);
            return p.length ? '/' + p[0] : '';
        })();

        // Helper selectors
        const q = id => document.getElementById(id);
        const escapeHtml = s => s ? String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])) : '';

        // DOM refs
        const viewAllCoursesBtn = q('viewAllCoursesBtn');
        const courseFilter = q('courseFilter');
        const courseSelect = q('courseSelect');
        const loadCourseBtn = q('loadCourseBtn');

        const gradeForm = q('gradeForm');
        const singleCourseInner = q('singleCourseInner');
        const multiCourseInner = q('multiCourseInner');

        const courseCodeEl = q('courseCode');
        const courseNameEl = q('courseName');
        const courseCreditsEl = q('courseCredits');
        const courseSemesterEl = q('courseSemester');
        const courseProgramEl = q('courseProgram');
        const courseStatusEl = q('courseStatus');
        const currentGradeDisplay = q('currentGradeDisplay');
        const gradeOptionsContainer = q('gradeOptions');
        const gradeDescription = q('gradeDescription');

        const updateGradeBtn = q('updateGradeBtn');
        const cancelBtn = q('cancelBtn');

        const statusMessage = q('statusMessage');
        const statusText = q('statusText');

        // Profile dropdown elements
        const profileBtn = q('profileBtn');
        const profileMenu = q('profileMenu');
        const profileNameEl = q('profileName');
        const profilePicEl = q('profilePic');
        const logoutBtn = q('logoutBtn');
        const dropdownBackdrop = q('dropdownBackdrop');

        let courses = [];
        let selectedCourse = null;
        let studentSemester = 2; // fallback
        let selectedGrade = "";

        // Profile dropdown functionality (matching Activity.html)
        if (profileBtn && profileMenu) {
            profileBtn.addEventListener('click', e => {
                e.stopPropagation();
                profileMenu.classList.toggle('show');
                profileBtn.classList.toggle('active');
            });
            
            document.addEventListener('click', e => {
                if (!profileBtn.contains(e.target) && !profileMenu.contains(e.target)) {
                    profileMenu.classList.remove('show');
                    profileBtn.classList.remove('active');
                }
            });
        }
        
        if (logoutBtn) {
            logoutBtn.addEventListener('click', e => {
                e.preventDefault();
                window.location.href = ctx + '/logout';
            });
        }
        
        async function loadProfile() {
            try {
              const res = await fetch(ctx + '/api/student/me', { cache: 'no-store' });
              if (!res.ok) return; // not logged or not student
              const json = await res.json();
              const name = json.name || (json.firstName ? (json.firstName + (json.lastName ? ' ' + json.lastName : '')) : profileNameEl.textContent);
              profileNameEl.textContent = name;
              profileRoleEl.textContent = 'Student';
              // initials
              let initials = '';
              if (json.firstName || json.lastName) {
                initials = (json.firstName || '').charAt(0) + (json.lastName || '').charAt(0);
              } else if (name) {
                const parts = name.trim().split(/\s+/);
                initials = parts[0].charAt(0) + (parts.length > 1 ? parts[parts.length-1].charAt(0) : '');
              }
              profilePicEl.textContent = (initials || 'ME').toUpperCase();
            } catch (e) {
              // ignore
              console.warn('Could not load profile', e);
            }
        }

        // API helpers
        async function apiGet(path) {
            const res = await fetch(ctx + path, { cache: 'no-store' });
            if (!res.ok) throw new Error('GET ' + path + ' ' + res.status);
            return res.json();
        }
        async function apiPost(path, body) {
            const res = await fetch(ctx + path, { method: 'POST', body: body, headers: { 'Content-Type': 'application/x-www-form-urlencoded' }});
            if (!res.ok) {
                const txt = await res.text().catch(()=>null);
                throw new Error('POST ' + path + ' ' + res.status + ' ' + txt);
            }
            return res.json();
        }

        function showStatus(msg, type='info') {
            if (!statusMessage || !statusText) return;
            statusMessage.className = 'status-message ' + type;
            statusText.textContent = msg;
            statusMessage.style.display = 'flex';
            if (type !== 'error') setTimeout(()=> { statusMessage.style.display = 'none'; }, 3500);
        }

        // load student to get semester
        async function fetchStudent() {
            try {
                const res = await fetch(ctx + '/api/student/me', { cache: 'no-store' });
                if (res.ok) {
                    const js = await res.json();
                    if (js.semester) studentSemester = parseInt(js.semester) || studentSemester;
                }
            } catch (e) { console.warn('fetchStudent', e); }
        }

        // fetch courses list
        async function fetchCourses() {
            await fetchStudent();
            try {
                const json = await apiGet('/api/student/courses');
                courses = json.courses || [];
                populateCourseSelect();
            } catch (e) {
                console.error('fetchCourses', e);
                showStatus('Unable to load courses', 'error');
            }
        }

        // populate the select used for single course flow
        function populateCourseSelect() {
            if (!courseSelect) return;
            courseSelect.innerHTML = '<option value="">-- Select a course --</option>';
            const filterVal = courseFilter ? courseFilter.value : 'all';
            const filtered = (filterVal === 'all') ? courses : courses.filter(c => (c.status||'').toLowerCase() === filterVal.toLowerCase());
            filtered.forEach(c => {
                const opt = document.createElement('option');
                opt.value = c.progressID;
                opt.textContent = `\${c.courseName} (\${c.status || ''})`;
                opt.dataset.courseData = JSON.stringify(c);
                courseSelect.appendChild(opt);
            });
        }

        // restore original single-course area (inner HTML already present in DOM)
        function showSingleCourseView() {
            multiCourseInner.style.display = 'none';
            singleCourseInner.style.display = 'block';
            gradeForm.classList.add('active');
        }

        // build mini grade select for each course
        function buildGradeSelect(currentGrade) {
            const grades = ["A+","A","A-","B+","B","B-","C","F","NT",""];
            const sel = document.createElement('select');
            sel.className = 'form-select mini-grade-select';
            grades.forEach(g => {
                const o = document.createElement('option');
                o.value = g;
                o.textContent = (g === '') ? 'None' : g;
                if (String(currentGrade || '') === String(g)) o.selected = true;
                sel.appendChild(o);
            });
            return sel;
        }

        // open multi-course view inside grade-form container
        function openAllInGradeForm() {
            if (!gradeForm || !multiCourseInner || !singleCourseInner) return;
            // hide single view and show multi view
            singleCourseInner.style.display = 'none';
            multiCourseInner.innerHTML = ''; // clear previous
            multiCourseInner.style.display = 'block';
            gradeForm.classList.add('active');

            if (!courses || courses.length === 0) {
                multiCourseInner.innerHTML = '<div style="padding:12px;color:#666">No courses available.</div>';
                return;
            }

            const header = document.createElement('div');
            header.style.display = 'flex';
            header.style.justifyContent = 'space-between';
            header.style.alignItems = 'center';
            header.style.marginBottom = '12px';
            header.innerHTML = `<h3 style="margin:0;color:#1e3a8a">Bulk Grade Editor</h3>`;
            multiCourseInner.appendChild(header);

            // list
            courses.forEach(course => {
                const card = document.createElement('div');
                card.style.border = '1px solid #e6eefb';
                card.style.padding = '12px';
                card.style.borderRadius = '8px';
                card.style.marginBottom = '12px';
                card.style.display = 'flex';
                card.style.justifyContent = 'space-between';
                card.style.alignItems = 'center';
                card.style.gap = '12px';
                card.style.flexWrap = 'wrap';

                const info = document.createElement('div');
                info.style.flex = '1 1 60%';
                info.innerHTML = `<div style="font-weight:700;color:#1e3a8a">\${escapeHtml(course.courseName)} (\${escapeHtml(course.courseID)})</div>
                                  <div style="color:#64748b;font-size:0.9rem">Semester \${course.semester} • \${course.creditHour} Credit(s)</div>`;

                const controls = document.createElement('div');
                controls.style.display = 'flex';
                controls.style.gap = '8px';
                controls.style.alignItems = 'center';
                controls.style.flex = '0 0 auto';

                const sel = buildGradeSelect(course.grade);
                sel.style.minWidth = '120px';

                const btnUpdate = document.createElement('button');
                btnUpdate.className = 'btn btn-success';
                btnUpdate.textContent = 'Update';
                btnUpdate.addEventListener('click', async () => {
                    btnUpdate.disabled = true;
                    btnUpdate.textContent = 'Saving...';
                    try {
                        const form = new URLSearchParams();
                        form.append('progressID', course.progressID);
                        form.append('grade', sel.value || '');
                        const res = await fetch(ctx + '/api/student/grade', {
                            method: 'POST',
                            body: form,
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                        });
                        const json = await res.json();
                        if (res.ok && json.success) {
                            course.grade = sel.value || null;
                            course.status = (sel.value && sel.value !== '') ? 'Completed' : 'Ongoing';
                            showStatus(`Updated \${course.courseName}`, 'success');
                            // refresh select list
                            populateCourseSelect();
                        } else {
                            showStatus(json.error || 'Update failed', 'error');
                        }
                    } catch (err) {
                        console.error(err);
                        showStatus('Error updating grade', 'error');
                    } finally {
                        btnUpdate.disabled = false;
                        btnUpdate.textContent = 'Update';
                    }
                });

                const btnEdit = document.createElement('button');
                btnEdit.className = 'btn btn-outline';
                btnEdit.textContent = 'Edit in Form';
                btnEdit.addEventListener('click', () => {
                    // set single select to this course and load it
                    if (courseSelect) {
                        let found = false;
                        for (let i=0;i<courseSelect.options.length;i++){
                            const opt = courseSelect.options[i];
                            if (opt.value == course.progressID) { courseSelect.selectedIndex = i; found = true; break; }
                        }
                        if (!found) {
                            const opt = document.createElement('option');
                            opt.value = course.progressID;
                            opt.textContent = `\${course.courseName} (\${course.status || ''})`;
                            opt.dataset.courseData = JSON.stringify(course);
                            courseSelect.appendChild(opt);
                            courseSelect.value = course.progressID;
                        }
                    }
                    // simulate load button click for single form usage
                    loadCourseBtn?.click();
                });

                controls.appendChild(sel);
                controls.appendChild(btnUpdate);
                controls.appendChild(btnEdit);

                card.appendChild(info);
                card.appendChild(controls);
                multiCourseInner.appendChild(card);
            });
        }

        // single-course load handler
        if (loadCourseBtn) {
            loadCourseBtn.addEventListener('click', function() {
                const sel = courseSelect.options[courseSelect.selectedIndex];
                if (!sel || !sel.dataset.courseData) { showStatus('Please select a course first.', 'error'); return; }
                selectedCourse = JSON.parse(sel.dataset.courseData);
                // Populate single-course UI elements
                if (courseCodeEl) courseCodeEl.textContent = selectedCourse.courseID || '';
                if (courseNameEl) courseNameEl.textContent = selectedCourse.courseName || '';
                if (courseCreditsEl) courseCreditsEl.textContent = selectedCourse.creditHour || '';
                if (courseSemesterEl) courseSemesterEl.textContent = `Semester \${selectedCourse.semester || ''}`;
                if (courseProgramEl) courseProgramEl.textContent = selectedCourse.program || '';
                if (courseStatusEl) courseStatusEl.textContent = selectedCourse.status ? (selectedCourse.status.charAt(0).toUpperCase()+selectedCourse.status.slice(1)) : '';
                if (currentGradeDisplay) currentGradeDisplay.textContent = selectedCourse.grade || 'No grade';

                // reset grade option visuals
                const gradeOpts = gradeOptionsContainer ? gradeOptionsContainer.querySelectorAll('.grade-option') : [];
                gradeOpts.forEach(opt => opt.classList.remove('selected'));
                if (selectedCourse.grade && gradeOptionsContainer) {
                    const match = gradeOptionsContainer.querySelector(`.grade-option[data-grade="\${selectedCourse.grade}"]`);
                    if (match) match.classList.add('selected');
                    selectedGrade = selectedCourse.grade;
                    gradeDescription.textContent = (match && match.dataset.description) ? match.dataset.description : '';
                    gradeDescription.classList.toggle('show', !!match);
                } else {
                    selectedGrade = "";
                    gradeDescription.textContent = 'Select a grade to see its description';
                    gradeDescription.classList.remove('show');
                }

                // show single-course view
                showSingleCourseView();
                showStatus(`Loaded \${selectedCourse.courseName}`, 'success');
            });
        }

        // wire grade-option click for single-course (use event delegation)
        gradeOptionsContainer && gradeOptionsContainer.addEventListener('click', function(e) {
            const opt = e.target.closest('.grade-option');
            if (!opt) return;
            // toggle selected class
            const opts = gradeOptionsContainer.querySelectorAll('.grade-option');
            opts.forEach(o => o.classList.remove('selected'));
            opt.classList.add('selected');
            selectedGrade = opt.dataset.grade || '';
            gradeDescription.textContent = opt.dataset.description || '';
            gradeDescription.classList.add('show');
        });

        // single-course update button
        updateGradeBtn && updateGradeBtn.addEventListener('click', async function() {
            if (!selectedCourse) { showStatus('No course loaded', 'error'); return; }
            try {
                const form = new URLSearchParams();
                form.append('progressID', selectedCourse.progressID);
                form.append('grade', selectedGrade || '');
                const res = await fetch(ctx + '/api/student/grade', {
                    method: 'POST',
                    body: form,
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                });
                const json = await res.json();
                if (res.ok && json.success) {
                    // update local data
                    const idx = courses.findIndex(c => c.progressID == selectedCourse.progressID);
                    if (idx !== -1) {
                        courses[idx].grade = selectedGrade || null;
                        courses[idx].status = (selectedGrade && selectedGrade !== '') ? 'Completed' : 'Ongoing';
                        // update displayed grade
                        currentGradeDisplay.textContent = courses[idx].grade || 'No grade';
                    }
                    showStatus('Grade updated successfully', 'success');
                } else {
                    showStatus(json.error || 'Update failed', 'error');
                }
            } catch (err) {
                console.error(err);
                showStatus('Error updating grade', 'error');
            }
        });

        // cancel single form
        cancelBtn && cancelBtn.addEventListener('click', function() {
            // hide form container
            gradeForm.classList.remove('active');
            // reset single content visuals
            const opts = gradeOptionsContainer ? gradeOptionsContainer.querySelectorAll('.grade-option') : [];
            opts && opts.forEach(o => o.classList.remove('selected'));
            selectedGrade = "";
        });

        // wire viewAllCoursesBtn to show multi-course inside gradeForm
        if (viewAllCoursesBtn) {
            viewAllCoursesBtn.addEventListener('click', function(e) {
                e.preventDefault();
                openAllInGradeForm();
            });
        } else {
            console.warn('viewAllCoursesBtn not found');
        }

        // filter select changes should update the single select list
        courseFilter && courseFilter.addEventListener('change', populateCourseSelect);

        // initial load
        fetchCourses();
        loadProfile();
    });
    </script>
</body>
</html>