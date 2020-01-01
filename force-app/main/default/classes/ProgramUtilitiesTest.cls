@isTest
private with sharing class ProgramUtilitiesTest {

    @isTest
    private static void testGetWeekdayMap() {
        Map<Integer, String> result = ProgramUtilities.getWeekdayMap();
        System.assertEquals('Monday', result.get(1));
        System.assertEquals('Sunday', result.get(7));
    }
    
    @isTest
    private static void testGetWeekdayFromDate() {
        Date testDate = date.newInstance(2020, 1, 1); //Wednesday, Jan 1, 2020
        Integer result = ProgramUtilities.getWeekdayFromDate(testDate);
        System.assertEquals(3, result);

    }

    @isTest
    private static void testGetSundays() {
        List<Date> result = ProgramUtilities.getSundays();
        System.assertEquals(true, result.size() > 0);
        for(Date d: result) {
            System.assertEquals(7, ProgramUtilities.getWeekdayFromDate(d));
        }
    }

    @isTest
    private static void testGetProgramsAndSessions() {
        Program__c prog = new Program__c(Name='Test', Active__c=true);
        insert prog;
        Program_Session__c session = new Program_Session__c(Program__c=prog.Id, Date__c = date.today().addDays(5));
        insert session;
        Program_Session__c sessionOld = new Program_Session__c(Program__c=prog.Id, Date__c = date.today().addDays(-5));
        insert sessionOld;

        List<Program__c> result = ProgramUtilities.getProgramsAndSessions(date.today());
        List<Program_Session__c> result2 = result[0].Program_Sessions__r;
        //should only pick up the newer session
        System.assertEquals(1, result2.size());
        Date result3 = [SELECT Date__c FROM Program_Session__c WHERE Id = :result2[0].Id LIMIT 1].Date__c;
        System.assertEquals(date.today().addDays(5), result3);

    }

    @isTest
    private static void testGetSessionGridWithNoSessions() {
        Program__c prog = new Program__c(Name='Test', Active__c=true, Days__c = 'Tuesday; Thursday');
        insert prog;
        List<ProgramUtilities.GridWrapper> result = ProgramUtilities.getSessionGrid(date.newInstance(2020, 1, 6));
        List<Boolean> expectedChecked = new List<Boolean> {false, false, false, false, false, false, false};
        System.assertEquals(expectedChecked, result[0].Checked);
        List<Boolean> expectedDisabled = new List<Boolean> {true, true, false, true, false, true, true};
        System.assertEquals(expectedDisabled, result[0].Disabled);

    }

     @isTest
    private static void testGetSessionGridWithExistingSessions() {
        Program__c prog = new Program__c(Name='Test', Active__c=true, Days__c = 'Tuesday');
        insert prog;
        Program_Session__c session = new Program_Session__c(Date__c = date.newInstance(2020, 1, 7), Program__c = prog.Id);
        insert session;
        List<ProgramUtilities.GridWrapper> result = ProgramUtilities.getSessionGrid(date.newInstance(2020, 1, 5));
        List<Boolean> expectedChecked = new List<Boolean> {false, false, true, false, false, false, false};
        System.assertEquals(expectedChecked, result[0].Checked);
        List<Boolean> expectedDisabled = new List<Boolean> {true, true, true, true, true, true, true};
        System.assertEquals(expectedDisabled, result[0].Disabled);

    }

    @isTest
    private static void testCreateProgramSessions() {
        List<Id> programIds = new List<Id>();
        Program__c prog1 = new Program__c(Name='Test1');
        insert prog1;
        programIds.add(prog1.Id);
        Program__c prog2 = new Program__c(Name='Test2');
        insert prog2;
        programIds.add(prog2.Id);
        ProgramUtilities.createProgramSessions(programIds, null, 0);
        List<Program_Session__c> result1 = [SELECT Id, Name FROM Program_Session__c WHERE Date__c = :date.today() AND Program__c = :prog1.Id];
        System.assertEquals(1, result1.size());
        List<Program_Session__c> result2 = [SELECT Id, Name FROM Program_Session__c WHERE Date__c = :date.today() AND Program__c = :prog2.Id];
        System.assertEquals(1, result2.size());

    }

    @isTest
    private static void testGetProgramsToday() {
        Integer today = ProgramUtilities.getWeekdayFromDate(date.today());
        Map<Integer, String> weekdayMap = ProgramUtilities.getWeekdayMap();
        String day = weekdayMap.get(today);
        Program__c prog1 = new Program__c(Name='Test1', Days__c = day);
        insert prog1;
        Program__c prog2 = new Program__c(Name='Test2');
        insert prog2;
        List<Program__c> result = ProgramUtilities.getProgramsToday();
        System.assertEquals(1, result.size());
        System.assertEquals('Test1', result[0].Name);
    }

    @isTest
    private static void testGetSessionGridNull() {
        Integer today = ProgramUtilities.getWeekdayFromDate(date.today());
        Map<Integer, String> weekdayMap = ProgramUtilities.getWeekdayMap();
        String day = weekdayMap.get(today);
        Program__c prog1 = new Program__c(Name='Test1', Days__c = day);
        insert prog1;
        Program_Session__c session = new Program_Session__c(Program__c = prog1.Id, Date__c = date.today());
        insert session;
        Program__c prog2 = new Program__c(Name='Test2');
        insert prog2;
        List<ProgramUtilities.GridWrapper> result = ProgramUtilities.getSessionGrid(null);
         List<Boolean> expectedChecked = new List<Boolean> {true, false, false, false, false, false, false};
        System.assertEquals(expectedChecked, result[0].Checked);
        List<Boolean> expectedDisabled = new List<Boolean> {true, false, false, false, false, false, false};
        System.assertEquals(expectedDisabled, result[0].Disabled);
    }

    
}