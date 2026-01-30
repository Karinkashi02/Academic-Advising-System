<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Get URL parameters for error/success messages
    String error = request.getParameter("error");
    String reg = request.getParameter("reg");
    
    // Prepare error/success messages
    String errorTitle = "";
    String errorMessage = "";
    String messageType = "error";
    boolean showModal = false;
    boolean switchToRegister = false;
    
    if (error != null) {
        showModal = true;
        switch (error) {
            case "invalid":
                errorTitle = "Login Failed";
                errorMessage = "Invalid username or password. Please check your credentials and try again.";
                break;
            case "db_error":
                errorTitle = "Database Error";
                errorMessage = "A database error occurred. Please try again later or contact support.";
                break;
            case "advisor_full":
                errorTitle = "Advisor Full";
                errorMessage = "The selected advisor has reached their maximum student capacity. Please select another advisor.";
                break;
            case "username_exists":
                errorTitle = "Username Already Taken";
                errorMessage = "This username is already registered in the system. Please choose a different username.";
                switchToRegister = true;
                break;
            case "email_exists":
                errorTitle = "Email Already Registered";
                errorMessage = "This email address is already associated with an account. Please use a different email or try logging in.";
                switchToRegister = true;
                break;
        }
    }
    
    if ("success".equals(reg)) {
        showModal = true;
        messageType = "success";
        errorTitle = "Registration Successful";
        errorMessage = "Your account has been created successfully! You can now log in with your credentials.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AcademicTrack | Login & Register</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background-color: #f5f9fc;
            color: #333;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
            position: relative;
            overflow-x: hidden;
        }
        
        /* Academic-themed background with subtle animation */
        .academic-background {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            background: linear-gradient(135deg, #eef2ff 0%, #f0f9ff 50%, #f5f0ff 100%);
        }
        
        /* Decorative elements with improved styling */
        .academic-element {
            position: absolute;
            color: rgba(26, 95, 180, 0.1);
            z-index: -1;
            animation: float 15s ease-in-out infinite;
        }
        
        .element-1 {
            top: 10%;
            left: 5%;
            font-size: 90px;
            animation-delay: 0s;
        }
        
        .element-2 {
            top: 15%;
            right: 7%;
            font-size: 80px;
            animation-delay: 5s;
        }
        
        .element-3 {
            bottom: 20%;
            left: 10%;
            font-size: 70px;
            animation-delay: 10s;
        }
        
        .element-4 {
            bottom: 15%;
            right: 8%;
            font-size: 60px;
            animation-delay: 3s;
        }
        
        /* Floating animation for background elements */
        @keyframes float {
            0%, 100% { transform: translateY(0) rotate(0deg) scale(1); }
            25% { transform: translateY(-20px) rotate(5deg) scale(1.05); }
            50% { transform: translateY(0) rotate(0deg) scale(1); }
            75% { transform: translateY(10px) rotate(-5deg) scale(0.95); }
        }
        
        /* Main container with improved styling */
        .container {
            display: flex;
            max-width: 1100px;
            width: 100%;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 15px 35px rgba(0, 0, 100, 0.15);
            background-color: white;
            position: relative;
            z-index: 1;
            min-height: 650px;
            transition: transform 0.3s ease;
        }
        
        .container:hover {
            transform: translateY(-5px);
            box-shadow: 0 20px 40px rgba(0, 0, 100, 0.2);
        }
        
        /* Form container */
        .form-container {
            flex: 1;
            padding: 40px 45px;
            background-color: white;
            display: flex;
            flex-direction: column;
            position: relative;
            transition: all 0.5s ease;
        }
        
        /* Welcome section */
        .welcome-section {
            flex: 1;
            padding: 40px 45px;
            background: linear-gradient(135deg, rgba(26, 95, 180, 0.97) 0%, rgba(45, 135, 216, 0.97) 100%);
            color: white;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
            overflow: hidden;
        }
        
        /* Welcome section pattern */
        .welcome-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-image: 
                radial-gradient(circle at 10% 90%, rgba(255, 255, 255, 0.1) 2px, transparent 2px),
                radial-gradient(circle at 90% 10%, rgba(255, 255, 255, 0.1) 2px, transparent 2px);
            background-size: 60px 60px;
            opacity: 0.4;
        }
        
        /* Logo styling */
        .logo {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
            gap: 12px;
        }
        
        .logo-icon {
            font-size: 32px;
            background: linear-gradient(135deg, #1a5fb4, #26a269);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            filter: drop-shadow(0 2px 3px rgba(0,0,0,0.1));
        }
        
        .logo-text {
            font-size: 28px;
            font-weight: 800;
            color: #1a5fb4;
            letter-spacing: -0.5px;
        }
        
        /* Tab switcher */
        .tab-switcher {
            display: flex;
            margin-bottom: 30px;
            border-radius: 12px;
            overflow: hidden;
            border: 2px solid #eef2ff;
            background: #f8fafc;
            position: relative;
        }
        
        .tab-btn {
            flex: 1;
            padding: 16px 10px;
            text-align: center;
            background-color: transparent;
            border: none;
            cursor: pointer;
            font-weight: 700;
            font-size: 16px;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            color: #64748b;
            position: relative;
            z-index: 1;
        }
        
        .tab-btn.active {
            color: #1a5fb4;
        }
        
        .tab-indicator {
            position: absolute;
            width: 50%;
            height: 100%;
            background: linear-gradient(135deg, #eef2ff 0%, #dbeafe 100%);
            border-radius: 10px;
            top: 0;
            left: 0;
            transition: transform 0.4s cubic-bezier(0.68, -0.55, 0.27, 1.55);
            z-index: 0;
        }
        
        /* Title with elegant styling */
        h2 {
            font-size: 28px;
            color: #1e293b;
            margin-bottom: 25px;
            font-weight: 800;
            letter-spacing: -0.5px;
            position: relative;
        }
        
        h2::after {
            content: '';
            position: absolute;
            bottom: -8px;
            left: 0;
            width: 60px;
            height: 4px;
            background: linear-gradient(135deg, #1a5fb4, #26a269);
            border-radius: 2px;
        }
        
        /* Welcome section styling */
        .welcome-section h2 {
            font-size: 36px;
            margin-bottom: 20px;
            color: white;
            font-weight: 900;
            position: relative;
            z-index: 1;
        }
        
        .welcome-section p {
            font-size: 16px;
            margin-bottom: 20px;
            line-height: 1.7;
            color: rgba(255, 255, 255, 0.95);
            position: relative;
            z-index: 1;
        }
        
        /* Features list in welcome section */
        .features {
            list-style: none;
            margin-top: 25px;
            position: relative;
            z-index: 1;
        }
        
        .features li {
            padding: 12px 0;
            font-size: 15px;
            color: rgba(255, 255, 255, 0.9);
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .features li i {
            color: #26a269;
            font-size: 18px;
            filter: drop-shadow(0 0 3px rgba(38, 162, 105, 0.5));
        }
        
       
        .credential-item {
            padding: 10px;
            margin: 8px 0;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 8px;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.3s;
            border: 1px solid rgba(255, 255, 255, 0.15);
        }
        
        .credential-item:hover {
            background: rgba(255, 255, 255, 0.2);
            transform: translateX(5px);
        }
        
        .credential-item strong {
            color: #fff;
        }
        
        /* Form content sections */
        .form-content {
            display: none;
        }
        
        .form-content.active {
            display: block;
        }
        
        /* Role selector */
        .role-selector {
            display: flex;
            gap: 12px;
            margin-bottom: 25px;
        }
        
        .role-btn {
            flex: 1;
            padding: 14px;
            background-color: #f1f5f9;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            cursor: pointer;
            text-align: center;
            font-weight: 700;
            font-size: 15px;
            color: #64748b;
            transition: all 0.3s;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }
        
        .role-btn i {
            font-size: 22px;
        }
        
        .role-btn.active {
            background: linear-gradient(135deg, #1a5fb4, #2d87d8);
            color: white;
            border-color: #1a5fb4;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(26, 95, 180, 0.3);
        }
        
        /* Input group styling */
        .input-group {
            margin-bottom: 20px;
            position: relative;
        }
        
        .input-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: #475569;
            font-size: 14px;
        }
        
        .input-group input,
        .input-group select {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            font-size: 15px;
            transition: all 0.3s;
            background-color: #f8fafc;
            color: #1e293b;
        }
        
        .input-group input:focus,
        .input-group select:focus {
            outline: none;
            border-color: #1a5fb4;
            background-color: white;
            box-shadow: 0 0 0 4px rgba(26, 95, 180, 0.1);
        }
        
        .input-group input::placeholder {
            color: #94a3b8;
        }
        
        /* Required field indicator */
        .required {
            color: #dc2626;
            margin-left: 3px;
        }
        
        /* Button styling */
        .submit-btn {
            width: 100%;
            padding: 16px;
            background: linear-gradient(135deg, #1a5fb4, #2d87d8);
            color: white;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.3s;
            margin-top: 10px;
            box-shadow: 0 4px 15px rgba(26, 95, 180, 0.3);
        }
        
        .submit-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(26, 95, 180, 0.4);
        }
        
        .submit-btn:active {
            transform: translateY(0);
        }
        
        /* Link styling */
        .switch-form {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: #64748b;
        }
        
        .switch-form a {
            color: #1a5fb4;
            font-weight: 700;
            text-decoration: none;
            transition: all 0.3s;
        }
        
        .switch-form a:hover {
            color: #2d87d8;
            text-decoration: underline;
        }
        
        /* Forgot password link */
        .forgot-password {
            text-align: right;
            margin-top: -10px;
            margin-bottom: 20px;
        }
        
        .forgot-password a {
            color: #1a5fb4;
            font-size: 13px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .forgot-password a:hover {
            color: #2d87d8;
            text-decoration: underline;
        }
        
        /* Role specific sections */
        .role-specific-section {
            display: none;
        }
        
        .role-specific-section.active {
            display: block;
        }
        
        /* Grid layout for form fields */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .form-grid .input-group {
            margin-bottom: 0;
        }
        
        /* Advisor Selection Styles */
        #advisorSelection {
            margin-top: 25px;
            padding: 20px;
            background-color: #f8fafc;
            border-radius: 12px;
            border: 2px solid #e2e8f0;
        }
        
        #advisorSelection h3 {
            margin-bottom: 15px;
            color: #1e293b;
            font-size: 18px;
            font-weight: 700;
        }
        
        .advisor-search {
            margin-bottom: 15px;
        }
        
        .advisor-search input {
            width: 100%;
            padding: 12px 16px;
            border: 2px solid #e2e8f0;
            border-radius: 8px;
            font-size: 14px;
        }
        
        .advisors-list {
            max-height: 350px;
            overflow-y: auto;
            padding-right: 5px;
        }
        
        .advisor-card {
            background: white;
            padding: 15px;
            margin-bottom: 12px;
            border-radius: 10px;
            border: 2px solid #e2e8f0;
            transition: all 0.3s;
        }
        
        .advisor-card.available {
            border-left: 4px solid #26a269;
        }
        
        .advisor-card.unavailable {
            opacity: 0.6;
            border-left: 4px solid #dc2626;
        }
        
        .advisor-card:hover.available {
            box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            transform: translateY(-2px);
        }
        
        .advisor-card h4 {
            margin-bottom: 8px;
            color: #1e293b;
            font-size: 16px;
        }
        
        .advisor-card p {
            margin: 5px 0;
            font-size: 13px;
            color: #64748b;
        }
        
        .status-available {
            color: #26a269;
            font-weight: 600;
        }
        
        .status-full {
            color: #dc2626;
            font-weight: 600;
        }
        
        /* Scrollbar styling */
        .advisors-list::-webkit-scrollbar {
            width: 8px;
        }
        
        .advisors-list::-webkit-scrollbar-track {
            background: #f1f5f9;
            border-radius: 10px;
        }
        
        .advisors-list::-webkit-scrollbar-thumb {
            background: #cbd5e1;
            border-radius: 10px;
        }
        
        .advisors-list::-webkit-scrollbar-thumb:hover {
            background: #94a3b8;
        }

        /* Modal Styles */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
            justify-content: center;
            align-items: center;
            animation: fadeIn 0.3s ease;
        }
        
        .modal-overlay.active {
            display: flex;
        }
        
        @keyframes fadeIn {
            from {
                opacity: 0;
            }
            to {
                opacity: 1;
            }
        }
        
        @keyframes slideIn {
            from {
                transform: translateY(-50px);
                opacity: 0;
            }
            to {
                transform: translateY(0);
                opacity: 1;
            }
        }
        
        .modal {
            background: white;
            border-radius: 16px;
            padding: 30px;
            max-width: 400px;
            width: 90%;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: slideIn 0.3s ease;
            position: relative;
        }
        
        .modal-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            gap: 15px;
        }
        
        .modal-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            flex-shrink: 0;
        }
        
        .modal-icon.error {
            background-color: #fee2e2;
            color: #dc2626;
        }
        
        .modal-icon.success {
            background-color: #dcfce7;
            color: #16a34a;
        }
        
        .modal-title {
            font-size: 20px;
            font-weight: 700;
            color: #1e293b;
            margin: 0;
        }
        
        .modal-body {
            margin-bottom: 25px;
        }
        
        .modal-message {
            color: #64748b;
            font-size: 15px;
            line-height: 1.6;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        
        .modal-btn {
            padding: 12px 24px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .modal-btn-primary {
            background: linear-gradient(135deg, #1a5fb4, #2d87d8);
            color: white;
        }
        
        .modal-btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(26, 95, 180, 0.3);
        }
        
        .modal-btn-secondary {
            background: #f1f5f9;
            color: #64748b;
        }
        
        .modal-btn-secondary:hover {
            background: #e2e8f0;
        }
        
        /* Responsive design */
        @media (max-width: 968px) {
            .container {
                flex-direction: column;
            }
            
            .welcome-section {
                padding: 30px;
            }
            
            .form-container {
                padding: 30px;
            }
        }
        
        @media (max-width: 600px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            
            .role-selector {
                flex-direction: column;
            }
            
            h2 {
                font-size: 24px;
            }
            
            .welcome-section h2 {
                font-size: 28px;
            }
        }
    </style>
</head>
<body>
    <!-- Academic Background -->
    <div class="academic-background"></div>
    
    <!-- Decorative Academic Elements -->
    <div class="academic-element element-1">
        <i class="fas fa-graduation-cap"></i>
    </div>
    <div class="academic-element element-2">
        <i class="fas fa-book"></i>
    </div>
    <div class="academic-element element-3">
        <i class="fas fa-user-graduate"></i>
    </div>
    <div class="academic-element element-4">
        <i class="fas fa-chalkboard-teacher"></i>
    </div>

    <!-- Error Modal -->
    <div id="errorModal" class="modal-overlay">
        <div class="modal">
            <div class="modal-header">
                <div class="modal-icon error">
                    <i class="fas fa-exclamation-circle"></i>
                </div>
                <h3 class="modal-title" id="modalTitle">Error</h3>
            </div>
            <div class="modal-body">
                <p class="modal-message" id="modalMessage">An error occurred.</p>
            </div>
            <div class="modal-footer">
                <button class="modal-btn modal-btn-primary" onclick="closeModal()">
                    OK
                </button>
            </div>
        </div>
    </div>

    <!-- Main Container -->
    <div class="container">
        <!-- Welcome Section -->
        <div class="welcome-section">
            <h2>Welcome to AcademicTrack</h2>
            <p>Your comprehensive academic advising platform designed to streamline student-advisor interactions and enhance academic planning.</p>
            
            <ul class="features">
                <li>
                    <i class="fas fa-calendar-check"></i>
                    <span>Schedule and manage advising appointments</span>
                </li>
                <li>
                    <i class="fas fa-comments"></i>
                    <span>Real-time communication with advisors</span>
                </li>
                <li>
                    <i class="fas fa-chart-line"></i>
                    <span>Track academic progress and goals</span>
                </li>
                <li>
                    <i class="fas fa-file-alt"></i>
                    <span>Access personalized academic resources</span>
                </li>
            </ul>
        </div>

        <!-- Form Container -->
        <div class="form-container">
            <!-- Logo -->
            <div class="logo">
                <i class="fas fa-graduation-cap logo-icon"></i>
                <span class="logo-text">AcademicTrack</span>
            </div>

            <!-- Tab Switcher -->
            <div class="tab-switcher">
                <div class="tab-indicator"></div>
                <button class="tab-btn active" id="login-tab-btn" onclick="switchTab('login')">
                    <i class="fas fa-sign-in-alt"></i>
                    Login
                </button>
                <button class="tab-btn" id="register-tab-btn" onclick="switchTab('register')">
                    <i class="fas fa-user-plus"></i>
                    Register
                </button>
            </div>

            <!-- Login Form -->
            <div id="login-form-content" class="form-content active">
                <h2>Login</h2>
                
                <!-- Role Selector for Login -->
                <div class="role-selector">
                    <button type="button" class="role-btn active" id="student-btn">
                        <i class="fas fa-user-graduate"></i>
                        <span>Student</span>
                    </button>
                    <button type="button" class="role-btn" id="advisor-btn">
                        <i class="fas fa-chalkboard-teacher"></i>
                        <span>Advisor</span>
                    </button>
                </div>

                <form id="login-form" action="LoginServlet" method="post">
                    <input type="hidden" name="role" id="login-role" value="student">
                    
                    <div class="input-group">
                        <label for="login-username">Username <span class="required">*</span></label>
                        <input type="text" id="login-username" name="username" required placeholder="Enter your username">
                    </div>

                    <div class="input-group">
                        <label for="login-password">Password <span class="required">*</span></label>
                        <input type="password" id="login-password" name="password" required placeholder="Enter your password">
                    </div>

                    <div class="forgot-password">
                        <a href="#">Forgot Password?</a>
                    </div>

                    <button type="submit" class="submit-btn">
                        <i class="fas fa-sign-in-alt"></i> Login
                    </button>
                </form>

                <div class="switch-form">
                    Don't have an account? <a href="#" id="switch-to-register">Register here</a>
                </div>
            </div>

            <!-- Register Form -->
            <div id="register-form-content" class="form-content">
                <h2>Register</h2>

                <form id="register-form" action="RegisterServlet" method="post" onsubmit="return validateRegistration()">
                    <!-- Role Selection -->
                    <div class="input-group">
                        <label for="reg-role">I am a <span class="required">*</span></label>
                        <select id="reg-role" name="role" required>
                            <option value="">Select Role</option>
                            <option value="student">Student</option>
                            <option value="advisor">Advisor</option>
                        </select>
                    </div>

                    <!-- Common Fields -->
                    <div class="form-grid">
                        <div class="input-group">
                            <label for="reg-firstName">First Name <span class="required">*</span></label>
                            <input type="text" id="reg-firstName" name="firstName" required placeholder="First name">
                        </div>
                        <div class="input-group">
                            <label for="reg-lastName">Last Name <span class="required">*</span></label>
                            <input type="text" id="reg-lastName" name="lastName" required placeholder="Last name">
                        </div>
                    </div>

                    <div class="input-group">
                        <label for="reg-username">Username <span class="required">*</span></label>
                        <input type="text" id="reg-username" name="username" required placeholder="Choose a username">
                    </div>

                    <div class="input-group">
                        <label for="reg-email">Email <span class="required">*</span></label>
                        <input type="email" id="reg-email" name="email" required placeholder="your.email@university.edu">
                    </div>

                    <div class="form-grid">
                        <div class="input-group">
                            <label for="reg-password">Password <span class="required">*</span></label>
                            <input type="password" id="reg-password" name="password" required placeholder="Create password">
                        </div>
                        <div class="input-group">
                            <label for="reg-confirm-password">Confirm Password <span class="required">*</span></label>
                            <input type="password" id="reg-confirm-password" name="confirmPassword" required placeholder="Re-enter password">
                        </div>
                    </div>

                    <!-- Student Specific Fields -->
                    <div id="student-specific-section" class="role-specific-section">
                        <div class="input-group">
                            <label for="studentID">Student ID <span class="required">*</span></label>
                            <input type="text" id="studentID" name="studentID" placeholder="e.g., S123456">
                        </div>

                        <div class="form-grid">
                            <div class="input-group">
                                <label for="program">Program <span class="required">*</span></label>
                                <select id="program" name="program">
                                    <option value="">Select Program</option>
                                    <option value="Computer Science">Computer Science</option>
                                    <option value="Engineering">Engineering</option>
                                    <option value="Business">Business</option>
                                    <option value="Arts">Arts</option>
                                    <option value="Science">Science</option>
                                </select>
                            </div>
                            <div class="input-group">
                                <label for="yearOfStudy">Year of Study <span class="required">*</span></label>
                                <select id="yearOfStudy" name="yearOfStudy">
                                    <option value="">Select Year</option>
                                    <option value="1">Year 1</option>
                                    <option value="2">Year 2</option>
                                    <option value="3">Year 3</option>
                                    <option value="4">Year 4</option>
                                </select>
                            </div>
                        </div>

                        <div class="input-group">
                            <label for="semester">Current Semester <span class="required">*</span></label>
                            <select id="semester" name="semester">
                                <option value="">Select Semester</option>
                                <option value="1">Semester 1</option>
                                <option value="2">Semester 2</option>
                            </select>
                        </div>

                        <!-- Advisor Selection -->
                        <div id="advisorSelection" style="display: none;">
                            <h3>Select Your Advisor (Optional)</h3>
                            <div class="advisor-search">
                                <input type="text" id="search-advisor" placeholder="Search advisors by name or department...">
                            </div>
                            <div class="advisors-list" id="advisorsContainer">
                                <!-- Advisors will be loaded here dynamically -->
                            </div>
                            <input type="hidden" id="selectedAdvisorID" name="advisorID">
                        </div>
                    </div>

                    <!-- Advisor Specific Fields -->
                    <div id="advisor-specific-section" class="role-specific-section">
                        <div class="form-grid">
                            <div class="input-group">
                                <label for="phoneNum">Phone Number <span class="required">*</span></label>
                                <input type="tel" id="phoneNum" name="phoneNum" placeholder="e.g., +1234567890">
                            </div>
                            <div class="input-group">
                                <label for="department">Department <span class="required">*</span></label>
                                <select id="department" name="department">
                                    <option value="">Select Department</option>
                                    <option value="Computer Science">Computer Science</option>
                                    <option value="Engineering">Engineering</option>
                                    <option value="Business">Business</option>
                                    <option value="Arts">Arts</option>
                                    <option value="Science">Science</option>
                                </select>
                            </div>
                        </div>

                        <div class="input-group">
                            <label for="expertise">Area of Expertise <span class="required">*</span></label>
                            <input type="text" id="expertise" name="expertise" placeholder="e.g., Data Science, Software Engineering">
                        </div>

                        <div class="form-grid">
                            <div class="input-group">
                                <label for="maxSTD">Maximum Students <span class="required">*</span></label>
                                <input type="number" id="maxSTD" name="maxSTD" min="1" max="50" placeholder="e.g., 20">
                            </div>
                            <div class="input-group">
                                <label for="officeloc">Office Location <span class="required">*</span></label>
                                <input type="text" id="officeloc" name="officeloc" placeholder="e.g., Building A, Room 201">
                            </div>
                        </div>

                        <div class="input-group">
                            <label for="officehours">Office Hours <span class="required">*</span></label>
                            <input type="text" id="officehours" name="officehours" placeholder="e.g., Mon-Wed 2-4 PM">
                        </div>
                    </div>

                    <button type="submit" class="submit-btn">
                        <i class="fas fa-user-plus"></i> Register
                    </button>
                </form>

                <div class="switch-form">
                    Already have an account? <a href="#" id="switch-to-login">Login here</a>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Get references to DOM elements
        const loginTabBtn = document.getElementById('login-tab-btn');
        const registerTabBtn = document.getElementById('register-tab-btn');
        const loginFormContent = document.getElementById('login-form-content');
        const registerFormContent = document.getElementById('register-form-content');
        const tabIndicator = document.querySelector('.tab-indicator');
        const switchToRegister = document.getElementById('switch-to-register');
        const switchToLogin = document.getElementById('switch-to-login');

        // Modal functions
        function showModal(title, message, type = 'error') {
            const modal = document.getElementById('errorModal');
            const modalTitle = document.getElementById('modalTitle');
            const modalMessage = document.getElementById('modalMessage');
            const modalIcon = modal.querySelector('.modal-icon');
            
            modalTitle.textContent = title;
            modalMessage.textContent = message;
            
            // Update icon based on type
            if (type === 'success') {
                modalIcon.classList.remove('error');
                modalIcon.classList.add('success');
                modalIcon.innerHTML = '<i class="fas fa-check-circle"></i>';
            } else {
                modalIcon.classList.remove('success');
                modalIcon.classList.add('error');
                modalIcon.innerHTML = '<i class="fas fa-exclamation-circle"></i>';
            }
            
            modal.classList.add('active');
        }

        function closeModal() {
            const modal = document.getElementById('errorModal');
            modal.classList.remove('active');
        }

        // Close modal when clicking outside
        document.getElementById('errorModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeModal();
            }
        });

        // JSP-driven modal display
        <% if (showModal) { %>
            window.addEventListener('load', function() {
                showModal('<%= errorTitle %>', '<%= errorMessage %>', '<%= messageType %>');
                <% if (switchToRegister) { %>
                    switchTab('register');
                <% } %>
            });
        <% } %>

        // Form validation for registration
        function validateRegistration() {
            const password = document.getElementById('reg-password').value;
            const confirmPassword = document.getElementById('reg-confirm-password').value;
            
            // Check if passwords match
            if (password !== confirmPassword) {
                showModal('Password Mismatch', 'The passwords you entered do not match. Please make sure both password fields are identical.');
                return false;
            }
            
            // Check password strength (optional)
            if (password.length < 6) {
                showModal('Weak Password', 'Your password must be at least 6 characters long for security purposes.');
                return false;
            }
            
            return true;
        }

        // Function to switch between Login and Register tabs
        function switchTab(tab) {
            if (tab === 'login') {
                // Move indicator to left
                tabIndicator.style.transform = 'translateX(0)';
                
                // Show login form, hide register form
                loginFormContent.style.display = 'block';
                registerFormContent.style.display = 'none';
                
                // Update button active states
                loginTabBtn.classList.add('active');
                registerTabBtn.classList.remove('active');
            } else {
                // Move indicator to right
                tabIndicator.style.transform = 'translateX(100%)';
                
                // Show register form, hide login form
                loginFormContent.style.display = 'none';
                registerFormContent.style.display = 'block';
                
                // Update button active states
                loginTabBtn.classList.remove('active');
                registerTabBtn.classList.add('active');
            }
        }

        // Function to switch between Student and Advisor in login
        function switchLoginRole(role) {
            const studentBtn = document.getElementById('student-btn');
            const advisorBtn = document.getElementById('advisor-btn');
            const roleInput = document.getElementById('login-role');
            
            if (role === 'student') {
                studentBtn.classList.add('active');
                advisorBtn.classList.remove('active');
                if (roleInput) roleInput.value = 'student';
            } else {
                studentBtn.classList.remove('active');
                advisorBtn.classList.add('active');
                if (roleInput) roleInput.value = 'advisor';
            }
        }

        // Function to show/hide fields based on Student or Advisor role in registration
        function toggleFields() {
            const roleSelect = document.getElementById('reg-role');
            if (!roleSelect) return;
            const role = roleSelect.value;
            const studentSection = document.getElementById('student-specific-section');
            const advisorSection = document.getElementById('advisor-specific-section');
            const advisorSelectionDiv = document.getElementById('advisorSelection');

            if (role === 'student') {
                studentSection.classList.add('active');
                advisorSection.classList.remove('active');

                // Show advisor selection area and load advisors
                if (advisorSelectionDiv) {
                    advisorSelectionDiv.style.display = 'block';
                    loadAdvisors();
                }
            } else if (role === 'advisor') {
                studentSection.classList.remove('active');
                advisorSection.classList.add('active');

                // Hide advisor selection area
                if (advisorSelectionDiv) advisorSelectionDiv.style.display = 'none';
            } else {
                // If no role selected, hide both
                studentSection.classList.remove('active');
                advisorSection.classList.remove('active');
                if (advisorSelectionDiv) advisorSelectionDiv.style.display = 'none';
            }
        }

        // Initialize view
        window.onload = () => {
            // Set login as default tab
            switchTab('login');
            
            // Set student as default role in login
            switchLoginRole('student');
            
            // Add event listeners for the "switch to" links
            switchToRegister.addEventListener('click', function(e) {
                e.preventDefault();
                switchTab('register');
            });
            
            switchToLogin.addEventListener('click', function(e) {
                e.preventDefault();
                switchTab('login');
            });
            
            // Add event listeners for role buttons in login
            document.getElementById('student-btn').addEventListener('click', function() {
                switchLoginRole('student');
            });
            
            document.getElementById('advisor-btn').addEventListener('click', function() {
                switchLoginRole('advisor');
            });
            
            // Initialize registration role fields
            toggleFields();
            
            // Add change event listener to registration role dropdown
            const regRoleEl = document.getElementById('reg-role');
            if (regRoleEl) regRoleEl.addEventListener('change', toggleFields);
            
        };
        
        async function loadAdvisors() {
            try {
                // Build a robust base path in case the app is deployed under a context path.
                // e.g. /Academic_Advising/index.html -> base = /Academic_Advising
                const base = window.location.pathname.replace(/\/[^\/]*$/, '') || '';
                const url = base + '/api/advisors/available';
                const response = await fetch(url, { cache: 'no-store' });
                if (!response.ok) {
                    throw new Error('Failed to load advisors: ' + response.status);
                }
                const data = await response.json();
                const container = document.getElementById('advisorsContainer');
                container.innerHTML = '';
                
                // If search input exists, capture search term for simple client-side filtering
                const searchInput = document.getElementById('search-advisor');
                const searchTerm = searchInput ? searchInput.value.trim().toLowerCase() : '';

                (data.advisors || []).forEach(advisor => {
                    // Basic client-side filter by name or department if search term present
                    const matchesSearch = !searchTerm ||
                        (advisor.name && advisor.name.toLowerCase().includes(searchTerm)) ||
                        (advisor.department && advisor.department.toLowerCase().includes(searchTerm));
                    if (!matchesSearch) return;

                    const card = document.createElement('div');
                    card.className = 'advisor-card ' + (advisor.available ? 'available' : 'unavailable');
                    
                    // Use the exact properties the servlet provides (officeLocation vs officeLoc mapping)
                    const officeLocation = advisor.officeLocation || advisor.officeLoc || '';
                    const numStudents = advisor.numStudents != null ? advisor.numStudents : advisor.numSTD;
                    const maxStudents = advisor.maxStudents != null ? advisor.maxStudents : advisor.maxSTD;
                    
                    card.innerHTML = '<h4>' + advisor.name + '</h4>' +
                        '<p><strong>Department:</strong> ' + (advisor.department || '') + '</p>' +
                        '<p><strong>Expertise:</strong> ' + (advisor.expertise || '') + '</p>' +
                        '<p><strong>Office Hours:</strong> ' + (advisor.officeHours || '') + '</p>' +
                        '<p><strong>Location:</strong> ' + officeLocation + '</p>' +
                        '<p><strong>Current Students:</strong> ' + numStudents + '/' + maxStudents + '</p>' +
                        '<p class="' + (advisor.available ? 'status-available' : 'status-full') + '">' +
                            (advisor.status || (advisor.available ? 'Available' : 'Full')) + ' ' + (advisor.available ? '(' + advisor.availableSlots + ' slots remaining)' : '') +
                        '</p>' +
                        (advisor.available ? 
                            '<div style="margin-top:8px"><label><input type="radio" name="advisorID" value="' + advisor.advisorID + '" onchange="selectAdvisor(' + advisor.advisorID + ')"> Select this advisor</label></div>' : 
                            '<em>Currently unavailable</em>');
                    
                    container.appendChild(card);
                });

                // If a search box exists, wire it to refilter advisors client-side
                const searchInputEl = document.getElementById('search-advisor');
                if (searchInputEl) {
                    searchInputEl.oninput = () => loadAdvisors();
                }
            } catch (error) {
                console.error('Error loading advisors:', error);
                const container = document.getElementById('advisorsContainer');
                if (container) container.innerHTML = '<p style="color: #b00020;">Unable to load advisors at this time.</p>';
            }
        }
        
        function selectAdvisor(advisorID) {
            const hidden = document.getElementById('selectedAdvisorID');
            if (hidden) hidden.value = advisorID;
            // Optionally mark selected visually (for custom UI)
            // highlight the selected card (not strictly necessary)
        }
    </script>
</body>
</html>
