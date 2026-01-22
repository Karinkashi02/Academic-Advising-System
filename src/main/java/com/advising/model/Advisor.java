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
    private int advisorID;
    private String username;
    private String firstName;
    private String lastName;
    private String email;
    private String password;
    private String phoneNum;
    private String department;
    private String expertise;
    private String officeHours;
    private String officeLoc;
    private int numSTD;
    private int maxSTD;

    public Advisor() {}

    // Getters and Setters
    public int getAdvisorID() { return advisorID; }
    public void setAdvisorID(int advisorID) { this.advisorID = advisorID; }
    
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
    
    public int getMaxSTD() { return maxSTD; }
    public void setMaxSTD(int max) { this.maxSTD = max; }
    public int getNumSTD() { return numSTD; }
    public void setNumSTD(int nSTD) { this.numSTD = nSTD; }
}