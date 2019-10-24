@isTest
private with sharing class LoadDataTest {
    
    @isTest
    private static void testSomething() { 
        //MASHPeople needs to be uploaded as static resource
        LoadData.loadContacts();
        List<Contact> contacts = [SELECT Id FROM Contact];
        System.assertEquals(20, contacts.size());
        LoadData.loadPrograms();
        List<Program__c> programs = [SELECT Id FROM Program__c];
        System.assertEquals(4, programs.size());
        List<Program_Registration__c> registrations = [SELECT Id FROM Program_Registration__c];
        System.assertEquals(36, registrations.size());
        LoadData.loadProgramSessions();
        List<Program_Session__c> sessions = [SELECT Id FROM Program_Session__c];
        System.assertEquals(24, sessions.size());
        LoadData.loadSessionAttendance();
        List<Program_Attendance__c> attendance = [SELECT Id FROM Program_Attendance__c];
        System.assertEquals(148, attendance.size());

    }
}
