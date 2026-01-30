<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
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
    <title>Student Details - Academic Progress</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            /* Blue Theme Colors */
            --blue-primary: #3498db;
            --blue-dark: #2980b9;
            --blue-light: #ebf5fb;
            --blue-border: #d4e6f1;
            
            /* Additional colors */
            --sidebar-bg: #2c3e50;
            --sidebar-text: #ecf0f1;
            --bg-light: #f8f9fa;
            --bg-card: #ffffff;
            --text-dark: #2c3e50;
            --text-light: #7f8c8d;
            --border: #dfe6e9;
            
            /* Grade colors */
            --grade-a: #27ae60;
            --grade-b: #2ecc71;
            --grade-c: #f39c12;
            --grade-d: #e67e22;
            --grade-f: #e74c3c;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-light);
            color: var(--text-dark);
            min-height: 100vh;
            overflow-x: hidden;
        }

        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background-color: var(--sidebar-bg);
            color: var(--sidebar-text);
            transition: all 0.3s ease;
            display: flex;
            flex-direction: column;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.08);
            z-index: 100;
            position: relative;
        }

        .sidebar-header {
            padding: 24px 20px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            position: relative;
            z-index: 1;
        }

        .logo {
            font-size: 24px;
            font-weight: 700;
            color: #FFFFFF;
            text-align: center;
            line-height: 1.2;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .logo-main {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .logo-main span {
            color: var(--blue-primary);
        }

        .sidebar-nav {
            flex: 1;
            padding: 20px 0;
                position: relative;
                z-index: 1;
            position: relative;
            z-index: 1;
        }

        .nav-item {
            display: flex;
            align-items: center;
            padding: 14px 20px;
            color: var(--sidebar-text);
            text-decoration: none;
            transition: all 0.2s;
            font-weight: 500;
            border-left: 3px solid transparent;
                font-size: 15px;
            font-size: 15px;
        }

        .nav-item:hover {
            background-color: rgba(52, 152, 219, 0.1);
            border-left-color: var(--blue-primary);
        }

        .nav-item.active {
            background-color: rgba(52, 152, 219, 0.2);
            border-left-color: var(--blue-primary);
            color: white;
        }

        .nav-item i {
            margin-right: 12px;
            font-size: 18px;
            width: 24px;
            text-align: center;
        }

        .sidebar-footer {
            padding: 20px;
            font-size: 13px;
            text-align: center;
            color: rgba(255, 255, 255, 0.7);
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            position: relative;
            z-index: 1;
        }

        /* Main Content Styles */
        .main-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow-y: auto;
        }

        .header {
            background-color: var(--bg-card);
            padding: 18px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.05);
            border-bottom: 1px solid var(--border);
        }

        .header h1 {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-dark);
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .search-btn, .profile-btn, .logout-btn, .back-btn {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--bg-light);
            border: 1px solid var(--border);
            cursor: pointer;
            transition: all 0.2s;
            font-size: 14px;
        }

        .search-btn:hover, .profile-btn:hover, .back-btn:hover {
            background: var(--blue-primary);
            color: white;
            border-color: var(--blue-primary);
        }

        .logout-btn {
            background: var(--bg-light);
            color: var(--text-light);
            border-color: var(--border);
        }

        .logout-btn:hover {
            background: var(--blue-light);
            color: var(--blue-primary);
        }

        /* Content Area */
        .content {
            padding: 30px;
            flex: 1;
        }

        .card {
            background: var(--bg-card);
            border-radius: 10px;
            box-shadow: 0 4px 16px rgba(0, 0, 0, 0.06);
            padding: 25px;
            border-top: 3px solid var(--blue-primary);
            margin-bottom: 30px;
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border);
        }

        .card-header h2 {
            font-size: 20px;
            font-weight: 700;
            color: var(--blue-primary);
        }

        /* NEW: Student Profile - Square Design */
        .student-profile-square {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .profile-square {
            background: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
            border: 1px solid var(--border);
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .profile-square:hover {
            transform: translateY(-5px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }

        .profile-square-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--blue-border);
        }

        .square-avatar {
            width: 70px;
            height: 70px;
            border-radius: 8px;
            background-color: rgba(52, 152, 219, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--blue-primary);
            font-size: 28px;
            font-weight: 700;
            margin-right: 15px;
            border: 2px solid var(--blue-border);
        }

        .square-name {
            font-size: 22px;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 5px;
        }

        .square-major {
            font-size: 14px;
            color: var(--blue-primary);
            font-weight: 600;
        }

        .profile-details-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 15px;
        }

        .detail-square {
            padding: 12px 15px;
            background-color: var(--bg-light);
            border-radius: 6px;
            border-left: 3px solid var(--blue-primary);
        }

        .detail-label {
            font-size: 12px;
            color: var(--text-light);
            margin-bottom: 5px;
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        .detail-value {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .detail-value i {
            color: var(--blue-primary);
            width: 18px;
        }

        /* CGPA Square - Special Styling */
        .cgpa-square {
            background: linear-gradient(135deg, var(--blue-light), white);
            border: 2px solid var(--blue-border);
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .cgpa-label {
            font-size: 14px;
            color: var(--text-light);
            margin-bottom: 5px;
            font-weight: 600;
        }

        .cgpa-value {
            font-size: 36px;
            font-weight: 800;
            color: var(--blue-primary);
            line-height: 1;
            margin-bottom: 5px;
        }

        .cgpa-rating {
            font-size: 14px;
            color: var(--text-light);
            font-weight: 500;
            padding: 4px 12px;
            background-color: rgba(39, 174, 96, 0.1);
            color: var(--grade-a);
            border-radius: 12px;
            margin-top: 5px;
        }

        /* Academic Progress Section */
        .academic-progress-section {
            margin-top: 30px;
        }

        .semester-selector {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 25px;
        }

        .semester-selector label {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 16px;
        }

        .semester-dropdown {
            padding: 10px 15px;
            border: 1px solid var(--border);
            border-radius: 6px;
            font-family: 'Inter', sans-serif;
            font-size: 15px;
            color: var(--text-dark);
            background-color: white;
            cursor: pointer;
            min-width: 200px;
            transition: border-color 0.2s;
        }

        .semester-dropdown:focus {
            outline: none;
            border-color: var(--blue-primary);
        }

        /* Course Table Styles */
        .courses-table-container {
            overflow-x: auto;
            margin-top: 20px;
        }

        .courses-table {
            width: 100%;
            border-collapse: collapse;
        }

        .courses-table thead {
            background-color: var(--blue-light);
        }

        .courses-table th {
            padding: 16px 12px;
            text-align: left;
            font-weight: 600;
            color: var(--blue-dark);
            border-bottom: 2px solid var(--blue-primary);
            font-size: 14px;
        }

        .courses-table td {
            padding: 16px 12px;
            border-bottom: 1px solid var(--blue-border);
            font-size: 14px;
            vertical-align: top;
        }

        .courses-table tr:hover {
            background-color: rgba(52, 152, 219, 0.05);
        }

        .course-code {
            font-weight: 600;
            color: var(--text-dark);
            font-size: 14px;
        }

        .course-name {
            color: var(--text-dark);
            font-size: 15px;
            font-weight: 500;
        }

        .credit-hours {
            text-align: center;
            font-weight: 600;
            color: var(--text-dark);
        }

        /* Grade Styles */
        .grade-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 6px;
            font-weight: 700;
            font-size: 14px;
            text-align: center;
            min-width: 60px;
        }

        .grade-a {
            background-color: rgba(39, 174, 96, 0.1);
            color: var(--grade-a);
            border: 1px solid rgba(39, 174, 96, 0.3);
        }

        .grade-b {
            background-color: rgba(46, 204, 113, 0.1);
            color: var(--grade-b);
            border: 1px solid rgba(46, 204, 113, 0.3);
        }

        .grade-c {
            background-color: rgba(243, 156, 18, 0.1);
            color: var(--grade-c);
            border: 1px solid rgba(243, 156, 18, 0.3);
        }

        .grade-d {
            background-color: rgba(230, 126, 34, 0.1);
            color: var(--grade-d);
            border: 1px solid rgba(230, 126, 34, 0.3);
        }

        .grade-f {
            background-color: rgba(231, 76, 60, 0.1);
            color: var(--grade-f);
            border: 1px solid rgba(231, 76, 60, 0.3);
        }

        .not-taken {
            color: var(--text-light);
            font-style: italic;
            font-size: 14px;
        }

        /* Semester Summary */
        .semester-summary {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 25px;
            padding: 20px;
            background-color: var(--blue-light);
            border-radius: 8px;
            border-left: 4px solid var(--blue-primary);
        }

        .semester-gpa {
            text-align: center;
        }

        .semester-gpa-label {
            font-size: 14px;
            color: var(--text-light);
            margin-bottom: 5px;
        }

        .semester-gpa-value {
            font-size: 28px;
            font-weight: 800;
            color: var(--blue-primary);
        }

        .semester-credits {
            text-align: center;
        }

        .semester-credits-label {
            font-size: 14px;
            color: var(--text-light);
            margin-bottom: 5px;
        }

        .semester-credits-value {
            font-size: 24px;
            font-weight: 700;
            color: var(--text-dark);
        }

        /* Button Styles */
        .action-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin-top: 20px;
        }

        .btn {
            padding: 10px 18px;
            border-radius: 6px;
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }

        .btn-primary {
            background-color: var(--blue-primary);
            color: white;
            border: 1px solid var(--blue-primary);
        }

        .btn-primary:hover {
            background-color: var(--blue-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(52, 152, 219, 0.3);
        }

        .btn-secondary {
            background-color: var(--blue-light);
            color: var(--blue-primary);
            border: 1px solid var(--blue-border);
        }

        .btn-secondary:hover {
            background-color: rgba(52, 152, 219, 0.2);
            transform: translateY(-2px);
        }

        /* Footer */
        footer {
            text-align: center;
            padding: 20px;
            color: var(--text-light);
            font-size: 13px;
            background: var(--bg-light);
            margin-top: auto;
            border-top: 1px solid var(--border);
        }

        /* Responsive Styles */
        @media (max-width: 992px) {
            .sidebar {
                width: 70px;
            }
            
            .sidebar .logo-main span,
            .sidebar .nav-item span {
                display: none;
            }
            
            .logo-main {
                flex-direction: column;
                gap: 0;
            }
            
            .sidebar .nav-item {
                justify-content: center;
                padding: 18px 0;
            }
            
            .sidebar .nav-item i {
                margin-right: 0;
                font-size: 20px;
            }
            
            .header h1 {
                font-size: 18px;
            }
            
            .student-profile-square {
                grid-template-columns: 1fr;
            }
            
            .profile-details-grid {
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            }
        }

        @media (max-width: 768px) {
            .header {
                padding: 15px 20px;
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .header-actions {
                align-self: flex-end;
            }
            
            .content {
                padding: 20px;
            }
            
            .card {
                padding: 20px;
            }
            
            .semester-selector {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            
            .semester-dropdown {
                width: 100%;
            }
            
            .semester-summary {
                flex-direction: column;
                gap: 20px;
                text-align: center;
            }
            
            .square-name {
                font-size: 20px;
            }
        }

        @media (max-width: 480px) {
            .btn {
                padding: 8px 12px;
                font-size: 13px;
            }
            
            .courses-table th,
            .courses-table td {
                padding: 12px 8px;
            }
            
            .profile-square-header {
                flex-direction: column;
                text-align: center;
            }
            
            .square-avatar {
                margin-right: 0;
                margin-bottom: 15px;
            }
            
            .profile-details-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <!-- Sidebar -->
        <div class="sidebar">
            <div class="sidebar-header">
                <div class="logo">
                    <div class="logo-main">
                        Advise<span>.</span>
                    </div>
                </div>
            </div>
            
            <nav class="sidebar-nav">
                <a href="advisor_dashboard.jsp" class="nav-item">
                    <i class="fas fa-home"></i>
                    <span>Dashboard</span>
                </a>
                <a href="manage_student.jsp" class="nav-item">
                    <i class="fas fa-users"></i>
                    <span>My Students</span>
                </a>
                <a href="#" class="nav-item active">
                    <i class="fas fa-user-graduate"></i>
                    <span>Student Details</span>
                </a>
                <a href="advisor_report.jsp" class="nav-item">
                    <i class="fas fa-chart-bar"></i>
                    <span>Reports</span>
                </a>
            </nav>
            
            <div class="sidebar-footer">
                <p>© 2025 Advising System</p>
            </div>
        </div>
        
        <!-- Main Content -->
        <div class="main-content">
            <!-- Header -->
            <header class="header">
                <h1>Student Academic Progress</h1>
                <div class="header-actions">
                    <div class="back-btn" title="Back to Students" id="backBtn">
                        <i class="fas fa-arrow-left"></i>
                    </div>
                    <a href="advisor_profile.jsp" class="profile-btn" title="Advisor Profile">👤</a>
                    <div class="logout-btn" title="Logout">🚪</div>
                </div>
            </header>
            
            <!-- Content Area -->
            <div class="content">
                <!-- Student Profile Card - Square Design -->
                <div class="card">
                    <div class="card-header">
                        <h2>Student Profile</h2>
                    </div>
                    
                    <div class="student-profile-square">
                        <!-- Personal Information Square -->
                        <div class="profile-square">
                            <div class="profile-square-header">
                                <div class="square-avatar">--</div>
                                <div>
                                    <div class="square-name">Loading...</div>
                                    <div class="square-major">Loading...</div>
                                </div>
                            </div>
                            
                            <div class="profile-details-grid">
                                <div class="detail-square">
                                    <div class="detail-label">Student ID</div>
                                    <div class="detail-value">
                                        <i class="fas fa-id-card"></i>
                                        <span>--</span>
                                    </div>
                                </div>
                                
                                <div class="detail-square">
                                    <div class="detail-label">Email Address</div>
                                    <div class="detail-value">
                                        <i class="fas fa-envelope"></i>
                                        <span>--</span>
                                    </div>
                                </div>
                                
                                <div class="detail-square">
                                    <div class="detail-label">Phone Number</div>
                                    <div class="detail-value">
                                        <i class="fas fa-phone"></i>
                                        <span>--</span>
                                    </div>
                                </div>
                                
                                <div class="detail-square">
                                    <div class="detail-label">Advisor Name</div>
                                    <div class="detail-value">
                                        <i class="fas fa-chalkboard-teacher"></i>
                                        <span>--</span>
                                    </div>
                                </div>
                                
                                <div class="detail-square">
                                    <div class="detail-label">Student Remark</div>
                                    <div class="detail-value">
                                        <span id="studentRemark" style="font-size: 14px; color: var(--text-light);">--</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- CGPA Square -->
                        <div class="profile-square cgpa-square">
                            <div class="cgpa-label">Cumulative GPA</div>
                            <div class="cgpa-value">0.00</div>
                            <div class="cgpa-rating">--</div>
                            
                            <div style="margin-top: 20px; text-align: left; width: 100%;">
                                <div class="detail-label" style="margin-bottom: 10px;">Academic Details</div>
                                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 15px;">
                                    <div>
                                        <div class="detail-label">Current Semester</div>
                                        <div class="detail-value" style="font-size: 14px;">--</div>
                                    </div>
                                    <div>
                                        <div class="detail-label">Credits Earned</div>
                                        <div class="detail-value" style="font-size: 14px;">--</div>
                                    </div>
                                    <div>
                                        <div class="detail-label">Year of Study</div>
                                        <div class="detail-value" style="font-size: 14px;">--</div>
                                    </div>
                                    <div>
                                        <div class="detail-label">Status</div>
                                        <div class="detail-value" style="font-size: 14px; color: var(--grade-a);">Active</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Academic Progress Card -->
                <div class="card">
                    <div class="card-header">
                        <h2>Academic Progress</h2>
                    </div>
                    
                    <div class="academic-progress-section">
                        <!-- Semester Selector -->
                        <div class="semester-selector">
                            <label for="semesterSelect">Select Semester:</label>
                            <select class="semester-dropdown" id="semesterSelect">
                                <!-- Options populated by JavaScript -->
                            </select>
                        </div>
                        
                        <!-- Courses Table -->
                        <div class="courses-table-container">
                            <table class="courses-table" id="coursesTable">
                                <thead>
                                    <tr>
                                        <th>Course Code</th>
                                        <th>Course Name</th>
                                        <th>Credit Hours</th>
                                        <th>Grade</th>
                                    </tr>
                                </thead>
                                <tbody id="coursesTableBody">
                                    <!-- Courses will be populated by JavaScript -->
                                </tbody>
                            </table>
                        </div>
                        
                        <!-- Semester Summary -->
                        <div class="semester-summary">
                            <div class="semester-gpa">
                                <div class="semester-gpa-label">Semester GPA</div>
                                <div class="semester-gpa-value" id="semesterGPA">3.85</div>
                            </div>
                            
                            <div class="semester-credits">
                                <div class="semester-credits-label">Total Credits</div>
                                <div class="semester-credits-value" id="semesterCredits">15</div>
                            </div>
                            
                            <div class="semester-credits">
                                <div class="semester-credits-label">Completed Credits</div>
                                <div class="semester-credits-value" id="completedCredits">12</div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="action-buttons" style="margin-top: 25px;">
                    </div>
                </div>

                <!-- Degree Progress Card -->
                <div class="card">
                    <div class="card-header">
                        <h2>Degree Progress</h2>
                    </div>
                    
                    <div style="padding: 20px 0;">
                        <div style="display: flex; justify-content: space-between; margin-bottom: 10px;">
                            <span style="font-weight: 600; color: var(--text-dark);">Program Completion</span>
                            <span id="degreeProgressText" style="font-weight: 600; color: var(--blue-primary);">0%</span>
                        </div>
                        <div style="width: 100%; height: 24px; background-color: #e5e7eb; border-radius: 12px; overflow: hidden; position: relative;">
                            <div id="degreeProgressFillAdvisor" style="height: 100%; background: linear-gradient(90deg, #3b82f6, #2563eb); width: 0%; border-radius: 12px; transition: width 0.4s ease; display: flex; align-items: center; justify-content: center; color: white; font-weight: 600; font-size: 12px;"></div>
                        </div>
                        <div style="display: flex; justify-content: space-between; margin-top: 12px; font-size: 13px; color: var(--text-light);">
                            <span>Current Semester: <strong id="progressCurrentSem">-</strong></span>
                            <span>Target: Semester 7</span>
                        </div>
                        <div id="graduationStatus" style="margin-top: 16px; padding: 12px; border-radius: 6px; background-color: #f0f9ff; border-left: 4px solid #3b82f6; display: none;">
                            <span style="color: #0369a1; font-weight: 600;"><i class="fas fa-graduation-cap"></i> Student is graduating</span>
                        </div>
                    </div>
                </div>

                <!-- Advisor Remarks Card -->
                <div class="card">
                    <div class="card-header">
                        <h2>Advisor Remarks</h2>
                    </div>
                    
                    <div style="display: grid; gap: 20px;">
                        <div>
                            <label for="remarkSelect" style="font-weight: 600; color: var(--text-dark); display: block; margin-bottom: 10px;">
                                Student Status
                            </label>
                            <select id="remarkSelect" class="semester-dropdown" style="width: 100%; max-width: 400px;">
                                <option value="">-- Select Status --</option>
                                <option value="On Track">✓ On Track</option>
                                <option value="Needs Attention">⚠ Needs Attention</option>
                                <option value="At Risk">✗ At Risk</option>
                            </select>
                        </div>
                        
                        <div style="display: flex; gap: 10px;">
                            <button class="btn btn-primary" id="saveRemarkBtn">
                                <i class="fas fa-save"></i> Save Remark
                            </button>
                            <button class="btn btn-secondary" id="cancelRemarkBtn">
                                <i class="fas fa-times"></i> Cancel
                            </button>
                        </div>
                        
                        <div id="remarkStatus" style="display: none; padding: 12px; border-radius: 6px; border-left: 4px solid var(--blue-primary); background-color: var(--blue-light);">
                            <span id="remarkStatusText"></span>
                        </div>
                    </div>
                </div>
            </div>
            
            <footer>
                © 2025 Advising System — University Academic Services
            </footer>
        </div>
    </div>

    <script>
        // DEBUG: Log immediately on page load
        console.log('=== VIEW_STUDENT_DETAIL.HTML LOADED ===');
        console.log('User Agent:', navigator.userAgent);
        console.log('Current URL:', window.location.href);
        console.log('Pathname:', window.location.pathname);
        console.log('Hostname:', window.location.hostname);
        console.log('Port:', window.location.port);
        
        // Global state
        let studentData = null;
        let allCourses = [];
        let semesterCourses = {};
        
        // Get the application context path intelligently
        // If accessing at /Advisor/view_student_detail.html, context is the part before /Advisor
        const pathParts = window.location.pathname.split('/').filter(p => p);
        console.log('Path parts:', pathParts);
        
        let contextPath = '';
        
        // Find where "Advisor" directory is and get everything before it as context
        const advisorIndex = pathParts.indexOf('Advisor');
        console.log('Advisor index in path:', advisorIndex);
        
        if (advisorIndex > 0) {
            contextPath = '/' + pathParts.slice(0, advisorIndex).join('/');
        }
        
        const apiBase = contextPath;
        
        console.log('=== CONTEXT DETECTION ===');
        console.log('Current path:', window.location.pathname);
        console.log('Context path detected:', contextPath || '(root deployment)');
        console.log('API base URL:', apiBase || '(using root)');
        console.log('Full API URLs will be:');
        console.log('  - Students search:', (apiBase) + '/api/students/search');
        console.log('  - Courses:', (apiBase) + '/api/student/courses');
        console.log('=====================================');

        // Initialize the page
        document.addEventListener('DOMContentLoaded', async function() {
            console.log('DOMContentLoaded event fired');
            
            // Get student ID from URL parameter
            const urlParams = new URLSearchParams(window.location.search);
            let studentID = urlParams.get('studentID') || urlParams.get('student_id');
            
            console.log('Query params:', {
                studentID: urlParams.get('studentID'),
                student_id: urlParams.get('student_id'),
                resolved_studentID: studentID
            });
            
            if (!studentID) {
                console.error('ERROR: No student ID provided in URL');
                alert("No student ID provided. Please provide ?student_id=XXX or ?studentID=XXX");
                window.location.href = 'manage_student.jsp';
                return;
            }
            
            console.log('Loading data for student: ' + (studentID));
            
            // Load student data and courses
            console.log('Starting parallel data load...');
            await Promise.all([
                loadStudentData(studentID),
                loadStudentCourses(studentID)
            ]);
            
            console.log('Data load complete. StudentData:', studentData);
            
            // Check if data was loaded
            if (!studentData) {
                console.error('ERROR: Could not load student data');
                alert('Could not load student data. Please check the student ID and try again.');
                window.location.href = 'manage_student.jsp';
                return;
            }
            
            console.log('Populating UI with student data...');
            
            // Populate UI
            populateStudentProfile();
            populateSemesterDropdown();
            
            // Load initial semester data
            const currentSemester = studentData.semester || 1;
            console.log('Loading initial semester:', currentSemester);
            loadSemesterData(currentSemester);
            
            console.log('Page initialization complete');
            
            // Add event listeners
            document.getElementById('semesterSelect').addEventListener('change', function() {
                const selectedSemester = parseInt(this.value);
                console.log('Semester changed to:', selectedSemester);
                loadSemesterData(selectedSemester);
            });
            
            document.getElementById('backBtn').addEventListener('click', function() {
                window.location.href = 'manage_student.jsp';
            });
            

            
            document.querySelector('.logout-btn').addEventListener('click', function() {
                if (confirm("Are you sure you want to logout?")) {
                    // Perform a full-page navigation to the logout endpoint so the
                    // servlet can invalidate the session and redirect the browser.
                    window.location.href = (apiBase) + '/logout';
                }
            });
            
            // Remark section event listeners
            document.getElementById('saveRemarkBtn').addEventListener('click', function() {
                saveRemark(studentID);
            });
            
            document.getElementById('cancelRemarkBtn').addEventListener('click', function() {
                document.getElementById('remarkSelect').value = '';
                document.getElementById('remarkStatus').style.display = 'none';
            });
        });

        // Fetch student data from backend
        async function loadStudentData(studentID) {
            try {
                const url = (apiBase) + '/api/students/search?q=' + (encodeURIComponent(studentID)) + '&limit=1';
                console.log('🔄 Fetching student data from:', url);
                const response = await fetch(url);
                
                console.log('Response status:', response.status, response.statusText);
                
                if (!response.ok) {
                    console.error('❌ API Error: ' + (response.status) + ' ' + (response.statusText));
                    const errorText = await response.text();
                    console.error('Response body:', errorText);
                    throw new Error('HTTP ' + (response.status) + ': Failed to load student');
                }
                
                const data = await response.json();
                console.log('✅ API Response:', data);
                
                if (data.students && data.students.length > 0) {
                    studentData = data.students[0];
                    console.log('✅ Student data loaded:', studentData);
                } else {
                    throw new Error('Student not found in response');
                }
            } catch (error) {
                console.error('❌ Error loading student:', error);
                alert('Failed to load student data:\n' + (error.message) + '\n\nCheck browser console for details.');
            }
        }

        // Fetch student courses from backend
        async function loadStudentCourses(studentID) {
            try {
                // First, fetch all courses for this student with their progress
                const url = (apiBase) + '/api/student/courses?studentID=' + (encodeURIComponent(studentID));
                console.log('🔄 Fetching courses from:', url);
                const response = await fetch(url);
                
                console.log('Response status:', response.status, response.statusText);
                
                if (!response.ok) {
                    console.error('❌ API Error: ' + (response.status) + ' ' + (response.statusText));
                    const errorText = await response.text();
                    console.error('Response body:', errorText);
                    throw new Error('HTTP ' + (response.status) + ': Failed to load courses');
                }
                
                const data = await response.json();
                console.log('✅ API Response:', data);
                
                allCourses = data.courses || [];
                console.log('✅ Loaded ' + (allCourses.length) + ' courses');
                
                // Group courses by semester
                semesterCourses = {};
                allCourses.forEach(course => {
                    const sem = course.semester;
                    if (!semesterCourses[sem]) {
                        semesterCourses[sem] = [];
                    }
                    semesterCourses[sem].push(course);
                });
                console.log('📊 Semesters available:', Object.keys(semesterCourses));
            } catch (error) {
                console.error('❌ Error loading courses:', error);
                alert('Failed to load courses:\n' + (error.message) + '\n\nCheck browser console for details.');
                allCourses = [];
            }
        }

        // Populate student profile section
        function populateStudentProfile() {
            if (!studentData) return;
            
            // Get initials for avatar
            const initials = ((studentData.firstName || 'S')[0] + (studentData.lastName || 'J')[0]).toUpperCase();
            document.querySelector('.square-avatar').textContent = initials;
            
            // Update student name
            const fullName = (studentData.firstName || '') + ' ' + (studentData.lastName || '').trim();
            document.querySelector('.square-name').textContent = fullName;
            document.querySelector('.square-major').textContent = (studentData.program || 'Unknown') + ' • Year ' + (studentData.yearOfStudy || 1);
            
            // Update detail squares
            const detailSquares = document.querySelectorAll('.profile-details-grid .detail-square');
            detailSquares.forEach(square => {
                const label = square.querySelector('.detail-label').textContent;
                const valueSpan = square.querySelector('.detail-value span');
                
                switch(label) {
                    case 'Student ID':
                        valueSpan.textContent = studentData.studentID || 'N/A';
                        break;
                    case 'Email Address':
                        valueSpan.textContent = studentData.email || 'N/A';
                        break;
                    case 'Phone Number':
                        valueSpan.textContent = studentData.phoneNum || 'N/A';
                        break;
                    case 'Advisor Name':
                        valueSpan.textContent = studentData.advisorName || 'Not Assigned';
                        break;
                    case 'Student Remark':
                        valueSpan.textContent = studentData.remark || 'No remark set';
                        // Also populate the select if remark exists
                        if (studentData.remark) {
                            document.getElementById('remarkSelect').value = studentData.remark;
                        }
                        break;
                }
            });
            
            // Update CGPA section
            document.querySelector('.cgpa-value').textContent = (studentData.cgpa || 0).toFixed(2);
            document.querySelector('.cgpa-rating').textContent = getRatingText(studentData.cgpa || 0);
            
            // Update academic details in CGPA square
            const academicDetailsDiv = document.querySelectorAll('.cgpa-square [style*="display: grid"] > div');
            if (academicDetailsDiv.length >= 4) {
                academicDetailsDiv[0].querySelector('.detail-value').textContent = 'Semester ' + (studentData.semester || 1);
                academicDetailsDiv[1].querySelector('.detail-value').textContent = (studentData.creditsCompleted || 0);
                academicDetailsDiv[2].querySelector('.detail-value').textContent = 'Year ' + (studentData.yearOfStudy || 1);
                academicDetailsDiv[3].querySelector('.detail-value').textContent = 'Active';
            }

            // Update Degree Progress
            const semesterNum = Number(studentData.semester) || 0;
            const degreeProgress = Math.min((semesterNum / 7) * 100, 100);
            const progressFill = document.getElementById('degreeProgressFillAdvisor');
            const progressText = document.getElementById('degreeProgressText');
            const progressCurrentSem = document.getElementById('progressCurrentSem');
            const graduationStatus = document.getElementById('graduationStatus');
            
            if (progressFill) {
                progressFill.style.width = degreeProgress + '%';
                progressFill.textContent = degreeProgress >= 10 ? Math.round(degreeProgress) + '%' : '';
            }
            if (progressText) progressText.textContent = Math.round(degreeProgress) + '%';
            if (progressCurrentSem) progressCurrentSem.textContent = semesterNum || '-';
            
            // Show graduation status if semester >= 7
            if (graduationStatus && semesterNum >= 7) {
                graduationStatus.style.display = 'block';
            }
        }

        // Get rating text based on CGPA
        function getRatingText(cgpa) {
            if (cgpa >= 3.75) return 'Excellent';
            if (cgpa >= 3.5) return 'Very Good';
            if (cgpa >= 3.0) return 'Good';
            if (cgpa >= 2.5) return 'Satisfactory';
            return 'Needs Improvement';
        }

        // Populate semester dropdown
        function populateSemesterDropdown() {
            const semesterSelect = document.getElementById('semesterSelect');
            semesterSelect.innerHTML = '';
            
            const semesters = Object.keys(semesterCourses).map(Number).sort((a, b) => a - b);
            if (semesters.length === 0) {
                semesterSelect.innerHTML = '<option>No semesters available</option>';
                return;
            }
            
            const currentSemester = studentData.semester || semesters[semesters.length - 1];
            
            semesters.forEach(sem => {
                const option = document.createElement('option');
                option.value = sem;
                option.textContent = 'Semester ' + (sem);
                if (sem === currentSemester) {
                    option.textContent += ' (Current)';
                    option.selected = true;
                }
                semesterSelect.appendChild(option);
            });
        }

        // Calculate semester GPA
        function calculateSemesterGPA(courses) {
            let totalPoints = 0;
            let totalCredits = 0;
            
            courses.forEach(course => {
                if (course.grade && !['NT', null, 'In Progress', 'Not Yet Taken'].includes(course.grade)) {
                    const points = letterGradeToPoint(course.grade);
                    if (points !== null) {
                        totalPoints += points * course.creditHour;
                        totalCredits += course.creditHour;
                    }
                }
            });
            
            return totalCredits > 0 ? (totalPoints / totalCredits).toFixed(2) : 0;
        }

        // Convert letter grade to points
        function letterGradeToPoint(grade) {
            if (!grade) return null;
            const g = grade.trim().toUpperCase();
            const gradeMap = {
                'A+': 4.0, 'A': 4.0, 'A-': 3.7,
                'B+': 3.3, 'B': 3.0, 'B-': 2.7,
                'C+': 2.3, 'C': 2.0, 'C-': 1.7,
                'D+': 1.3, 'D': 1.0, 'D-': 0.7,
                'F': 0.0
            };
            return gradeMap[g] !== undefined ? gradeMap[g] : null;
        }

        // Load semester data
        function loadSemesterData(semester) {
            const courses = semesterCourses[semester] || [];
            const tableBody = document.getElementById('coursesTableBody');
            
            tableBody.innerHTML = '';
            
            courses.forEach(course => {
                const row = document.createElement('tr');
                const gradeClass = getGradeClass(course.grade);
                const gradeDisplay = course.grade || 'Not Yet Taken';
                
                row.innerHTML = '\n                    <td><div class="course-code">' + (course.courseID) + '</div></td>\n                    <td><div class="course-name">' + (course.courseName) + '</div></td>\n                    <td class="credit-hours">' + (course.creditHour) + '</td>\n                    <td>\n                        ' + (gradeClass ? 
                          '<span class="grade-badge ' + gradeClass + '">' + gradeDisplay + '</span>' : 
                          '<span class="not-taken">' + gradeDisplay + '</span>') + '\n                    </td>\n                ';
                
                tableBody.appendChild(row);
            });
            
            // Calculate and update semester summary
            const semesterGPA = calculateSemesterGPA(courses);
            const totalCredits = courses.reduce((sum, c) => sum + c.creditHour, 0);
            const completedCredits = courses.filter(c => c.grade && !['NT', null, 'In Progress', 'Not Yet Taken'].includes(c.grade))
                                           .reduce((sum, c) => sum + c.creditHour, 0);
            
            document.getElementById('semesterGPA').textContent = semesterGPA;
            document.getElementById('semesterCredits').textContent = totalCredits;
            document.getElementById('completedCredits').textContent = completedCredits;
        }

        // Get grade class based on letter grade
        function getGradeClass(grade) {
            if (!grade) return '';
            const g = grade.trim().toUpperCase();
            
            if (g === 'NOT YET TAKEN' || g === 'NT' || g === 'IN PROGRESS') return '';
            if (g.startsWith('A')) return 'grade-a';
            if (g.startsWith('B')) return 'grade-b';
            if (g.startsWith('C')) return 'grade-c';
            if (g.startsWith('D')) return 'grade-d';
            if (g.startsWith('F')) return 'grade-f';
            return '';
        }

        // Save remark for student
        async function saveRemark(studentID) {
            try {
                const remark = document.getElementById('remarkSelect').value;
                
                if (!remark) {
                    alert('Please select a status');
                    return;
                }
                
                console.log('💾 Saving remark for student:', studentID, 'Remark:', remark);
                
                const url = (apiBase) + '/api/advisor/student/update?studentID=' + (encodeURIComponent(studentID));
                const response = await fetch(url, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'remark=' + (encodeURIComponent(remark))
                });
                
                if (!response.ok) {
                    console.error('❌ API Error: ' + (response.status) + ' ' + (response.statusText));
                    const errorText = await response.text();
                    console.error('Response body:', errorText);
                    
                    // Try alternative endpoint
                    console.log('⚠️ Trying alternative endpoint...');
                    const altUrl = (apiBase) + '/api/student/update';
                    const altResponse = await fetch(altUrl, {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: 'remark=' + (encodeURIComponent(remark))
                    });
                    
                    if (!altResponse.ok) {
                        throw new Error('HTTP ' + (response.status) + ': Failed to save remark');
                    }
                }
                
                const data = await response.json();
                console.log('✅ Remark saved:', data);
                
                // Update display - update the Student Remark field (id="studentRemark")
                document.getElementById('studentRemark').textContent = remark;
                
                // Show success message
                const statusDiv = document.getElementById('remarkStatus');
                const statusText = document.getElementById('remarkStatusText');
                statusText.textContent = '✓ Remark updated successfully: "' + (remark) + '"';
                statusDiv.style.display = 'block';
                
                setTimeout(() => {
                    statusDiv.style.display = 'none';
                }, 3000);
                
            } catch (error) {
                console.error('❌ Error saving remark:', error);
                alert('Failed to save remark:\n' + (error.message));
            }
        }
    </script>
</body>
</html>