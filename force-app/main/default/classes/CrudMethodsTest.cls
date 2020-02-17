@isTest
private class CrudMethodsTest {
    
    @TestSetup
    static void makeData(){

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
        
    }

    @isTest
    private static void testCheckObjectReadAccess() {
        Boolean noAccess = false;
        CrudMethods.checkObjectReadAccess('Program__c');
        System.assertEquals(false, noAccess);

        User u = [SELECT Id FROM User WHERE UserName = 'test@SGexample.com' LIMIT 1];
        system.runAs(u) {

            try {
                CrudMethods.checkObjectReadAccess('Program__c');
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
                noAccess = true;
            }
        }
        System.assertEquals(true, noAccess);
    }

    @isTest
    private static void testCheckFieldReadAccess() {
        Boolean noAccess = false;
        Schema.DescribeSObjectResult dsr = Program__c.sObjectType.getDescribe();
        String [] accessFields = new String []  {'Days__c'};
        CrudMethods.checkFieldReadAccess(dsr, accessFields);
        System.assertEquals(false, noAccess);

        User u = [SELECT Id FROM User WHERE UserName = 'test@SGexample.com' LIMIT 1];
        system.runAs(u) {
            try {
               CrudMethods.checkFieldReadAccess(dsr, accessFields);
           } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
                noAccess = true;
           }
       }
       System.assertEquals(true, noAccess);
    }


    @isTest
    private static void testCheckObjectCreateAccess() {
        Boolean noAccess = false;
        CrudMethods.checkObjectCreateAccess('Program__c');
        System.assertEquals(false, noAccess);

        User u = [SELECT Id FROM User WHERE UserName = 'test@SGexample.com' LIMIT 1];
        system.runAs(u) {

            try {
                CrudMethods.checkObjectCreateAccess('Program__c');
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
                noAccess = true;
            }
        }
        System.assertEquals(true, noAccess);
    }

    @isTest
    private static void testCheckObjectUpdateAccess() {
        Boolean noAccess = false;
        CrudMethods.checkObjectUpdateAccess('Program__c');
        System.assertEquals(false, noAccess);

        User u = [SELECT Id FROM User WHERE UserName = 'test@SGexample.com' LIMIT 1];
        system.runAs(u) {

            try {
                CrudMethods.checkObjectUpdateAccess('Program__c');
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
                noAccess = true;
            }
        }
        System.assertEquals(true, noAccess);
    }

    @isTest
    private static void testCheckFieldUpdateAccess() {
        Boolean noAccess = false;
        Schema.DescribeSObjectResult dsr = Program__c.sObjectType.getDescribe();
        String [] accessFields = new String []  {'Days__c'};
        CrudMethods.checkFieldUpdateAccess(dsr, accessFields);
        System.assertEquals(false, noAccess);

        User u = [SELECT Id FROM User WHERE UserName = 'test@SGexample.com' LIMIT 1];
        system.runAs(u) {
            try {
               CrudMethods.checkFieldUpdateAccess(dsr, accessFields);
           } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
                noAccess = true;
           }
       }
       System.assertEquals(true, noAccess);
    }
   

    @isTest
    private static void testCheckDeleteAccess() {
        Boolean noAccess = false;
        CrudMethods.checkDeleteAccess('Program__c');
        System.assertEquals(false, noAccess);

        User u = [SELECT Id FROM User WHERE UserName = 'test@SGexample.com' LIMIT 1];
        system.runAs(u) {
            try {
                CrudMethods.checkDeleteAccess('Program__c');
            } catch(Exception e) {
                System.assert(e.getTypeName().contains('System.NoAccessException'));
                noAccess = true;
            }
        }
        System.assertEquals(true, noAccess);
    }
    
}