public with sharing class TakeAttendanceController {
 
    //****** #1. get the session date for the class to be edited (to populate the default in date picker)   
    @AuraEnabled
    public static Date getProgramSessionDate(Id sd) {
        
        checkProgramSessionReadAccess();
        Program_Session__c session = [SELECT Date__c FROM Program_Session__c WHERE Id = :sd];
        return session.Date__c;
        
    } // end #1
    
    //****** #2. get the Program Session Attendance to be edited
    @AuraEnabled
    public static List<AttendanceFormWrapper> getSessionAttendanceForEdit(Id sd) {
        
        Program_Session__c programSession = getProgramSession(sd);
        List<Program_Registration__c> registrations = getRegistrations(programSession.Program__c);  //get all registrants
        List<Program_Attendance__c> attendances = getAttendances(programSession.Program__c, sd);  //get attendances for session
        
        System.debug(attendances);

                
        //get the Contacts associated with each Attendance Record
        List<Id> attendees = getAttendanceContacts(attendances);
        
        List<AttendanceFormWrapper> attendanceForm = new List<AttendanceFormWrapper>();

        //Identify registrants who have attendance record for this specific session
        //so that their names will show as checked on the edit page
        for(Integer i=0; i < registrations.size(); i++) {
            Boolean checkBox;
            if(listContains(attendees, registrations[i].Contact__c)) {
                checkBox = true;               
            } else {
                checkBox = false;
            }
            AttendanceFormWrapper af = new AttendanceFormWrapper(registrations[i].Status__c, registrations[i].Contact_Name__c, registrations[i].Contact_Phone__c,
                                                   checkBox, registrations[i].Id);
            attendanceForm.add(af);
            System.debug('form entry ' + af);
        }    
        return attendanceForm;
    } // end #2
    
    //inner class for attendance wrapper
    public class AttendanceFormWrapper {
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String ContactName;
        @AuraEnabled
        public String ContactPhone;
        @AuraEnabled
        public Boolean CheckboxSetting;
        @AuraEnabled
        public Id RegistrationId;
        
        public AttendanceFormWrapper(String status, String contactName, String contactPhone, boolean checkboxSetting, Id regId) {
            this.Status = status;
            this.ContactName = contactName;
            this.ContactPhone = contactPhone;
            this.CheckboxSetting = checkboxSetting;
            this.RegistrationId = regId;
        }
    }  // end AttendanceFormWrapper  


    //****** #3. update the Attendance records for the Program Session being edited
    @AuraEnabled
    public static void saveEditedAttendance(Id sd, List<String> regIds, String sessionDate) {  
        
        checkRegistrationsReadAccess();
        checkAttendanceDeleteAccess();
        
        
        Program_Session__c programSession = getProgramSession(sd); //which class session is this?
        List<Program_Attendance__c> attendances = getAttendances(programSession.Program__c, sd);  //get attendances for session
        
        //Get contact name for each registration (required field for Attendance record)
        List<Program_Registration__c> checkedRegs = [SELECT Id, Contact__c FROM Program_Registration__c 
                                                     WHERE Id IN :regIds ORDER BY Contact__c];
        
        //Get contacts to compare registrations with attendances
        List<id> registrationContacts = getRegistrationContacts(checkedRegs);
        List<Id> attendanceContacts = getAttendanceContacts(attendances);
        
        //Find registrations which have no attendance for this session
        List<Integer> noAttendance = new List<Integer>();
        List<String> regsWithNoAttendance = new List<string>();
        for(Integer i=0; i < checkedRegs.size(); i++) {
            if(!listContains(attendanceContacts, registrationContacts[i])) {
                //this registration needs an attendance record
                //noAttendance.add(i);
                regsWithNoAttendance.add(checkedRegs[i].Id);
            } 
        }
        
        System.debug('Needing attendance: ' + regsWithNoAttendance);
        //Create attendance records for the remaining checked registrations (added during edit)
        saveAttendances(programSession.Program__c, regsWithNoAttendance, programSession);
        
        //Find attendances with registrations that are now unchecked and need deletion
        List<Program_Attendance__c> attendancesToDelete = new List<Program_Attendance__c>();
        for(Integer i=0; i < attendances.size(); i++) {
            if(!listContains(registrationContacts, attendanceContacts[i])) {
                attendancesToDelete.add(attendances[i]);
            } 
        }  
        //Delete the unwanted attendance records (names unchecked on edit)
        delete attendancesToDelete;
        programSession.Date__c = Date.valueOf(sessionDate);
        update programSession;
        
    } // end #3
    
    //****** #4. get required fields from the Program Session record being edited
    public static Program_Session__c getProgramSession (Id sd) {
        
        checkProgramSessionReadAccess();
        
        Program_Session__c sessionToEdit = [SELECT Id, Program__c, Date__c FROM Program_Session__c 
                                     WHERE Id = :sd];
        return sessionToEdit;  
        
    } // end #4 
    
    //****** #5. get registrations for the given Program
    public static List<Program_Registration__c> getRegistrations(Id recordId) {
        
        checkRegistrationsReadAccess();
        
        //Get all people registered for this program
        List<Program_Registration__c> regsList = [SELECT Id, Contact_Name__c, Contact__c, Contact_Phone__c, Status__c FROM Program_Registration__c 
                                                  WHERE Program__c = :recordId ORDER BY Status__c, Contact_Name__c];
        System.debug('Number of regs found: ' + regsList.size());
        return regsList;
        
    } // end #5
  
    //****** #6. get the Attendance records entered for the Program Session being edited
    public static List<Program_Attendance__c> getAttendances(Id programId, Id programSessionId) { 
        
        checkAttendanceReadAccess();
        
        List<Program_Attendance__c> attendances = [SELECT Id, Contact__c, ServiceDate__c FROM Program_Attendance__c 
                                           WHERE Program__c =:programId AND
                                          Program_Session__c = :programSessionId ORDER BY Contact__c];
        return attendances;
        
    } // end #6
    
    //****** #7. get the Contacts associated with each Attendance record
    public static List<id> getAttendanceContacts(List<Program_Attendance__c> attendances) {
        List<Id> attendees = new List<Id>();
        for(Program_Attendance__c att : attendances) {
            attendees.add(att.Contact__c);
        }
        return attendees;
    } // end #7
 
    //****** #8. get the Contacts associated with each Registration record
    public static List<id> getRegistrationContacts(List<Program_Registration__c> regs) {
        List<Id> registrations = new List<Id>();
        for(Program_Registration__c r : regs) {
            registrations.add(r.Contact__c);
        }
        return registrations;
    } // end #8
    
    //****** #9. save new Program Session record and associated Attendance records
    //called when sObject is Program__c
    public static void saveSelected(Id recordId, List<String> regIds, String sessionDate) {
        
        Program_Session__c sd = saveProgramSession(recordId, sessionDate); 
        saveAttendances(recordId, regIds, sd); 
        
    } // end #9
    
        //****** #10. create the Program Session record and return the Id to pass to Attendances
    public static Program_Session__c saveProgramSession(Id recordId, String sessionDate) {
        
        checkProgramSessionCreateAccess();      
        checkProgramSessionUpdateAccess();
            
        Program_Session__c sd = new Program_Session__c();
                
        //dates like to be passed from JS as strings!!
        sd.Date__c = Date.valueOf(sessionDate);
        sd.Program__c = recordId;
        
        upsert sd;
        return sd;  
        
    } // end #10
    
    
    //****** #11. save attendance records for checked registrations
    public static void saveAttendances(Id programId, List<String> regIds, Program_Session__c sd) {
        
        checkRegistrationsReadAccess();
        checkRegistrationsUpdateAccess();
        checkAttendanceCreateAccess();
        checkAttendanceUpdateAccess();
        
        //Get contact name for each registration (required field for Attendance record)
        List<Program_Registration__c> registrations = [SELECT Id, Contact__c FROM Program_Registration__c 
                                               WHERE Id IN :regIds];
        List<Program_Attendance__c> attendances = new List<Program_Attendance__c>();
        
        //Create attendance record for each registration
        for(Program_Registration__c reg : registrations) {
            reg.Inactive__c = false; // with an attendance, this registration is no longer inactive
            Program_Attendance__c att = new Program_Attendance__c();
            att.Program_Session__c = sd.Id; 	//master-detail - shows program session by name
            att.Program__c = programId; 	//master-detail - shows class by name
            att.Contact__c = reg.Contact__c; 	//master-detail - shows contact by name
            att.ServiceDate__c = sd.Date__c;
            attendances.add(att);
        }
        
        System.debug(attendances);
        insert attendances;
        update registrations;
               
    } // end #11
      
    
    //useful method!
    public static Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    } 

    //************************CRUD methods************************************
    
 	public static void checkRegistrationsReadAccess() {
        
        if (!Schema.sObjectType.Program_Registration__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        
        checkRegistrationsFieldReadAccess();
    }
    
    public static void checkRegistrationsFieldReadAccess() {
        
        String [] regAccessFields = new String []  {'Id','Contact_Name__c','Contact__c', 'Contact_Phone__c', 'Status__c'};                                                        
        Map<String, Schema.SOBjectField> m = Schema.SOBjectType.Program_Registration__c.fields.getMap();
        System.debug(m);
        for (String fieldToCheck : regAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug('User cannot read Registrations');
                throw new System.NoAccessException();
            }
        }
    }
    
    public static void checkRegistrationsUpdateAccess() {
        if (!Schema.sObjectType.Program_Registration__c.isUpdateable()) {
            throw new System.NoAccessException();   
        }
        checkRegistrationsFieldUpdateAccess();
    }
    
    public static void checkRegistrationsFieldUpdateAccess() {
        
        String [] regAccessFields = new String []   {'Inactive__c'};                                                        
        Map<String, Schema.SOBjectField> m = Schema.SOBjectType.Program_Registration__c.fields.getMap();
        System.debug(m);
        for (String fieldToCheck : regAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('User cannot update Registrations');
                throw new System.NoAccessException();
            }
        }
    }
    
    public static void checkRegistrationsDeleteAccess() {
        if (!Schema.sObjectType.Program_Registration__c.isDeletable()) {
            throw new System.NoAccessException();   
        }
    }
    
    public static void checkProgramSessionReadAccess() {
        
        if (!Schema.sObjectType.Program_Session__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        
        checkProgramSessionFieldReadAccess();
    }
        
	public static void checkProgramSessionFieldReadAccess() {
        
        String [] psAccessFields = new String []  {'Id','Program__c', 'Date__c'};                                                
        Map<String, Schema.SOBjectField> m = Schema.SOBjectType.Program_Session__c.fields.getMap();
        for (String fieldToCheck : psAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
            }
        }
    }
    
    public static void checkProgramSessionCreateAccess() {
        if (!Schema.sObjectType.Program_Session__c.isCreateable()) {
         	 throw new System.NoAccessException();  
        }
    }
    
    public static void checkProgramSessionUpdateAccess() {
        
        if (!Schema.sObjectType.Program_Session__c.isUpdateable()) {
         	 throw new System.NoAccessException();  
        }
        checkProgramSessionFieldUpdateAccess();
    }
    
    public static void checkProgramSessionFieldUpdateAccess() {
        
       // String [] classAccessFields = new String [] {'Date__c', 'Program__c'};
        String [] programSessionAccessFields = new String [] {'Date__c'};
        Map<String, Schema.SObjectField> m = Schema.SObjectType.Program_Session__c.fields.getMap();
		for (String fieldToCheck : programSessionAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isUpdateable()) {
                throw new System.NoAccessException();
            }
        }    
    }
    
    public static void checkAttendanceCreateAccess() {      
        if (!Schema.sObjectType.Program_Attendance__c.isCreateable()) {
            throw new System.NoAccessException();   
        }
    }
    
    public static void checkAttendanceReadAccess() {
        
        if (!Schema.sObjectType.Program_Attendance__c.isAccessible()) {
            throw new System.NoAccessException();
        }       
        checkAttendanceFieldReadAccess();
    }
    
	public static void checkAttendanceFieldReadAccess() {   
        
        String [] attAccessFields = new String []  {'Id','Program_Session__c','Contact__c','ServiceDate__c'};                                                
        Map<String, Schema.SOBjectField> mm = Schema.SOBjectType.Program_Attendance__c.fields.getMap();
        for (String fieldToCheck : attAccessFields) {
            if (!mm.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
            }
        }
    }
    
    public static void checkAttendanceUpdateAccess() {
        
        if (!Schema.sObjectType.Program_Attendance__c.isUpdateable()) {
         	 throw new System.NoAccessException();  
        }
        checkAttendanceFieldUpdateAccess();
    }
      
    public static void checkAttendanceFieldUpdateAccess() {
        
        String [] attAccessFields = new String []  {'Program__c','ServiceDate__c'};                                                
        Map<String, Schema.SOBjectField> mm = Schema.SOBjectType.Program_Attendance__c.fields.getMap();
        for (String fieldToCheck : attAccessFields) {
            if (!mm.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Not updateable' + fieldToCheck);
                throw new System.NoAccessException();
            }
        }
    }
    
    public static void checkAttendanceDeleteAccess() {
        if (!Schema.sObjectType.Program_Attendance__c.isDeletable()) {
            throw new System.NoAccessException();   
        }
    }
    
    
}