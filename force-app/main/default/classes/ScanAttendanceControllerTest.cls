@isTest
public class ScanAttendanceControllerTest {
    
    @isTest static void testGetContacts() {
        makeData();
        test.startTest();
        Contact con = ScanAttendanceController.getContacts('123456');
        System.assertEquals('Barcode', con.LastName);
        con = ScanAttendanceController.getContacts('');
        System.assertEquals(null, con);
        test.stopTest();
    }
    
    @isTest static void testSaveAttendance() {
        makeData();
        Id psid = [SELECT Id FROM Program_Session__c LIMIT 1].Id;
        test.startTest();
        Contact con = ScanAttendanceController.getContacts('123456');
        ScanAttendanceController.saveAttendance(con, psid);
        List<Program_Attendance__c> result = [SELECT Id FROM Program_Attendance__c];
        System.assertEquals(1, result.size());
        test.stopTest();        
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
                ScanAttendanceController.checkContactReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ScanAttendanceController.checkContactFieldReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ScanAttendanceController.checkProgramReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ScanAttendanceController.checkProgramFieldReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ScanAttendanceController.checkProgramSessionReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ScanAttendanceController.checkProgramSessionFieldReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ScanAttendanceController.checkAttendanceCreateAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ScanAttendanceController.checkAttendanceFieldUpdateAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
        }
    }
    
    public static void makeData() {
        
        Program__c prog = new Program__c(Name='Welcome');
        insert prog;
        Program_Session__c ps = new Program_Session__c(Date__c = date.today(), Program__c = prog.id);
        insert ps;
        Contact con1 = new Contact(FirstName='test', LastName='NoBarcode',Barcode__c = '');
        insert con1;
        Contact con2 = new Contact(FirstName='test', LastName='Barcode',Barcode__c = '123456');
        insert con2;
        
    }    
}