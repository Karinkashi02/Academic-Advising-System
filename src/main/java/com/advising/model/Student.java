/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.advising.model;

/**
 *
 * @author Xander
 */

public class Student {
    private String studentID;
    private String username;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
    private String program;
    private String remark;
    private int yearOfStudy;
    private int semester;
    private int advisorID;
    private String phoneNum;
    private double cgpa;
    private int creditsCompleted;

    public Student() {}

    public String getStudentID() { return studentID; }
    public void setStudentID(String studentID) { this.studentID = studentID; }

    public String getUsername() { return username; }
    public void setName(String uname) { this.username = uname; }

    public String getName() { 
        String f = firstName == null ? "" : firstName;
        String l = lastName == null ? "" : lastName;
        return (f + " " + l).trim();
    }

    public String getfirstName() { return firstName; }
    public void setfirstName(String fname) { this.firstName = fname; }

    public String getlastName() { return lastName; }
    public void setlastName(String lname) { this.lastName = lname; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getProgram() { return program; }
    public void setProgram(String program) { this.program = program; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public int getYearOfStudy() { return yearOfStudy; }
    public void setYearOfStudy(int yearOfStudy) { this.yearOfStudy = yearOfStudy; }
    public int getSemester() { return semester; }
    public void setSemester(int semester) { this.semester = semester; }
    public int getAdvisorID() { return advisorID; }
    public void setAdvisorID(int advisorID) { this.advisorID = advisorID; }

    public String getPhoneNum() { return phoneNum; }
    public void setPhoneNum(String phoneNum) { this.phoneNum = phoneNum; }

    public double getCgpa() { return cgpa; }
    public void setCgpa(double cgpa) { this.cgpa = cgpa; }

    public int getCreditsCompleted() { return creditsCompleted; }
    public void setCreditsCompleted(int creditsCompleted) { this.creditsCompleted = creditsCompleted; }
}