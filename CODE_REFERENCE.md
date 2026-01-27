# View Advising Session - Code Reference

## Quick Copy-Paste Solutions

### Test the Integration Locally

1. **Check if servlets are working** (Browser Console):
```javascript
fetch(ctx + '/api/advisor/sessions')
    .then(r => r.json())
    .then(d => console.log(d))
    .catch(e => console.error(e));
```

2. **Manually trigger session load**:
```javascript
loadSessions();
```

3. **View current data**:
```javascript
console.table(mySessions);
console.table(sessionRequests);
```

### Debug Common Issues

**Check if context path is correct**:
```javascript
console.log('Context path:', ctx);
```

**Check if API is returning data**:
```javascript
// In browser console
fetch(ctx + '/api/advisor/sessions')
    .then(r => r.json())
    .then(d => {
        console.log('Success:', d);
        console.log('Session count:', d.sessions.length);
    })
    .catch(e => console.error('Error:', e));
```

**Verify session filtering**:
```javascript
// See what's in each category
console.log('My Sessions:', mySessions.length);
console.log('Requests:', sessionRequests.length);
mySessions.forEach(s => console.log(s.sessionID, s.status, s.title));
sessionRequests.forEach(s => console.log(s.sessionID, s.status, s.title));
```

### Manually Trigger Actions (for testing)

**Approve a request**:
```javascript
approveRequest(5); // Replace 5 with actual session ID
```

**Reject a request**:
```javascript
rejectRequest(5); // Replace 5 with actual session ID
```

**Edit a session**:
```javascript
editSession(1); // Replace 1 with actual session ID
// Then fill in form and click Submit
```

**Delete a session**:
```javascript
deleteSession(1); // Replace 1 with actual session ID
```

**Force data reload**:
```javascript
loadSessions();
```

### Common Code Modifications

**Change pagination size** (default 8):
```javascript
// Find these lines:
const sessionsPerPage = 8;
const requestsPerPage = 8;

// Change to:
const sessionsPerPage = 10;  // Show 10 per page
const requestsPerPage = 10;
```

**Change status filter options**:
```html
<!-- Find this in HTML -->
<button class="filter-btn" data-status="pending">Pending</button>

<!-- Add more status buttons -->
<button class="filter-btn" data-status="scheduled">Scheduled</button>
<button class="filter-btn" data-status="completed">Completed</button>
```

**Add automatic refresh every 5 minutes**:
```javascript
// Add to DOMContentLoaded:
setInterval(loadSessions, 5 * 60 * 1000); // 5 minutes in milliseconds
```

**Log all API calls for debugging**:
```javascript
// Replace fetch calls with this wrapper:
async function fetchWithLogging(url, options = {}) {
    console.log('API Call:', url, options);
    const res = await fetch(url, options);
    const data = await res.json();
    console.log('API Response:', data);
    return { ok: res.ok, status: res.status, data };
}

// Usage:
const { ok, data } = await fetchWithLogging(ctx + '/api/advisor/sessions');
```

## Database Query Examples

If you need to check data directly in the database:

```sql
-- View all sessions for an advisor
SELECT * FROM advising_session 
WHERE advisorID = 'ADV001' 
ORDER BY sessionDateTime DESC;

-- View pending requests
SELECT s.*, st.firstName, st.lastName 
FROM advising_session s
LEFT JOIN student st ON s.studentID = st.studentID
WHERE s.status IN ('pending', 'cancel_requested')
ORDER BY s.sessionDateTime;

-- Count sessions by status
SELECT status, COUNT(*) as count 
FROM advising_session 
WHERE advisorID = 'ADV001'
GROUP BY status;

-- View confirmed sessions with student details
SELECT s.sessionID, s.title, s.sessionDateTime, 
       st.firstName, st.lastName, s.status
FROM advising_session s
LEFT JOIN student st ON s.studentID = st.studentID
WHERE s.advisorID = 'ADV001' AND s.status = 'confirmed'
ORDER BY s.sessionDateTime;
```

## HTML Element IDs Reference

### Form Inputs (Edit Modal)
```javascript
editSessionId              // Hidden input storing session ID
editSessionName            // Session title input
editSessionType            // Session type select
editSessionDate            // Date input (YYYY-MM-DD)
editSessionTime            // Time input (HH:MM)
editSessionDuration        // Duration input
editSessionLocation        // Meeting link input
editSessionStatus          // Status select
editSessionNotes           // Notes textarea
```

### Display Elements (View Modal)
```javascript
viewSessionName            // Session name display
viewSessionType            // Session type display
viewSessionDate            // Date display
viewSessionTime            // Time display
viewSessionDuration        // Duration display
viewSessionLocation        // Location/link display
viewSessionStatus          // Status badge
viewSessionNotes           // Notes display
viewSessionStudents        // Student list container
```

### Table Bodies
```javascript
mySessionsTableBody        // Advisor's sessions table
requestsTableBody          // Pending requests table
```

### Statistics
```javascript
'total-sessions'           // Total session count
'pending-count'            // Pending requests count
'approved-count'           // Confirmed sessions count
'rejected-count'           // Completed sessions count
```

### Search & Filter
```javascript
searchMySessions           // Search box for My Sessions
searchRequests             // Search box for Requests
mySessionsCard             // My Sessions section
requestsCard               // Requests section
```

### Pagination
```javascript
mySessionsPagination       // My Sessions pagination container
requestsPagination         // Requests pagination container
```

## Useful JavaScript Patterns

**Find a session by ID**:
```javascript
const session = mySessions.find(s => s.sessionID === 5);
console.log(session);
```

**Get all pending sessions**:
```javascript
const pending = sessionRequests.filter(r => r.status === 'pending');
console.log(pending);
```

**Count sessions by status**:
```javascript
const counts = {};
mySessions.forEach(s => {
    counts[s.status] = (counts[s.status] || 0) + 1;
});
console.log(counts);
```

**Format datetime for display**:
```javascript
function formatSessionDateTime(isoString) {
    const ts = new Date(isoString.replace(' ', 'T'));
    return {
        date: ts.toLocaleDateString('en-US', { 
            year: 'numeric', month: 'long', day: 'numeric'
        }),
        time: ts.toLocaleTimeString('en-US', { 
            hour: 'numeric', minute: '2-digit', hour12: true
        })
    };
}

const formatted = formatSessionDateTime('2025-02-15T14:30:00');
console.log(formatted.date, formatted.time);
```

**Parse form date/time back to ISO**:
```javascript
function combineDateTime(dateStr, timeStr) {
    return `${dateStr}T${timeStr}:00`;
}

const datetime = combineDateTime('2025-02-15', '14:30');
console.log(datetime); // 2025-02-15T14:30:00
```

## Testing Checklist for Developers

- [ ] Verify sessions load on page load
- [ ] Confirm sessions split correctly (My Sessions vs Requests)
- [ ] Test viewing session details
- [ ] Test editing session and saving
- [ ] Test deleting session
- [ ] Test approving pending request
- [ ] Test rejecting pending request
- [ ] Verify statistics update correctly
- [ ] Test pagination on both tables
- [ ] Test search functionality
- [ ] Test filter buttons
- [ ] Test logout button
- [ ] Check browser console for errors
- [ ] Test with various session statuses
- [ ] Test with empty data sets
- [ ] Test response error handling
- [ ] Test network errors

## API Error Response Examples

**Authentication error**:
```json
{
  "error": "Not authenticated as advisor"
}
```

**Validation error**:
```json
{
  "error": "sessionID and action required"
}
```

**Not found error**:
```json
{
  "error": "Session not found"
}
```

**Permission error**:
```json
{
  "error": "Not allowed to modify this session"
}
```

**Database error**:
```json
{
  "error": "Database error"
}
```

## Common Bugs and Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| Sessions not loading | API endpoint not accessible | Check servlet URL and server status |
| Data displays but buttons don't work | Missing session ID | Ensure sessionID is passed in data attribute |
| Modal won't close | Close button event not attached | Check DOMContentLoaded is firing |
| Pagination not showing | Data length <= page size | Render pagination only if totalPages > 1 |
| Search not working | Case sensitivity issue | Filter uses `.toLowerCase()` - working as designed |
| Date parsing fails | Format mismatch | Use `.replace(' ', 'T')` for MySQL datetime |
| Filter buttons stay active | Missing class removal | Clear active class from all buttons before adding |
| Stats show wrong counts | Using wrong status names | Verify status values match database exactly |

## Performance Optimization Ideas

1. **Lazy load session details** instead of fetching all data upfront
2. **Implement virtual scrolling** for large lists
3. **Add search debouncing** to avoid excessive filtering
4. **Cache API responses** with a 5-minute TTL
5. **Use IndexedDB** for offline-first approach
6. **Implement progressive enhancement** for older browsers
7. **Add service worker** for PWA functionality

## Mobile Optimization

The page is responsive, but for better mobile experience:

1. Add touch-friendly button sizing (min 44x44px)
2. Implement swipe gestures for pagination
3. Use native date/time pickers
4. Stack tables vertically on small screens
5. Collapse filter buttons into dropdown on mobile

## Accessibility Improvements

1. Add ARIA labels to buttons
2. Ensure color contrast meets WCAG AA
3. Add keyboard navigation support
4. Implement focus management in modals
5. Add loading states for async operations
6. Use semantic HTML elements

## Localization Support

The page uses English hardcoded. To support multiple languages:

1. Extract all strings to a language object:
```javascript
const i18n = {
    en: {
        'session.pending': 'Pending',
        'action.approve': 'Approve',
        'action.reject': 'Reject'
    },
    es: {
        'session.pending': 'Pendiente',
        'action.approve': 'Aprobar',
        'action.reject': 'Rechazar'
    }
};
```

2. Replace hardcoded strings with i18n lookups:
```javascript
statusText = i18n[currentLanguage]['session.pending'];
```
