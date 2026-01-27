# System Architecture & Flow Diagrams

## Overall Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Web Browser (Client)                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │   view_advising_session.html                           │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │            HTML Structure                        │  │    │
│  │  │  - Sidebar Navigation                           │  │    │
│  │  │  - Header with Actions                          │  │    │
│  │  │  - Statistics Dashboard                         │  │    │
│  │  │  - My Sessions Table                            │  │    │
│  │  │  - Pending Requests Table                       │  │    │
│  │  │  - Modals (View, Edit)                          │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  │                                                         │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │        JavaScript Functions                      │  │    │
│  │  │  - loadSessions()         ← Initial data        │  │    │
│  │  │  - renderMySessions()     ← Render sessions     │  │    │
│  │  │  - renderRequests()       ← Render requests     │  │    │
│  │  │  - viewSession(id)        ← Open details        │  │    │
│  │  │  - editSession(id)        ← Open edit form      │  │    │
│  │  │  - saveEditedSession()    ← Save changes        │  │    │
│  │  │  - deleteSession(id)      ← Delete session      │  │    │
│  │  │  - approveRequest(id)     ← Approve request     │  │    │
│  │  │  - rejectRequest(id)      ← Reject request      │  │    │
│  │  │  - updateStats()          ← Update counts       │  │    │
│  │  │  - applyFilter()          ← Filter data         │  │    │
│  │  │  - Search functionality   ← Real-time search    │  │    │
│  │  │  - Pagination controls    ← Browse pages        │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  │                                                         │    │
│  │  ┌──────────────────────────────────────────────────┐  │    │
│  │  │           CSS Styling                           │  │    │
│  │  │  - Responsive Layout                            │  │    │
│  │  │  - Color Scheme                                 │  │    │
│  │  │  - Animations & Transitions                     │  │    │
│  │  │  - Mobile Optimization                          │  │    │
│  │  └──────────────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
                            ↓↑ Fetch API
┌─────────────────────────────────────────────────────────────────┐
│                  Backend Server (Java)                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │        AdvisorSessionsServlet                         │    │
│  │        GET /api/advisor/sessions                      │    │
│  │  - Validates session & role                          │    │
│  │  - Queries database for advisor's sessions           │    │
│  │  - Returns JSON with sessions                        │    │
│  └────────────────────────────────────────────────────────┘    │
│                            ↓↑                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │      AdvisorSessionUpdateServlet                      │    │
│  │      POST /api/advisor/session/update                │    │
│  │  - Accepts: action, sessionID, meetLink, etc         │    │
│  │  - Validates ownership                               │    │
│  │  - Updates database                                  │    │
│  │  - Returns success/error                             │    │
│  └────────────────────────────────────────────────────────┘    │
│                            ↓↑                                   │
│  ┌────────────────────────────────────────────────────────┐    │
│  │          LogoutServlet                                │    │
│  │          GET/POST /logout                             │    │
│  │  - Terminates session                                 │    │
│  │  - Clears cookies                                     │    │
│  │  - Redirects to login                                 │    │
│  └────────────────────────────────────────────────────────┘    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                            ↓↑ JDBC
┌─────────────────────────────────────────────────────────────────┐
│                      Database (MySQL)                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────┐  ┌──────────────────────────┐    │
│  │  advising_session        │  │  student                 │    │
│  ├──────────────────────────┤  ├──────────────────────────┤    │
│  │ sessionID (PK)           │  │ studentID (PK)           │    │
│  │ title                    │  │ firstName                │    │
│  │ sessionDateTime          │  │ lastName                 │    │
│  │ sessionType              │  │ ...                      │    │
│  │ status                   │  └──────────────────────────┘    │
│  │ notes                    │  ┌──────────────────────────┐    │
│  │ meetLink                 │  │  advisor                 │    │
│  │ advisorID (FK)           │  ├──────────────────────────┤    │
│  │ studentID (FK)           │  │ advisorID (PK)           │    │
│  │ cancelReason             │  │ firstName                │    │
│  │ ...                      │  │ lastName                 │    │
│  └──────────────────────────┘  │ ...                      │    │
│                                 └──────────────────────────┘    │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### 1. Initial Page Load
```
Browser Loads view_advising_session.html
    ↓
DOMContentLoaded event fires
    ↓
JavaScript: loadSessions()
    ↓
Fetch GET /api/advisor/sessions
    ↓
Servlet validates advisor session
    ↓
Query database for sessions
    ↓
Return JSON response
    ↓
Parse response in JavaScript
    ↓
Filter into mySessions[] and sessionRequests[]
    ↓
renderMySessions() - Draw table
    ↓
renderRequests() - Draw table
    ↓
updateStats() - Update counts
    ↓
Page displays with live data
```

### 2. Approve Session Request
```
User clicks "Approve" button
    ↓
JavaScript: approveRequest(sessionID)
    ↓
Prompt: Enter meeting link (optional)
    ↓
Fetch POST /api/advisor/session/update
    {sessionID: 5, action: 'accept', meetLink: 'zoom...'}
    ↓
Servlet receives POST request
    ↓
Validate: User is advisor? Session exists? User owns session?
    ↓
UPDATE advising_session SET status='confirmed', meetLink=?
    ↓
Commit transaction
    ↓
Return JSON: {success: true}
    ↓
JavaScript: Show success message
    ↓
Reload sessions: loadSessions()
    ↓
Request moved from "Requests" table to "My Sessions" table
```

### 3. Edit & Save Session
```
User clicks "Edit" button
    ↓
JavaScript: editSession(sessionID)
    ↓
Modal opens with form pre-filled
    ↓
User modifies fields (title, date, time, etc.)
    ↓
User clicks "Submit"
    ↓
JavaScript: saveEditedSession()
    ↓
Validate: All required fields filled?
    ↓
Combine date + time into ISO format
    ↓
Fetch POST /api/advisor/session/update
    {sessionID: 1, title: '...', sessionType: '...', ...}
    ↓
Servlet receives and validates request
    ↓
UPDATE advising_session SET title=?, sessionType=?, ...
    ↓
Commit transaction
    ↓
Return JSON: {success: true}
    ↓
JavaScript: Close modal
    ↓
Reload: loadSessions()
    ↓
Table updates with new values
```

### 4. Search & Filter
```
User types in search box
    ↓
JavaScript: Search event listener triggers
    ↓
Get filter criteria (status) and search term
    ↓
Filter mySessions[] array:
   - Check status matches
   - Check search term in title, type, notes
    ↓
Create filtered array: filteredMySessions[]
    ↓
Reset to page 1
    ↓
renderMySessions() with filtered data
    ↓
Table updates with matching sessions only
```

## Component Interaction Diagram

```
┌──────────────────────────────────────────────────┐
│         HTML Elements (Display Layer)             │
├──────────────────────────────────────────────────┤
│                                                  │
│  Sidebar  Header  Statistics  Tables  Modals    │
│    │         │         │          │       │     │
│    └─────────┼─────────┼──────────┼───────┘     │
│              │         │          │              │
│              v         v          v              │
├──────────────────────────────────────────────────┤
│   JavaScript Functions (Business Logic Layer)    │
├──────────────────────────────────────────────────┤
│                                                  │
│  Data Loading  │  CRUD Operations  │  Rendering │
│   - loadSessions  - viewSession       - render   │
│   - applyFilter   - editSession       - paginate │
│   - search        - saveSession       - update   │
│                   - deleteSession               │
│                   - approve/reject              │
│                                                  │
│              │             │                     │
│              └─────────────┘                     │
│                    │                             │
│                    v                             │
├──────────────────────────────────────────────────┤
│    Data Management (In-Memory State)             │
├──────────────────────────────────────────────────┤
│                                                  │
│  mySessions[]       sessionRequests[]           │
│  filteredMySessions[] filteredRequests[]        │
│  Current filters    Current page                │
│                                                  │
│              │             │                     │
│              └─────────────┘                     │
│                    │                             │
│                    v                             │
├──────────────────────────────────────────────────┤
│         Fetch API (HTTP Layer)                   │
├──────────────────────────────────────────────────┤
│                                                  │
│  GET /api/advisor/sessions                      │
│  POST /api/advisor/session/update               │
│  GET /logout                                    │
│                                                  │
│              │                                   │
│              v                                   │
├──────────────────────────────────────────────────┤
│       Backend Servlets (Server Layer)            │
├──────────────────────────────────────────────────┤
│                                                  │
│  AdvisorSessionsServlet                         │
│  AdvisorSessionUpdateServlet                    │
│  LogoutServlet                                  │
│                                                  │
│              │                                   │
│              v                                   │
├──────────────────────────────────────────────────┤
│        Database (Persistence Layer)              │
├──────────────────────────────────────────────────┤
│                                                  │
│  advising_session  student  advisor             │
│                                                  │
└──────────────────────────────────────────────────┘
```

## State Management

```
┌─────────────────────────────────────────────┐
│         Application State                    │
├─────────────────────────────────────────────┤
│                                             │
│  Session Data:                              │
│  ├─ mySessions[]        (Confirmed/Complete) │
│  ├─ sessionRequests[]   (Pending)           │
│  │                                          │
│  Filter State:                              │
│  ├─ currentMySessionFilter   (status)       │
│  ├─ currentRequestFilter     (status)       │
│  │                                          │
│  Search State:                              │
│  ├─ filteredMySessions[] (search results)  │
│  ├─ filteredRequests[]   (search results)  │
│  │                                          │
│  Pagination State:                          │
│  ├─ currentPageMySessions    (page number)  │
│  ├─ currentPageRequests      (page number)  │
│  │                                          │
│  UI State:                                  │
│  ├─ Modal visibility        (shown/hidden)  │
│  ├─ Loading indicators      (loading)       │
│  ├─ Error messages          (displayed)     │
│                                             │
└─────────────────────────────────────────────┘
     ↑ Updated by Functions ↓ Renders to DOM
```

## User Interaction Flow

```
┌─────────────────────────────────────────────────┐
│         User Actions                            │
├─────────────────────────────────────────────────┤
│                                                 │
│  View           Edit          Delete            │
│    │              │              │              │
│    v              v              v              │
│  View Modal    Edit Modal    Confirm Dialog    │
│    │              │              │              │
│    │              │              v              │
│    │              │         API: Delete         │
│    │              │              │              │
│    │              v              │              │
│    │          API: Update        │              │
│    │              │              │              │
│    └──────────────┼──────────────┘              │
│                   v                             │
│              Reload Data                        │
│                   │                             │
│                   v                             │
│           Re-render Tables                      │
│                   │                             │
│                   v                             │
│           Update Statistics                     │
│                                                 │
│  Approve        Reject        Search            │
│    │              │              │              │
│    v              v              v              │
│  Prompt 1      Prompt 2      Filter & Render   │
│    │              │              │              │
│    v              v              v              │
│  API Call      API Call      No API Call        │
│    │              │              │              │
│    └──────────────┼──────────────┘              │
│                   v                             │
│              Reload Data (if needed)            │
│                   │                             │
│                   v                             │
│           Re-render Affected Table              │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Error Handling Flow

```
┌────────────────────────────────────────┐
│      API Call Made                     │
├────────────────────────────────────────┤
│              │                         │
│              v                         │
│    ┌──────────────────┐               │
│    │ Network Error?   │               │
│    └────┬─────────────┘               │
│         │Yes         │No              │
│         v            v                │
│     Catch       Response OK?          │
│     Block       ┌────┬────┐           │
│     │           │Yes │No  │           │
│     │           v    v    │           │
│     │       Parse JSON    │           │
│     │           │    v    │           │
│     │           │   Has error?       │
│     │           │    │    │           │
│     │           │    v    v           │
│     │           │   Success  Error   │
│     │           │    │       │        │
│     │           └────┼───────┘        │
│     │                v                │
│     └──────────> Alert User           │
│                  Log to Console       │
│                  Clear UI             │
│                                       │
└────────────────────────────────────────┘
```

## Table Rendering Pipeline

```
┌──────────────────────────────────────────┐
│      Render Function Called              │
├──────────────────────────────────────────┤
│              │                           │
│              v                           │
│       Get tbody element                  │
│              │                           │
│              v                           │
│    Clear existing rows                   │
│              │                           │
│              v                           │
│  Calculate start & end index             │
│      (pagination)                        │
│              │                           │
│              v                           │
│    Get page slice of data                │
│              │                           │
│              v                           │
│    Any rows to show?                     │
│      │Yes        │No                     │
│      v           v                       │
│   Loop        Empty State                │
│   Rows        Message                    │
│      │                                   │
│      v                                   │
│  Create TR                               │
│  Create TDs                              │
│  Format data                             │
│  Add event listeners                     │
│  Insert row in tbody                     │
│      │                                   │
│      └────────> Repeat for each row      │
│                 │                        │
│                 v                        │
│           Table Complete                 │
│                 │                        │
│                 v                        │
│       renderPagination()                 │
│                                          │
└──────────────────────────────────────────┘
```

## Session Status Transitions

```
                    ┌─────────────┐
                    │   PENDING   │ ← Student creates request
                    └──┬──────┬───┘
                       │      │
        ┌──────────────┘      └────────────────┐
        │ (approve)                (reject)     │
        v                                      v
   ┌────────────┐                        ┌─────────┐
   │ CONFIRMED  │ ← Advisor approves    │ DENIED  │
   └────┬───────┘                        └─────────┘
        │
        │ (after meeting)
        v
   ┌───────────┐
   │ COMPLETED │
   └───────────┘

   Separate flow for cancellations:
   ┌────────────┐     (cancel)      ┌──────────────────┐
   │ CONFIRMED  ├─────────────────→ │ CANCEL_REQUESTED │
   └────────────┘                   └────┬─────────────┘
                                         │
                          ┌──────────────┴──────────────┐
                          │ (advisor approve)          │
                          v                            v
                    ┌───────────────┐            ┌──────────┐
                    │   CANCELLED   │            │  DENIED  │
                    └───────────────┘            └──────────┘
```

## Responsive Design Breakpoints

```
Desktop (1200px+)
├─ Full sidebar width (260px)
├─ All table columns visible
├─ Side-by-side layout
└─ Full filter buttons

Tablet (768px - 1199px)
├─ Narrow sidebar (70px, icons only)
├─ Adjusted column widths
├─ Stacked layout options
└─ Responsive buttons

Mobile (< 768px)
├─ Hidden sidebar (menu button)
├─ Single column layout
├─ Collapsed tables
└─ Touch-friendly buttons (44px min)
```

---

## Key Takeaways

1. **Multi-layer architecture** separates concerns clearly
2. **Fetch API** handles all client-server communication
3. **In-memory state** enables fast filtering and search
4. **Event-driven** design for responsive UX
5. **Robust error handling** at every level
6. **Database-backed** for persistent data

This architecture is:
- ✅ Scalable (can handle more sessions)
- ✅ Maintainable (clear separation of concerns)
- ✅ Performant (client-side filtering is fast)
- ✅ Reliable (error handling at every step)
- ✅ Extensible (easy to add features)
