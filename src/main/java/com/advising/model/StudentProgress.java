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
    private String name;
    private String program;
    private int semester;
    private String grade;
    private String status;
    private String studentID;

    public StudentProgress() {}

    // Getters and Setters
    public int getProgressID() { return progressID; }
    public void setProgressID(int progressID) { this.progressID = progressID; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }
    public int getSemester() { return semester; }
    public void setSemester(int semester) { this.semester = semester; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getStudentID() { return studentID; }
    public void setStudentID(String studentID) { this.studentID = studentID; }
}
