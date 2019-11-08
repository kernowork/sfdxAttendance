public with sharing class ManageRegistrationsController {
            
    @AuraEnabled
    public static List<Program_Registration__c> showRegistrations(Id programID, Integer nMonths) {
        
        checkContactsReadAccess();
        checkRegistrationsReadAccess();
        checkAttendanceReadAccess();
        
        List<Program_Registration__c> regsToDelete;
        List<Program_Registration__c> regsCheck;
        
        // This runs whenever the user clicks on the Show List button
        // "integer.valueOf" makes sure nMonths is cast as integer!
        Date cutoffDate = Date.today().addDays(-integer.valueOf(nMonths)*30); // need to multiply nMonths * 30 
        System.debug('Cutoff Date: ' + cutoffDate); 
        
        /* Select Contacts with Registrations for this Program and also get Attendances
          sorted by date with most recent first */
        
        List<Contact> cons = [SELECT FirstName, LastName, 
                              (SELECT Name, ServiceDate__c FROM Program_Attendance__r  WHERE Program__c= :programID 
                               ORDER BY ServiceDate__c DESC NULLS LAST),
                              (SELECT Id, Name, Contact__c, Contact_Name__c, Contact_Phone__c, CreatedDate FROM Program_Registrations__r WHERE Program__c=:programID)
                              FROM Contact
                              WHERE Id IN
                              (SELECT Contact__c FROM Program_Registration__c WHERE Program__c=:programID) ORDER BY LastName]; 
        
        Integer nRegs = cons.size();
        
        if(nRegs > 0)  {      
            regsToDelete = new List<Program_Registration__c>();

            // Loop through the client list
                                
            for(Contact c : cons) {
                String client = c.FirstName + ' ' + c.LastName ;
                System.debug(client);
                // Get the related registrations
                List<Program_Registration__c> reg = c.Program_Registrations__r;
     
                // Get the attendances
                List<Program_Attendance__c> att = c.Program_Attendance__r;
                               
                if(att.size() > 0) {        
                    Date lastAttended = att[0].ServiceDate__c; 
                    System.debug('Last Attendance: ' + lastAttended);
                    
                    if(lastAttended < cutoffDate) {
                        //add registration(s) to delete list
                        for(Program_Registration__c r : reg) {
                            regsToDelete.add(r);
                        } 
                    }
                
                } else {
                    // No attendance record
                    for(Program_Registration__c r : reg) {
                        // Delete registration if created before the cutoff date
                        if(r.CreatedDate < cutoffDate) {
                            regsToDelete.add(r);
                        }
                    }
                }
                
            } // End of loop through client list
              
            List<Id> consToDelete = getContactsToDelete(regsToDelete);
        
            // get the names of the registrants to be deleted, for display on component
            List<Contact> conRegsToDelete = getContactNamesToDelete(consToDelete);      
            Integer numToDelete = consToDelete.size();
            System.debug(consToDelete);
            
        }
        
        return regsToDelete;
    }
    
    public static List<Id> getContactsToDelete(List<Program_Registration__c> regs) {
        //loop through registrations to delete to get the contact Ids
        List<Id> cons = new List<Id>();
        for(Program_Registration__c r : regs){
                cons.add(r.Contact__c);
            }
        return cons;
    }
    
    public static List<Contact> getContactNamesToDelete(List<Id> conRegs) {
        return [SELECT FirstName, LastName FROM Contact WHERE Id in :conRegs];  
    }
    

    @AuraEnabled
    public static boolean deleteRegs(List<Id> regIDs){
        // this happens when the user clicks on the Delete Registrations button
        boolean regsDeleted = false;
        checkRegistrationsDeleteAccess();
        List<Program_Registration__c> regsToDelete;

        if(regIDs.size() > 0) {           	
            regsToDelete = [SELECT Id FROM Program_Registration__c WHERE Id IN :regIDs]; 
        }

        try {
            delete regsToDelete;
            regsDeleted = true;
        } catch (Exception e) {
            System.debug(e);
        }   

        return regsDeleted;
    }
    
    //********************************** CRUD methods ***********************************
    
    public static void checkContactsReadAccess() {
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
        }
        
        checkContactsFieldReadAccess();
    }
    
    public static void checkContactsFieldReadAccess() {
        
        String [] regAccessFields = new String []  {'Id','FirstName','LastName'};                                                        
        Map<String, Schema.SOBjectField> m = Schema.SOBjectType.Contact.fields.getMap();
        System.debug(m);
        for (String fieldToCheck : regAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
            }
        }
    }
    
    public static void checkRegistrationsReadAccess() {
        
        if (!Schema.sObjectType.Program_Registration__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        
        checkRegistrationsFieldReadAccess();
    }
    
    public static void checkRegistrationsFieldReadAccess() {
        
        String [] regAccessFields = new String []  {'Id','Name','Contact_Name__c', 'Contact_Phone__c', 'Contact__c', 'CreatedDate'};                                                        
        Map<String, Schema.SOBjectField> m = Schema.SOBjectType.Program_Registration__c.fields.getMap();
        System.debug(m);
        for (String fieldToCheck : regAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug('User cannot read Registrations');
                throw new System.NoAccessException();
            }
        }
    }
    
    
    public static void checkRegistrationsDeleteAccess() {
        if (!Schema.sObjectType.Program_Registration__c.isDeletable()) {
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
        
        String [] attAccessFields = new String []  {'Id', 'Name', 'ServiceDate__c'};                                                
        Map<String, Schema.SOBjectField> mm = Schema.SOBjectType.Program_Attendance__c.fields.getMap();
        for (String fieldToCheck : attAccessFields) {
            if (!mm.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
            }
        }
    }

}