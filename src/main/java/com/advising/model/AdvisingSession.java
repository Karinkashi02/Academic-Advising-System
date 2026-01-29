/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.advising.model;

/**
 *
 * @author Xander
 */

public class AdvisingSession {
    private int sessionID;
    private String title;
    private String sessionDate; // String or java.sql.Date
    private String sessionTime;
    private String status;
    private String notes;
    private String meetLink;
    private String sessionType;
    private String location;
    private String advisorID;
    private String studentID;

    public AdvisingSession() {}

    // Getters and Setters
    public int getSessionID() { return sessionID; }
    public void setSessionID(int sessionID) { this.sessionID = sessionID; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getSessionDate() { return sessionDate; }
    public void setSessionDate(String sessionDate) { this.sessionDate = sessionDate; }
    public String getSessionTime() { return sessionTime; }
    public void setSessionTime(String sessionTime) { this.sessionTime = sessionTime; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getMeetLink() { return meetLink; }
    public void setMeetLink(String meetLink) { this.meetLink = meetLink; }
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    public String getSessionType() { return sessionType; }
    public void setSessionType(String sessionType) { this.sessionType = sessionType; }
    public String getAdvisorID() { return advisorID; }
    public void setAdvisorID(String advisorID) { this.advisorID = advisorID; }
    public String getStudentID() { return studentID; }
    public void setStudentID(String studentID) { this.studentID = studentID; }
}
