/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.advising.model;

/**
 *
 * @author Xander
 */

public class Advisor {
    private String advisorID;
    private String name;
    private String email;
    private String password;
    private String phoneNum;
    private String department;
    private String expertise;
    private String officeHours;
    private String officeLoc;

    public Advisor() {}

    // Getters and Setters
    public String getAdvisorID() { return advisorID; }
    public void setAdvisorID(String advisorID) { this.advisorID = advisorID; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPhoneNum() { return phoneNum; }
    public void setPhoneNum(String phoneNum) { this.phoneNum = phoneNum; }
    public String getDepartment() { return department; }
    public void setDepartment(String department) { this.department = department; }
    public String getExpertise() { return expertise; }
    public void setExpertise(String expertise) { this.expertise = expertise; }
    public String getOfficeHours() { return officeHours; }
    public void setOfficeHours(String officeHours) { this.officeHours = officeHours; }
    public String getOfficeLoc() { return officeLoc; }
    public void setOfficeLoc(String officeLoc) { this.officeLoc = officeLoc; }
}