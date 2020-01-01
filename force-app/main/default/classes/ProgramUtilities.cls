public with sharing class ProgramUtilities {


    public static List<Program__c> getProgramsAndSessions(Date sunday) {
        checkProgramReadAccess();
        checkProgramSessionReadAccess();

        return [SELECT Name, Days__c, (SELECT Id, Date__c FROM Program_Sessions__r WHERE Date__c >= :sunday AND Date__c < :sunday.addDays(7)) 
        FROM Program__c WHERE Active__c = true ORDER BY Name];
    }

    public static List<Program__c> getProgramsToday() {
        checkProgramReadAccess();
        checkProgramSessionReadAccess();

        List<Program__c> programs = [SELECT Name, Days__c, (SELECT Id, Date__c FROM Program_Sessions__r WHERE Date__c >= :date.today()) 
        FROM Program__c WHERE Active__c = true ORDER BY Name];
        Integer today = getWeekdayFromDate(date.today());
        Map<Integer, String> weekdayMap = getWeekdayMap();
        String day = weekdayMap.get(today);
        List<Program__c> todayPrograms = new List<Program__c>();
        for(Program__c p: programs) {
            if(p.Days__c == null) continue;
            if(p.Days__c.contains(day)) {
                todayPrograms.add(p);
            }
        }
        return todayPrograms;    
    }
    
    public static Integer getWeekdayFromDate(Date myDate) {
        DateTime dt = DateTime.newInstance(myDate, Time.newInstance(0,0,0,0));
		String dayOfWeek = dt.format('u');
        return Integer.ValueOf(dayOfWeek);
    }

    @AuraEnabled
    public static List<Date> getSundays() {
        //get list of dates for upcoming Mondays
        List<Date> sundays = new List<Date>();
        Date d;
        Integer dayOfWeek;
        for(Integer i = 0; i < 30; i++) {
            d = date.today().addDays(i);
            dayOfWeek = getWeekdayFromDate(d);
            if(dayOfWeek == 7) {
                sundays.add(d);
            }
        }
        return sundays;
    }

    @AuraEnabled
    public static List<GridWrapper> getSessionGrid(Date sunday){
        checkProgramReadAccess();
        checkProgramSessionReadAccess();

        // If sunday is null, then we are only concerned with classes that run today
        Map<Integer, String> weekdayMap = getWeekdayMap();
        List<Program__c> programs;
        Integer loopN;

        if(sunday == null) {
            programs = getProgramsToday();
            loopN = 1;
        } else {
            programs = getProgramsAndSessions(sunday);
            loopN = 7;
        }

        System.debug(programs);

        List<GridWrapper> grid = new List<GridWrapper>();

        for (Program__c prog: programs) {
            List<Boolean> disabled = new List<Boolean>{false, false, false, false, false, false, false};
            List<Boolean> checked = new List<Boolean>{false, false, false, false, false, false, false};
            String days = prog.Days__c;
            if(days == null) continue; //skip this program

            GridWrapper gw = new GridWrapper(disabled, checked);
            gw.ProgramId = prog.Id;
            gw.ProgramName = prog.Name;
            for(Integer i = 1; i <= loopN ; i++) {
                if(!days.contains(weekdayMap.get(i)) && sunday != null) {
                    if(i < loopN) {
                        gw.disabled[i] = true; 
                    } else {
                        gw.disabled[0] = true;  //Sunday
                    }                    
                } 
            }
            List<Program_Session__c> sessions = prog.Program_Sessions__r;
            if(sessions.size() > 0) {
                for(Program_Session__c ps: sessions) {
                    if(sunday == null) {
                        gw.Checked[0] = true;
                        gw.Disabled[0] = true;
                    } else {
                        Integer dow = getWeekdayFromDate(ps.Date__c);
                        if(dow == 7) {
                            dow = 0;
                        } 
                        gw.Checked[dow] = true;
                        gw.Disabled[dow] = true;
                    }
                }
            } 
            System.debug(gw);
            grid.add(gw);
            
        }

        return grid;
    }

    public class GridWrapper {
        @AuraEnabled
        public Id ProgramId {get; set;}
        @AuraEnabled
        public String ProgramName {get; set;}
        @AuraEnabled
        public List<Boolean> Disabled;
        @AuraEnabled
        public List<Boolean> Checked;

        public GridWrapper(List<Boolean> disabled, List<Boolean> checked) {
            this.Disabled = disabled;
            this.Checked = checked;
        }
           
    }

    public static Map<Integer, String> getWeekdayMap() {
        Map<Integer, String> weekdayMap = new Map<Integer,String>();
        List<String> weekdays = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'};
        for(Integer i = 1; i <= 7; i++) {
            weekdayMap.put(i, weekdays[i-1]);
        }
        return weekdayMap;
    }


    @AuraEnabled
    public static void createProgramSessions(List<Id> programIds, Date sundayDate, Integer days){
        checkProgramSessionCreateAccess();

        if(sundayDate == null) {
            sundayDate = date.today();
            days = 0;
        }
        List<Program_Session__c> sessions = new List<Program_Session__c>();
        for(Id pid: programIds) {
            Program_Session__c ps = new Program_Session__c();
            ps.Program__c = pid;
            ps.Date__c = sundayDate.addDays(days);
            sessions.add(ps);
        }

        insert sessions;
    }

    


    // *************************** CRUD methods *************************************

    public static void checkProgramReadAccess() {
        if (!Schema.sObjectType.Program__c.isAccessible()) {
            throw new System.NoAccessException();
        }
    }
    
    public static void checkProgramSessionCreateAccess() {
        if (!Schema.sObjectType.Program_Session__c.isCreateable()) {
         	 throw new System.NoAccessException();  
        }
    }

    public static void checkProgramSessionReadAccess() {
        if (!Schema.sObjectType.Program_Session__c.isAccessible()) {
            throw new System.NoAccessException();
        }
    }

    
}