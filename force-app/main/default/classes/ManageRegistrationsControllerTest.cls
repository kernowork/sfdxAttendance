@isTest
private class ManageRegistrationsControllerTest {
    
    @isTest static void TestEmptyList() {
        System.debug('Testing Empty List');
        // create activity with no registrations
        Program__c pg = new Program__c(Name='Wine Tasting');
        insert pg;       
        Test.startTest();
        List<Program_Registration__c> result = ManageRegistrationsController.showRegistrations(pg.Id, 1);
        // There should be no registrations to delete
        System.AssertEquals(null, result);
        Test.stopTest();
    }

    @isTest static void TestDeleteEmptyList() {
        // create activity with no registrations
        Program__c pg = new Program__c(Name='Wine Tasting');
        insert pg;       
        Test.startTest();
        List<Id> regIds = new List<Id>(); // pass empty list
        boolean result = ManageRegistrationsController.deleteRegs(regIds);
        // There are no registrations to delete
        System.AssertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void TestWineClassList() {
        // create an activity with 4 registrants and attendances
        // Contact 'Client Notcurrent' has no attendance within 30 days and Registration will be deleted
        
        Program__c pg = TestAttendanceFactory.createContactsWithAttendances();

        Test.startTest();
        List<Program_Registration__c> regs = ManageRegistrationsController.showRegistrations(pg.Id, 1);        
        System.AssertEquals(1, regs.size());
        List<Id> conIds = ManageRegistrationsController.getContactsToDelete(regs);
        List<Contact> conNames = ManageRegistrationsController.getContactNamesToDelete(conIds);
        System.AssertEquals('Notcurrent', conNames[0].LastName); 
        List<Id> regIds = new List<Id>();
        for(Program_Registration__c r : regs) {
            regIds.add(r.Id);
        }
		ManageRegistrationsController.deleteRegs(regIds);
        
        Test.stopTest();
        //make sure the registrations no longer show
        regs = ManageRegistrationsController.showRegistrations(pg.Id, 1);  
        System.AssertEquals(0, regs.size());
    }
    
    @isTest static void TestForceDeleteNoshow() {
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
    
    
}