/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.advising.model;

/**
 *
 * @author Xander
 */

public class StudentProgress {
    private int progressID;
    private int semester;
    private String grade;
    private String status;
    private int courseID;
    private String studentID;

    public StudentProgress() {}

    // Getters and Setters
    public int getProgressID() { return progressID; }
    public void setProgressID(int progressID) { this.progressID = progressID; }
    public int getSemester() { return semester; }
    public void setSemester(int semester) { this.semester = semester; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public int getCourseID() { return courseID; }
    public void setCourseID(int courseID) { this.courseID = courseID; }
    public String getStudentID() { return studentID; }
    public void setStudentID(String studentID) { this.studentID = studentID; }
}
