public with sharing class MultiSessionAttendance {
    // calls methods in TakeAttendanceController.cls and ProgramUtilities.cls

    @AuraEnabled
    public static String getProgramName(Id recordId){
        return [SELECT Name FROM Program__c WHERE Id = :recordId LIMIT 1].Name;
    }
    
    @AuraEnabled
    public static List<String> getSessionDateStrings(Date startDate, Date endDate, Id recordId){

        List<Date> sessionDates = getSessionDates(startDate, endDate, recordId);
        List<String> sessionDateStrings = new List<String>();
        for(Date d: sessionDates) {
            sessionDateStrings.add(d.month()+'/'+d.day());
        }
        return sessionDateStrings;

    }

    public static List<Date> getSessionDates(Date startDate, Date endDate, Id recordId) {
        Schema.DescribeSObjectResult dsr = Program__c.sObjectType.getDescribe();
        String [] accessFields = new String []  {'Days__c'};
        CrudMethods.checkFieldReadAccess(dsr, accessFields);

        Program__c program = [SELECT Days__c FROM Program__c WHERE Id = :recordId LIMIT 1];
        List<String> programDays = program.Days__c.split(';');

        Map<Integer, String> weekdayMap = programUtilities.getWeekdayMap();
        Integer dow;
        String day;
       
        List<Date> sessionDates = new List<Date>();
        while(startDate <= endDate) {
            dow = programUtilities.getWeekdayFromDate(startDate);
            day = weekdayMap.get(dow);
            if(programDays.contains(day) && (sessionDates.size() < 10) ) {
                sessionDates.add(startDate);
            }
            startDate = startDate.addDays(1);
        }

        return sessionDates;
    }

    @AuraEnabled
    public static List<MultiFormWrapper> getRegistrantList(Id recordId, Date startDate, Date endDate){
        CrudMethods.checkObjectReadAccess('Contact');

        Schema.DescribeSObjectResult dsr;
        String [] accessFields;

        dsr = Program_Registration__c.sObjectType.getDescribe();
        accessFields = new String []  {'Contact_Name__c','Contact_Phone__c'};
        CrudMethods.checkFieldReadAccess(dsr, accessFields);

        dsr = Program_Attendance__c.sObjectType.getDescribe();
        accessFields = new String []  {'ServiceDate__c'};
        CrudMethods.checkFieldReadAccess(dsr, accessFields);

        List<String> sessionDates = getSessionDateStrings(startDate, endDate, recordId);
       
        List<MultiFormWrapper> wrapList = new List<MultiFormWrapper>();
        List<Program_Registration__c> regs = new List<Program_Registration__c>();
        List<Program_Attendance__c> atts = new List<Program_Attendance__c>();

        List<Boolean> CheckboxSettingsFalse = new List<Boolean>();
        for(Integer i=0; i < sessionDates.size(); i++) {
            CheckboxSettingsFalse.add(false);
        }

        List<Contact> contacts = [SELECT Id,
                                (SELECT Contact_Name__c, Contact_Phone__c FROM Program_Registrations__r WHERE Program__c = :recordId LIMIT 1),
                                (SELECT ServiceDate__c FROM Program_Attendance__r WHERE Program__c = :recordId AND ServiceDate__c >= :startDate AND ServiceDate__c <= :endDate) FROM Contact ORDER BY LastName];
       
        for(Contact con: contacts) {
            regs = con.Program_Registrations__r;
            if(regs.size() > 0) {
                atts = con.Program_Attendance__r;
                List<Boolean> CheckboxSettings = CheckboxSettingsFalse.clone();
                if(atts.size() > 0) {
                    for(Program_Attendance__c a: atts) {
                        String shortDate = a.ServiceDate__c.month()+'/'+a.ServiceDate__c.day();
                        if(sessionDates.contains(shortDate)) {
                            CheckboxSettings[sessionDates.indexOf(shortDate)] = true;
                        }
                    }
                }
                MultiFormWrapper mfw = new MultiFormWrapper(regs[0].Contact_Name__c, regs[0].Contact_Phone__c, CheckBoxSettings, regs[0].Id);
                System.debug(mfw);
                wrapList.add(mfw);
                
            }
        }    
        
        return wrapList;
        
    }

    //inner class for attendance wrapper
    public class MultiFormWrapper {
        @AuraEnabled
        public String ContactName;
        @AuraEnabled
        public String ContactPhone;
        @AuraEnabled
        public List<Boolean> CheckboxSettings;
        @AuraEnabled
        public Id RegistrationId;
        
        public MultiFormWrapper(String contactName, String contactPhone, List<Boolean> checkboxSettings, Id regId) {
            this.ContactName = contactName;
            this.ContactPhone = contactPhone;
            this.CheckboxSettings = checkboxSettings;
            this.RegistrationId = regId;
        }
    }  // end MultiFormWrapper  

    @AuraEnabled
    public static void saveChanges(Id recordId, Date startDate, Date endDate, List<Id> tempIDs, List<Integer> days) {
        List<Program_Session__c> programSessions = upsertProgramSessions(recordId, startDate, endDate);
       
        // make sure the sessions are sorted by Date so that we can reference them with values in List<Integer> days
        ProgramSessionWrapper[] psList = new List<ProgramSessionWrapper>();
        for(Program_Session__c ps: programSessions) {
            psList.add( new ProgramSessionWrapper(new Program_Session__c(
            Date__c=ps.Date__c,
            Id = ps.Id,
            Program__c=ps.Program__c)));
        }

        psList.sort();
        
        //loop through sessions
        for(Integer i=0; i<psList.size(); i++) {
            List<Id> regIds = new List<Id>();
            Integer n=0;
            // get the ids for this session only
            for(Id tid: tempIDs) {
                if(days[n] == i) {
                    regIds.add(tid);
                }
                n++;
            }
            System.debug(regIds);
            // use the methods in the single-session controller to finish
            TakeAttendanceController.saveEditedAttendance(psList[i].session.Id, regIds);

        } // end sessions loop

    }


    // not sure how this wrapper with interface works...but it does
    public class ProgramSessionWrapper implements Comparable {
        public Program_Session__c session;

        public ProgramSessionWrapper(Program_Session__c ps) {
            session = ps;
        }

        // Compare program sessions based on date
        public Integer compareTo(Object compareTo) {
            ProgramSessionWrapper compareToPS = (ProgramSessionWrapper)compareTo;
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if (session.Date__c > compareToPS.session.Date__c) {
            // Set return value to a positive value.
                returnValue = 1;
            } else if (session.Date__c < compareToPS.session.Date__c) {
            // Set return value to a negative value.
            returnValue = -1;
        }

        return returnValue;  
        }

    }


    public static List<Program_Session__c> upsertProgramSessions(Id recordId, Date startDate, Date endDate) {
        Schema.DescribeSObjectResult dsr = Program_Session__c.sObjectType.getDescribe();
        String [] accessFields = new String []  {'Date__c'};
        CrudMethods.checkFieldReadAccess(dsr, accessFields);
        CrudMethods.checkObjectCreateAccess('Program_Session__c');
        CrudMethods.checkFieldUpdateAccess(dsr, accessFields);


        List<Date> sessionDates = getSessionDates(startDate, endDate, recordId);
        List<Program_Session__c> programSessions = [SELECT Date__c, Program__c FROM Program_Session__c WHERE Program__c = :recordId AND Date__c >= :startDate AND Date__c <=:endDate];
        
        if(programSessions.size() == 0) {
            //go ahead and create all sessions
            for(Date d: sessionDates) {
                Program_Session__c ps = new Program_Session__c();
                ps.Date__c = d;
                ps.Program__c = recordId;
                programSessions.add(ps);
            }
        } else {
            List<Date> savedDates = new List<Date>();
            for(Program_Session__c ps: programSessions) {
                savedDates.add(ps.Date__c);
            }
            for(Date d:sessionDates) {
                if(!savedDates.contains(d)) {
                    Program_Session__c ps = new Program_Session__c();
                    ps.Date__c = d;
                    ps.Program__c = recordId;
                    programSessions.add(ps);
                }
            }   
        }
        upsert programSessions;
        return programSessions;

    }


}