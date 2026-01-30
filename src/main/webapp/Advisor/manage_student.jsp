<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Session check for advisor role
    if (session.getAttribute("role") == null || !"advisor".equals(session.getAttribute("role"))) {
        response.sendRedirect(request.getContextPath() + "/index.html?error=unauthorized");
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
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width,initial-scale=1" />
    <title>Advisor Dashboard - Student Management</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">

    <style>
        /* ===== preserved styles from your existing manage_student.html ===== */
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

            /* Updated Remark Colors */
            --success-green: #27ae60;
            --success-bg: rgba(39, 174, 96, 0.1);
            --warning-orange: #f39c12;
            --warning-bg: rgba(243, 156, 18, 0.1);
            --danger-red: #e74c3c;
            --danger-bg: rgba(231, 76, 60, 0.1);
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
            padding: 24px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .logo {
            font-size: 24px;
            font-weight: 700;
            text-align: center;
        }

        .logo-main {
            display: flex;
            align-items: center;
            gap: 8px;
            justify-content: center;
        }

        .logo-main span {
            color: var(--primary);
        }

        .sidebar-nav {
            flex: 1;
            padding: 20px 0;
        }

        .nav-item {
            display: flex;
            align-items: center;
            padding: 14px 20px;
            color: rgba(255, 255, 255, 0.8);
            text-decoration: none;
            transition: all 0.2s;
            font-weight: 500;
            border-left: 3px solid transparent;
        }

        .nav-item:hover {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
        }

        .nav-item.active {
            background-color: rgba(52, 152, 219, 0.2);
            border-left-color: var(--primary);
            color: white;
        }

        .nav-item i {
            margin-right: 12px;
            width: 24px;
            text-align: center;
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

        .profile-btn, .logout-btn {
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

        .profile-btn:hover {
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
            transition: transform 0.3s ease;
        }

        .stat-card:hover {
            transform: translateY(-3px);
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

        /* Button Styles */
        .action-buttons {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
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

        a.btn-secondary {
            background-color: var(--blue-primary);
            color: white;
            border: 1px solid var(--blue-primary);
            text-decoration: none;
        }

        a.btn-secondary:hover {
            background-color: var(--blue-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(52, 152, 219, 0.3);
            color: white;
        }

        .btn-success {
            background-color: var(--success-green);
            color: white;
            border: 1px solid var(--success-green);
        }

        .btn-danger {
            background-color: var(--danger-red);
            color: white;
            border: 1px solid var(--danger-red);
        }

        /* Student Cards Grid - FIXED LAYOUT */
        .students-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-top: 20px;
            min-height: 400px;
        }

        .student-card {
            background-color: var(--bg-card);
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.08);
            padding: 20px;
            transition: all 0.3s ease;
            border-left: 4px solid var(--blue-primary);
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 220px;
        }

        .student-header {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            margin-bottom: 15px;
        }

        .student-avatar {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background-color: rgba(52, 152, 219, 0.1);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--blue-primary);
            font-size: 24px;
            font-weight: 600;
            flex-shrink: 0;
        }

        .student-info {
            flex: 1;
            margin-left: 15px;
            min-width: 0;
        }

        .student-name {
            font-size: 18px;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 5px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .student-major-year {
            font-size: 14px;
            color: var(--text-light);
            margin-bottom: 3px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .student-details {
            margin-top: 15px;
            padding-top: 15px;
            border-top: 1px solid var(--border);
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
        }

        .detail-label {
            font-size: 12px;
            color: var(--text-light);
            margin-bottom: 4px;
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 0.5px;
        }

        .detail-value {
            font-size: 16px;
            font-weight: 700;
            color: var(--text-dark);
        }

        .detail-remark {
            grid-column: 1 / span 2;
            margin-top: 10px;
        }

        /* UPDATED Remark Styles with distinct colors */
        .remark-on-track {
            color: var(--success-green);
            background-color: var(--success-bg);
            padding: 8px 12px;
            border-radius: 6px;
            font-weight: 600;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid rgba(39, 174, 96, 0.3);
            width: 100%;
            justify-content: center;
            text-align: center;
        }

        .remark-need-attention {
            color: var(--warning-orange);
            background-color: var(--warning-bg);
            padding: 8px 12px;
            border-radius: 6px;
            font-weight: 600;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid rgba(243, 156, 18, 0.3);
            width: 100%;
            justify-content: center;
            text-align: center;
        }

        .remark-at-risk {
            color: var(--danger-red);
            background-color: var(--danger-bg);
            padding: 8px 12px;
            border-radius: 6px;
            font-weight: 600;
            font-size: 14px;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            border: 1px solid rgba(231, 76, 60, 0.3);
            width: 100%;
            justify-content: center;
            text-align: center;
        }

        /* Pagination & Modal reused styles (kept) */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            margin-top: 30px;
            gap: 10px;
            flex-wrap: wrap;
        }

        .page-btn {
            padding: 8px 12px;
            border-radius: 6px;
            border: 1px solid var(--blue-border);
            background: white;
            color: var(--blue-primary);
            cursor: pointer;
            font-weight: 600;
        }

        .page-btn.active { background: var(--blue-primary); color: white; border-color: var(--blue-primary); }

        .modal { display:none; position:fixed; inset:0; background:rgba(0,0,0,0.5); z-index:1200; justify-content:center; align-items:center; }
        .modal.show { display:flex; }
        .modal-content { background:white; border-radius:12px; width:90%; max-width:820px; max-height:90vh; overflow:auto; }

        /* Small helpers used in new UI */
        .search-box { padding:8px 12px; border-radius:8px; border:1px solid var(--border); width:260px; }
        .candidate-item { padding:10px; border-bottom:1px solid var(--border); cursor:pointer; display:flex; gap:10px; align-items:center; }
        .candidate-item:hover { background:var(--blue-light); }
        .muted { color: var(--text-light); }
        .denied-reason { color: var(--danger-red); font-weight:700; margin-top:8px; }
        .status-pill { padding:6px 10px; border-radius:10px; font-weight:700; font-size:12px; }
        .status-confirmed { background:rgba(39,174,96,.12); color:var(--success-green); border:1px solid rgba(39,174,96,.15); }
        .status-pending { background:rgba(243,156,18,.12); color:var(--warning-orange); border:1px solid rgba(243,156,18,.15); }
        .status-denied { background:rgba(231,76,60,.08); color:var(--danger-red); border:1px solid rgba(231,76,60,.12); }

        .toast { position: fixed; right: 20px; bottom: 20px; padding:12px 16px; border-radius:8px; color:#fff; display:none; z-index:1300; box-shadow:0 8px 20px rgba(0,0,0,.18) }
        .toast.success { background:var(--success-green) }
        .toast.error { background:var(--danger-red) }

        @media (max-width: 992px) {
            .sidebar { width: 72px; }
            .main-content { margin-left: 72px; }
        }
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar">
            <div class="sidebar-header">
                <div class="logo-main">Advise<span>.</span></div>
            </div>

            <nav class="sidebar-nav">
                <a href="advisor_dashboard.jsp" class="nav-item"><i class="fas fa-home"></i><span>Dashboard</span></a>
                <a href="manage_student.jsp" class="nav-item active"><i class="fas fa-users"></i><span>My Advisees</span></a>
                <a href="view_advising_session.jsp" class="nav-item"><i class="fas fa-calendar-check"></i><span>Advising Sessions</span></a>
                <a href="advisor_report.jsp" class="nav-item"><i class="fas fa-chart-bar"></i><span>Reports</span></a>
            </nav>

            <div class="sidebar-footer">© 2025 Advising System</div>
        </div>

        <div class="main-content">
            <header class="header">
                <h1>My Students - Advisor Dashboard</h1>
                <div class="header-actions">
                    <button class="btn btn-success" id="addAdviseeBtn"><i class="fas fa-user-plus"></i> Add Advisee</button>
                    <a href="advisor_profile.jsp" class="profile-btn" title="Advisor Profile">👤</a>
                    <button class="logout-btn" id="logoutBtn" title="Logout">🚪</button>
                </div>
            </header>

            <main class="content">
                <div class="card">
                    <div class="card-header">
                        <h2>My Advisees</h2>
                        <div style="display:flex;gap:12px;align-items:center">
                            <input id="searchInput" class="search-box" placeholder="Search students by name / ID / major..." aria-label="Search students">
                            <button id="filterBtn" class="btn btn-secondary"><i class="fas fa-filter"></i> Filter</button>
                        </div>
                    </div>

                    <div class="students-grid" id="studentsGrid" aria-live="polite">
                        <!-- student cards injected here -->
                    </div>

                    <div class="pagination" id="paginationContainer"></div>
                </div>
            </main>

            <footer style="padding:18px;text-align:center;border-top:1px solid var(--border);background:var(--bg-card);">© 2025 Advising System — University Academic Services</footer>
        </div>
    </div>

    <!-- Add Advisee Modal (selection-only) -->
    <div class="modal" id="addAdviseeModal" aria-hidden="true" role="dialog" aria-modal="true">
        <div class="modal-content" role="document">
            <div style="display:flex;align-items:center;justify-content:space-between;padding:18px 20px;border-bottom:1px solid var(--border);">
                <h3 style="margin:0;color:var(--blue-primary)">Add Advisee</h3>
                <button id="closeAddModal" class="close-modal" aria-label="Close" style="background:none;border:0;font-size:22px;cursor:pointer">&times;</button>
            </div>

            <div style="padding:18px;">
                <p style="margin-bottom:12px">Search for an existing student by ID or name. Select a student to preview their details, then click <strong>Add Advisee</strong> to assign them to you.</p>

                <div style="display:flex;gap:12px;align-items:flex-start">
                    <div style="width:360px;">
                        <input type="search" id="candidateSearch" class="search-box" placeholder="Search student ID or name..." aria-label="Search candidate students">
                        <div id="candidatesList" style="margin-top:12px;border:1px solid var(--border);border-radius:8px;max-height:320px;overflow:auto;background:white;">
                            <!-- candidate rows -->
                        </div>
                    </div>

                    <div style="flex:1;border-left:1px solid var(--border);padding-left:16px;">
                        <h4 style="margin-top:0">Selected Student</h4>
                        <div id="selectedPreview" style="min-height:160px;color:var(--text-dark)">
                            <p class="muted">No student selected.</p>
                        </div>

                        <div style="margin-top:12px;display:flex;gap:8px">
                            <button id="confirmAddBtn" class="btn btn-primary" disabled><i class="fas fa-user-plus"></i> Add Advisee</button>
                            <button id="cancelAddBtn" class="btn btn-secondary">Cancel</button>
                        </div>

                        <p style="margin-top:12px;font-size:13px;color:var(--text-light)">
                            Note: This form assigns an existing student to you. If you'd like to register a brand new student, use the admin panel or contact system admin.
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast -->
    <div id="toast" class="toast" role="status" aria-live="polite"></div>

    <script>
    (function(){
        'use strict';

        // context path helper
        function ctxPath(){ const p = window.location.pathname.split('/').filter(Boolean); return p.length ? '/' + p[0] : ''; }
        const ctx = ctxPath();

        const qs = id => document.getElementById(id);
        const studentsGrid = qs('studentsGrid');
        const paginationContainer = qs('paginationContainer');
        const searchInput = qs('searchInput');
        const addAdviseeBtn = qs('addAdviseeBtn');
        const addModal = qs('addAdviseeModal');
        const closeAddModal = qs('closeAddModal');
        const candidateSearch = qs('candidateSearch');
        const candidatesList = qs('candidatesList');
        const selectedPreview = qs('selectedPreview');
        const confirmAddBtn = qs('confirmAddBtn');
        const cancelAddBtn = qs('cancelAddBtn');

        // Create session modal elements
        const createSessionBtn = qs('createSessionBtn');
        const createSessionModal = qs('createSessionModal');
        const closeCreateModal = qs('closeCreateModal');
        const cancelCreateBtn = qs('cancelCreateBtn');
        const createSessionForm = qs('createSessionForm');
        const sessionStudent = qs('sessionStudent');
        const toast = qs('toast');

        function showToast(msg, type='success', timeout=3000){
            toast.textContent = msg;
            toast.className = 'toast ' + (type === 'error' ? 'error' : 'success');
            toast.style.display = 'block';
            setTimeout(()=> toast.style.display = 'none', timeout);
        }

        // API helpers
        async function apiGet(path){
            const res = await fetch(ctx + path, { cache: 'no-store' });
            if (!res.ok) {
                const txt = await res.text().catch(()=>null);
                const err = new Error('GET ' + path + ' -> ' + res.status + ' ' + (txt||''));
                err.status = res.status;
                throw err;
            }
            return res.json();
        }

        async function apiPost(path, formData){
            const res = await fetch(ctx + path, {
                method: 'POST',
                body: formData,
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
            });
            const text = await res.text();
            try { return JSON.parse(text); } catch(e){ return { ok: res.ok, status: res.status, text }; }
        }

        // state
        let advisees = []; // current advisees (from /api/advisor/students)
        let currentPage = 1;
        const PAGE_SIZE = 8;
        let allCandidatesCache = null; // list of candidate students (from server search)
        let selectedCandidate = null;

        // ----- Load current advisees and render -----
        async function loadAdvisees(){
            try {
                const j = await apiGet('/api/advisor/students');
                advisees = Array.isArray(j.students) ? j.students : [];
                currentPage = 1;
                renderAdviseesPage(currentPage);
                renderPagination();
            } catch (err) {
                console.warn('loadAdvisees error', err);
                studentsGrid.innerHTML = '<div style="padding:12px;color:#666">Could not load advisees.</div>';
            }
        }

        function renderAdviseesPage(page){
            studentsGrid.innerHTML = '';
            if (!advisees || advisees.length === 0) {
                studentsGrid.innerHTML = '<div style="padding:12px;color:#666">No advisees found.</div>';
                return;
            }
            const start = (page - 1) * PAGE_SIZE;
            const slice = advisees.slice(start, start + PAGE_SIZE);
            slice.forEach(s => {
                const card = document.createElement('div');
                card.className = 'student-card';
                const name = s.name || ((s.firstName||'') + ' ' + (s.lastName||'')).trim() || s.studentID;
                const cgpa = (s.cgpa === null || typeof s.cgpa === 'undefined') ? 'N/A' : (Number(s.cgpa).toFixed ? Number(s.cgpa).toFixed(2) : s.cgpa);
                const credits = s.creditsCompleted === null || typeof s.creditsCompleted === 'undefined' ? 'N/A' : s.creditsCompleted;
                const program = s.program || s.major || '';
                const year = s.yearOfStudy || s.year || '';

                card.innerHTML = `
                    <div class="student-header">
                        <div style="display:flex;align-items:center;gap:12px">
                            <div class="student-avatar" aria-hidden="true">\${(s.firstName||'').charAt(0) || (s.name||'').charAt(0) || 'S'}</div>
                            <div class="student-info">
                                <div class="student-name">\${escapeHtml(name)}</div>
                                <div class="student-major-year">\${escapeHtml(program)}<br><span style="font-size:12px;color:#999">Year \${escapeHtml(String(year||''))}</span></div>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;flex-direction:column;align-items:flex-end">
                            <div style="font-size:13px;color:#666">CGPA: <strong>\${escapeHtml(cgpa)}</strong></div>
                            <div style="font-size:13px;color:#666">Credits: <strong>\${escapeHtml(String(credits))}</strong></div>
                        </div>
                    </div>
                    <div class="student-details" aria-hidden="false">
                        <div>
                            <div class="detail-label">Email</div>
                            <div class="detail-value">\${escapeHtml(s.email || '')}</div>
                        </div>
                        <div>
                            <div class="detail-label">Phone</div>
                            <div class="detail-value">\${escapeHtml(s.phoneNum || '')}</div>
                        </div>
                        <div class="detail-remark" style="display:flex;gap:8px;justify-content:flex-start">
                            <a class="btn btn-secondary" href="view_student_detail.jsp?student_id=\${encodeURIComponent(s.studentID||'')}">View Profile</a>
                            <button class="btn btn-primary btn-email" data-id="\${escapeHtml(s.studentID||'')}" data-email="\${escapeHtml(s.email||'')}">Email</button>
                        </div>
                    </div>
                `;
                studentsGrid.appendChild(card);

                // email button behaviour
                const emailBtn = card.querySelector('.btn-email');
                if (emailBtn) {
                    emailBtn.addEventListener('click', (e) => {
                        e.preventDefault();
                        const email = emailBtn.getAttribute('data-email');
                        if (email) {
                            const gmailUrl = `https://mail.google.com/mail/?view=cm&fs=1&to=\${encodeURIComponent(email)}`;
                            window.open(gmailUrl, '_blank');
                        } else {
                            alert('Email address not available for this student.');
                        }
                    });
                }
            });
        }

        function renderPagination(){
            paginationContainer.innerHTML = '';
            const total = advisees.length;
            const pages = Math.max(1, Math.ceil(total / PAGE_SIZE));
            for (let i=1;i<=pages;i++){
                const b = document.createElement('button');
                b.className = 'page-btn' + (i === currentPage ? ' active' : '');
                b.textContent = i;
                b.addEventListener('click', () => { currentPage = i; renderAdviseesPage(i); renderPagination(); });
                paginationContainer.appendChild(b);
            }
        }

        // search/filter locally by name/id/major
        function applyLocalSearch(term){
            term = (term || '').toLowerCase().trim();
            if (!term) {
                renderAdviseesPage(currentPage);
                return;
            }
            const filtered = advisees.filter(s => {
                return (s.name||'').toLowerCase().includes(term) ||
                       (s.studentID||'').toLowerCase().includes(term) ||
                       (s.program||s.major||'').toLowerCase().includes(term);
            });
            // show filtered (no pagination for simplicity)
            studentsGrid.innerHTML = '';
            if (filtered.length === 0) {
                studentsGrid.innerHTML = '<div style="padding:12px;color:#666">No matching students.</div>';
                return;
            }
            filtered.forEach(s => {
                const card = document.createElement('div');
                card.className = 'student-card';
                const name = s.name || ((s.firstName||'') + ' ' + (s.lastName||'')).trim() || s.studentID;
                const cgpa = (s.cgpa === null || typeof s.cgpa === 'undefined') ? 'N/A' : (Number(s.cgpa).toFixed ? Number(s.cgpa).toFixed(2) : s.cgpa);
                const credits = s.creditsCompleted === null || typeof s.creditsCompleted === 'undefined' ? 'N/A' : s.creditsCompleted;
                const program = s.program || s.major || '';
                const year = s.yearOfStudy || s.year || '';

                card.innerHTML = `
                    <div class="student-header">
                        <div style="display:flex;align-items:center;gap:12px">
                            <div class="student-avatar" aria-hidden="true">\${(s.firstName||'').charAt(0) || (s.name||'').charAt(0) || 'S'}</div>
                            <div class="student-info">
                                <div class="student-name">\${escapeHtml(name)}</div>
                                <div class="student-major-year">\${escapeHtml(program)}<br><span style="font-size:12px;color:#999">Year \${escapeHtml(String(year||''))}</span></div>
                            </div>
                        </div>
                        <div style="display:flex;gap:8px;flex-direction:column;align-items:flex-end">
                            <div style="font-size:13px;color:#666">CGPA: <strong>\${escapeHtml(cgpa)}</strong></div>
                            <div style="font-size:13px;color:#666">Credits: <strong>\${escapeHtml(String(credits))}</strong></div>
                        </div>
                    </div>
                    <div class="student-details" aria-hidden="false">
                        <div>
                            <div class="detail-label">Email</div>
                            <div class="detail-value">\${escapeHtml(s.email || '')}</div>
                        </div>
                        <div>
                            <div class="detail-label">Phone</div>
                            <div class="detail-value">\${escapeHtml(s.phoneNum || '')}</div>
                        </div>
                        <div class="detail-remark" style="display:flex;gap:8px;justify-content:flex-start">
                            <a class="btn btn-secondary" href="view_student_detail.jsp?student_id=\${encodeURIComponent(s.studentID||'')}">View Profile</a>
                            <button class="btn btn-primary btn-email" data-id="\${escapeHtml(s.studentID||'')}" data-email="\${escapeHtml(s.email||"")}">Email</button>
                        </div>
                    </div>
                `;
                studentsGrid.appendChild(card);
                
                // email button behaviour for filtered results
                const emailBtn = card.querySelector('.btn-email');
                if (emailBtn) {
                    emailBtn.addEventListener('click', (e) => {
                        e.preventDefault();
                        const email = emailBtn.getAttribute('data-email');
                        if (email) {
                            const gmailUrl = `https://mail.google.com/mail/?view=cm&fs=1&to=\${encodeURIComponent(email)}`;
                            window.open(gmailUrl, '_blank');
                        } else {
                            alert('Email address not available for this student.');
                        }
                    });
                }
            });
        }

        // ----- Candidate search for add advisee -----
        // Try endpoints in this order:
        // 1) /api/students/search?q=  (recommended backend)
        // 2) /api/students  (all students)
        // 3) fallback: show message (no backend)
        async function fetchCandidates(query){
            // cache per session
            try {
                // try search endpoint
                const endpoint = '/api/students/search?q=' + encodeURIComponent(query || '');
                const res = await fetch(ctx + endpoint, { cache: 'no-store' });
                if (res.ok) {
                    const json = await res.json();
                    // expecting array in json.students or json.results
                    const arr = Array.isArray(json.students) ? json.students : (Array.isArray(json.results) ? json.results : (Array.isArray(json) ? json : []));
                    allCandidatesCache = arr;
                    return arr;
                }
            } catch (e) { /* ignore and fallback */ }

            try {
                // fallback: try /api/students
                const res2 = await fetch(ctx + '/api/students', { cache: 'no-store' });
                if (res2.ok) {
                    const json = await res2.json();
                    const arr = Array.isArray(json.students) ? json.students : (Array.isArray(json) ? json : []);
                    // simple filter by query
                    const filtered = (query ? arr.filter(s => ((s.name||'') + ' ' + (s.studentID||'')).toLowerCase().includes(query.toLowerCase())) : arr);
                    allCandidatesCache = filtered;
                    return filtered;
                }
            } catch (e){ /* ignore */ }

            // final fallback: empty
            return [];
        }

        function renderCandidates(list){
            candidatesList.innerHTML = '';
            if (!list || list.length === 0) {
                candidatesList.innerHTML = '<div style="padding:12px;color:#666">No matching students found on server.</div>';
                return;
            }
            list.forEach(s => {
                const item = document.createElement('div');
                item.className = 'candidate-item';
                const name = s.name || ((s.firstName||'') + ' ' + (s.lastName||'')).trim() || s.studentID;
                const isAssigned = s.advisorID != null && s.advisorID !== '';
                item.innerHTML = `<div style="width:40px;height:40px;border-radius:8px;background:var(--blue-light);display:flex;align-items:center;justify-content:center;color:var(--blue-dark);font-weight:700">\${escapeHtml((s.firstName||'').charAt(0) || (s.name||'').charAt(0) || 'S')}</div>
                                  <div style="flex:1">
                                    <div style="font-weight:700">\${escapeHtml(name)}</div>
                                    <div style="font-size:13px;color:var(--text-light)">\${escapeHtml(s.studentID || '')} • \${escapeHtml(s.program || s.major || '')}</div>
                                    \${isAssigned ? '<div style="font-size:12px;color:#f00">Already assigned to advisor</div>' : ''}
                                  </div>`;
                item.addEventListener('click', () => {
                    selectCandidate(s);
                });
                candidatesList.appendChild(item);
            });
        }

        function selectCandidate(s){
            selectedCandidate = s;
            const isAssigned = s.advisorID != null && s.advisorID !== '';
            // populate preview
            const name = s.name || ((s.firstName||'') + ' ' + (s.lastName||'')).trim() || s.studentID;
            selectedPreview.innerHTML = `
                <div style="display:flex;gap:12px;align-items:center">
                    <div style="width:60px;height:60px;border-radius:8px;background:var(--blue-light);display:flex;align-items:center;justify-content:center;font-weight:700;color:var(--blue-dark)">\${escapeHtml((s.firstName||'').charAt(0) || (s.name||'').charAt(0) || 'S')}</div>
                    <div>
                        <div style="font-weight:700">\${escapeHtml(name)}</div>
                        <div style="font-size:13px;color:var(--text-light)">\${escapeHtml(s.studentID || '')}</div>
                        <div style="margin-top:8px;font-size:13px">Email: <strong>\${escapeHtml(s.email || '-')}</strong></div>
                        \${isAssigned ? '<div style="margin-top:8px;font-size:13px;color:#f00">Currently assigned to advisor ID: ' + escapeHtml(s.advisorID) + '</div>' : ''}
                    </div>
                </div>
                <div style="margin-top:12px">
                    <div style="font-size:13px;color:var(--text-light)">Program / Major</div>
                    <div style="font-weight:700">\${escapeHtml(s.program || s.major || '-')}</div>
                    <div style="margin-top:8px;font-size:13px;color:var(--text-light)">Year</div>
                    <div style="font-weight:700">\${escapeHtml(String(s.yearOfStudy || s.year || '-'))}</div>
                    <div style="margin-top:8px;font-size:13px;color:var(--text-light)">CGPA</div>
                    <div style="font-weight:700">\${(s.cgpa===null||s.cgpa===undefined)?'-':escapeHtml(String(s.cgpa))}</div>
                </div>
            `;
            confirmAddBtn.disabled = false;
            confirmAddBtn.innerHTML = `<i class="fas fa-user-plus"></i> \${isAssigned ? 'Reassign Advisee' : 'Add Advisee'}`;
        }

        // Add advisee action: POST to /api/advisor/students/add (best-effort). If 404, show helpful message.
        async function addAdvisee(studentID){
            if (!studentID) return;
            // form payload
            const params = new URLSearchParams();
            params.append('studentID', studentID);

            try {
                const res = await fetch(ctx + '/api/advisor/students/add', {
                    method: 'POST',
                    body: params,
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
                });

                if (res.ok) {
                    // ideally server returns JSON { success:true }
                    try {
                        const j = await res.json().catch(()=>null);
                        showToast('Advisee added successfully');
                    } catch (e) {
                        showToast('Advisee added successfully');
                    }
                    closeAddAdviseeModal();
                    await loadAdvisees();
                    return;
                } else if (res.status === 409) {
                    // Conflict: already assigned to another advisor
                    showToast('Student already assigned to another advisor. Reassignment not allowed.', 'error', 6000);
                    return;
                } else if (res.status === 404) {
                    // endpoint not implemented on server
                    showToast('Add endpoint not found on server. Ask admin to implement POST /api/advisor/students/add', 'error', 6000);
                    return;
                } else {
                    const txt = await res.text().catch(()=>null);
                    showToast('Add failed: ' + (txt || res.status), 'error', 6000);
                    return;
                }
            } catch (err) {
                console.error('addAdvisee error', err);
                showToast('Network error while adding advisee', 'error', 4000);
            }
        }

        // modal open/close
        function openAddAdviseeModal(){
            addModal.classList.add('show');
            addModal.setAttribute('aria-hidden','false');
            candidateSearch.value = '';
            candidatesList.innerHTML = '<div style="padding:12px;color:#666">Start typing to search students...</div>';
            selectedPreview.innerHTML = '<p class="muted">No student selected.</p>';
            confirmAddBtn.disabled = true;
            selectedCandidate = null;

            // initial candidate list (empty) - prefetch first page of candidates without query
            fetchCandidates('').then(list => renderCandidates(list.slice(0, 50))).catch(()=>{/*ignore*/});
            candidateSearch.focus();
        }

        function closeAddAdviseeModal(){
            addModal.classList.remove('show');
            addModal.setAttribute('aria-hidden','true');
            selectedCandidate = null;
        }

        // debounce helper
        function debounce(fn, wait=300){
            let t;
            return function(...args){ clearTimeout(t); t = setTimeout(()=> fn.apply(this,args), wait); };
        }

        // Setup events
        document.addEventListener('DOMContentLoaded', function(){
            loadAdvisees();

            // search input on main grid
            searchInput.addEventListener('input', debounce((e)=>{
                applyLocalSearch(e.target.value);
            }, 250));

            // Add Advisee modal triggers
            addAdviseeBtn.addEventListener('click', openAddAdviseeModal);
            closeAddModal.addEventListener('click', closeAddAdviseeModal);
            cancelAddBtn.addEventListener('click', closeAddAdviseeModal);

            // candidate search (live)
            candidateSearch.addEventListener('input', debounce(async function(e){
                const q = e.target.value.trim();
                candidatesList.innerHTML = '<div style="padding:12px;color:#666">Searching…</div>';
                try {
                    const list = await fetchCandidates(q);
                    renderCandidates(list.slice(0,200));
                } catch (err) {
                    candidatesList.innerHTML = '<div style="padding:12px;color:#666">Search failed.</div>';
                }
            }, 300));

            // confirm add button
            confirmAddBtn.addEventListener('click', async function(){
                if (!selectedCandidate || !selectedCandidate.studentID) return;
                const isAssigned = selectedCandidate.advisorID != null && selectedCandidate.advisorID !== '';
                const action = isAssigned ? 'Reassign' : 'Assign';
                if (!confirm(action + ' ' + (selectedCandidate.name || selectedCandidate.studentID) + ' as your advisee?')) return;
                await addAdvisee(selectedCandidate.studentID);
            });

            // logout button
            const logoutBtn = document.getElementById('logoutBtn');
            if (logoutBtn) logoutBtn.addEventListener('click', function(){
                if (!confirm('Are you sure you want to logout?')) return;
                // navigate to server logout (common path)
                window.location.href = ctx + '/logout';
            });

            // filter button (simple prompt filter for demo)
            const filterBtn = qs('filterBtn');
            if (filterBtn) {
                filterBtn.addEventListener('click', function(){
                    const options = ['All','Seniors','Juniors','Sophomores','Freshmen','Need Attention','At Risk','On Track'];
                    const sel = prompt('Filter by:\n\n' + options.map((o,i)=> (i+1) + '. ' + o).join('\n') + '\n\nEnter number:', '1');
                    if (!sel) return;
                    switch(sel){
                        case '1': loadAdvisees(); break;
                        case '2': advisees = advisees.filter(s => s.yearOfStudy === 4 || s.yearOfStudy === 'Senior'); renderAdviseesPage(1); renderPagination(); break;
                        case '3': advisees = advisees.filter(s => s.yearOfStudy === 3 || s.yearOfStudy === 'Junior'); renderAdviseesPage(1); renderPagination(); break;
                        case '4': advisees = advisees.filter(s => s.yearOfStudy === 2 || s.yearOfStudy === 'Sophomore'); renderAdviseesPage(1); renderPagination(); break;
                        case '5': advisees = advisees.filter(s => s.yearOfStudy === 1 || s.yearOfStudy === 'Freshman'); renderAdviseesPage(1); renderPagination(); break;
                        default: loadAdvisees();
                    }
                });
            }
        });

        // small helpers
        function escapeHtml(s){ if (s === null || s === undefined) return ''; return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
    })();
    </script>
</body>
</html>