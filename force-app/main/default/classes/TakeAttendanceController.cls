public with sharing class TakeAttendanceController {
  
    //****** #1. get the Program Session Attendance to be edited
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
            AttendanceFormWrapper af = new AttendanceFormWrapper(registrations[i].Contact_Name__c, checkBox, registrations[i].Id);
            attendanceForm.add(af);
            System.debug('form entry ' + af);
        }    
        return attendanceForm;
    } // end #1
    
    //inner class for attendance wrapper
    public class AttendanceFormWrapper {
        @AuraEnabled
        public String ContactName;
        @AuraEnabled
        public Boolean CheckboxSetting;
        @AuraEnabled
        public Id RegistrationId;
        
        public AttendanceFormWrapper(String contactName, boolean checkboxSetting, Id regId) {
            this.ContactName = contactName;
            this.CheckboxSetting = checkboxSetting;
            this.RegistrationId = regId;
        }
    }  // end AttendanceFormWrapper  


    //****** #2. update the Attendance records for the Program Session being edited
    @AuraEnabled
    public static void saveEditedAttendance(Id sd, List<String> regIds) {  
        Schema.DescribeSObjectResult dsr;
        String [] accessFields;

        dsr = Program_Registration__c.sObjectType.getDescribe();
        accessFields = new String []  {'Id','Contact_Name__c','Contact__c', 'Contact_Phone__c'}; 
        CrudMethods.checkFieldReadAccess(dsr, accessFields);
        CrudMethods.checkObjectDeleteAccess('Program_Attendance__c');
        
        Program_Session__c programSession = getProgramSession(sd); //which class session is this?
        List<Program_Attendance__c> attendances = getAttendances(programSession.Program__c, sd);  //get attendances for session
        
        //Get contact name for each registration (required field for Attendance record)
        List<Program_Registration__c> checkedRegs = [SELECT Id, Contact__c FROM Program_Registration__c 
                                                     WHERE Id IN :regIds ORDER BY Contact__c];
        
        //Get contacts to compare registrations with attendances
        List<id> registrationContacts = getRegistrationContacts(checkedRegs);
        List<Id> attendanceContacts = getAttendanceContacts(attendances);
        
        //Find registrations which have no attendance for this session
        List<String> regsWithNoAttendance = new List<string>();
        for(Integer i=0; i < checkedRegs.size(); i++) {
            if(!listContains(attendanceContacts, registrationContacts[i])) {
                //this registration needs an attendance record
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
        try {
            delete attendancesToDelete;
        } catch (DmlException e) {
            System.debug(e);
        }   

        
    } // end #2
    
    //****** #3. get required fields from the Program Session record being edited
    public static Program_Session__c getProgramSession (Id sd) {
        Schema.DescribeSObjectResult dsr = Program_Session__c.sObjectType.getDescribe();
        String [] accessFields = new String [] {'Id','Program__c', 'Date__c'};  
        CrudMethods.checkFieldReadAccess(dsr, accessFields);
        
        Program_Session__c sessionToEdit = [SELECT Id, Program__c, Date__c FROM Program_Session__c 
                                     WHERE Id = :sd];
        return sessionToEdit;  
        
    } // end #3
    
    //****** #4. get registrations for the given Program
    public static List<Program_Registration__c> getRegistrations(Id recordId) {
        Schema.DescribeSObjectResult dsr = Program_Registration__c.sObjectType.getDescribe();
        String [] accessFields = new String [] {'Id','Contact_Name__c','Contact__c', 'Contact_Phone__c'};
        CrudMethods.checkFieldReadAccess(dsr, accessFields);
        
        //Get all people registered for this program
        List<Program_Registration__c> regsList = [SELECT Id, Contact_Name__c, Contact__c FROM Program_Registration__c 
                                                  WHERE Program__c = :recordId ORDER BY Contact_Name__c];
        System.debug('Number of regs found: ' + regsList.size());
        return regsList;
        
    } // end #4
  
    //****** #5. get the Attendance records entered for the Program Session being edited
    public static List<Program_Attendance__c> getAttendances(Id programId, Id programSessionId) { 
        Schema.DescribeSObjectResult dsr = Program_Attendance__c.sObjectType.getDescribe();
        String [] accessFields = new String [] {'Id','Program_Session__c','Contact__c','ServiceDate__c'}; 
        CrudMethods.checkFieldReadAccess(dsr, accessFields);
        
        List<Program_Attendance__c> attendances = [SELECT Id, Contact__c FROM Program_Attendance__c 
                                           WHERE Program_Session__c = :programSessionId ORDER BY Contact__c];
        return attendances;
        
    } // end #5
    
    //****** #6. get the Contacts associated with each Attendance record
    public static List<id> getAttendanceContacts(List<Program_Attendance__c> attendances) {
        List<Id> attendees = new List<Id>();
        for(Program_Attendance__c att : attendances) {
            attendees.add(att.Contact__c);
        }
        return attendees;
    } // end #6
 
    //****** #7. get the Contacts associated with each Registration record
    public static List<id> getRegistrationContacts(List<Program_Registration__c> regs) {
        List<Id> registrations = new List<Id>();
        for(Program_Registration__c r : regs) {
            registrations.add(r.Contact__c);
        }
        return registrations;
    } // end #7
    
    
    
    //****** #8. save attendance records for checked registrations
    public static void saveAttendances(Id programId, List<String> regIds, Program_Session__c sd) {
        Schema.DescribeSObjectResult dsr = Program_Registration__c.sObjectType.getDescribe();
        String [] accessFields = new String [] {'Id','Contact_Name__c','Contact__c', 'Contact_Phone__c'};
        CrudMethods.checkFieldReadAccess(dsr, accessFields);

        dsr = Program_Attendance__c.sObjectType.getDescribe();
        accessFields = new String [] {'Program__c','ServiceDate__c'}; 
        CrudMethods.checkFieldUpdateAccess(dsr, accessFields);
        
        //Get contact name for each registration (required field for Attendance record)
        List<Program_Registration__c> registrations = [SELECT Id, Contact__c FROM Program_Registration__c 
                                               WHERE Id IN :regIds];
        List<Program_Attendance__c> attendances = new List<Program_Attendance__c>();
        
        //Create attendance record for each registration
        for(Program_Registration__c reg : registrations) {
            Program_Attendance__c att = new Program_Attendance__c();
            att.Program_Session__c = sd.Id; 	//master-detail - shows program session by name
            att.Program__c = programId; 	//lookup - shows class by name
            att.Contact__c = reg.Contact__c; 	//master-detail - shows contact by name
            att.ServiceDate__c = sd.Date__c;
            attendances.add(att);
        }
        
        try {
            insert attendances;
        } catch (DmlException e) {
            System.debug(e);
        }

        try {
            update registrations;
        } catch (DmlException e) {
            System.debug(e);
        }
               
    } // end #8
      
    
    //useful method!
    public static Boolean listContains(Object[] source, Object target) {
        return (new Set<Object>(source)).contains(target);
    } 

   
    
}