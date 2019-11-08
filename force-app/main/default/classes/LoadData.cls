public with sharing class LoadData {
    
    @AuraEnabled
    public static void loadContacts() {

        Account acc = new Account(Name='MASH 4077');
        insert acc;

        StaticResource defaultResource = [SELECT s.Body From StaticResource s WHERE s.Name LIKE 'MASHPeople%'];
        blob tempB = defaultResource.Body;
        String contentFile = tempB.toString();
        String[] filelines = contentFile.split('\n');
        List<Contact> contacts = new List<Contact>();
        for (Integer i=1;i<filelines.size();i++)
            {
            Contact temp = new Contact();
            String[] inputvalues = filelines[i].split(',');
            temp.FirstName = inputValues[0];
            temp.LastName = inputValues[1];
            temp.Birthdate = date.parse(inputValues[2]);
            temp.MailingPostalCode = inputValues[3];
            temp.Phone = inputValues[4];
            temp.Email = inputvalues[5];
            temp.Barcode__c = inputvalues[6];
            temp.AccountId = acc.Id;
            contacts.add(temp);
        }
        System.debug(contacts.size());
        insert contacts; 

    }

    @AuraEnabled
    public static void loadPrograms() {

        List<Program_Registration__c> registrations = new List<Program_Registration__c>();

        Program__c prog1 = new Program__c();
        prog1.Active__c = true;
        prog1.Name = 'Dressmaking';
        prog1.Description__c = 'Learn to make dresses that will be the envy of your friends (or get you a Section 8!)';
        prog1.Instructor1__c = [SELECT Id FROM Contact WHERE LastName='Klinger'].Id;
        prog1.Days__c = 'Friday';
        prog1.Hours__c = 3;
        insert prog1;
        System.debug('prog1 ' + prog1 );

        Set<String> dressMakers = new Set<String>{'Houlihan', 'Cutler', 'Rayburn', 'Bigelow','Straminsky'};
        List<Contact> cons1 = [SELECT Id FROM Contact WHERE LastName IN :dressMakers];
        for(Contact c: cons1) {
            Program_Registration__c reg = new Program_Registration__c();
            reg.Contact__c = c.Id;
            reg.Program__c = prog1.Id;
            registrations.add(reg);
        }

        Program__c prog2 = new Program__c();
        prog2.Active__c = true;
        prog2.Name = 'Book Club';
        prog2.Description__c = 'Discover literary classics and enjoy fine wine.';
        prog2.Instructor1__c = [SELECT Id FROM Contact WHERE LastName='Winchester'].Id;
        prog2.Days__c = 'Thursday';
        prog2.Hours__c = 2;
        insert prog2;

        Set<String> bookWorms = new Set<String>{'Potter','Bayliss', 'Nakahara', 'Friedman', 'Mulchahey','Burns'};
        List<Contact> cons2 = [SELECT Id FROM Contact WHERE LastName IN :bookWorms];
        for(Contact c: cons2) {
            Program_Registration__c reg = new Program_Registration__c();
            reg.Contact__c = c.Id;
            reg.Program__c = prog2.Id;
            registrations.add(reg);
        }

        Program__c prog3 = new Program__c();
        prog3.Active__c = true;
        prog3.Name = 'Homebrewing';
        prog3.Description__c = 'Wine, beer and more!';
        prog3.Instructor1__c = [SELECT Id FROM Contact WHERE LastName='Pierce'].Id;
        prog3.Days__c = 'Saturday';
        prog3.Hours__c = 3;
        insert prog3;

        Set<String> boozers = new Set<String>{'Blake','Hunnicut','McIntyre','Bigelow','Friedman','Houlihan','Zale'};
        List<Contact> cons3 = [SELECT Id FROM Contact WHERE LastName IN :boozers];
        for(Contact c: cons3) {
            Program_Registration__c reg = new Program_Registration__c();
            reg.Contact__c = c.Id;
            reg.Program__c = prog3.Id;
            registrations.add(reg);
        }

        Program__c prog4 = new Program__c();
        prog4.Active__c = true;
        prog4.Name = 'Hygiene Lecture';
        prog4.Description__c = 'Demo for Manage Registrations component';
        prog4.Instructor1__c = [SELECT Id FROM Contact WHERE LastName='Blake'].Id;
        prog4.Days__c = 'Wednesday';
        prog3.Hours__c = 1;
        insert prog4;

        
        List<Contact> cons4 = [SELECT Id FROM Contact WHERE LastName != 'Blake'];
        for(Contact c: cons4) {
            Program_Registration__c reg = new Program_Registration__c();
            reg.Contact__c = c.Id;
            reg.Program__c = prog4.Id;
            registrations.add(reg);
        }

        insert registrations;
    }

    @AuraEnabled
    public static void loadProgramSessions() {

        Map<Integer, String> weekdayMap = new Map<Integer,String>();
        List<String> weekdays = new List<String>{'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'};
        for(Integer i = 1; i <= 7; i++) {
            weekdayMap.put(i, weekdays[i-1]);
        }
        Integer dayOfWeek = getWeekdayFromDate(date.today());
        List<Program_Session__c> sessions = new List<Program_Session__c>();
		List<Program__c> programs = getPrograms();
        for (Program__c program: programs) {
            String days = program.Days__c;
            Integer offset = 0;
            while(!days.contains(weekdayMap.get(dayOfWeek))) {
                offset++;
                dayOfWeek = getWeekdayFromDate(date.today().addDays(offset));
            }
            for(Integer i = 1; i <= 6; i++) {
                Program_Session__c session = new Program_Session__c();
                session.Program__c = program.Id;
                if(program.Name == 'Hygiene Lecture') {
                    session.Date__c = date.today().addDays(-(i * 60) + offset);
                } else {
                    session.Date__c = date.today().addDays(-(i * 7) + offset);
                }
                System.debug(session);
                sessions.add(session);
            }   
        }
        insert sessions;
    }

    @AuraEnabled
    public static void loadSessionAttendance() {
        List<Program_Attendance__c> attendance = new List<Program_Attendance__c>();
        List<Program__c> programs = [SELECT Name, (SELECT Contact__c FROM Program_Registrations__r),
                                    (SELECT Date__c FROM Program_Sessions__r ORDER BY Date__c) FROM Program__c];
        for(Program__c program: programs) {
            List<Program_Registration__c> regs = program.Program_Registrations__r;
            List<Program_Session__c> sessions = program.Program_Sessions__r;
            if(program.Name != 'Hygiene Lecture') {  
                for(Program_Session__c session: sessions) {
                    //select one registrant to not attend
                    Integer randomNumber = Integer.valueof((Math.random() * regs.size()));
                    for(Integer i=0; i<regs.size(); i++) {
                        if(i != randomNumber) {
                            Program_Attendance__c att = new Program_Attendance__c();
                            att.Program__c = program.Id;
                            att.Program_Session__c = session.Id;
                            att.Contact__c = regs[i].Contact__c;
                            att.ServiceDate__c = session.Date__c;
                            attendance.add(att);
                        }// end if
                    }// end for loop
                }// end session loop
            } else { 
                // Hygiene Lecture!
                Integer s = 0;
                for(Program_Session__c session: sessions) {
                    if(s == 0) {
                        //everyone attends first session!
                        for(Program_Registration__c r: regs) {
                            Program_Attendance__c att = new Program_Attendance__c();
                            att.Program__c = program.Id;
                            att.Program_Session__c = session.Id;
                            att.Contact__c = r.Contact__c;
                            att.ServiceDate__c = session.Date__c;
                            attendance.add(att);
                        }
                    } else {
                        //only first 10 registrants attend each session
                        for(Integer i = 0; i < regs.size()/2; i++) {
                            Program_Attendance__c att = new Program_Attendance__c();
                            att.Program__c = program.Id;
                            att.Program_Session__c = session.Id;
                            att.Contact__c = regs[i].Contact__c;
                            att.ServiceDate__c = session.Date__c;
                            attendance.add(att);
                        }
                    } // end else   
                    s++;
                }// end session loop
            } // end else loop
        }// end program loop

        insert attendance;
    }
    
    public static List<Program__c> getPrograms() {
        return [SELECT Name, Days__c FROM Program__c];
    }
    
    public static Integer getWeekdayFromDate(Date myDate) {
        DateTime dt = DateTime.newInstance(myDate, Time.newInstance(0,0,0,0));
		String dayOfWeek = dt.format('u');
        return Integer.ValueOf(dayOfWeek);
    }

    
}
