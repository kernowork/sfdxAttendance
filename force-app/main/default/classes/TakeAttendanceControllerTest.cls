@isTest
public class TakeAttendanceControllerTest {
       
    @isTest static void testGetProgramSessionDateEdit() {
        Program__c wineClass = makeClass();
        Program_Session__c testSession = makeSession(wineClass);
        Test.startTest();
        Date result = TakeAttendanceController.getProgramSessionDate(testSession.id);
        System.assertEquals(date.today(), result);
        Test.stopTest();
    }

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
        String sessionDate = '2017-12-31';
        
        // save these registrations
        Program_Session__c thisClass = TakeAttendanceController.saveProgramSession(wineClass.Id, sessionDate);
        TakeAttendanceController.saveAttendances(wineClass.Id, regIds, thisClass);
        test.startTest();
        List<TakeAttendanceController.AttendanceFormWrapper> result = TakeAttendanceController.getSessionAttendanceForEdit(thisClass.Id);
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
    
    @isTest static void TestSaveProgramSession() {
        
        Program__c wineClass = makeClass();
        String sessionDate = '2017-12-31';
        Test.startTest();
        TakeAttendanceController.saveProgramSession(wineClass.Id, sessionDate);
        List<Program_Session__c> result = [SELECT Program__c FROM Program_Session__c];
        System.assertEquals(wineClass.Id, result[0].Program__c);
        Test.stopTest();
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
    
    @isTest static void testSaveSelected() {
        Program__c wineClass = makeClass();
        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, wineClass);
        List<String> regIds = new List<String>();
        for(Program_Registration__c r: regList) {
            regIds.add(r.Id);
        }
        regList[0].Inactive__c = true; //let one of the registrations be currently inactive
        update regList[0];
        String sessionDate = '2017-12-31';
        Test.startTest(); 
        TakeAttendanceController.saveSelected(wineClass.Id, regIds, sessionDate);
        List<Program_Attendance__c> result = [SELECT Contact__c FROM Program_Attendance__c];
        System.assertEquals(conList[4].Id, result[4].Contact__c);
        //test that the inactive regisration is now active
        Program_Registration__c result1 = [SELECT Status__c FROM Program_Registration__c WHERE Id = :regList[0].Id];
        System.assertEquals('Active', result1.Status__c);
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
        String sessionDate = '2017-12-31';
        //Date sd = Date.valueOf(classDate);
        
        // save these registrations
        Program_Session__c thisClass = TakeAttendanceController.saveProgramSession(wineClass.Id, sessionDate);
        TakeAttendanceController.saveAttendances(wineClass.Id, regIds, thisClass);
        // then make a new list: 0 and 1 will be deleted, 2 remains, 3 and 4 will be added
        regIds = new List<String>();
        for (Integer i = 2; i<5; i++) {
            regIds.add(regList[i].Id);
        }
        
        Test.startTest();      
        Date sd = Date.valueOf(TakeAttendanceController.getProgramSessionDate(thisClass.Id));
        sessionDate = sd.year() + '-' + sd.month() + '-' + sd.day();
        System.debug(sessionDate);
        TakeAttendanceController.saveEditedAttendance(thisClass.id, regIds, sessionDate);
        List<TakeAttendanceController.AttendanceFormWrapper> checkBoxes = TakeAttendanceController.getSessionAttendanceForEdit(thisClass.id);
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
    
    @isTest static void testAccess() {
        Id p = [SELECT Id FROM profile WHERE name = 'Standard User'].Id;
        User u = new User(
        	Alias = 'testu',
        	Email = 'test@example.com',
        	EmailEncodingKey = 'UTF-8',
        	LastName = 'Test',
        	LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
        	TimeZonesidKey = 'America/Los_Angeles',
        	ProfileId = p,
        	UserName = 'test@SGexample.com',
        	IsActive = true);
        insert u;
        
        system.runAs(u) {
            
            try {
                TakeAttendanceController.checkRegistrationsReadAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkRegistrationsFieldReadAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkRegistrationsUpdateAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkRegistrationsFieldUpdateAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkRegistrationsDeleteAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkProgramSessionReadAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkProgramSessionFieldReadAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkProgramSessionCreateAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkProgramSessionUpdateAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkProgramSessionFieldUpdateAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkAttendanceCreateAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkAttendanceReadAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkAttendanceFieldReadAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkAttendanceUpdateAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkAttendanceFieldUpdateAccess();
                } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                TakeAttendanceController.checkAttendanceDeleteAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
        }
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