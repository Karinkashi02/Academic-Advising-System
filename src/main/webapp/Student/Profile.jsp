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
    <title>My Profile - Academic Advising System</title>
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
            --gradient-light: linear-gradient(135deg, #e0f2fe, #f0f9ff);
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
            padding: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        /* Header */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: var(--gradient-blue);
            padding: 20px 35px;
            border-radius: 15px;
            box-shadow: 0 6px 20px rgba(30, 58, 138, 0.25);
            margin-bottom: 30px;
            color: white;
            position: relative;
            width: 100%;
            max-width: 1200px;
        }

        .page-title {
            font-size: 1.8rem;
            font-weight: 700;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
        }

        .page-title i {
            margin-right: 10px;
        }

        .header-actions {
            display: flex;
            gap: 15px;
            align-items: center;
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

        .profile-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            background: rgba(255, 255, 255, 0.2);
            padding: 10px 20px;
            border-radius: 50px;
            transition: all 0.3s ease;
            border: 2px solid rgba(255, 255, 255, 0.3);
            cursor: pointer;
            text-decoration: none;
            color: white;
        }

        .profile-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            border-color: rgba(255, 255, 255, 0.5);
        }

        /* Profile Container */
        .profile-container {
            width: 100%;
            max-width: 1200px;
            display: flex;
            gap: 30px;
            flex: 1;
        }

        /* Profile Card - Display Mode */
        .profile-card {
            background-color: var(--card-white);
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            position: relative;
            overflow: hidden;
            border: 1px solid rgba(147, 197, 253, 0.3);
            width: 100%;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            animation: fadeIn 0.6s ease-out;
        }

        .profile-card:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 8px;
            background: linear-gradient(to right, var(--primary-blue), var(--accent-blue), var(--secondary-blue));
        }

        /* Large Profile Icon */
        .profile-icon {
            width: 140px;
            height: 140px;
            background: linear-gradient(135deg, var(--light-blue), var(--secondary-blue));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 25px;
            box-shadow: 0 10px 30px rgba(14, 165, 233, 0.3);
            border: 5px solid white;
            position: relative;
        }

        .profile-icon i {
            font-size: 4.5rem;
            color: white;
        }

        .profile-icon:after {
            content: '';
            position: absolute;
            top: -10px;
            left: -10px;
            right: -10px;
            bottom: -10px;
            border: 2px solid rgba(14, 165, 233, 0.1);
            border-radius: 50%;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); opacity: 1; }
            100% { transform: scale(1.1); opacity: 0; }
        }

        /* Student Name */
        .student-name {
            font-size: 2.2rem;
            color: var(--primary-blue);
            font-weight: 700;
            margin-bottom: 10px;
        }

        .student-id {
            font-size: 1.1rem;
            color: #64748b;
            margin-bottom: 30px;
            background: var(--gradient-light);
            padding: 8px 20px;
            border-radius: 50px;
            display: inline-block;
        }

        /* Profile Info Grid */
        .profile-info-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 25px;
            width: 100%;
            margin: 30px 0;
            padding: 30px;
            background: var(--gradient-light);
            border-radius: 15px;
            border: 1px solid rgba(147, 197, 253, 0.2);
        }

        .info-item {
            display: flex;
            flex-direction: column;
            align-items: flex-start;
            padding: 20px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            transition: all 0.3s ease;
        }

        .info-item:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.1);
        }

        .info-label {
            font-weight: 600;
            color: var(--dark-text);
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 8px;
            font-size: 0.95rem;
            width: 100%;
        }

        .info-label i {
            color: var(--secondary-blue);
            font-size: 1.1rem;
            width: 25px;
        }

        .info-value {
            font-size: 1.2rem;
            color: #475569;
            padding-left: 35px;
            width: 100%;
            word-break: break-word;
        }

        .locked-field {
            color: #94a3b8;
            font-style: italic;
        }

        .lock-icon {
            color: #94a3b8;
            font-size: 0.9rem;
            margin-left: 5px;
        }

        /* Action Buttons */
        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            width: 100%;
            justify-content: center;
        }

        .action-btn {
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-blue));
            color: white;
            border: none;
            padding: 14px 28px;
            border-radius: 12px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            box-shadow: 0 6px 20px rgba(30, 58, 138, 0.25);
            font-size: 1rem;
            min-width: 180px;
        }

        .action-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(30, 58, 138, 0.35);
        }

        .action-btn i {
            font-size: 1.1rem;
        }

        .secondary-btn {
            background: linear-gradient(135deg, #f1f5f9, #e2e8f0);
            color: var(--primary-blue);
            border: 2px solid #cbd5e1;
        }

        .secondary-btn:hover {
            background: linear-gradient(135deg, #e2e8f0, #cbd5e1);
        }

        .edit-btn {
            background: linear-gradient(135deg, var(--secondary-blue), var(--accent-blue));
        }

        .save-btn {
            background: linear-gradient(135deg, #10b981, #059669);
        }

        .save-btn:hover {
            background: linear-gradient(135deg, #059669, #047857);
        }

        .cancel-btn {
            background: linear-gradient(135deg, #ef4444, #dc2626);
        }

        .cancel-btn:hover {
            background: linear-gradient(135deg, #dc2626, #b91c1c);
        }

        /* Edit Form Overlay - Initially Hidden */
        .edit-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            display: none; /* Hidden by default */
            justify-content: center;
            align-items: center;
            z-index: 1000;
            padding: 20px;
        }

        /* Compact Edit Form */
        .edit-form {
            background: white;
            border-radius: 20px;
            padding: 25px; /* Compact padding */
            width: 100%;
            max-width: 500px; /* Smaller width */
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            position: relative;
            animation: slideIn 0.4s ease-out;
        }

        .edit-form:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 8px;
            background: linear-gradient(to right, var(--primary-blue), var(--accent-blue));
            border-radius: 20px 20px 0 0;
        }

        /* Edit Header */
        .edit-header {
            display: flex;
            align-items: center;
            gap: 12px; /* Compact gap */
            margin-bottom: 20px; /* Compact margin */
        }

        .edit-header i {
            color: var(--secondary-blue);
            font-size: 1.5rem; /* Compact size */
        }

        .edit-header h2 {
            font-size: 1.5rem; /* Compact size */
            color: var(--primary-blue);
            font-weight: 700;
        }

        .form-group {
            margin-bottom: 15px; /* Compact margin */
        }

        .form-group label {
            display: block;
            font-weight: 600;
            color: var(--dark-text);
            margin-bottom: 6px; /* Compact margin */
            font-size: 0.9rem; /* Compact font */
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-group input {
            width: 100%;
            padding: 12px 15px; /* Compact padding */
            border: 2px solid #e5e7eb;
            border-radius: 10px;
            font-size: 0.95rem; /* Compact font */
            background-color: #f8fafc;
            color: #475569;
            transition: all 0.3s ease;
        }

        .form-group input:focus {
            outline: none;
            border-color: var(--secondary-blue);
            background-color: white;
            box-shadow: 0 0 0 3px rgba(14, 165, 233, 0.1);
        }

        .form-group input:disabled {
            background-color: #f1f5f9;
            color: #94a3b8;
            cursor: not-allowed;
            border-color: #e5e7eb;
        }

        /* Form Actions */
        .form-actions {
            display: flex;
            gap: 12px; /* Compact gap */
            margin-top: 20px; /* Compact margin */
            justify-content: flex-end;
        }

        /* Compact Form Action Buttons */
        .form-action-btn {
            background: linear-gradient(135deg, var(--primary-blue), var(--accent-blue));
            color: white;
            border: none;
            padding: 10px 20px; /* Compact padding */
            border-radius: 10px; /* Compact radius */
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px; /* Compact gap */
            box-shadow: 0 4px 15px rgba(30, 58, 138, 0.25);
            font-size: 0.9rem; /* Compact font */
            min-width: 140px; /* Compact width */
        }

        .form-action-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(30, 58, 138, 0.35);
        }

        .form-action-btn i {
            font-size: 0.9rem; /* Compact icon */
        }

        .form-cancel-btn {
            background: linear-gradient(135deg, #ef4444, #dc2626);
        }

        .form-save-btn {
            background: linear-gradient(135deg, #10b981, #059669);
        }

        /* Footer */
        footer {
            text-align: center;
            padding: 20px;
            color: var(--dark-text);
            opacity: 0.7;
            font-size: 0.85rem;
            background: #f8fafc;
            border-radius: 12px;
            margin-top: 30px;
            border: 1px solid rgba(147, 197, 253, 0.3);
            width: 100%;
            max-width: 1200px;
        }

        /* Responsive */
        @media (max-width: 1024px) {
            .profile-info-grid {
                grid-template-columns: 1fr;
            }
            
            .profile-container {
                flex-direction: column;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 70px;
            }
            
            .logo-container h2, .logo-container p {
                display: none;
            }
            
            .nav-links a span {
                display: none;
            }
            
            .nav-links i {
                margin-right: 0;
                font-size: 1.2rem;
            }
            
            .main-content {
                margin-left: 70px;
                padding: 20px;
            }
            
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
                padding: 20px;
            }
            
            .header-actions {
                width: 100%;
                justify-content: center;
                flex-wrap: wrap;
            }
            
            .profile-card {
                padding: 25px;
            }
            
            .student-name {
                font-size: 1.8rem;
            }
            
            .profile-icon {
                width: 120px;
                height: 120px;
            }
            
            .profile-icon i {
                font-size: 3.5rem;
            }
            
            .action-buttons {
                flex-direction: column;
                align-items: center;
            }
            
            .action-btn {
                width: 100%;
                max-width: 300px;
            }
            
            .edit-form {
                padding: 20px;
                margin: 10px;
                max-width: 90%;
            }
            
            .form-actions {
                flex-direction: column;
            }
            
            .form-action-btn {
                width: 100%;
                min-width: auto;
            }
        }

        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(-20px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
    </style>
</head>
<body>
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
                <i class="fas fa-user-circle"></i> Student Profile
            </div>
            <div class="header-actions">
                
                <a href="Dashboard.jsp" class="profile-btn">
                    <div class="profile-pic">MA</div>
                    <span>Dashboard</span>
                </a>
            </div>
        </header>

        <!-- Profile Container - Default View -->
        <div class="profile-container">
            <!-- Profile Card - Display Mode -->
            <div class="profile-card" id="displayCard">
                <div class="profile-icon">
                    <i class="fas fa-user-graduate"></i>
                </div>
                
                <h1 class="student-name" id="displayName">Muhammad Amar Ghazali Bin Aziz</h1>
                <div class="student-id" id="displayStudentID">Student ID: 2025190337</div>
                
                <!-- Profile Information Grid -->
                <div class="profile-info-grid">
                    <!-- Email -->
                    <div class="info-item">
                        <div class="info-label">
                            <i class="fas fa-envelope"></i> Email Address
                        </div>
                        <div class="info-value" id="displayEmail"><a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4b2a262a39652c232a312a27220b383f3e2f2e253f653e223f26652e2f3e652632">[email&#160;protected]</a></div>
                    </div>
                    
                    <!-- Program -->
                    <div class="info-item">
                        <div class="info-label">
                            <i class="fas fa-graduation-cap"></i> Program
                        </div>
                        <div class="info-value locked-field" id="displayProgram">
                            Bachelor of Computer Science <i class="fas fa-lock lock-icon"></i>
                        </div>
                    </div>
                    
                    <!-- Phone Number -->
                    <div class="info-item">
                        <div class="info-label">
                            <i class="fas fa-phone"></i> Phone Number
                        </div>
                        <div class="info-value" id="displayPhone">+6012-3456789</div>
                    </div>
                    
                    <!-- Year of Study -->
                    <div class="info-item">
                        <div class="info-label">
                            <i class="fas fa-calendar-alt"></i> Year of Study
                        </div>
                        <div class="info-value locked-field" id="displayYear">
                            3 <i class="fas fa-lock lock-icon"></i>
                        </div>
                    </div>
                    
                    <!-- Password -->
                    <div class="info-item">
                        <div class="info-label">
                            <i class="fas fa-key"></i> Password
                        </div>
                        <div class="info-value" id="displayPassword">••••••••</div>
                    </div>
                    
                    <!-- Advisor Name -->
                    <div class="info-item">
                        <div class="info-label">
                            <i class="fas fa-user-tie"></i> Academic Advisor
                        </div>
                        <div class="info-value locked-field" id="displayAdvisor">
                            Dr. Ahmad bin Ismail <i class="fas fa-lock lock-icon"></i>
                        </div>
                    </div>
                </div>
                
                <!-- Action Buttons -->
                <div class="action-buttons">
                    <a href="Dashboard.jsp" class="action-btn secondary-btn">
                        <i class="fas fa-arrow-left"></i> Back to Dashboard
                    </a>
                    <button class="action-btn edit-btn" onclick="openEditForm()">
                        <i class="fas fa-edit"></i> Edit Profile
                    </button>
                </div>
            </div>
        </div>

        <!-- Edit Form Overlay - Hidden by Default -->
        <div class="edit-overlay" id="editOverlay">
            <div class="edit-form">
                <!-- Single Column Compact Edit Form Only -->
                <div class="edit-header">
                    <i class="fas fa-user-edit"></i>
                    <h2>Edit Profile Information</h2>
                </div>
                
                <form id="profileForm">
                    <!-- Editable Fields -->
                    <div class="form-group">
                        <label for="editName"><i class="fas fa-user"></i> Full Name</label>
                        <input type="text" id="editName" value="Muhammad Amar Ghazali Bin Aziz">
                    </div>
                    
                    <div class="form-group">
                        <label for="editEmail"><i class="fas fa-envelope"></i> Email Address</label>
                        <input type="email" id="editEmail" value="amar.ghazali@student.uitm.edu.my">
                    </div>
                    
                    <div class="form-group">
                        <label for="editPhone"><i class="fas fa-phone"></i> Phone Number</label>
                        <input type="tel" id="editPhone" value="+6012-3456789">
                    </div>
                    
                    <div class="form-group">
                        <label for="editPassword"><i class="fas fa-key"></i> Change Password</label>
                        <input type="password" id="editPassword" placeholder="Enter new password (optional)">
                    </div>
                    
                    <!-- Non-Editable Fields (Locked) -->
                    <div class="form-group">
                        <label><i class="fas fa-graduation-cap"></i> Program</label>
                        <input type="text" id="editProgram" value="" disabled>
                    </div>

                    <div class="form-group">
                        <label><i class="fas fa-calendar-alt"></i> Year of Study</label>
                        <input type="text" id="editYear" value="" disabled>
                    </div>

                    <div class="form-group">
                        <label><i class="fas fa-user-tie"></i> Academic Advisor</label>
                        <input type="text" id="editAdvisor" value="" disabled>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="form-action-btn form-cancel-btn" onclick="closeEditForm()">
                            <i class="fas fa-times"></i> Cancel
                        </button>
                        <button type="button" class="form-action-btn form-save-btn" onclick="saveProfile()">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Footer -->
        <footer>
            <p><strong>Academic Advising & Progress Tracking System</strong> | UiTM Terengganu, Campus Chendering</p>
            <p>© 2025 CSC584 - Enterprise Programming | Last update: 10 Dec 2025</p>
        </footer>
    </div>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/cloudflare-email-decode/1.0.0/email-decode.min.js"></script><script>
    document.addEventListener('DOMContentLoaded', function() {
        const displayName = document.getElementById('displayName');
        const displayStudentID = document.getElementById('displayStudentID');
        const displayEmail = document.getElementById('displayEmail');
        const displayPhone = document.getElementById('displayPhone');
        const displayProgram = document.getElementById('displayProgram');
        const displayYear = document.getElementById('displayYear');
        const displayAdvisor = document.getElementById('displayAdvisor');

        const editOverlay = document.getElementById('editOverlay');
        const displayCard = document.getElementById('displayCard');

        const editName = document.getElementById('editName');
        const editEmail = document.getElementById('editEmail');
        const editPhone = document.getElementById('editPhone');
        const editPassword = document.getElementById('editPassword');

        // Robust function to determine the webapp context path.
        // If app is deployed at root it returns '' (empty string),
        // otherwise returns '/MyAppContext' (no trailing slash).
        function getContextPath() {
            const p = window.location.pathname; // e.g. /Academic-Advising/Student/Profile.html
            const parts = p.split('/').filter(Boolean); // removes empty parts
            // If no segment or first segment looks like a filename (has a dot), assume root
            if (parts.length === 0) return '';
            // The first segment is usually the context path (unless app deployed at root)
            const first = parts[0];
            // If the first segment looks like a file name (contains '.'), treat as root
            if (first.indexOf('.') !== -1) return '';
            return '/' + first;
        }

        const ctx = getContextPath();

        async function loadStudent() {
            try {
                const url = ctx + '/api/student/me'; // e.g. /Academic-Advising/api/student/me or /api/student/me
                console.log('Fetching student data from', url);
                const res = await fetch(url, { cache: 'no-store' });
                if (!res.ok) {
                    // Helpful log for debugging
                    console.error('GET', url, 'returned', res.status, res.statusText);
                    if (res.status === 401) {
                        alert('Not authenticated. Please login.');
                        // redirect to index relative to context
                        window.location.href = (ctx || '/') + 'index.html';
                        return;
                    }
                    throw new Error('Failed to fetch student data: ' + res.status);
                }
                const data = await res.json();
                // Populate UI
                displayName.textContent = data.name || '';
                displayStudentID.textContent = 'Student ID: ' + (data.studentID || '');
                displayEmail.textContent = data.email || '';
                displayPhone.textContent = data.phoneNum || '';
                displayProgram.textContent = data.program || '';
                displayYear.textContent = data.yearOfStudy || '';
                displayAdvisor.textContent = data.advisorName || '';

                editName.value = data.name || '';
                editEmail.value = data.email || '';
                editPhone.value = data.phoneNum || '';

                const editProgram = document.getElementById('editProgram');
                const editYear = document.getElementById('editYear');
                const editAdvisor = document.getElementById('editAdvisor');

                if (editProgram) editProgram.value = data.program || '';
                if (editYear) editYear.value = data.yearOfStudy || '';
                if (editAdvisor) editAdvisor.value = data.advisorName || '';
            } catch (err) {
                console.error('Error loading student data:', err);
                showNotification('Unable to load profile data (see console)', 'error');
            }
        }

        loadStudent();

        // Open edit form
        window.openEditForm = function() {
            displayCard.style.display = 'none';
            editOverlay.style.display = 'flex';
        };

        // Close edit form
        window.closeEditForm = function() {
            displayCard.style.display = 'flex';
            editOverlay.style.display = 'none';
            editPassword.value = '';
        };

        // Save profile (calls API)
        window.saveProfile = async function() {
            const fullName = editName.value.trim();
            const email = editEmail.value.trim();
            const phone = editPhone.value.trim();
            const password = editPassword.value;

            // split into firstName / lastName (simple)
            let firstName = '', lastName = '';
            if (fullName) {
                const parts = fullName.split(' ');
                firstName = parts.shift();
                lastName = parts.join(' ');
            }

            if (!firstName || !email) {
                showNotification('Please fill required fields', 'error');
                return;
            }

            try {
                const form = new URLSearchParams();
                form.append('firstName', firstName);
                form.append('lastName', lastName);
                form.append('email', email);
                form.append('phoneNum', phone);
                if (password) form.append('password', password);

                const url = ctx + '/api/student/update';
                console.log('POST', url, 'payload', { firstName, lastName, email, phoneNum: phone, password: !!password });
                const res = await fetch(url, {
                    method: 'POST',
                    body: form,
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                });

                let json;
                try { json = await res.json(); } catch (e) { json = {}; }

                if (res.ok && json.success) {
                    showNotification('Profile updated', 'success');
                    closeEditForm();
                    loadStudent();
                } else {
                    console.error('Update failed', res.status, json);
                    showNotification(json.error || json.message || 'Update failed', 'error');
                }
            } catch (err) {
                console.error('Error updating profile:', err);
                showNotification('Error updating profile (see console)', 'error');
            }
        };

        // notification helper
        function showNotification(message, type) {
            const notification = document.createElement('div');
            notification.textContent = message;
            notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 12px 18px;
                border-radius: 10px;
                color: white;
                font-weight: 600;
                z-index: 2000;
                box-shadow: 0 6px 20px rgba(0,0,0,0.15);
            `;
            if (type === 'success') notification.style.background = 'linear-gradient(135deg,#10b981,#059669)';
            else if (type === 'error') notification.style.background = 'linear-gradient(135deg,#ef4444,#dc2626)';
            else notification.style.background = 'linear-gradient(135deg,#3b82f6,#1e3a8a)';

            document.body.appendChild(notification);
            setTimeout(() => {
                notification.style.transition = 'opacity 0.3s';
                notification.style.opacity = '0';
                setTimeout(() => notification.remove(), 300);
            }, 2500);
        }

        // Close edit overlay when clicking outside
        editOverlay.addEventListener('click', function(e) {
            if (e.target === this) closeEditForm();
        });
    });
    </script>
</body>
</html>

  