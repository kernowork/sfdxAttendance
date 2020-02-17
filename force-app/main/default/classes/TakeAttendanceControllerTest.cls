@isTest
public class TakeAttendanceControllerTest {

    @isTest static void TestGetRegistrations() {
        
        Program__c wineClass = makeClass();
        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, wineClass);
        Test.startTest();
        List<Program_Registration__c> regsFound = TakeAttendanceController.getRegistrations(wineClass.Id);
        System.AssertEquals(5, regsFound.size());
        Test.stopTest();
    }   
    
    @isTest static void TestGetAttendances() {
        
        Program__c wineClass = makeClass();
        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, wineClass);
        Program_Session__c testSession = makeSession(wineClass);
        List<Program_Attendance__c> attList = makeAttendance(conList, wineClass, regList, testSession);
        Test.startTest();
        List<Program_Attendance__c> attsFound = TakeAttendanceController.getAttendances(wineClass.Id, testSession.id);
        System.AssertEquals(5, attsFound.size());
        Test.stopTest();
    }  
    
    @isTest static void TestGetProgramSession() {
        Program__c wineClass = makeClass();
        Program_Session__c testSession = makeSession(wineClass);
        Program_Session__c result = TakeAttendanceController.getProgramSession(testSession.id);
        Test.startTest();
        System.assertEquals(date.today(), result.Date__c);
        System.assertEquals(wineClass.id, result.Program__c);
        Test.stopTest();
    }
    
    @isTest static void TestGetAttendanceContacts() {
        Program__c wineClass = makeClass();
        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, wineClass);
        Program_Session__c testSession = makeSession(wineClass);
        List<Program_Attendance__c> attList = makeAttendance(conList, wineClass, regList, testSession);
        Test.startTest();
        List<Id> result = TakeAttendanceController.getAttendanceContacts(attList);
        System.AssertEquals(conList[4].Id, result[4]);
        Test.stopTest();        
    }
    
    @isTest static void TestGetRegistrationContacts() {
        Program__c wineClass = makeClass();
        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, wineClass);
        Program_Session__c testSession = makeSession(wineClass);
        List<Program_Attendance__c> attList = makeAttendance(conList, wineClass, regList, testSession);
        Test.startTest();
        List<Id> result = TakeAttendanceController.getRegistrationContacts(regList);
        System.AssertEquals(conList[4].Id, result[4]);
        Test.stopTest();        
    }
       
    
    @isTest static void TestGetSessionAttendanceForEdit() {
        Program__c wineClass = makeClass();
        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, wineClass);
        List<String> regIds = new List<String>();
        for (Integer i = 0; i<3; i++) {
            regIds.add(regList[i].Id);
        }
        Program_Session__c session = new Program_Session__c(Program__c=wineClass.Id, Date__c=date.newInstance(2017,12,31));
        insert session;
        
        // save these registrations
        TakeAttendanceController.saveAttendances(wineClass.Id, regIds, session);
        test.startTest();
        List<TakeAttendanceController.AttendanceFormWrapper> result = TakeAttendanceController.getSessionAttendanceForEdit(session.Id);
        List<Boolean> checked = new List<Boolean>();
        for(TakeAttendanceController.AttendanceFormWrapper r : result) {
            checked.add(r.CheckboxSetting);
        }
        System.AssertEquals(true, checked[0]);  
        System.AssertEquals(true, checked[1]);
        System.AssertEquals(true, checked[2]);
        System.AssertEquals(false, checked[3]);
        System.AssertEquals(false, checked[4]);                  
        test.stopTest();
    }
    
    @isTest static void TestSaveAttendances() {

        Program__c wineClass = makeClass();
        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, wineClass);
        List<String> regIds = new List<String>();
        for(Program_Registration__c r: regList) {
            regIds.add(r.Id);
        }
        Program_Session__c testSession = makeSession(wineClass);
        Test.startTest(); 
        TakeAttendanceController.saveAttendances(wineClass.Id, regIds, testSession);
        List<Program_Attendance__c> result = [SELECT Contact__c FROM Program_Attendance__c];
        System.assertEquals(conList[4].Id, result[4].Contact__c);
        Test.stopTest();
    }
    
    @isTest static void testSaveEditedAttendanceEdit() {
        Program__c wineClass = makeClass();
        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, wineClass);
        List<String> regIds = new List<String>();
        for (Integer i = 0; i<3; i++) {
            regIds.add(regList[i].Id);
        }
        Program_Session__c session = new Program_Session__c(Program__c=wineClass.Id, Date__c=date.newInstance(2017,12,31));
        insert session;
        
        // save these registrations
         TakeAttendanceController.saveAttendances(wineClass.Id, regIds, session);
        // then make a new list: 0 and 1 will be deleted, 2 remains, 3 and 4 will be added
        regIds = new List<String>();
        for (Integer i = 2; i<5; i++) {
            regIds.add(regList[i].Id);
        }
        
        Test.startTest();      
        TakeAttendanceController.saveEditedAttendance(session.id, regIds);
        List<TakeAttendanceController.AttendanceFormWrapper> checkBoxes = TakeAttendanceController.getSessionAttendanceForEdit(session.id);
        List<Boolean> checked = new List<Boolean>();
        for (Integer i=0; i<5; i++) {
            checked.add(checkBoxes[i].CheckboxSetting);
        }
        System.debug(checked);
        
        System.AssertEquals(false, checked[0]);  
        System.AssertEquals(false, checked[1]);
        System.AssertEquals(true, checked[2]);
        System.AssertEquals(true, checked[3]);
        System.AssertEquals(true, checked[4]);
        
        Test.stopTest();
    }
    
    
    //Data creation methods -----------------------------------------------------------------
    
    static List<Contact> makeContacts() {
        List<Contact> conList = new List<Contact>();
        for(Integer i=0; i<5; i++) {
            Contact con = new Contact(FirstName='Class',LastName='Participant'+i);
            conList.add(con);
        }   
        insert conList;	
        return conList;
    }
    
    static Program__c makeClass() {
        Program__c wineClass = new Program__c(Name='Wine Tasting');
        insert wineClass;
        return wineClass;
    }
    
    static List<Program_Registration__c> makeRegistrations(List<Contact> conList, Program__c wineClass) {
        List<Program_Registration__c> regList = new List<Program_Registration__c>();
        for(Contact c : conList){
            Program_Registration__c r = new Program_Registration__c(Contact__c=c.id, Program__c=wineClass.Id);
            regList.add(r);
        }
        
        insert regList;
        return regList;
    }
    
    static Program_Session__c makeSession(Program__c wineClass) {
        Program_Session__c testSession = new Program_Session__c();
        testSession.Date__c = date.today();
        testSession.Program__c = wineClass.id;
        insert testSession;
        return testSession;
       
    }
    
    static List<Program_Attendance__c> makeAttendance(List<Contact> conList, Program__c wineClass, List<Program_Registration__c> regList, Program_Session__c testSession) {
        List<Program_Attendance__c> attList = new List<Program_Attendance__c>();
        for(Program_Registration__c reg: regList) {
            Program_Attendance__c att = new Program_Attendance__c();
            att.Program_Session__c = testSession.Id;
            att.Program__c = wineClass.Id;
            att.Contact__c = reg.Contact__c;
            att.ServiceDate__c = testSession.Date__c;
            attList.add(att);
        }
 
    insert attList;  
    return attList;
    }
    
}