# View Advising Session HTML - Integration Guide

## Quick Start

The `view_advising_session.html` file is now fully integrated with the backend servlets and database. It works with the following flow:

```
Page Load → loadSessions() API Call → Parse Response → Render Tables → User Interactions
                                                          ↓
                                                    Approve/Edit/Delete
                                                      (API Calls)
                                                          ↓
                                                    Reload & Update UI
```

## API Endpoints Used

### 1. GET `/api/advisor/sessions`
**Purpose**: Fetch all advising sessions for the logged-in advisor

**Response Format**:
```json
{
  "sessions": [
    {
      "sessionID": 1,
      "title": "Career Planning Session",
      "sessionDateTime": "2025-02-15T14:30:00",
      "sessionType": "Career",
      "status": "confirmed",
      "notes": "Discussed career path options",
      "meetLink": "https://zoom.us/j/...",
      "studentID": "STU001",
      "studentName": "John Doe",
      "advisorID": "ADV001",
      "cancelReason": null
    }
  ]
}
```

### 2. POST `/api/advisor/session/update`
**Purpose**: Update session status, approve requests, reject requests, or delete sessions

**Parameters**:
- `sessionID` (required): The session to update
- `action` (optional): One of `accept`, `deny`, `delete`
- `meetLink` (optional): Virtual meeting link for approval
- `reason` (optional): Reason for denial/cancellation
- `title`, `sessionType`, `sessionDateTime`, etc. (optional): For editing

**Example Requests**:

Approve a pending request:
```
POST /api/advisor/session/update
sessionID=5&action=accept&meetLink=https://zoom.us/j/123456
```

Reject a request:
```
POST /api/advisor/session/update
sessionID=5&action=deny&reason=Schedule%20conflict
```

Update session details:
```
POST /api/advisor/session/update
sessionID=1&title=New%20Title&sessionType=Academic&meetLink=https://...
```

Delete a session:
```
POST /api/advisor/session/update
sessionID=1&action=delete
```

### 3. GET `/logout`
**Purpose**: Terminate advisor session and redirect to login

## JavaScript Functions Reference

### Core Functions

#### `loadSessions()`
- **Purpose**: Load sessions from server and populate tables
- **Calls**: `GET /api/advisor/sessions`
- **Filters**: Separates sessions into `mySessions` (confirmed/completed) and `sessionRequests` (pending)
- **Side Effects**: Updates page statistics and renders both tables

#### `viewSession(sessionId)`
- **Purpose**: Display session details in a modal
- **Parameters**: Session ID from database
- **Shows**: Full session information including student details
- **Stores**: SessionID in modal for later operations

#### `editSession(sessionId)`
- **Purpose**: Open edit modal with session data pre-populated
- **Parameters**: Session ID from database
- **Behavior**: Parses datetime for form inputs

#### `saveEditedSession()`
- **Purpose**: Save edited session to database
- **Calls**: `POST /api/advisor/session/update`
- **Validation**: Requires title, type, date, time
- **Side Effects**: Reloads all sessions after successful save

#### `deleteSession(sessionId)`
- **Purpose**: Delete session with confirmation
- **Calls**: `POST /api/advisor/session/update` with `action=delete`
- **Side Effects**: Reloads sessions after deletion

#### `approveRequest(sessionId)`
- **Purpose**: Approve a pending session request
- **Calls**: `POST /api/advisor/session/update` with `action=accept`
- **Input**: Prompts for optional meeting link
- **Side Effects**: Changes status to "confirmed", reloads sessions

#### `rejectRequest(sessionId)`
- **Purpose**: Reject a pending session request
- **Calls**: `POST /api/advisor/session/update` with `action=deny`
- **Input**: Prompts for optional rejection reason
- **Side Effects**: Changes status to "denied", reloads sessions

#### `renderMySessions()`
- **Purpose**: Render advisor's sessions in the first table
- **Input**: `filteredMySessions` array and current page
- **Output**: Populates `mySessionsTableBody` with HTML rows

#### `renderRequests()`
- **Purpose**: Render pending session requests in the second table
- **Input**: `filteredRequests` array and current page
- **Output**: Populates `requestsTableBody` with HTML rows

#### `updateStats()`
- **Purpose**: Update dashboard statistics
- **Input**: `mySessions` and `sessionRequests` arrays
- **Updates**:
  - `total-sessions`: Sum of all sessions
  - `pending-count`: Pending/cancel-requested sessions
  - `approved-count`: Confirmed/scheduled sessions
  - `rejected-count`: Completed sessions

### Data Management

#### Global Arrays
```javascript
let mySessions = [];          // Advisor's confirmed/completed sessions
let sessionRequests = [];     // Pending requests requiring action
let filteredMySessions = [];  // Currently displayed sessions (after filtering)
let filteredRequests = [];    // Currently displayed requests (after filtering)
```

#### Pagination Variables
```javascript
let currentPageMySessions = 1;
let currentPageRequests = 1;
const sessionsPerPage = 8;
const requestsPerPage = 8;
```

#### Filter Variables
```javascript
let currentMySessionFilter = 'all';
let currentRequestFilter = 'all';
```

## Event Listeners

The following events are automatically handled:

1. **Page Load**: `loadSessions()` called via `DOMContentLoaded`
2. **Filter Buttons**: Status filtering in both tables
3. **Search Boxes**: Real-time search as user types
4. **Pagination Buttons**: Navigate between pages
5. **Action Buttons**: View, Edit, Delete, Approve, Reject
6. **Header Actions**: Profile, Logout, Search focus
7. **Modal Close**: Clicking close buttons or overlay

## Status Mapping

### Session Statuses in Database

| Status | Display | CSS Class | Location |
|--------|---------|-----------|----------|
| `confirmed` | Confirmed | `status-upcoming` | My Sessions |
| `scheduled` | Confirmed | `status-upcoming` | My Sessions |
| `completed` | Completed | `status-completed` | My Sessions |
| `cancelled` | Cancelled | `status-cancelled` | My Sessions |
| `denied` | Denied | `status-cancelled` | My Sessions |
| `pending` | Pending | `status-pending` | Requests |
| `cancel_requested` | Cancel Request | `status-pending` | Requests |

## Date/Time Handling

### Database Format
ISO 8601: `2025-02-15T14:30:00`

### HTML Input Format
- Date input: `YYYY-MM-DD`
- Time input: `HH:MM` (24-hour)

### Display Format
- Date: `Saturday, February 15, 2025`
- Time: `2:30 PM`

### Parsing Code
```javascript
// Parse from database
const ts = new Date(String(session.sessionDateTime).replace(' ', 'T'));

// Format for display
const formattedDate = ts.toLocaleDateString('en-US', { 
    year: 'numeric', month: 'long', day: 'numeric', weekday: 'long'
});
const formattedTime = ts.toLocaleTimeString('en-US', { 
    hour: 'numeric', minute: '2-digit', hour12: true
});

// Combine for API call
const sessionDateTime = `${dateStr}T${timeStr}:00`;
```

## Error Handling

All API calls include error handling:

```javascript
try {
    const response = await fetch(endpoint, options);
    const data = await response.json();
    if (!response.ok || data.error) {
        alert('Error: ' + (data.error || 'Unknown error'));
        return;
    }
    // Success handling
} catch (e) {
    console.error('Error:', e);
    alert('Error: ' + e.message);
}
```

## Context Path Helper

The application automatically detects the context path:

```javascript
const ctx = (function(){
    const p = window.location.pathname.split('/').filter(Boolean);
    return p.length ? '/' + p[0] : '';
})();

// Usage: fetch(ctx + '/api/advisor/sessions')
```

This works for:
- Local: `/api/advisor/sessions`
- Production: `/advising/api/advisor/sessions` (if deployed as `advising.war`)

## Customization Points

### Add More Session Types
Edit the select dropdown in the Edit Session modal:
```html
<select id="editSessionType">
    <option value="academic">Academic Advising</option>
    <option value="career">Career Counseling</option>
    <!-- Add new types here -->
</select>
```

### Change Items Per Page
```javascript
const sessionsPerPage = 8;  // Change to desired number
const requestsPerPage = 8;  // Change to desired number
```

### Customize Styling
All colors use CSS custom properties defined in `:root`:
```css
--blue-primary: #3498db;
--success-green: #27ae60;
--danger-red: #e74c3c;
--warning: #f39c12;
```

### Add Bulk Operations
The `sessionRequests` array can be easily filtered and updated:
```javascript
function approveAllPending() {
    sessionRequests.forEach(req => approveRequest(req.sessionID));
}
```

## Troubleshooting

### Sessions Not Loading
1. Check browser console for errors
2. Verify `/api/advisor/sessions` endpoint is accessible
3. Check if user is authenticated (session exists)
4. Verify database connection in servlet

### Buttons Not Working
1. Check that session ID is correctly passed
2. Verify onclick attributes have correct function calls
3. Check browser console for JavaScript errors
4. Verify `/api/advisor/session/update` endpoint exists

### Modal Not Closing
1. Verify `closeViewSessionModal()` and `closeEditSessionModal()` functions exist
2. Check modal IDs match in HTML and JavaScript
3. Ensure close button onclick handlers are attached

### Statistics Not Updating
1. Call `updateStats()` after data changes
2. Verify `mySessions` and `sessionRequests` arrays are populated
3. Check HTML element IDs match JavaScript references

## Performance Tips

1. **Caching**: Sessions are loaded once per page load
2. **Pagination**: Only 8 items shown per page to limit DOM size
3. **Filtering**: Client-side filtering is fast for <1000 items
4. **Search**: Uses `filter()` method which is optimized

## Security Considerations

1. **Session Validation**: Server validates advisor ownership before updates
2. **CSRF Protection**: Ensure servlets have CSRF tokens if applicable
3. **Input Validation**: Client validates required fields before submission
4. **Server-Side Validation**: Server must validate all input parameters

## Browser DevTools Tips

Monitor network requests:
1. Open DevTools (F12)
2. Go to Network tab
3. Perform actions to see API calls
4. Click request to see headers and response

Check local state:
1. Open DevTools Console
2. Type `mySessions` to see loaded sessions
3. Type `sessionRequests` to see pending requests
4. Type `currentMySessionFilter` to see filter state
