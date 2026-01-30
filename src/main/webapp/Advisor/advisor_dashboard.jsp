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
    <title>Advisor Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Playfair+Display:wght@600;700;800&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #3498db;
            --primary-light: #5dade2;
            --primary-dark: #2980b9;
            --secondary: #2c3e50;
            --light-bg: #f8f9fa;
            --card-bg: #ffffff;
            --text-dark: #2c3e50;
            --text-light: #7f8c8d;
            --border: #e9ecef;
            --success: #27ae60;
            --warning: #f39c12;
            --danger: #e74c3c;
            --info: #3498db;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--light-bg);
            color: var(--text-dark);
            min-height: 100vh;
        }

        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background-color: var(--secondary);
            color: white;
            display: flex;
            flex-direction: column;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
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

        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 260px;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .header {
            background-color: var(--card-bg);
            padding: 20px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border);
        }

        .header h1 {
            font-size: 24px;
            font-weight: 700;
            color: var(--text-dark);
        }

        .header-actions {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .profile-btn, .logout-btn {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background: var(--light-bg);
            border: 1px solid var(--border);
            cursor: pointer;
            transition: all 0.2s;
            color: var(--text-light);
        }

        .profile-btn:hover, .logout-btn:hover {
            background-color: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        /* Content Area */
        .content {
            padding: 30px;
            flex: 1;
        }

        /* Welcome Section */
        .welcome-section {
            background: linear-gradient(135deg, var(--card-bg) 0%, #f0f7ff 100%);
            padding: 30px;
            border-radius: 16px;
            margin-bottom: 30px;
            border: 1px solid var(--border);
            position: relative;
            overflow: hidden;
        }

        .welcome-section::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary), var(--primary-light));
        }

        .welcome-header h1 {
            font-size: 28px;
            font-weight: 700;
            margin-bottom: 8px;
            color: var(--primary);
        }

        .welcome-header .subtitle {
            color: var(--text-light);
            font-size: 16px;
            margin-bottom: 20px;
        }

        /* Quick Stats */
        .quick-stats {
            display: flex;
            gap: 16px;
            margin-bottom: 25px;
            flex-wrap: wrap;
        }

        .stat-badge {
            background: rgba(52, 152, 219, 0.1);
            border: 1px solid rgba(52, 152, 219, 0.2);
            color: var(--primary);
            padding: 10px 20px;
            border-radius: 12px;
            font-size: 14px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }

        .stat-badge:hover {
            background: rgba(52, 152, 219, 0.15);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(52, 152, 219, 0.1);
        }

        .stat-badge i {
            font-size: 16px;
        }

        /* Main Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card-large {
            background: var(--card-bg);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 25px;
            text-align: center;
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card-large::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 4px;
            background: linear-gradient(90deg, var(--primary), var(--primary-light));
        }

        .stat-card-large:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(52, 152, 219, 0.1);
        }

        .stat-card-large .stat-icon {
            font-size: 32px;
            color: white;
            margin-bottom: 15px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            border-radius: 50%;
            box-shadow: 0 4px 12px rgba(52, 152, 219, 0.3);
        }

        .stat-card-large .stat-info h3 {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-dark);
            margin: 10px 0;
        }

        .stat-card-large .stat-info p {
            color: var(--text-light);
            font-size: 14px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .stat-extra {
            margin-top: 10px;
            font-size: 13px;
            color: var(--primary);
            opacity: 0.8;
        }

        /* Recent Activities */
        .recent-activities {
            background: var(--card-bg);
            border-radius: 16px;
            padding: 30px;
            border: 1px solid var(--border);
            margin-bottom: 30px;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border);
        }

        .section-header h2 {
            font-size: 20px;
            font-weight: 700;
            color: var(--primary);
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .activities-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .activity-item {
            display: flex;
            align-items: center;
            padding: 16px;
            background: var(--light-bg);
            border-radius: 12px;
            border-left: 4px solid var(--primary);
            transition: all 0.2s ease;
        }

        .activity-item:hover {
            background: #e8f4fc;
            transform: translateX(5px);
        }

        .activity-icon {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 16px;
            font-size: 18px;
            color: white;
            flex-shrink: 0;
        }

        .activity-icon.meeting {
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
        }

        .activity-icon.report {
            background: linear-gradient(135deg, var(--success), #2ecc71);
        }

        .activity-icon.approval {
            background: linear-gradient(135deg, var(--warning), #f1c40f);
        }

        .activity-icon.alert {
            background: linear-gradient(135deg, var(--danger), #c0392b);
        }

        .activity-details {
            flex: 1;
        }

        .activity-title {
            font-size: 15px;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 4px;
        }

        .activity-description {
            font-size: 13px;
            color: var(--text-light);
            margin-bottom: 6px;
        }

        .activity-meta {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .activity-time, .activity-student {
            font-size: 12px;
            color: var(--text-light);
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .view-all-btn {
            text-align: center;
            margin-top: 25px;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 8px;
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            transition: all 0.2s;
            border: 1px solid var(--primary);
            background: var(--primary);
            color: white;
            text-decoration: none;
            display: inline-block;
        }

        .btn:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(52, 152, 219, 0.2);
        }

        /* Footer */
        footer {
            text-align: center;
            padding: 20px;
            color: var(--text-light);
            font-size: 14px;
            border-top: 1px solid var(--border);
            background: var(--card-bg);
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .sidebar {
                width: 70px;
            }
            
            .sidebar .nav-item span {
                display: none;
            }
            
            .sidebar .nav-item {
                justify-content: center;
                padding: 18px 0;
            }
            
            .sidebar .nav-item i {
                margin-right: 0;
                font-size: 20px;
            }
            
            .main-content {
                margin-left: 70px;
            }
        }

        @media (max-width: 768px) {
            .content {
                padding: 20px;
            }

            .welcome-section {
                padding: 20px;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .quick-stats {
                flex-direction: column;
            }

            .stat-badge {
                justify-content: center;
            }

            .activity-meta {
                flex-direction: column;
                gap: 8px;
            }
        }

        @media (max-width: 480px) {
            .header {
                flex-direction: column;
                gap: 15px;
                text-align: center;
            }

            .header-actions {
                align-self: center;
            }

            .welcome-header h1 {
                font-size: 24px;
            }
        }
        
        .advisee-card{background:#fff;border-radius:12px;padding:14px;border:1px solid var(--border);display:flex;flex-direction:column;gap:8px}
        .advisee-name{font-weight:700;color:var(--text-dark)}
        .advisee-meta{font-size:13px;color:var(--text-light)}
        .pagination{display:flex;gap:8px;justify-content:center;margin-top:12px}
        .page-btn{padding:6px 10px;border:1px solid var(--border);background:white;border-radius:6px;cursor:pointer}
        .page-btn.active{background:var(--primary);color:white;border-color:var(--primary)}
        
        .filter-controls { display:flex; gap:12px; align-items:center; }
        .filter-select { padding:6px 10px; border-radius:8px; border:1px solid var(--border); background:white; }
        
        .status-badge { display:inline-block; padding:6px 10px; border-radius:12px; font-weight:700; font-size:12px; text-transform:capitalize; margin-left:8px; }
        .status-confirmed { background:rgba(39,174,96,0.12); color:var(--success); border:1px solid rgba(39,174,96,0.14); }
        .status-pending   { background:rgba(243,156,18,0.12); color:var(--warning); border:1px solid rgba(243,156,18,0.14); }
        .status-denied    { background:rgba(239,68,68,0.08); color:var(--danger); border:1px solid rgba(239,68,68,0.12); }

        .cancel-reason { color:var(--danger); margin-top:6px; font-size:13px; font-weight:600; }
        .status-pill{font-size:12px;padding:4px 8px;border-radius:12px;font-weight:700;margin-left:6px}
        .status-cancelled{background:rgba(107,114,128,0.06);color:#6b7280;border:1px solid rgba(107,114,128,0.08)}
        .session-actions{display:flex;gap:8px;margin-left:12px;align-self:flex-start}
        .small-muted{font-size:12px;color:#6b7280;margin-top:6px}
        @media (max-width:1200px){.sidebar{width:70px}.main-content{margin-left:70px}}
    </style>
</head>
<body>
    <div class="dashboard-container">
        <div class="sidebar">
          <div class="sidebar-header">
            <div class="logo">
              <div class="logo-main">
                Advise<span>.</span>
              </div>
            </div>
          </div>
            
          <nav class="sidebar-nav">
            <a href="advisor_dashboard.jsp" class="nav-item active">
              <i class="fas fa-home"></i>
              <span>Dashboard</span>
            </a>
            <a href="manage_student.jsp" class="nav-item">
              <i class="fas fa-users"></i>
              <span>My Advisees</span>
            </a>
            <a href="view_advising_session.jsp" class="nav-item">
              <i class="fas fa-calendar-check"></i>
              <span>Advising Sessions</span>
            </a>
            <a href="advisor_report.jsp" class="nav-item">
              <i class="fas fa-chart-bar"></i>
              <span>Reports</span>
            </a>
          </nav>

        </div>  <!-- END OF SIDEBAR -->

        <div class="main-content">
            <header class="header">
                <h1>Dashboard Overview</h1>
                <div class="header-actions">
                    <a href="advisor_profile.jsp" class="profile-btn" title="My Profile"><i class="fas fa-user"></i></a>
                    <div class="logout-btn" title="Logout" id="logoutBtn"><i class="fas fa-sign-out-alt"></i></div>
                </div>
            </header>

            <div class="content">
                <div class="welcome-section">
                    <div class="welcome-header">
                        <h1 id="welcomeName">Welcome back, Advisor</h1>
                        <div class="subtitle">Manage and monitor your advising responsibilities, support student success, and track academic progress.</div>

                        <div class="quick-stats">
                            <div class="stat-badge" id="badgePendingApprovals"><i class="fas fa-clock"></i> <span id="pendingApprovalsCount">0</span> Pending</div>
                            <div class="stat-badge" id="badgeTodaysSessions"><i class="fas fa-calendar-day"></i> <span id="todaysSessionsCount">0</span> Today</div>
                            <div class="stat-badge" id="badgeOnTrack"><i class="fas fa-percentage"></i> <span id="onTrackPercent">--</span> On-track</div>
                            <div class="stat-badge" id="badgeRecentMeetings"><i class="fas fa-user-clock"></i> <span id="recentMeetingsCount">0</span> Recent</div>
                        </div>
                    </div>

                    <div class="stats-grid">
                        <div class="stat-card-large">
                            <div class="stat-icon"><i class="fas fa-users"></i></div>
                            <div class="stat-info">
                                <h3 id="totalStudentsStat">0</h3>
                                <p>Total Students</p>
                            </div>
                        </div>

                        <div class="stat-card-large">
                            <div class="stat-icon"><i class="fas fa-calendar-check"></i></div>
                            <div class="stat-info">
                                <h3 id="upcomingSessionsStat">0</h3>
                                <p>Upcoming Sessions</p>
                            </div>
                        </div>

                        <div class="stat-card-large">
                            <div class="stat-icon"><i class="fas fa-graduation-cap"></i></div>
                            <div class="stat-info">
                                <h3 id="graduatingSoonStat">0</h3>
                                <p>Graduating Soon</p>
                            </div>
                        </div>

                        <div class="stat-card-large">
                            <div class="stat-icon"><i class="fas fa-chart-line"></i></div>
                            <div class="stat-info">
                                <h3 id="avgGpaStat">0.00</h3>
                                <p>Average GPA</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="recent-activities">
                    <div class="section-header">
                        <h2><i class="fas fa-history"></i> Recent Sessions</h2>
                        <div style="display:flex;align-items:center;gap:12px">
                            <label for="sessionFilter" style="font-size:13px;color:var(--text-light);margin-right:6px;">Filter:</label>
                            <select id="sessionFilter" class="filter-select" title="Filter sessions by status">
                                <option value="all">All</option>
                                <option value="confirmed">Confirmed</option>
                                <option value="pending">Pending</option>
                                <option value="denied">Denied</option>
                            </select>
                            <a href="view_advising_session.jsp" class="btn" style="margin-left:8px;">View All Sessions</a>
                        </div>
                    </div>

                    <div class="activities-list" id="activitiesList"></div>
                </div>

                <div class="card" id="adviseesCard">
                    <div class="card-header" style="display:flex;justify-content:space-between;align-items:center;">
                        <h2>My Advisees</h2>
                        <div>
                            <a href="manage_student.jsp" class="btn btn-outline" id="manageAdviseesBtn">Manage Advisees</a>
                        </div>
                    </div>

                    <div id="adviseesList" style="display:grid; grid-template-columns: repeat(auto-fill,minmax(260px,1fr)); gap:16px; padding-top:12px;"></div>
                    <div id="adviseesPagination" class="pagination" style="margin-top:12px;"></div>
                </div>
            </div>

            <footer>© 2025 Advising System — University Academic Services</footer>
        </div>
    </div>

    <script>
    (function () {
      const ctx = (function(){ const p = window.location.pathname.split('/').filter(Boolean); return p.length ? '/' + p[0] : ''; })();

      function q(id){ return document.getElementById(id); }
      function fmtDate(ts) { if (!ts) return ''; try { const d = new Date(String(ts).replace(' ', 'T')); return d.toLocaleString(); } catch(e){ return ts; } }
      function escapeHtml(t){ if (t === null || typeof t === 'undefined') return ''; return String(t).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }

      async function apiGet(path) {
        const res = await fetch(ctx + path, { cache: 'no-store' });
        if (!res.ok) {
          const txt = await res.text().catch(()=>null);
          throw new Error('GET ' + path + ' ' + res.status + ' ' + (txt || ''));
        }
        return res.json();
      }

      async function apiPost(path, body) {
        const res = await fetch(ctx + path, { method: 'POST', body: body, headers: { 'Content-Type': 'application/x-www-form-urlencoded' }});
        const text = await res.text().catch(()=>null);
        try { return JSON.parse(text); } catch (e) { return { ok: res.ok, status: res.status, text }; }
      }

      // state
      let allSessions = []; // store sessions fetched from /api/advisor/sessions
    let advisees = [];
    let adviseesPage = 1;
    const PAGE_SIZE = 8;

      // load overview + prefer server-provided counts for accuracy
      async function loadOverview() {
        try {
          const data = await apiGet('/api/advisor/me');
          if (data.advisor) {
            const adv = data.advisor;
            const name = ((adv.firstName||'') + ' ' + (adv.lastName||'')).trim() || adv.email || '';
            if (name) q('welcomeName').textContent = 'Welcome back, ' + name + '!';
          }
          if (typeof data.totalStudents !== 'undefined') q('totalStudentsStat').textContent = data.totalStudents;
          if (typeof data.upcomingSessions !== 'undefined') q('upcomingSessionsStat').textContent = data.upcomingSessions;
          if (typeof data.graduatingSoon !== 'undefined') q('graduatingSoonStat').textContent = data.graduatingSoon;
          if (typeof data.averageAdviseeCgpa !== 'undefined' && data.averageAdviseeCgpa !== null) q('avgGpaStat').textContent = Number(data.averageAdviseeCgpa).toFixed(2);

          // todaysSessions provided by server is authoritative: only confirmed counted server-side
          if (typeof data.todaysSessions !== 'undefined') {
            q('todaysSessionsCount').textContent = data.todaysSessions;
          }

          // recentMeetings: we consider past confirmed/completed sessions; if server returns recentSessions use length
          if (Array.isArray(data.recentSessions)) {
            q('recentMeetingsCount').textContent = data.recentSessions.length;
          }

        } catch (err) {
          console.warn('loadOverview error', err);
        }
      }

      // load sessions and render list respecting filter (filter UI will control)
      async function loadSessionsAndRender() {
        try {
          const j = await apiGet('/api/advisor/sessions');
          allSessions = Array.isArray(j.sessions) ? j.sessions : [];
          // compute pending (status === 'pending')
          const pending = allSessions.filter(s => (s.status||'').toLowerCase() === 'pending').length;
          q('pendingApprovalsCount').textContent = pending;

          // compute today's confirmed sessions (use confirmed only)
          const todayStart = new Date(); todayStart.setHours(0,0,0,0);
          const tomorrow = new Date(todayStart); tomorrow.setDate(todayStart.getDate()+1);
          const todaysConfirmed = allSessions.filter(s => {
            if (!s.sessionDateTime) return false;
            const ts = new Date(String(s.sessionDateTime).replace(' ', 'T'));
            return ts >= todayStart && ts < tomorrow && (String(s.status||'').toLowerCase() === 'confirmed');
          }).length;
          q('todaysSessionsCount').textContent = todaysConfirmed;

          // compute upcoming confirmed sessions in next 30 days (if you want to update stat)
          const now = new Date();
          const in30 = new Date(now); in30.setDate(in30.getDate()+30);
          const upcomingConfirmed = allSessions.filter(s => {
            if (!s.sessionDateTime) return false;
            const ts = new Date(String(s.sessionDateTime).replace(' ', 'T'));
            const st = String(s.status||'').toLowerCase();
            return ts >= now && ts <= in30 && st === 'confirmed';
          }).length;
          q('upcomingSessionsStat').textContent = upcomingConfirmed;

          // set recent meetings count (past confirmed/completed)
          const pastConfirmed = allSessions.filter(s => {
            if (!s.sessionDateTime) return false;
            const ts = new Date(String(s.sessionDateTime).replace(' ', 'T'));
            const st = String(s.status||'').toLowerCase();
            return ts <= new Date() && (st === 'confirmed' || st === 'completed');
          }).length;
          q('recentMeetingsCount').textContent = pastConfirmed;

          // render according to selected filter
          renderRecentSessionsCards();
        } catch (err) {
          console.warn('loadSessionsAndRender', err);
        }
      }

      // returns current session filter value
      function getSessionFilter() {
        const sel = q('sessionFilter');
        return sel ? sel.value : 'all';
      }

      // render recent sessions area applying filter
      function renderRecentSessionsCards() {
        const container = q('activitiesList');
        if (!container) return;
        container.innerHTML = '';
        const filter = getSessionFilter();
        let sessions = allSessions.slice(); // copy

        // optionally sort descending by datetime
        sessions.sort((a,b) => {
          const ta = a.sessionDateTime ? new Date(String(a.sessionDateTime).replace(' ', 'T')).getTime() : 0;
          const tb = b.sessionDateTime ? new Date(String(b.sessionDateTime).replace(' ', 'T')).getTime() : 0;
          return tb - ta;
        });

        // apply filter
        if (filter !== 'all') {
          sessions = sessions.filter(s => (String(s.status||'').toLowerCase() === filter));
        }

        if (sessions.length === 0) {
          container.innerHTML = '<div style="padding:12px;color:#666">No sessions (matching filter).</div>';
          return;
        }

        // limit to 5 recent sessions
        sessions.slice(0, 5).forEach(s => {
          const card = document.createElement('div');
          card.className = 'activity-item';

          const student = (s.studentName && s.studentName !== 'null') ? s.studentName : (s.studentID || 'Unknown Student');
          const notes = s.notes || '';
          const status = (s.status || '').toLowerCase();
          const cancelReason = s.cancelReason || s.cancelreason || '';

          // status badge markup
          let statusClass = 'status-pending';
          let statusLabel = status || 'pending';
          if (status === 'confirmed') { statusClass = 'status-confirmed'; statusLabel = 'Confirmed'; }
          else if (status === 'denied' || status === 'denial' || status === 'rejected') { statusClass = 'status-denied'; statusLabel = 'Denied'; }
          else if (status === 'completed') { statusClass = 'status-confirmed'; statusLabel = 'Completed'; }
          else if (status === 'pending') { statusClass = 'status-pending'; statusLabel = 'Pending'; }

          const when = fmtDate(s.sessionDateTime);

          card.innerHTML = '\n            <div class="activity-icon meeting"><i class="fas fa-calendar-check"></i></div>\n            <div class="activity-details">\n              <div style="display:flex;align-items:center;gap:8px">\n                <div class="activity-title">' + (escapeHtml(s.title || '(no title)')) + '</div>\n                <span class="status-badge ' + (statusClass) + '" title="Status">' + (escapeHtml(statusLabel)) + '</span>\n              </div>\n              <div class="activity-description">' + (escapeHtml(student)) + ' • <span style="color:#666">' + (escapeHtml(when)) + '</span></div>\n              ' + (notes ? '<div style="margin-top:6px;font-size:13px;color:#445">' + escapeHtml(notes) + '</div>' : '') + '\n              ' + ((status === 'denied' || status === 'cancelled' || cancelReason) ? '<div class="cancel-reason">Reason: ' + escapeHtml(cancelReason) + '</div>' : '') + '\n              <div class="activity-meta" style="margin-top:8px;">\n                <div class="activity-time"><i class="far fa-clock"></i> ' + (escapeHtml(when)) + '</div>\n                <div class="activity-student"><i class="fas fa-user"></i> ' + (escapeHtml(student)) + '</div>\n              </div>\n            </div>\n          ';

          // actions area
          const actions = document.createElement('div');
          actions.style.display = 'flex';
          actions.style.gap = '8px';
          actions.style.marginLeft = '8px';

          // pending -> Accept / Deny
          if (status === 'pending') {
            const acceptBtn = document.createElement('button');
            acceptBtn.className = 'btn';
            acceptBtn.textContent = 'Accept';
            acceptBtn.addEventListener('click', async (ev) => {
              ev.stopPropagation();
              const meetLink = prompt('Enter Google Meet link for this session (optional):');
              if (!confirm('Accept this advising session?')) return;
              try {
                const params = new URLSearchParams({ sessionID: s.sessionID, action: 'accept' });
                if (meetLink && meetLink.trim()) params.append('meetLink', meetLink.trim());
                const res = await apiPost('/api/advisor/session/update', params);
                if (res && (res.success || res.ok)) {
                  alert('Session accepted.');
                  await loadOverview();
                  await loadSessionsAndRender();
                } else {
                  alert('Could not accept session: ' + (res && res.error ? res.error : JSON.stringify(res)));
                }
              } catch (err) { console.error(err); alert('Network error'); }
            });
            const denyBtn = document.createElement('button');
            denyBtn.className = 'btn';
            denyBtn.style.background = 'var(--danger)';
            denyBtn.style.borderColor = 'var(--danger)';
            denyBtn.textContent = 'Deny';
            denyBtn.addEventListener('click', async (ev) => {
              ev.stopPropagation();
              const reason = prompt('Reason for denying (optional):');
              if (reason === null) return;
              try {
                const res = await apiPost('/api/advisor/session/update', new URLSearchParams({ sessionID: s.sessionID, action: 'deny', reason }));
                if (res && (res.success || res.ok)) {
                  alert('Session denied.');
                  await loadOverview();
                  await loadSessionsAndRender();
                } else {
                  alert('Could not deny session: ' + (res && res.error ? res.error : JSON.stringify(res)));
                }
              } catch (err) { console.error(err); alert('Network error'); }
            });
            actions.appendChild(acceptBtn);
            actions.appendChild(denyBtn);
          } else {
            const viewBtn = document.createElement('button');
            viewBtn.className = 'btn';
            viewBtn.textContent = 'Details';
            viewBtn.addEventListener('click', (ev) => {
              ev.stopPropagation();
              alert('Session: ' + (s.title||'') + '\nStudent: ' + student + '\nWhen: ' + fmtDate(s.sessionDateTime) + '\nStatus: ' + (s.status || '') + '\n\nNotes:\n' + (s.notes || '') + (cancelReason ? '\n\nReason: ' + cancelReason : ''));
            });
            actions.appendChild(viewBtn);
          }

          card.appendChild(actions);
          card.addEventListener('click', () => {
            alert('Session: ' + (s.title||'') + '\nStudent: ' + student + '\nWhen: ' + fmtDate(s.sessionDateTime) + '\nStatus: ' + (s.status || '') + '\n\nNotes:\n' + (s.notes || '') + (cancelReason ? '\n\nReason: ' + cancelReason : ''));
          });

          container.appendChild(card);
        });
      }

      // advisees: load / render / pagination
      async function loadAdvisees() {
        try {
          const j = await apiGet('/api/advisor/students');
          advisees = Array.isArray(j.students) ? j.students : [];
          adviseesPage = 1;
          renderAdviseesPage(adviseesPage);
          renderAdviseesPagination();
          if (advisees && advisees.length) q('totalStudentsStat').textContent = advisees.length;
        } catch (err) {
          console.warn('loadAdvisees', err);
        }
      }

      function renderAdviseesPage(page) {
        const container = q('adviseesList');
        if (!container) return;
        container.innerHTML = '';
        const start = (page-1)*PAGE_SIZE;
        const slice = advisees.slice(start, start+PAGE_SIZE);
        if (slice.length === 0) {
          container.innerHTML = '<div style="padding:12px;color:#666">No advisees found.</div>';
          return;
        }
        slice.forEach(s => {
          const card = document.createElement('div');
          card.className = 'advisee-card';
          const name = s.name || ((s.firstName||'')+' '+(s.lastName||'')).trim() || s.studentID;
          const cgpa = (s.cgpa === null || typeof s.cgpa === 'undefined') ? 'N/A' : Number(s.cgpa).toFixed(2);
          const credits = s.creditsCompleted === null || typeof s.creditsCompleted === 'undefined' ? 'N/A' : s.creditsCompleted;
          const remark = s.remark || '';
          card.innerHTML = '\n            <div class="advisee-name">' + (escapeHtml(name)) + '</div>\n            <div class="advisee-meta">' + (escapeHtml(s.program || '')) + ' • Year ' + (escapeHtml(String(s.yearOfStudy || ''))) + '</div>\n            <div style="display:flex;justify-content:space-between;align-items:center;margin-top:8px;">\n              <div style="font-size:13px;color:#666">CGPA: <strong>' + (escapeHtml(cgpa)) + '</strong></div>\n              <div style="font-size:13px;color:#666">Credits: <strong>' + (escapeHtml(String(credits))) + '</strong></div>\n            </div>\n            ' + (remark ? '<div style="margin-top:8px;font-size:12px;padding:8px;background:#f0f8ff;border-left:3px solid #3498db;border-radius:4px;color:#333;"><strong>Remark:</strong> ' + escapeHtml(remark) + '</div>' : '') + '\n          ';
          container.appendChild(card);
        });
      }

      function renderAdviseesPagination() {
        const pag = q('adviseesPagination'); if (!pag) return;
        pag.innerHTML = '';
        const total = advisees.length;
        const pages = Math.max(1, Math.ceil(total/PAGE_SIZE));
        for (let i=1;i<=pages;i++){
          const b = document.createElement('button');
          b.className = 'page-btn' + (i===adviseesPage ? ' active' : '');
          b.textContent = i;
          b.addEventListener('click', () => { adviseesPage = i; renderAdviseesPage(i); renderAdviseesPagination(); });
          pag.appendChild(b);
        }
      }

      // full refresh
      async function refreshAll() {
        await loadOverview();
        await loadSessionsAndRender();
        await loadAdvisees();
      }

      document.addEventListener('DOMContentLoaded', function(){
        // logout
        const logoutBtn = q('logoutBtn');
        if (logoutBtn) logoutBtn.addEventListener('click', function(){ if (!confirm('Logout?')) return; window.location.href = ctx + '/logout'; });

        // filter change
        const filterEl = q('sessionFilter');
        if (filterEl) {
          filterEl.addEventListener('change', () => renderRecentSessionsCards());
        }

        refreshAll();
        setInterval(refreshAll, 60*1000);
      });
    })();
    </script>
</body>
</html>
