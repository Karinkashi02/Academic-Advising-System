-- Migration: Add session_participant junction table for multi-student support
-- This allows multiple students to participate in a single advising session
-- Apache Derby version

-- Step 1: Create the junction table
-- Note: studentID is VARCHAR (string), sessionID is INT
CREATE TABLE session_participant (
    participantID INT GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1) PRIMARY KEY,
    sessionID INT NOT NULL,
    studentID VARCHAR(50) NOT NULL,
    joinedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_session FOREIGN KEY (sessionID) REFERENCES advising_session(sessionID) ON DELETE CASCADE,
    CONSTRAINT unique_participant UNIQUE (sessionID, studentID)
);

-- Step 2: Create indexes for performance (must be after table creation)
CREATE INDEX idx_session_participant_sessionID ON session_participant(sessionID);
CREATE INDEX idx_session_participant_studentID ON session_participant(studentID);

-- Step 3: Migrate existing data: Create participants from advising_session.studentID
-- This ensures existing 1-on-1 sessions are properly represented
INSERT INTO session_participant (sessionID, studentID)
SELECT sessionID, studentID FROM advising_session 
WHERE studentID IS NOT NULL AND TRIM(studentID) <> ''
  AND NOT EXISTS (
    SELECT 1 FROM session_participant sp 
    WHERE sp.sessionID = advising_session.sessionID 
      AND sp.studentID = advising_session.studentID
  );

-- Optional: Add a comment to the advising_session table explaining the relationship
-- ALTER TABLE advising_session COMMENT = 'Sessions can now have multiple participants via session_participant junction table';

-- Verification query - shows all sessions with their participants
-- SELECT 
--     s.sessionID, 
--     s.title, 
--     s.sessionDateTime,
--     COUNT(sp.participantID) as participant_count,
--     GROUP_CONCAT(CONCAT(st.firstName, ' ', st.lastName) SEPARATOR ', ') as students
-- FROM advising_session s
-- LEFT JOIN session_participant sp ON s.sessionID = sp.sessionID
-- LEFT JOIN student st ON sp.studentID = st.studentID
-- GROUP BY s.sessionID
-- ORDER BY s.sessionDateTime DESC;
