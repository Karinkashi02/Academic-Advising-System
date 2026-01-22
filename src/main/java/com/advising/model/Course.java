/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.advising.model;

/**
 *
 * @author Xander
 */
public class Course {
    private String courseID;
    private String name;
    private int creditHour;
    private String remark;
    private String program;

    public Course() {}
    // Getters and Setters...
    public String getCourseID() { return courseID; }
    public void setCourseID(String courseID) { this.courseID = courseID; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getCreditHour() { return creditHour; }
    public void setCreditHour(int creditHour) { this.creditHour = creditHour; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }
}
