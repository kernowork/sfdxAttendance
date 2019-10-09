@isTest
private class ManageRegistrationsControllerTest {
    
    @isTest static void TestEmptyList() {
        System.debug('Testing Empty List');
        // create activity with no registrations
        Program__c pg = new Program__c(Name='Wine Tasting');
        insert pg;       
        Test.startTest();
        List<Program_Registration__c> result = ManageRegistrationsController.showRegistrations(pg.Id, 1);
        // There should be no registrations to inactivate
        System.AssertEquals(null, result);
        Test.stopTest();
    }
    
    @isTest static void TestInactivateEmptyList() {
        // create activity with no registrations
        Program__c pg = new Program__c(Name='Wine Tasting');
        insert pg;       
        Test.startTest();
        List<Id> regIds = new List<Id>(); // pass empty list
        boolean result = ManageRegistrationsController.inactivateRegs(regIds);
        // There are no registrations to delete
        System.AssertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void TestWineClassList() {
        // create an activity with 4 registrants and attendances
        // Contact 'Client Notcurrent' has no attendance within 30 days and Registration will be inactivated
        
        Program__c pg = TestAttendanceFactory.createContactsWithAttendances();

        Test.startTest();
        List<Program_Registration__c> regs = ManageRegistrationsController.showRegistrations(pg.Id, 1);        
        System.AssertEquals(1, regs.size());
        List<Id> conIds = ManageRegistrationsController.getContactsToInactivate(regs);
        List<Contact> conNames = ManageRegistrationsController.getContactNamesToInactivate(conIds);
        System.AssertEquals('Notcurrent', conNames[0].LastName); 
        List<Id> regIds = new List<Id>();
        for(Program_Registration__c r : regs) {
            regIds.add(r.Id);
        }
		ManageRegistrationsController.inactivateRegs(regIds);
        Program_Registration__c result = [SELECT Status__c FROM Program_Registration__c WHERE Id = :regs[0].id];
        System.assertEquals('Not active', result.Status__c);
        
        Test.stopTest();
        //make sure it doesn't show up on the list now
        regs = ManageRegistrationsController.showRegistrations(pg.Id, 1);  
        System.AssertEquals(0, regs.size());
    }
    
    @isTest static void TestForceInactivateNoshow() {
        System.debug('Testing for no show');
        // create an activity with 4 registrants and attendances
        // set cutoff date in the future so that no registrant has a recent attendance
        // and where there are no attendances at all, the registration is old enough for deletion
        // all 4 registrations should be deleted
        // as the Registration CreatedDate is the reference date, have to set cutoff date in future
        // look ahead 30 days for attendances
        // 
        Program__c pg = TestAttendanceFactory.createContactsWithAttendances();

        Test.startTest();
        List<Program_Registration__c> result = ManageRegistrationsController.showRegistrations(pg.Id, -1); 
        
        System.AssertEquals(4, result.size());
                      
        Test.stopTest();       
    }
    
    @isTest static void testRestrictedAccess() {
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
                ManageRegistrationsController.checkContactsReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ManageRegistrationsController.checkContactsFieldReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ManageRegistrationsController.checkRegistrationsReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ManageRegistrationsController.checkRegistrationsFieldReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ManageRegistrationsController.checkRegistrationsDeleteAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ManageRegistrationsController.checkAttendanceReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
            
            try {
                ManageRegistrationsController.checkAttendanceFieldReadAccess();
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
            }
               
        }
    }
}