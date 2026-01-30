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
    <title>Advising Session Management</title>
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
            
            /* Action colors */
            --success-green: #27ae60;
            --danger-red: #e74c3c;
            --warning: #f39c12;
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
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            font-size: 13px;
            text-align: center;
            color: rgba(255, 255, 255, 0.7);
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

        .search-btn, .profile-btn, .logout-btn {
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

        .search-btn:hover, .profile-btn:hover {
            background: var(--blue-primary);
            color: white;
            border-color: var(--blue-primary);
        }

        .logout-btn {
            background: #ffeaea;
            color: #e74c3c;
            border-color: #ffcdcd;
        }

        .logout-btn:hover {
            background: #ffcdcd;
            color: #c0392b;
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

        /* Filter Section Styles */
        .filter-section {
            background: var(--blue-light);
            border-radius: 8px;
            padding: 15px 20px;
            margin-bottom: 20px;
            border: 1px solid var(--blue-border);
        }

        .filter-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }

        .filter-header h3 {
            font-size: 16px;
            font-weight: 600;
            color: var(--blue-dark);
        }

        .filter-options {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .filter-btn {
            padding: 8px 16px;
            background: white;
            border: 2px solid var(--blue-border);
            border-radius: 6px;
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            font-size: 13px;
            color: var(--blue-primary);
            cursor: pointer;
            transition: all 0.2s;
        }

        .filter-btn:hover {
            background: var(--blue-light);
        }

        .filter-btn.active {
            background: var(--blue-primary);
            color: white;
            border-color: var(--blue-primary);
        }

        .clear-filter-btn {
            padding: 8px 16px;
            background: white;
            border: 2px solid var(--blue-border);
            border-radius: 6px;
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            font-size: 13px;
            color: var(--text-light);
            cursor: pointer;
            transition: all 0.2s;
        }

        .clear-filter-btn:hover {
            background: var(--blue-light);
            color: var(--blue-primary);
        }

        /* Stats Cards */
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--bg-card);
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
            display: flex;
            align-items: center;
            gap: 15px;
            border-left: 4px solid var(--blue-primary);
        }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 8px;
            background-color: rgba(52, 152, 219, 0.1);
            color: var(--blue-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
        }

        .stat-info h3 {
            font-size: 28px;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1;
        }

        .stat-info p {
            font-size: 14px;
            color: var(--text-light);
        }

        /* Table Styles - IMPROVED */
        .table-container {
            overflow-x: auto;
            margin-top: 20px;
            width: 100%;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            table-layout: fixed; /* Use fixed layout for better column control */
        }

        thead {
            background-color: var(--blue-light);
        }

        th {
            padding: 16px 12px;
            text-align: left;
            font-weight: 600;
            color: var(--blue-dark);
            border-bottom: 2px solid var(--blue-primary);
            font-size: 14px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        td {
            padding: 16px 12px;
            border-bottom: 1px solid var(--blue-border);
            font-size: 14px;
            vertical-align: top;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        tr:hover {
            background-color: rgba(52, 152, 219, 0.05);
        }

        /* Table Cell Styles - IMPROVED COLUMN DISTRIBUTION */
        .number-cell {
            text-align: center;
            font-weight: 600;
            color: var(--blue-primary);
            width: 50px;
            min-width: 50px;
            max-width: 50px;
        }

        /* Improved Session Name & Type column - LESS SPACE */
        td:nth-child(2) {
            font-weight: 600;
            color: var(--text-dark);
            min-width: 180px;
            max-width: 220px;
            width: 22%; /* Reduced from larger value */
            white-space: normal;
            word-wrap: break-word;
        }

        .session-name-cell {
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 4px;
            line-height: 1.3;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .session-type-cell {
            font-size: 12px;
            color: var(--text-light);
            line-height: 1.3;
        }

        .date-cell {
            color: var(--text-dark);
            font-weight: 500;
            width: 120px;
            min-width: 120px;
            max-width: 120px;
        }

        .status-cell {
            width: 90px;
            min-width: 90px;
            max-width: 90px;
        }

        .notes-cell {
            color: var(--text-dark);
            font-size: 13px;
            line-height: 1.5;
            width: 200px;
            min-width: 180px;
            max-width: 220px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .actions-cell {
            width: 140px;
            min-width: 140px;
            max-width: 140px;
        }

        /* Set column widths for the first table */
        #mySessionsTable th:nth-child(1) { width: 50px; } /* No. */
        #mySessionsTable th:nth-child(2) { width: 22%; } /* Session Name & Type - REDUCED */
        #mySessionsTable th:nth-child(3) { width: 120px; } /* Date & Time */
        #mySessionsTable th:nth-child(4) { width: 95px; text-align: center; } /* Status */
        #mySessionsTable th:nth-child(5) { width: 160px; text-align: center; } /* Details */
        #mySessionsTable th:nth-child(6) { width: 150px; text-align: center; } /* Notes */
        #mySessionsTable th:nth-child(7) { width: 140px; text-align: center; } /* Actions */

        /* Set column widths for the second table - ADJUSTED FOR REMOVED STUDENT NAME COLUMN */
        #requestsTable th:nth-child(1) { width: 50px; min-width: 50px; } /* No. */
        #requestsTable th:nth-child(2) { width: 30%; min-width: 180px; } /* Session Name */
        #requestsTable th:nth-child(3) { width: 15%; min-width: 120px; } /* Date & Time */
        #requestsTable th:nth-child(4) { width: 10%; min-width: 90px; text-align: center; } /* Status */
        #requestsTable th:nth-child(5) { width: 30%; min-width: 160px; } /* Notes */
        #requestsTable th:nth-child(6) { width: 140px; min-width: 120px; text-align: center; } /* Actions */

        /* Status Styles */
        .status-badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 16px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-completed {
            background-color: rgba(39, 174, 96, 0.1);
            color: var(--success-green);
            border: 1px solid rgba(39, 174, 96, 0.3);
        }

        .status-upcoming {
            background-color: rgba(52, 152, 219, 0.1);
            color: var(--blue-primary);
            border: 1px solid rgba(52, 152, 219, 0.3);
        }

        .status-cancelled {
            background-color: rgba(231, 76, 60, 0.1);
            color: var(--danger-red);
            border: 1px solid rgba(231, 76, 60, 0.3);
        }

        .status-pending {
            background-color: rgba(243, 156, 18, 0.1);
            color: var(--warning);
            border: 1px solid rgba(243, 156, 18, 0.3);
        }

        .status-approved {
            background-color: rgba(39, 174, 96, 0.1);
            color: var(--success-green);
            border: 1px solid rgba(39, 174, 96, 0.3);
        }

        .status-rejected {
            background-color: rgba(231, 76, 60, 0.1);
            color: var(--danger-red);
            border: 1px solid rgba(231, 76, 60, 0.3);
        }

        /* Action buttons */
        .action-buttons {
            display: flex;
            gap: 8px;
            flex-wrap: nowrap;
        }

        .btn {
            padding: 8px 12px;
            border-radius: 6px;
            font-family: 'Inter', sans-serif;
            font-weight: 600;
            font-size: 13px;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            min-width: 70px;
            justify-content: center;
        }

        .btn-primary {
            background-color: var(--blue-primary);
            color: white;
            border: 1px solid var(--blue-primary);
        }

        .btn-primary:hover {
            background-color: var(--blue-dark);
            transform: translateY(-2px);
        }

        .btn-secondary {
            background-color: var(--blue-light);
            color: var(--blue-primary);
            border: 1px solid var(--blue-border);
        }

        .btn-secondary:hover {
            background-color: rgba(52, 152, 219, 0.2);
        }

        .btn-success {
            background-color: rgba(39, 174, 96, 0.1);
            color: var(--success-green);
            border: 1px solid rgba(39, 174, 96, 0.3);
        }

        .btn-success:hover {
            background-color: rgba(39, 174, 96, 0.2);
        }

        .btn-danger {
            background-color: rgba(231, 76, 60, 0.1);
            color: var(--danger-red);
            border: 1px solid rgba(231, 76, 60, 0.3);
        }

        .btn-danger:hover {
            background-color: rgba(231, 76, 60, 0.2);
        }

        .btn-small {
            padding: 6px 10px;
            font-size: 12px;
            min-width: 20px;
        }

        .btn-icon {
            padding: 8px;
            min-width: 36px;
            max-width: 36px;
        }

        .btn-export {
            background-color: var(--blue-light);
            color: var(--blue-primary);
            border: 1px solid var(--blue-border);
        }

        .btn-export:hover {
            background-color: var(--blue-primary);
            color: white;
        }

        /* Search box */
        .search-box {
            padding: 10px 15px;
            border: 1px solid var(--border);
            border-radius: 6px;
            width: 250px;
            font-family: 'Inter', sans-serif;
            font-size: 14px;
        }

        .search-box:focus {
            outline: none;
            border-color: var(--blue-primary);
        }

        /* Pagination Styles */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 30px;
            gap: 10px;
            flex-wrap: wrap;
        }

        .pagination-btn {
            padding: 8px 16px;
            border: 1px solid var(--blue-border);
            background: white;
            color: var(--blue-primary);
            border-radius: 6px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .pagination-btn:hover:not(:disabled) {
            background-color: var(--blue-light);
            transform: translateY(-2px);
        }

        .pagination-btn.active {
            background-color: var(--blue-primary);
            color: white;
            border-color: var(--blue-primary);
        }

        .pagination-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .pagination-info {
            margin: 0 15px;
            color: var(--text-light);
            font-size: 14px;
            min-width: 150px;
            text-align: center;
        }

        /* Modal Styles */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            backdrop-filter: blur(3px);
            z-index: 1000;
            justify-content: center;
            align-items: center;
            animation: fadeIn 0.3s ease;
        }

        @keyframes fadeIn {
            from { opacity: 0; }
            to { opacity: 1; }
        }

        .modal-content {
            background-color: var(--bg-card);
            border-radius: 12px;
            width: 90%;
            max-width: 800px;
            max-height: 90vh;
            overflow-y: auto;
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.2);
            position: relative;
            border: 1px solid var(--blue-border);
            animation: slideUp 0.3s ease;
        }

        @keyframes slideUp {
            from { transform: translateY(20px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }

        .modal-header {
            padding: 25px 30px;
            border-bottom: 1px solid var(--blue-border);
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: linear-gradient(135deg, var(--blue-primary) 0%, var(--blue-dark) 100%);
            color: white;
            border-radius: 12px 12px 0 0;
        }

        .modal-header h3 {
            font-size: 22px;
            font-weight: 700;
            color: white;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .close-modal {
            background: rgba(255, 255, 255, 0.2);
            border: none;
            width: 36px;
            height: 36px;
            border-radius: 50%;
            font-size: 20px;
            color: white;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .close-modal:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: rotate(90deg);
        }

        .modal-body {
            padding: 30px;
        }

        .form-group {
            margin-bottom: 25px;
        }

        .form-group label {
            display: block;
            margin-bottom: 10px;
            font-weight: 600;
            color: var(--text-dark);
            font-size: 15px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .form-group label i {
            color: var(--blue-primary);
            width: 20px;
        }

        .form-control {
            width: 100%;
            padding: 14px 16px;
            border: 2px solid var(--blue-border);
            border-radius: 8px;
            font-family: 'Inter', sans-serif;
            font-size: 15px;
            transition: all 0.2s;
            background: var(--bg-light);
        }

        .form-control:focus {
            outline: none;
            border-color: var(--blue-primary);
            background: white;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.15);
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
            line-height: 1.5;
        }

        .modal-footer {
            padding: 25px 30px;
            border-top: 1px solid var(--blue-border);
            display: flex;
            justify-content: flex-end;
            gap: 15px;
            background: var(--bg-light);
            border-radius: 0 0 12px 12px;
        }

        /* Form row for inline fields */
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        /* Student list in view modal */
        .student-list {
            margin-top: 15px;
            max-height: 200px;
            overflow-y: auto;
            padding: 10px;
            background: var(--bg-light);
            border-radius: 8px;
            border: 2px dashed var(--blue-border);
        }

        .student-item {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 12px;
            padding: 15px;
            border: 2px solid var(--blue-border);
            border-radius: 8px;
            background: white;
        }

        .student-item:last-child {
            margin-bottom: 0;
        }

        .student-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background-color: var(--blue-light);
            color: var(--blue-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            font-weight: 600;
            border: 2px solid var(--blue-border);
        }

        .student-info {
            flex: 1;
        }

        .student-name {
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 4px;
        }

        .student-major-year {
            font-size: 13px;
            color: var(--text-light);
        }

        /* Session details in view modal */
        .session-details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 25px;
        }

        .detail-item {
            margin-bottom: 15px;
        }

        .detail-label {
            font-size: 13px;
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
            padding: 10px;
            background: var(--bg-light);
            border-radius: 6px;
            border: 1px solid var(--blue-border);
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
        @media (max-width: 1200px) {
            /* Adjust column widths for medium-large screens */
            #mySessionsTable th:nth-child(2) { width: 25%; }
            #mySessionsTable th:nth-child(5) { width: 180px; }

            #requestsTable th:nth-child(2) { width: 28%; }
            #requestsTable th:nth-child(3) { width: 16%; }
            #requestsTable th:nth-child(4) { width: 10%; }
            #requestsTable th:nth-child(5) { width: 26%; }
            #requestsTable th:nth-child(6) { width: 140px; }
        }

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
            
            .search-box {
                width: 200px;
            }
            
            .pagination {
                flex-direction: column;
                gap: 15px;
            }
            
            /* Adjust table for medium screens */
            table {
                table-layout: auto; /* Switch to auto layout for flexibility */
            }
            
            .date-cell, .status-cell, .actions-cell {
                min-width: auto;
                max-width: none;
                width: auto;
            }
            
            .notes-cell {
                min-width: 150px;
                max-width: none;
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
            
            .stats {
                grid-template-columns: 1fr;
            }
            
            .search-box {
                width: 100%;
            }
            
            .card-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 15px;
            }
            
            .filter-options {
                justify-content: center;
            }
            
            .filter-btn {
                flex: 1;
                min-width: 100px;
                text-align: center;
            }
            
            .table-container {
                font-size: 13px;
            }
            
            th, td {
                padding: 12px 8px;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
                min-width: auto;
            }
            
            .pagination-info {
                margin: 10px 0;
            }
            
            .session-details-grid {
                grid-template-columns: 1fr;
            }
            
            .form-row {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 480px) {
            .table-container {
                font-size: 12px;
            }
            
            th, td {
                padding: 10px 6px;
            }
            
            .number-cell {
                width: 40px;
            }
            
            .btn {
                padding: 6px 10px;
                font-size: 12px;
            }
            
            .pagination-btn {
                padding: 6px 10px;
                font-size: 12px;
            }
            
            .action-buttons .btn {
                font-size: 11px;
                padding: 4px 6px;
            }
            
            .filter-btn {
                min-width: 80px;
                font-size: 12px;
                padding: 6px 10px;
            }
            
            /* Hide session type on very small screens to save space */
            .session-type-cell {
                display: none;
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
                    <span>My Advisees</span>
                </a>
                <a href="view_advising_session.jsp" class="nav-item active">
                    <i class="fas fa-calendar-check"></i>
                    <span>Advising Sessions</span>
                </a>
                <a href="advisor_report.jsp" class="nav-item">
                    <i class="fas fa-chart-bar"></i>
                    <span>Reports</span>
                </a>
            </nav>
            
            <div class="sidebar-footer">
                © 2025 Advising System
            </div>
        </div>  <!-- END OF SIDEBAR -->
        
        <!-- Main Content -->
        <div class="main-content">
            <!-- Header -->
            <header class="header">
                <h1>Advising Session Management</h1>
                <div class="header-actions">
                    <div class="search-btn" title="Search">🔍</div>
                    <a href="advisor_profile.jsp" class="profile-btn" title="Admin Profile">👤</a>
                    <div class="logout-btn" title="Logout">🚪</div>
                </div>
            </header>
            
            <!-- Content Area -->
            <div class="content">
                <!-- Stats Cards -->
                <div class="stats">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-calendar-alt"></i>
                        </div>
                        <div class="stat-info">
                            <h3 id="total-sessions">24</h3>
                            <p>Total Sessions</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-clock"></i>
                        </div>
                        <div class="stat-info">
                            <h3 id="pending-count">8</h3>
                            <p>Pending Review</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-check-circle"></i>
                        </div>
                        <div class="stat-info">
                            <h3 id="approved-count">14</h3>
                            <p>Approved</p>
                        </div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-times-circle"></i>
                        </div>
                        <div class="stat-info">
                            <h3 id="rejected-count">2</h3>
                            <p>Cancelled</p>
                        </div>
                    </div>
                </div>
                
                <!-- My Advising Sessions Card -->
                <div class="card">
                    <div class="card-header">
                        <h2>My Advising Sessions</h2>
                        <div style="display: flex; gap: 15px; align-items: center;">
                            <button class="btn btn-primary" id="createSessionBtnTop" title="Create new session">
                                <i class="fas fa-plus"></i> Create Session
                            </button>
                            <input type="text" class="search-box" placeholder="Search my sessions..." id="searchMySessions">
                        </div>
                    </div>
                    
                    <!-- Filter Section for My Sessions -->
                    <div class="filter-section">
                        <div class="filter-header">
                            <h3>Filter by Status</h3>
                            <button class="clear-filter-btn" id="clearMySessionFilter">
                                <i class="fas fa-times"></i> Clear Filter
                            </button>
                        </div>
                        <div class="filter-options">
                            <button class="filter-btn active" data-status="all">All Sessions</button>
                            <button class="filter-btn" data-status="upcoming">Upcoming</button>
                            <button class="filter-btn" data-status="confirmed">Confirmed</button>
                            <button class="filter-btn" data-status="completed">Completed</button>
                            <button class="filter-btn" data-status="cancelled">Cancelled</button>
                        </div>
                    </div>
                    
                    <div class="table-container">
                        <table id="mySessionsTable">
                            <thead>
                                <tr>
                                    <th class="number-cell">No.</th>
                                    <th>Session Name & Type</th>
                                    <th class="date-cell">Date & Time</th>
                                    <th class="status-cell">Status</th>
                                    <th class="notes-cell">Details</th>
                                    <th class="notes-cell">Notes</th>
                                    <th class="actions-cell">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="mySessionsTableBody">
                                <!-- Sessions will be loaded by JavaScript -->
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination for My Sessions -->
                    <div class="pagination" id="mySessionsPagination">
                        <!-- Pagination will be loaded by JavaScript -->
                    </div>
                </div>

                <!-- Session Requests Card -->
                <div class="card">
                    <div class="card-header">
                        <h2>Student Session Requests</h2>
                    </div>
                    
                    <div class="table-container">
                        <table id="requestsTable">
                            <thead>
                                <tr>
                                    <th class="number-cell">No.</th>
                                    <th>Session Name</th>
                                    <th class="date-cell">Date & Time</th>
                                    <th class="status-cell">Status</th>
                                    <th class="notes-cell">Notes</th>
                                    <th class="actions-cell">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="requestsTableBody">
                                <!-- Session Requests will be loaded by JavaScript -->
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination for Session Requests -->
                    <div class="pagination" id="requestsPagination">
                        <!-- Pagination will be loaded by JavaScript -->
                    </div>
                </div>
            </div>
            
            <footer>
                © 2025 Advising System — University Academic Services
            </footer>
        </div>
    </div>

    <!-- View Session Modal -->
    <div class="modal" id="viewSessionModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-eye"></i> Session Details</h3>
                <button class="close-modal" id="closeViewSessionModal">&times;</button>
            </div>
            <div class="modal-body">
                <div class="session-details-grid">
                    <div class="detail-item">
                        <div class="detail-label">Session Name</div>
                        <div class="detail-value" id="viewSessionName">Loading...</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Session Type</div>
                        <div class="detail-value" id="viewSessionType">Loading...</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Date</div>
                        <div class="detail-value" id="viewSessionDate">Loading...</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Time</div>
                        <div class="detail-value" id="viewSessionTime">Loading...</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Duration</div>
                        <div class="detail-value" id="viewSessionDuration">Loading...</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Status</div>
                        <div class="detail-value">
                            <span id="viewSessionStatus" class="status-badge status-upcoming">Upcoming</span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Meeting Link</div>
                        <div class="detail-value" id="viewSessionLocation">Not specified</div>
                    </div>
                    <div class="detail-item">
                        <div class="detail-label">Physical Location</div>
                        <div class="detail-value" id="viewSessionPhysicalLocation">Not specified</div>
                    </div>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-users"></i> Students in this Session</label>
                    <div class="student-list" id="viewSessionStudents">
                        <!-- Students will be populated here -->
                    </div>
                </div>
                
                <div class="form-group">
                    <label><i class="fas fa-sticky-note"></i> Session Notes</label>
                    <div class="detail-value" id="viewSessionNotes" style="min-height: 100px; padding: 15px;">
                        Loading...
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-success" id="joinSessionBtn" style="display: none;">
                    <i class="fas fa-video"></i> Join Session
                </button>
                <button class="btn btn-secondary" id="closeViewBtn">
                    <i class="fas fa-times"></i> Close
                </button>
            </div>
        </div>
    </div>

    <!-- Edit Session Modal -->
    <div class="modal" id="editSessionModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-edit"></i> Edit Session</h3>
                <button class="close-modal" id="closeEditSessionModal">&times;</button>
            </div>
            <div class="modal-body">
                <form id="editSessionForm">
                    <input type="hidden" id="editSessionId">
                    
                    <div class="form-group">
                        <label class="form-label" for="editSessionName">
                            <i class="fas fa-comment-alt"></i> Session Title *
                        </label>
                        <input type="text" class="form-control" id="editSessionName" placeholder="Enter session title" required>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="editSessionDateTime">
                                <i class="fas fa-calendar"></i> Session Date & Time *
                            </label>
                            <input type="datetime-local" class="form-control" id="editSessionDateTime" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="editSessionType">
                                <i class="fas fa-tag"></i> Session Type *
                            </label>
                            <select class="form-control" id="editSessionType" required>
                                <option value="">Select session type</option>
                                <option value="academic">Academic Planning</option>
                                <option value="course">Course Selection</option>
                                <option value="career">Career Guidance</option>
                                <option value="personal">Personal Issues</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="editSessionStudents">
                            <i class="fas fa-users"></i> Students *
                        </label>
                        <select class="form-control" id="editSessionStudents" multiple required style="min-height: 120px;">
                            <option value="">-- Select students --</option>
                        </select>
                        <small style="color: #666; margin-top: 5px; display: block;">Hold Ctrl (Cmd on Mac) to select multiple students</small>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="editSessionLocation">
                            <i class="fas fa-video"></i> Meeting Link
                        </label>
                        <input type="url" class="form-control" id="editSessionLocation" placeholder="Enter Google Meet or Zoom link">
                    </div>
                    
                    <h2>OR</h2><br><br>

                    <div class="form-group">
                        <label class="form-label" for="editSessionPhysicalLocation">
                            <i class="fas fa-map-marker-alt"></i> Physical Location
                        </label>
                        <input type="text" class="form-control" id="editSessionPhysicalLocation" placeholder="Enter physical location (room, building)">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="editSessionNotes">
                            <i class="fas fa-align-left"></i> Notes
                        </label>
                        <textarea class="form-control" id="editSessionNotes" placeholder="Enter notes or agenda for this session..."></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" id="cancelEditSessionBtn">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button class="btn btn-primary" id="submitEditSessionBtn">
                    <i class="fas fa-save"></i> Save Changes
                </button>
            </div>
        </div>
    </div>

    <!-- Create Session Modal -->
    <div class="modal" id="createSessionModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3><i class="fas fa-plus"></i> Create New Session</h3>
                <button class="close-modal" id="closeCreateSessionModal">&times;</button>
            </div>
            <div class="modal-body">
                <form id="createSessionForm">
                    <div class="form-group">
                        <label class="form-label" for="createSessionName">
                            <i class="fas fa-comment-alt"></i> Session Title *
                        </label>
                        <input type="text" class="form-control" id="createSessionName" placeholder="Enter session title" required>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label" for="createSessionDateTime">
                                <i class="fas fa-calendar"></i> Session Date & Time *
                            </label>
                            <input type="datetime-local" class="form-control" id="createSessionDateTime" required>
                        </div>
                        <div class="form-group">
                            <label class="form-label" for="createSessionType">
                                <i class="fas fa-tag"></i> Session Type *
                            </label>
                            <select class="form-control" id="createSessionType" required>
                                <option value="">Select session type</option>
                                <option value="academic">Academic Planning</option>
                                <option value="course">Course Selection</option>
                                <option value="career">Career Guidance</option>
                                <option value="personal">Personal Issues</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="createSessionStudents">
                            <i class="fas fa-users"></i> Students *
                        </label>
                        <select class="form-control" id="createSessionStudents" multiple required style="min-height: 120px;">
                            <option value="">-- Select students --</option>
                        </select>
                        <small style="color: #666; margin-top: 5px; display: block;">Hold Ctrl (Cmd on Mac) to select multiple students</small>
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="createSessionLocation">
                            <i class="fas fa-video"></i> Meeting Link
                        </label>
                        <input type="url" class="form-control" id="createSessionLocation" placeholder="Enter Google Meet or Zoom link">
                    </div>
                    
                    <h2>OR</h2><br><br>

                    <div class="form-group">
                        <label class="form-label" for="createSessionPhysicalLocation">
                            <i class="fas fa-map-marker-alt"></i> Physical Location
                        </label>
                        <input type="text" class="form-control" id="createSessionPhysicalLocation" placeholder="Enter physical location (room, building)">
                    </div>
                    
                    <div class="form-group">
                        <label class="form-label" for="createSessionNotes">
                            <i class="fas fa-align-left"></i> Notes
                        </label>
                        <textarea class="form-control" id="createSessionNotes" placeholder="Enter notes or agenda for this session..."></textarea>
                    </div>
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn btn-secondary" id="cancelCreateSessionBtn">
                    <i class="fas fa-times"></i> Cancel
                </button>
                <button class="btn btn-primary" id="submitCreateSessionBtn">
                    <i class="fas fa-plus"></i> Create Session
                </button>
            </div>
        </div>
    </div>

    <script>
        // Data
        let mySessions = [];
        let sessionRequests = [];

        // Context path helper
        const ctx = (function(){ const p = window.location.pathname.split('/').filter(Boolean); return p.length ? '/' + p[0] : ''; })();

        // Network helpers
        async function apiGet(path) {
            const res = await fetch(ctx + path, { cache: 'no-store' });
            if (!res.ok) throw new Error('GET ' + path + ' returned ' + res.status);
            return res.json();
        }

        // Small helpers
        function capitalize(text) {
            if (text === null || typeof text === 'undefined') return '';
            const s = String(text).trim();
            if (s.length === 0) return '';
            return s.charAt(0).toUpperCase() + s.slice(1).toLowerCase();
        }

        // Load sessions from API
        async function loadSessions() {
            try {
                const data = await apiGet('/api/advisor/sessions');
                const sessions = data.sessions || [];
                // Filter: confirmed, completed sessions go to mySessions
                // cancel_requested, pending sessions go to sessionRequests
                mySessions = sessions.filter(s => {
                    const status = (s.status || '').toLowerCase();
                    return status === 'confirmed' || status === 'completed' || status === 'scheduled' || status === 'cancelled';
                });
                sessionRequests = sessions.filter(s => {
                    const status = (s.status || '').toLowerCase();
                    return status === 'pending' || status === 'cancel_requested';
                });
                filteredMySessions = [...mySessions];
                filteredRequests = [...sessionRequests];
                renderMySessions();
                renderMySessionsPagination();
                renderRequests();
                renderRequestsPagination();
                updateStats();
            } catch (e) {
                console.error('Failed to load sessions:', e);
                // Fallback to empty arrays
                mySessions = [];
                sessionRequests = [];
                filteredMySessions = [];
                filteredRequests = [];
            }
        }

        // Pagination variables for My Sessions
        let currentPageMySessions = 1;
        const sessionsPerPage = 8;
        let filteredMySessions = [];
        let currentMySessionFilter = "all";

        // Pagination variables for Session Requests
        let currentPageRequests = 1;
        const requestsPerPage = 8;
        let filteredRequests = [];
        let currentRequestFilter = "all";

        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            // Load sessions from API
            loadSessions();
            
            // Filter functionality for My Sessions
            document.querySelectorAll('.filter-section .filter-btn').forEach(btn => {
                btn.addEventListener('click', function() {
                    // Remove active class from all buttons
                    document.querySelectorAll('.filter-section .filter-btn').forEach(b => b.classList.remove('active'));
                    // Add active class to clicked button
                    this.classList.add('active');
                    
                    const status = this.getAttribute('data-status');
                    applyMySessionFilter(status);
                });
            });
            
            // Clear filter for My Sessions
            document.getElementById('clearMySessionFilter').addEventListener('click', function() {
                // Set active class to "All Sessions" button
                document.querySelectorAll('.filter-section .filter-btn').forEach(b => b.classList.remove('active'));
                const allBtn = document.querySelector('.filter-section .filter-btn[data-status="all"]');
                if (allBtn) allBtn.classList.add('active');
                
                applyMySessionFilter('all');
            });
            
            // Search functionality for My Sessions
            document.getElementById('searchMySessions').addEventListener('keyup', function() {
                const searchTerm = this.value.toLowerCase();
                
                if (searchTerm.trim() === '') {
                    applyMySessionFilter(currentMySessionFilter);
                } else {
                    filteredMySessions = mySessions.filter(session => {
                        // First apply status filter
                        if (currentMySessionFilter !== 'all' && session.status !== currentMySessionFilter) {
                            return false;
                        }
                        
                        // Then apply search filter
                        return (session.title || '').toLowerCase().includes(searchTerm) ||
                               (session.sessionType || '').toLowerCase().includes(searchTerm) ||
                               (session.notes || '').toLowerCase().includes(searchTerm) ||
                               (session.status || '').toLowerCase().includes(searchTerm);
                    });
                    
                    currentPageMySessions = 1;
                    renderMySessions();
                    renderMySessionsPagination();
                }
            });

            
            // Modal close buttons
            document.getElementById('closeViewSessionModal').addEventListener('click', closeViewSessionModal);
            document.getElementById('closeViewBtn').addEventListener('click', closeViewSessionModal);
            
            document.getElementById('closeEditSessionModal').addEventListener('click', closeEditSessionModal);
            document.getElementById('cancelEditSessionBtn').addEventListener('click', closeEditSessionModal);
            
            document.getElementById('closeCreateSessionModal').addEventListener('click', closeCreateSessionModal);
            document.getElementById('cancelCreateSessionBtn').addEventListener('click', closeCreateSessionModal);
            
            // Submit Edit Session form
            document.getElementById('submitEditSessionBtn').addEventListener('click', function(e) {
                e.preventDefault();
                saveEditedSession();
            });
            
            // Submit Create Session form
            document.getElementById('submitCreateSessionBtn').addEventListener('click', function(e) {
                e.preventDefault();
                saveNewSession();
            });
            
            // Create Session button
            document.getElementById('createSessionBtnTop').addEventListener('click', function(e) {
                e.preventDefault();
                openCreateSessionModal();
            });
            
            // Header action buttons
            document.querySelector('.search-btn').addEventListener('click', function(e) {
                e.preventDefault();
                document.getElementById('searchMySessions').focus();
            });
            
            document.querySelector('.profile-btn').addEventListener('click', function(e) {
                e.preventDefault();
                window.location.href = "advisor_profile.jsp";
            });
            
            document.querySelector('.logout-btn').addEventListener('click', function(e) {
                e.preventDefault();
                if (confirm("Are you sure you want to logout?")) {
                    window.location.href = ctx + "/logout";
                }
            });
        });

        // Apply filter for My Sessions
        function applyMySessionFilter(status) {
            currentMySessionFilter = status;
            
            if (status === 'all') {
                filteredMySessions = [...mySessions];
            } else if (status === 'upcoming') {
                // Map "upcoming" to confirmed or scheduled statuses that are in the future
                const now = new Date();
                filteredMySessions = mySessions.filter(session => {
                    const sessionStatus = (session.status || '').toLowerCase();
                    const ts = session.sessionDateTime ? new Date(String(session.sessionDateTime).replace(' ', 'T')) : null;
                    return (sessionStatus === 'confirmed' || sessionStatus === 'scheduled') && ts && ts > now;
                });
            } else if (status === 'confirmed') {
                // For confirmed filter, show all confirmed and scheduled sessions regardless of date
                filteredMySessions = mySessions.filter(session => {
                    const sessionStatus = (session.status || '').toLowerCase();
                    return sessionStatus === 'confirmed' || sessionStatus === 'scheduled';
                });
            } else if (status === 'completed') {
                // For completed filter, include confirmed sessions that are in the past
                const now = new Date();
                filteredMySessions = mySessions.filter(session => {
                    const sessionStatus = (session.status || '').toLowerCase();
                    const ts = session.sessionDateTime ? new Date(String(session.sessionDateTime).replace(' ', 'T')) : null;
                    return (sessionStatus === 'completed' || (sessionStatus === 'confirmed' && ts && ts < now));
                });
            } else {
                // For cancelled (includes both 'cancelled' and 'denied'), use exact match
                filteredMySessions = mySessions.filter(session => {
                    const sessionStatus = (session.status || '').toLowerCase();
                    return sessionStatus === 'cancelled' || sessionStatus === 'denied';
                });
            }
            
            currentPageMySessions = 1;
            renderMySessions();
            renderMySessionsPagination();
            updateStats();
        }

        // Apply filter for Session Requests
        function applyRequestFilter(status) {
            currentRequestFilter = status;
            
            if (status === 'all') {
                filteredRequests = [...sessionRequests];
            } else {
                filteredRequests = sessionRequests.filter(request => request.status === status);
            }
            
            currentPageRequests = 1;
            renderRequests();
            renderRequestsPagination();
            updateStats();
        }

        // Render My Sessions for current page
        function renderMySessions() {
            const tbody = document.getElementById('mySessionsTableBody');
            tbody.innerHTML = '';
            
            // Calculate start and end index for current page
            const startIndex = (currentPageMySessions - 1) * sessionsPerPage;
            const endIndex = startIndex + sessionsPerPage;
            const pageSessions = filteredMySessions.slice(startIndex, endIndex);
            
            if (pageSessions.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="6" style="text-align: center; padding: 40px; color: var(--text-light);">
                            <i class="fas fa-calendar-times" style="font-size: 32px; margin-bottom: 15px; display: block;"></i>
                            <h3 style="margin-bottom: 10px; color: var(--text-light);">No sessions found</h3>
                            <p>Try adjusting your search or filter criteria</p>
                        </td>
                    </tr>
                `;
                return;
            }
            
            pageSessions.forEach((session, index) => {
                const row = document.createElement('tr');
                row.setAttribute('data-id', session.sessionID);
                
                // Parse sessionDateTime
                const ts = session.sessionDateTime ? new Date(String(session.sessionDateTime).replace(' ', 'T')) : null;
                const formattedDate = ts ? ts.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }) : '';
                const formattedTime = ts ? ts.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit', hour12: true }) : '';
                
                // Get status badge class and text
                let statusClass, statusText;
                const status = (session.status || '').toLowerCase();
                switch(status) {
                    case 'completed':
                        statusClass = 'status-completed';
                        statusText = 'Completed';
                        break;
                    case 'cancelled':
                    case 'denied':
                        statusClass = 'status-cancelled';
                        statusText = 'Cancelled';
                        break;
                    case 'confirmed':
                    case 'scheduled':
                        statusClass = 'status-upcoming';
                        statusText = 'Confirmed';
                        break;
                    default:
                        statusClass = 'status-upcoming';
                        statusText = 'Upcoming';
                }
                
                // Truncate notes for display
                const notes = session.notes || '';
                const truncatedNotes = notes.length > 80 ? notes.substring(0, 80) + '...' : notes;
                const cancelReason = session.cancelReason || '';
                
                // Determine what to display in the Details column
                let detailsDisplay = '-';
                let detailsTitle = '';
                
                if (status === 'cancelled' || status === 'denied') {
                    // Show cancel reason for cancelled sessions
                    const truncatedReason = cancelReason.length > 80 ? cancelReason.substring(0, 80) + '...' : cancelReason;
                    detailsDisplay = truncatedReason || '-';
                    detailsTitle = cancelReason;
                } else if (status === 'confirmed' || status === 'scheduled') {
                    // Show location/gmeet info for confirmed sessions
                    const hasLocation = session.location && session.location.trim();
                    const hasGmeet = session.meetlink && session.meetlink.trim();
                    
                    if (hasLocation && hasGmeet) {
                        // Both location and gmeet
                        const truncatedLocation = session.location.length > 60 ? session.location.substring(0, 60) + '...' : session.location;
                        detailsDisplay = (truncatedLocation) + ' + Meet';
                        detailsTitle = 'Location: ' + (session.location) + ' | Meet Link: ' + (session.meetlink);
                    } else if (hasGmeet) {
                        // Only gmeet
                        detailsDisplay = 'Google Meet';
                        detailsTitle = 'Meet Link: ' + (session.meetlink);
                    } else if (hasLocation) {
                        // Only location
                        const truncatedLocation = session.location.length > 60 ? session.location.substring(0, 60) + '...' : session.location;
                        detailsDisplay = (truncatedLocation);
                        detailsTitle = 'Location: ' + (session.location);
                    }
                }
                
                row.innerHTML = '\n                    <td class="number-cell">' + (startIndex + index + 1) + '</td>\n                    <td>\n                        <div class="session-name-cell">' + (session.title || '') + '</div>\n                        <div class="session-type-cell">' + (capitalize(session.sessionType || 'General')) + ' • 60 mins</div>\n                    </td>\n                    <td class="date-cell">\n                        <div>' + (formattedDate) + '</div>\n                        <div style="font-size: 12px; color: var(--text-light);">' + (formattedTime) + '</div>\n                    </td>\n                    <td class="status-cell" style="text-align: center;">\n                        <span class="status-badge ' + (statusClass) + '">' + (statusText) + '</span>\n                    </td>\n                    <td class="notes-cell" style="text-align: center;" title="' + (detailsTitle) + '">' + (detailsDisplay) + '</td>\n                    <td class="notes-cell" style="text-align: center;" title="' + (notes) + '">' + (truncatedNotes) + '</td>\n                    <td class="actions-cell" style="text-align: center;">\n                        <div class="action-buttons">\n                            ' + ((() => {
                                const statusLower = (session.status || '').toLowerCase();
                                const isConfirmed = statusLower === 'confirmed' || statusLower === 'scheduled';
                                const hasLink = session.meetlink && session.meetlink.trim();
                                return isConfirmed && hasLink ? '<button class="btn btn-success btn-small" onclick="window.open(\'' + session.meetlink + '\', \'_blank\')" title="Join Meeting"><i class="fas fa-video"></i></button>' : '';
                            })()) + '\n                            <button class="btn btn-secondary btn-small view-session-btn" onclick="viewSession(' + (session.sessionID) + ')" title="View Details">\n                                <i class="fas fa-eye"></i>\n                            </button>\n                            <button class="btn btn-success btn-small edit-session-btn" onclick="editSession(' + (session.sessionID) + ')" title="Edit Session">\n                                <i class="fas fa-edit"></i>\n                            </button>\n                        </div>\n                    </td>\n                ';
                
                tbody.appendChild(row);
            });
        }

        // Render Session Requests for current page
        function renderRequests() {
            const tbody = document.getElementById('requestsTableBody');
            tbody.innerHTML = '';
            
            // Calculate start and end index for current page
            const startIndex = (currentPageRequests - 1) * requestsPerPage;
            const endIndex = startIndex + requestsPerPage;
            const pageRequests = filteredRequests.slice(startIndex, endIndex);
            
            if (pageRequests.length === 0) {
                tbody.innerHTML = `
                    <tr>
                        <td colspan="7" style="text-align: center; padding: 40px; color: var(--text-light);">
                            <i class="fas fa-inbox" style="font-size: 32px; margin-bottom: 15px; display: block;"></i>
                            <h3 style="margin-bottom: 10px; color: var(--text-light);">No requests found</h3>
                            <p>All session requests have been reviewed</p>
                        </td>
                    </tr>
                `;
                return;
            }
            
            pageRequests.forEach((request, index) => {
                const row = document.createElement('tr');
                row.setAttribute('data-id', request.sessionID);
                
                // Parse sessionDateTime
                const ts = request.sessionDateTime ? new Date(String(request.sessionDateTime).replace(' ', 'T')) : null;
                const formattedDate = ts ? ts.toLocaleDateString('en-US', { year: 'numeric', month: 'short', day: 'numeric' }) : '';
                
                // Get status badge class and text
                let statusClass, statusText;
                const status = (request.status || '').toLowerCase();
                switch(status) {
                    case 'pending':
                        statusClass = 'status-pending';
                        statusText = 'Pending';
                        break;
                    case 'cancel_requested':
                        statusClass = 'status-pending';
                        statusText = 'Cancel Request';
                        break;
                    default:
                        statusClass = 'status-upcoming';
                        statusText = 'Pending';
                }
                
                // Truncate notes for display
                const notes = request.notes || request.cancelReason || '';
                const truncatedNotes = notes.length > 80 ? notes.substring(0, 80) + '...' : notes;
                
                row.innerHTML = '\n                    <td class="number-cell">' + (startIndex + index + 1) + '</td>\n                    <td>' + (request.title || '') + '</td>\n                    <td class="date-cell">' + (formattedDate) + '</td>\n                    <td class="status-cell">\n                        <span class="status-badge ' + (statusClass) + '">' + (statusText) + '</span>\n                    </td>\n                    <td class="notes-cell" title="' + (notes) + '">' + (truncatedNotes) + '</td>\n                    <td class="actions-cell">\n                        <div class="action-buttons">\n                            <button class="btn btn-success btn-small" onclick="approveRequest(' + (request.sessionID) + ')" title="Approve Request">\n                                <i class="fas fa-check"></i>\n                            </button>\n                            <button class="btn btn-danger btn-small" onclick="rejectRequest(' + (request.sessionID) + ')" title="Reject Request">\n                                <i class="fas fa-times"></i>\n                            </button>\n                        </div>\n                    </td>\n                ';
                
                tbody.appendChild(row);
            });
        }

        // Render pagination for My Sessions
        function renderMySessionsPagination() {
            const totalPages = Math.ceil(filteredMySessions.length / sessionsPerPage);
            const paginationContainer = document.getElementById('mySessionsPagination');
            
            if (totalPages <= 1) {
                paginationContainer.style.display = 'none';
                return;
            }
            
            paginationContainer.style.display = 'flex';
            
            let paginationHTML = '\n                <button class="pagination-btn" id="firstPageMySessions" ' + (currentPageMySessions === 1 ? 'disabled' : '') + '>\n                    <i class="fas fa-angle-double-left"></i> First\n                </button>\n                <button class="pagination-btn" id="prevPageMySessions" ' + (currentPageMySessions === 1 ? 'disabled' : '') + '>\n                    <i class="fas fa-angle-left"></i> Previous\n                </button>\n            ';
            
            // Show page numbers
            const maxVisiblePages = 5;
            let startPage = Math.max(1, currentPageMySessions - Math.floor(maxVisiblePages / 2));
            let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
            
            // Adjust start page if we're near the end
            if (endPage - startPage + 1 < maxVisiblePages) {
                startPage = Math.max(1, endPage - maxVisiblePages + 1);
            }
            
            for (let i = startPage; i <= endPage; i++) {
                if (i === currentPageMySessions) {
                    paginationHTML += '<button class="pagination-btn active">' + (i) + '</button>';
                } else {
                    paginationHTML += '<button class="pagination-btn page-number-my-sessions" data-page="' + (i) + '">' + (i) + '</button>';
                }
            }
            
            paginationHTML += '\n                <button class="pagination-btn" id="nextPageMySessions" ' + (currentPageMySessions === totalPages ? 'disabled' : '') + '>\n                    Next <i class="fas fa-angle-right"></i>\n                </button>\n                <button class="pagination-btn" id="lastPageMySessions" ' + (currentPageMySessions === totalPages ? 'disabled' : '') + '>\n                    Last <i class="fas fa-angle-double-right"></i>\n                </button>\n            ';
            
            paginationContainer.innerHTML = paginationHTML;
            
            // Add event listeners to pagination buttons
            document.getElementById('firstPageMySessions').addEventListener('click', function(e) {
                e.preventDefault();
                goToPageMySessions(1);
            });
            
            document.getElementById('prevPageMySessions').addEventListener('click', function(e) {
                e.preventDefault();
                goToPageMySessions(currentPageMySessions - 1);
            });
            
            document.getElementById('nextPageMySessions').addEventListener('click', function(e) {
                e.preventDefault();
                goToPageMySessions(currentPageMySessions + 1);
            });
            
            document.getElementById('lastPageMySessions').addEventListener('click', function(e) {
                e.preventDefault();
                goToPageMySessions(totalPages);
            });
            
            // Add event listeners to page number buttons
            document.querySelectorAll('.page-number-my-sessions').forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const page = parseInt(this.getAttribute('data-page'));
                    goToPageMySessions(page);
                });
            });
        }

        // Go to specific page for My Sessions
        function goToPageMySessions(page) {
            const totalPages = Math.ceil(filteredMySessions.length / sessionsPerPage);
            
            if (page < 1 || page > totalPages || page === currentPageMySessions) {
                return;
            }
            
            currentPageMySessions = page;
            renderMySessions();
            renderMySessionsPagination();
        }

        // Render Session Requests pagination
        function renderRequestsPagination() {
            const totalPages = Math.ceil(filteredRequests.length / requestsPerPage);
            const paginationContainer = document.getElementById('requestsPagination');
            
            if (totalPages <= 1) {
                paginationContainer.style.display = 'none';
                return;
            }
            
            paginationContainer.style.display = 'flex';
            
            let paginationHTML = '\n                <button class="pagination-btn" id="firstPageRequests" ' + (currentPageRequests === 1 ? 'disabled' : '') + '>\n                    <i class="fas fa-angle-double-left"></i> First\n                </button>\n                <button class="pagination-btn" id="prevPageRequests" ' + (currentPageRequests === 1 ? 'disabled' : '') + '>\n                    <i class="fas fa-angle-left"></i> Previous\n                </button>\n                <div class="pagination-info">\n                    Page ' + (currentPageRequests) + ' of ' + (totalPages) + '\n                </div>\n            ';
            
            // Show page numbers
            const maxVisiblePages = 5;
            let startPage = Math.max(1, currentPageRequests - Math.floor(maxVisiblePages / 2));
            let endPage = Math.min(totalPages, startPage + maxVisiblePages - 1);
            
            // Adjust start page if we're near the end
            if (endPage - startPage + 1 < maxVisiblePages) {
                startPage = Math.max(1, endPage - maxVisiblePages + 1);
            }
            
            for (let i = startPage; i <= endPage; i++) {
                if (i === currentPageRequests) {
                    paginationHTML += '<button class="pagination-btn active">' + (i) + '</button>';
                } else {
                    paginationHTML += '<button class="pagination-btn page-number-requests" data-page="' + (i) + '">' + (i) + '</button>';
                }
            }
            
            paginationHTML += '\n                <button class="pagination-btn" id="nextPageRequests" ' + (currentPageRequests === totalPages ? 'disabled' : '') + '>\n                    Next <i class="fas fa-angle-right"></i>\n                </button>\n                <button class="pagination-btn" id="lastPageRequests" ' + (currentPageRequests === totalPages ? 'disabled' : '') + '>\n                    Last <i class="fas fa-angle-double-right"></i>\n                </button>\n            ';
            
            paginationContainer.innerHTML = paginationHTML;
            
            // Add event listeners to pagination buttons
            document.getElementById('firstPageRequests').addEventListener('click', function(e) {
                e.preventDefault();
                goToPageRequests(1);
            });
            
            document.getElementById('prevPageRequests').addEventListener('click', function(e) {
                e.preventDefault();
                goToPageRequests(currentPageRequests - 1);
            });
            
            document.getElementById('nextPageRequests').addEventListener('click', function(e) {
                e.preventDefault();
                goToPageRequests(currentPageRequests + 1);
            });
            
            document.getElementById('lastPageRequests').addEventListener('click', function(e) {
                e.preventDefault();
                goToPageRequests(totalPages);
            });
            
            // Add event listeners to page number buttons
            document.querySelectorAll('.page-number-requests').forEach(btn => {
                btn.addEventListener('click', function(e) {
                    e.preventDefault();
                    const page = parseInt(this.getAttribute('data-page'));
                    goToPageRequests(page);
                });
            });
        }

        // Go to specific page for Session Requests
        function goToPageRequests(page) {
            const totalPages = Math.ceil(filteredRequests.length / requestsPerPage);
            
            if (page < 1 || page > totalPages || page === currentPageRequests) {
                return;
            }
            
            currentPageRequests = page;
            renderRequests();
            renderRequestsPagination();
        }

        // Render Session Requests for current page

        // View Session Details
        function viewSession(sessionId) {
            const session = mySessions.find(s => s.sessionID === sessionId);
            if (!session) return;
            
            // Format date for display from ISO datetime
            let formattedDate = 'N/A';
            let formattedTime = 'N/A';
            if (session.sessionDateTime) {
                const ts = new Date(String(session.sessionDateTime).replace(' ', 'T'));
                formattedDate = ts.toLocaleDateString('en-US', { 
                    year: 'numeric', 
                    month: 'long', 
                    day: 'numeric',
                    weekday: 'long'
                });
                formattedTime = ts.toLocaleTimeString('en-US', { 
                    hour: 'numeric', 
                    minute: '2-digit',
                    hour12: true 
                });
            }
            
            // Get status text
            let statusText, statusClass;
            const status = (session.status || '').toLowerCase();
            switch(status) {
                case 'completed':
                    statusText = 'Completed';
                    statusClass = 'status-completed';
                    break;
                case 'confirmed':
                case 'scheduled':
                    statusText = 'Confirmed';
                    statusClass = 'status-upcoming';
                    break;
                case 'cancelled':
                case 'denied':
                    statusText = 'Cancelled';
                    statusClass = 'status-cancelled';
                    break;
                default:
                    statusText = 'Pending';
                    statusClass = 'status-upcoming';
            }
            
            // Populate modal fields
            document.getElementById('viewSessionName').textContent = session.title || 'N/A';
            document.getElementById('viewSessionType').textContent = capitalize(session.sessionType || 'General');
            document.getElementById('viewSessionDate').textContent = formattedDate;
            document.getElementById('viewSessionTime').textContent = formattedTime;
            document.getElementById('viewSessionDuration').textContent = '60 mins'; // Default duration
            document.getElementById('viewSessionLocation').textContent = session.meetlink || 'Not specified';
            document.getElementById('viewSessionPhysicalLocation').textContent = session.location || 'Not specified';
            document.getElementById('viewSessionNotes').textContent = session.notes || 'No notes';
            
            // Update status badge
            const statusBadge = document.getElementById('viewSessionStatus');
            statusBadge.textContent = statusText;
            statusBadge.className = 'status-badge ' + statusClass;
            
            // Show/hide Join Session button based on status and meetlink
            const joinBtn = document.getElementById('joinSessionBtn');
            const statusLower = (session.status || '').toLowerCase();
            const isConfirmedLike = statusLower === 'confirmed' || statusLower === 'scheduled';
            if (isConfirmedLike && session.meetlink) {
                joinBtn.style.display = 'inline-block';
                joinBtn.onclick = () => window.open(session.meetlink, '_blank');
            } else {
                joinBtn.style.display = 'none';
            }
            
            // Populate student list with all students
            const studentsContainer = document.getElementById('viewSessionStudents');
            studentsContainer.innerHTML = '';
            
            // Support both single student (legacy) and multiple students (new)
            const studentList = session.students && session.students.length > 0 ? session.students : 
                                (session.studentName ? [{studentID: session.studentID, studentName: session.studentName}] : []);
            
            studentList.forEach(student => {
                const studentItem = document.createElement('div');
                studentItem.className = 'student-item';
                const initials = (student.studentName || '').split(' ').map(n => n[0]).join('').toUpperCase();
                studentItem.innerHTML = '\n                    <div class="student-avatar">' + (initials) + '</div>\n                    <div class="student-info">\n                        <div class="student-name">' + (student.studentName) + '</div>\n                        <div class="student-major-year">Student ID: ' + (student.studentID) + '</div>\n                    </div>\n                ';
                studentsContainer.appendChild(studentItem);
            });
            
            // Store sessionID for later use
            document.getElementById('viewSessionModal').dataset.sessionId = sessionId;
            
            // Show the modal
            const modal = document.getElementById('viewSessionModal');
            modal.style.display = 'flex';
        }

        // Edit Session
        async function editSession(sessionId) {
            const session = mySessions.find(s => s.sessionID === sessionId);
            if (!session) return;
            
            // Parse the sessionDateTime for datetime-local input
            let dateTimeStr = '';
            if (session.sessionDateTime) {
                const ts = new Date(String(session.sessionDateTime).replace(' ', 'T'));
                // Format as YYYY-MM-DDTHH:MM for datetime-local input
                const year = ts.getFullYear();
                const month = String(ts.getMonth() + 1).padStart(2, '0');
                const day = String(ts.getDate()).padStart(2, '0');
                const hours = String(ts.getHours()).padStart(2, '0');
                const mins = String(ts.getMinutes()).padStart(2, '0');
                dateTimeStr = (year) + '-' + (month) + '-' + (day) + 'T' + (hours) + ':' + (mins);
            }
            
            // Load students for multi-select
            try {
                const studentData = await apiGet('/api/advisor/students');
                const studentSelect = document.getElementById('editSessionStudents');
                studentSelect.innerHTML = '<option value="">-- Select students --</option>';
                
                studentData.students.forEach(student => {
                    const option = document.createElement('option');
                    option.value = student.studentID;
                    option.textContent = (student.firstName) + ' ' + (student.lastName) + ' (' + (student.studentID) + ')';
                    studentSelect.appendChild(option);
                });
                
                // Select currently assigned students
                if (session.students && session.students.length > 0) {
                    const currentStudentIds = session.students.map(s => s.studentID);
                    Array.from(studentSelect.options).forEach(option => {
                        if (currentStudentIds.includes(option.value)) {
                            option.selected = true;
                        }
                    });
                }
            } catch (e) {
                console.error('Error loading students:', e);
            }
            
            // Populate form with session data
            document.getElementById('editSessionId').value = session.sessionID;
            document.getElementById('editSessionName').value = session.title || '';
            document.getElementById('editSessionType').value = session.sessionType || '';
            document.getElementById('editSessionDateTime').value = dateTimeStr;
            document.getElementById('editSessionLocation').value = session.meetlink || '';
            document.getElementById('editSessionPhysicalLocation').value = session.location || '';
            document.getElementById('editSessionNotes').value = session.notes || '';
            
            // Show the modal
            const modal = document.getElementById('editSessionModal');
            modal.style.display = 'flex';
        }

        // Save edited session
        async function saveEditedSession() {
            const sessionId = parseInt(document.getElementById('editSessionId').value);
            const title = document.getElementById('editSessionName').value;
            const sessionType = document.getElementById('editSessionType').value;
            const dateTimeStr = document.getElementById('editSessionDateTime').value;
            const meetLink = document.getElementById('editSessionLocation').value;
            const location = document.getElementById('editSessionPhysicalLocation').value;
            const notes = document.getElementById('editSessionNotes').value;
            
            // Get selected students
            const studentSelect = document.getElementById('editSessionStudents');
            const selectedStudents = Array.from(studentSelect.selectedOptions).map(opt => opt.value);
            
            if (!title || !sessionType || !dateTimeStr || selectedStudents.length === 0) {
                alert('Please fill in all required fields and select at least one student.');
                return;
            }
            
            // Convert datetime-local to ISO format (add :00 for seconds)
            const sessionDateTime = dateTimeStr + ':00';
            
            try {
                const response = await fetch(ctx + '/api/advisor/session/update', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'action=update&sessionID=' + (sessionId) + '&title=' + (encodeURIComponent(title)) + '&sessionType=' + (encodeURIComponent(sessionType)) + '&sessionDateTime=' + (encodeURIComponent(sessionDateTime)) + '&meetLink=' + (encodeURIComponent(meetLink)) + '&location=' + (encodeURIComponent(location)) + '&notes=' + (encodeURIComponent(notes)) + '&students=' + (encodeURIComponent(selectedStudents.join(',')))
                });
                const data = await response.json();
                if (!response.ok || data.error) {
                    alert('Error updating session: ' + (data.error || 'Unknown error'));
                    return;
                }
                
                alert('Session updated successfully!');
                closeEditSessionModal();
                await loadSessions();
            } catch (e) {
                console.error('Error updating session:', e);
                alert('Error updating session: ' + e.message);
            }
        }

        // Delete Session
        async function deleteSession(sessionId) {
            if (confirm('Are you sure you want to delete this session? This action cannot be undone.')) {
                try {
                    const response = await fetch(ctx + '/api/advisor/session/update', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: 'sessionID=' + (sessionId) + '&action=delete'
                    });
                    const data = await response.json();
                    if (!response.ok || data.error) {
                        alert('Error deleting session: ' + (data.error || 'Unknown error'));
                        return;
                    }
                    
                    alert('Session deleted successfully!');
                    await loadSessions();
                } catch (e) {
                    console.error('Error deleting session:', e);
                    alert('Error deleting session: ' + e.message);
                }
            }
        }

        // Close View Session Modal
        function closeViewSessionModal() {
            const modal = document.getElementById('viewSessionModal');
            modal.style.display = 'none';
        }

        // Close Edit Session Modal
        function closeEditSessionModal() {
            const modal = document.getElementById('editSessionModal');
            modal.style.display = 'none';
        }

        // Open Create Session Modal
        async function openCreateSessionModal() {
            // Load students for multi-select
            try {
                const studentData = await apiGet('/api/advisor/students');
                const studentSelect = document.getElementById('createSessionStudents');
                studentSelect.innerHTML = '<option value="">-- Select students --</option>';
                
                studentData.students.forEach(student => {
                    const option = document.createElement('option');
                    option.value = student.studentID;
                    option.textContent = (student.firstName) + ' ' + (student.lastName) + ' (' + (student.studentID) + ')';
                    studentSelect.appendChild(option);
                });
            } catch (e) {
                console.error('Error loading students:', e);
            }
            
            // Clear form
            document.getElementById('createSessionForm').reset();
            
            // Show the modal
            const modal = document.getElementById('createSessionModal');
            modal.style.display = 'flex';
        }

        // Close Create Session Modal
        function closeCreateSessionModal() {
            const modal = document.getElementById('createSessionModal');
            modal.style.display = 'none';
        }

        // Save new session
        async function saveNewSession() {
            const title = document.getElementById('createSessionName').value;
            const sessionType = document.getElementById('createSessionType').value;
            const dateTimeStr = document.getElementById('createSessionDateTime').value;
            const meetLink = document.getElementById('createSessionLocation').value;
            const location = document.getElementById('createSessionPhysicalLocation').value;
            const notes = document.getElementById('createSessionNotes').value;
            
            // Get selected students
            const studentSelect = document.getElementById('createSessionStudents');
            const selectedStudents = Array.from(studentSelect.selectedOptions).map(opt => opt.value);
            
            if (!title || !sessionType || !dateTimeStr || selectedStudents.length === 0) {
                alert('Please fill in all required fields and select at least one student.');
                return;
            }
            
            // Convert datetime-local to ISO format (add :00 for seconds)
            const sessionDateTime = dateTimeStr + ':00';
            
            try {
                // For creating a session, we'll insert directly via API
                const response = await fetch(ctx + '/api/sessions/create', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        title: title,
                        sessionType: sessionType,
                        sessionDate: sessionDateTime.substring(0, 10),
                        sessionTime: sessionDateTime.substring(11, 16),
                        meetLink: meetLink,
                        location: location,
                        notes: notes,
                        studentID: selectedStudents[0],
                        students: selectedStudents
                    })
                });
                const data = await response.json();
                if (!response.ok || data.error) {
                    alert('Error creating session: ' + (data.error || 'Unknown error'));
                    return;
                }
                
                alert('Session created successfully!');
                closeCreateSessionModal();
                await loadSessions();
            } catch (e) {
                console.error('Error creating session:', e);
                alert('Error creating session: ' + e.message);
            }
        }

        // Function to approve a session request
        async function approveRequest(sessionId) {
            const meetLink = prompt('Enter meeting link (optional):', '');
            try {
                const response = await fetch(ctx + '/api/advisor/session/update', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'sessionID=' + (sessionId) + '&action=accept&meetLink=' + (encodeURIComponent(meetLink || ''))
                });
                const data = await response.json();
                if (!response.ok || data.error) {
                    alert('Error approving request: ' + (data.error || 'Unknown error'));
                    return;
                }
                
                alert('Session request #' + (sessionId) + ' has been approved.');
                await loadSessions();
            } catch (e) {
                console.error('Error approving request:', e);
                alert('Error approving request: ' + e.message);
            }
        }
        
        // Function to reject a session request
        async function rejectRequest(sessionId) {
            const reason = prompt('Enter rejection reason (optional):', '');
            try {
                const response = await fetch(ctx + '/api/advisor/session/update', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'sessionID=' + (sessionId) + '&action=deny&reason=' + (encodeURIComponent(reason || ''))
                });
                const data = await response.json();
                if (!response.ok || data.error) {
                    alert('Error rejecting request: ' + (data.error || 'Unknown error'));
                    return;
                }
                
                alert('Session request #' + (sessionId) + ' has been rejected.');
                await loadSessions();
            } catch (e) {
                console.error('Error rejecting request:', e);
                alert('Error rejecting request: ' + e.message);
            }
        }
        
        // Function to update stats
        function updateStats() {
            let pendingCount = 0;
            let confirmedCount = 0;
            let cancelledCount = 0;
            
            // Count statuses for My Sessions
            mySessions.forEach(session => {
                const status = (session.status || '').toLowerCase();
                if (status === "confirmed" || status === "scheduled") confirmedCount++;
                if (status === "completed" || status === "denied" || status === "cancelled") cancelledCount++;
            });
            
            // Count pending requests
            sessionRequests.forEach(request => {
                const status = (request.status || '').toLowerCase();
                if (status === "pending" || status === "cancel_requested") pendingCount++;
            });
            
            // Update stat cards
            document.getElementById('pending-count').textContent = pendingCount;
            document.getElementById('approved-count').textContent = confirmedCount;
            document.getElementById('rejected-count').textContent = cancelledCount;
            
            // Update total sessions (My Sessions + Requests)
            const totalSessions = mySessions.length + sessionRequests.length;
            document.getElementById('total-sessions').textContent = totalSessions;
        }
    </script>
</body>
</html>