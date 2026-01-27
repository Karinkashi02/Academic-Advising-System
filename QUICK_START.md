# Quick Start Guide - View Advising Session

## 5-Minute Setup

### Step 1: Verify Backend is Running
```bash
# Check if servlets are deployed and server is running
curl http://localhost:8080/api/advisor/sessions
```

You should see a JSON response with sessions.

### Step 2: Open the Page
Navigate to:
```
http://localhost:8080/Advisor/view_advising_session.html
```

### Step 3: Check Browser Console
Press `F12` to open Developer Tools and click on **Console** tab.

You should see no red errors. If there are errors, check:
1. Are servlets accessible?
2. Is user logged in (has session)?
3. Does database have session records?

### Step 4: Verify Data Loads
You should see:
- Statistics cards with numbers
- "My Advising Sessions" table with sessions
- "Session Requests for Review" table with pending requests

## Common First-Time Issues & Solutions

### Issue 1: "No sessions found"
**Problem**: Tables are empty

**Solution**:
1. Check if database has data:
```sql
SELECT COUNT(*) FROM advising_session;
SELECT COUNT(*) FROM advising_session WHERE advisorID = '${currentAdvisorID}';
```

2. If no data, create test data:
```sql
INSERT INTO advising_session (title, sessionDateTime, sessionType, status, advisorID, studentID) 
VALUES ('Test Session', NOW(), 'Academic', 'confirmed', 'ADV001', 'STU001');
```

### Issue 2: "Error 401 - Not authenticated"
**Problem**: Session/authentication issue

**Solution**:
1. Log in first via login page
2. Check that session cookie exists (DevTools > Application > Cookies)
3. Verify servlet has `request.getSession()` call

### Issue 3: "Failed to load sessions"
**Problem**: API endpoint not accessible

**Solution**:
1. Check servlet URL: Should be `/api/advisor/sessions`
2. Test with curl:
```bash
curl -H "Cookie: JSESSIONID=..." http://localhost:8080/api/advisor/sessions
```
3. Check servlet mapping in web.xml:
```xml
<url-pattern>/api/advisor/sessions</url-pattern>
```

### Issue 4: Buttons don't respond
**Problem**: JavaScript not working

**Solution**:
1. Check browser console for errors (F12)
2. Verify JavaScript is enabled
3. Check if modals are defined (search for "modal" in HTML)

## Testing the Features

### Test 1: Load Sessions
```javascript
// In browser console:
loadSessions()
```
Sessions should reload and display.

### Test 2: View Session Details
```javascript
// Click "View" button on any session
// Or in console:
viewSession(1)  // Replace 1 with actual session ID
```
Modal should appear with session details.

### Test 3: Edit Session
```javascript
// Click "Edit" button or:
editSession(1)
// Fill form and click Submit
```
Session should update in database and table.

### Test 4: Approve Request
```javascript
// Click "Approve" button on any request
// When prompted, enter a meeting link (or leave empty)
```
Request status should change to "confirmed".

### Test 5: Search
```javascript
// Type in search box
// Sessions should filter in real-time
```

### Test 6: Pagination
```javascript
// If more than 8 items exist
// Pagination buttons should appear at bottom
// Click "Next" to go to page 2
```

## Debugging Tips

### See all sessions data:
```javascript
console.table(mySessions)
console.table(sessionRequests)
```

### See all API calls:
Open DevTools → Network tab → All

Then perform any action to see the API request and response.

### Track a specific session:
```javascript
const session = mySessions.find(s => s.sessionID === 5);
console.log(session);
```

### Manually test API endpoint:
```bash
curl -X GET \
  -H "Cookie: JSESSIONID=YOUR_SESSION_ID" \
  http://localhost:8080/api/advisor/sessions
```

### Check if context path is correct:
```javascript
console.log('Context:', ctx);
// Should be empty or '/yourappname'
```

## Quick Configuration Changes

### Change items per page (from 8 to 10):
Find these lines and change the number:
```javascript
const sessionsPerPage = 8;  // Change to 10
const requestsPerPage = 8;   // Change to 10
```

### Add automatic refresh every 30 seconds:
Add to DOMContentLoaded event:
```javascript
setInterval(loadSessions, 30 * 1000);
```

### Change table header colors:
Modify CSS variable:
```css
:root {
    --blue-primary: #3498db;  /* Change this color */
}
```

## Performance Tips

### For Large Datasets (1000+ sessions):
1. Implement server-side pagination in servlet
2. Add lazy loading instead of loading all sessions
3. Filter by date range on server

### For Slow Network:
1. Add loading spinner while fetching
2. Implement request caching
3. Add retry logic for failed requests

### For Better UX:
1. Add toast notifications
2. Show last sync time
3. Add offline indicator

## Security Checklist

Before going to production:

- [ ] Verify all inputs are validated on server
- [ ] Check CSRF tokens are implemented
- [ ] Ensure HTTPS is enabled
- [ ] Verify session timeout is set
- [ ] Check that users can only see their own sessions
- [ ] Test with SQL injection attempts
- [ ] Test with large/malicious data

## Monitoring in Production

### Key metrics to monitor:
1. API response time (should be < 500ms)
2. Session data accuracy
3. Error rate (should be < 0.1%)
4. User actions per session
5. Failed API calls

### Set up logging:
```javascript
// Add to loadSessions():
console.log(`[${new Date().toISOString()}] Loading sessions...`);
console.log(`Loaded ${mySessions.length} sessions`);
```

## Next Steps

1. **Test thoroughly** with your data
2. **Check documentation** if you need more info
3. **Customize styling** to match your brand
4. **Add notifications** for better UX
5. **Implement analytics** to track usage
6. **Plan enhancements** based on user feedback

## Getting Help

### If something breaks:
1. Check browser console (F12) for errors
2. Check network tab for API failures
3. Review documentation files
4. Check database logs
5. Look at server logs

### Documentation Files:
- `INTEGRATION_GUIDE.md` - For API & function details
- `CODE_REFERENCE.md` - For code snippets
- `UPDATES_SUMMARY.md` - For change list
- `COMPLETION_REPORT.md` - For full details

## Success Indicators

You'll know it's working when you see:

✅ Sessions load on page open
✅ Statistics show correct numbers
✅ Approve/reject buttons work
✅ Edit modal opens and saves
✅ Search filters results
✅ Pagination appears with 8+ items
✅ No red errors in console
✅ API calls succeed (status 200)

---

**That's it! You're ready to go.** 

For more details, see the comprehensive documentation files.
