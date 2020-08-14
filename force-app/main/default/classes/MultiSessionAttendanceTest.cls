@isTest
private class MultiSessionAttendanceTest {

    @isTest
    private static void testGetProgramName() {
        Program__c program = new Program__c(Name='Test', Days__c='Tuesday;Thursday');
        insert program;
        String result = MultiSessionAttendance.getProgramName(program.Id);
        System.assertEquals('Test', result);
    }
    
    @isTest
    private static void testGetSessionDates() {
        Program__c program = new Program__c(Name='Test', Days__c='Tuesday;Thursday');
        insert program;
        Date startDate = date.newInstance(2020, 02, 10);
        Date endDate = date.newInstance(2020, 02, 14);

        List<Date> result = MultiSessionAttendance.getSessionDates(startDate, endDate, program.Id);
        System.assertEquals(2, result.size());
        result.sort();
        System.assertEquals(date.newInstance(2020, 02, 11), result[0]);
        System.assertEquals(date.newInstance(2020, 02, 13), result[1]);

        List<String> result2 = MultiSessionAttendance.getSessionDateStrings(startDate, endDate, program.Id);
        result2.sort();
        System.assertEquals('2/11', result2[0]);
        System.assertEquals('2/13', result2[1]);
    }

    
    @isTest static void TestGetRegistrantList() {
        Program__c program = makeClass();

        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, program);

        Program_Session__c session1 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,10));
        insert session1;
        Program_Session__c session2 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,12));
        insert session2;

        makeAttendance(program, regList, session1);
        makeAttendance(program, regList, session2);

        Date startDate = date.newInstance(2020, 02, 10);
        Date endDate = date.newInstance(2020, 02, 14);

        List<MultiSessionAttendance.MultiFormWrapper> result = MultiSessionAttendance.getRegistrantList(program.Id, startDate, endDate);
        // all registrants attended Monday and Wednesday; none attended Friday
        List<Boolean> expectedChecked = new List<Boolean> {true, true, false};
        for(MultiSessionAttendance.MultiFormWrapper r : result) {
            System.assertEquals(expectedChecked, r.CheckboxSettings);
        }

       
    }

    @isTest
    private static void testUpsertProgramSessions() {
        Program__c program = makeClass();
        Date startDate = date.newInstance(2020, 02, 10);
        Date endDate = date.newInstance(2020, 02, 14);
        List<Program_Session__c> result = MultiSessionAttendance.upsertProgramSessions(program.Id, startDate, endDate);
        // there should now be 3 sessions (M, W, Thu)
        System.assertEquals(3, result.size());

        // delete the sessions and redo to cover the case with some sessions
        delete result;
        List<Program_Session__c> result1 = [SELECT Id FROM Program_Session__c];
        System.assertEquals(0, result1.size());

        Program_Session__c session1 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,10));
        insert session1;
        Program_Session__c session2 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,12));
        insert session2;
        
        MultiSessionAttendance.upsertProgramSessions(program.Id, startDate, endDate);
        // there should now be a session for 2020/02/13
        List<Program_Session__c> result2 = [SELECT Id, Date__c FROM Program_Session__c WHERE Program__c=:program.Id ORDER BY Date__c DESC];
        System.assertEquals(date.newInstance(2020,02,13), result2[0].Date__c);
     
    }
    
    
    @isTest
    private static void testProgramSessionWrapperSort() {
        Program__c program = makeClass();
        Program_Session__c session1 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,10));
        insert session1;
        Program_Session__c session2 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,03));
        insert session2;
        Program_Session__c session3 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,07));
        insert session3;
        List<Program_Session__c> sessions = [SELECT Id, Program__c, Date__c FROM Program_Session__c];

        MultiSessionAttendance.ProgramSessionWrapper[] psList = new List<MultiSessionAttendance.ProgramSessionWrapper>();
        for(Program_Session__c ps: sessions) {
            psList.add( new MultiSessionAttendance.ProgramSessionWrapper(new Program_Session__c(
            Date__c=ps.Date__c,
            Id = ps.Id,
            Program__c=ps.Program__c)));
        }

        psList.sort();
        //the earliest session to be first in list
        System.assertEquals(date.newInstance(2020,02,03), psList[0].session.Date__c);

    }

    @isTest
    private static void testSaveChanges() {
        Program__c program = makeClass();

        List<Contact> conList = makeContacts();
        List<Program_Registration__c> regList = makeRegistrations(conList, program);
        List<String> regIDs = new List<String>();
        for (Integer i = 0; i<5; i++) {
            regIDs.add(regList[i].Id);
        }

        Program_Session__c session1 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,10));
        insert session1;
        Program_Session__c session2 = new Program_Session__c(Program__c=program.Id, Date__c=date.newInstance(2020,02,12));
        insert session2;

        makeAttendance(program, regList, session1);
        makeAttendance(program, regList, session2);

        Date startDate = date.newInstance(2020, 02, 10);
        Date endDate = date.newInstance(2020, 02, 14);

        List<Program_Attendance__c> feb12 = [SELECT Id FROM Program_Attendance__c WHERE ServiceDate__c = :date.newInstance(2020, 02, 12)];
        System.assertEquals(5, feb12.size());
        // delete attendances for Wed 2/12 => only checkboxes for the first day, 2/10
        List<Integer> days = new List<Integer>{0, 0, 0, 0, 0};
        MultiSessionAttendance.saveChanges(program.Id, startDate, endDate, regIDs, days);
        feb12 = [SELECT Id FROM Program_Attendance__c WHERE ServiceDate__c = :date.newInstance(2020, 02, 12)];
        System.assertEquals(0, feb12.size());

        List<Program_Attendance__c> feb13 = [SELECT Id FROM Program_Attendance__c WHERE ServiceDate__c = :date.newInstance(2020, 02, 13)];
        System.assertEquals(0, feb13.size());
        // add attendance for Thurs 2/13 (Monday=0, Wednesday=1, Thursday=2)
        days = new List<Integer>{0, 0, 0, 0, 0, 2, 2, 2, 2, 2};
        regIDS.addAll(regIDs);
        MultiSessionAttendance.saveChanges(program.Id, startDate, endDate, regIDs, days);
        feb13 = [SELECT Id FROM Program_Attendance__c WHERE ServiceDate__c = :date.newInstance(2020, 02, 13)];
        System.assertEquals(5, feb13.size());

        //add attendance for Wed 2/12 for one registrant
        days = new List<Integer>{0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 1};
        regIDs.add(regIDs[0]);
        MultiSessionAttendance.saveChanges(program.Id, startDate, endDate, regIDs, days);
        feb12 = [SELECT Id, Contact__c FROM Program_Attendance__c WHERE ServiceDate__c = :date.newInstance(2020, 02, 12)];
        System.assertEquals(1, feb12.size());
        System.assertEquals(regList[0].Contact__c, feb12[0].Contact__c);
  
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
        Program__c program = new Program__c(Name='Test');
        program.Days__c = 'Monday;Wednesday;Thursday';
        insert program;
        return program;
    }
    
    static List<Program_Registration__c> makeRegistrations(List<Contact> conList, Program__c program) {
        List<Program_Registration__c> regList = new List<Program_Registration__c>();
        for(Contact c : conList){
            Program_Registration__c r = new Program_Registration__c(Contact__c=c.id, Program__c=program.Id);
            regList.add(r);
        }
        
        insert regList;
        return regList;
    }
    
    static Program_Session__c makeSession(Program__c program) {
        Program_Session__c testSession = new Program_Session__c();
        testSession.Date__c = date.today();
        testSession.Program__c = program.id;
        insert testSession;
        return testSession;
       
    }
    
    static List<Program_Attendance__c> makeAttendance(Program__c program, List<Program_Registration__c> regList, Program_Session__c testSession) {
        List<Program_Attendance__c> attList = new List<Program_Attendance__c>();
        for(Program_Registration__c reg: regList) {
            Program_Attendance__c att = new Program_Attendance__c();
            att.Program_Session__c = testSession.Id;
            att.Program__c = program.Id;
            att.Contact__c = reg.Contact__c;
            att.ServiceDate__c = testSession.Date__c;
            attList.add(att);
        }
 
        insert attList;  
        return attList;
    }

}