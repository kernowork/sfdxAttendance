public with sharing class ScanAttendanceController {

    @AuraEnabled
    public static Contact getContacts(String barcode) {
        if(barcode != null && barcode != '') {
            checkContactReadAccess();
            List<Contact> cons = new List<Contact>(); 
            cons = [SELECT FirstName, LastName, Birthdate, YearOfBirth__c, MailingPostalCode FROM Contact WHERE Barcode__c = :barcode LIMIT 1];
            System.debug(cons);
            return cons[0];
        } else {
            return null;
        }
    }
    
    @AuraEnabled
    public static void saveAttendance(Contact con, Id recordId) {
            
        checkProgramReadAccess();
        checkProgramSessionReadAccess();
        checkAttendanceCreateAccess();
             
        Program_Session__c ps = [SELECT Program__c, Date__c FROM Program_Session__c WHERE Id = :recordId];
             
        Program_Attendance__c pa = new Program_Attendance__c();
        pa.Contact__c = con.Id;
        pa.Program__c = ps.Program__c;
        pa.ServiceDate__c = ps.Date__c;
        pa.Program_Session__c = recordId;
        pa.Barcode_Scanned__c = true;
        insert pa; 
    }
    
    
    //****************************CRUD methods*****************************
    
    public static void checkContactReadAccess() {
        if (!Schema.sObjectType.Contact.isAccessible()) {
            throw new System.NoAccessException();
        }
        checkContactFieldReadAccess();
    }
    
    public static void checkContactFieldReadAccess() {
        
        String [] conAccessFields = new String []  {'FirstName', 'LastName', 'Birthdate', 'Barcode__c'};                                                        
        Map<String, Schema.SOBjectField> m = Schema.SOBjectType.Contact.fields.getMap();
        System.debug(m);
        for (String fieldToCheck : conAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                System.debug('User cannot read Contact fields');
                throw new System.NoAccessException();
            }
        }
    }
    
    public static void checkProgramReadAccess() {
        if (!Schema.sObjectType.Program__c.isAccessible()) {
            throw new System.NoAccessException();
        }
        checkProgramFieldReadAccess();
    }
    
    public static void checkProgramFieldReadAccess() {
        
        String [] psAccessFields = new String []  {'Id','Name'};                                                
        Map<String, Schema.SOBjectField> m = Schema.SOBjectType.Program_Session__c.fields.getMap();
        for (String fieldToCheck : psAccessFields) {
            if (!m.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
            }
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
    
    public static void checkAttendanceCreateAccess() {      
        if (!Schema.sObjectType.Program_Attendance__c.isCreateable()) {
            throw new System.NoAccessException();   
        }
        checkAttendanceFieldUpdateAccess();
    }
    
    public static void checkAttendanceFieldUpdateAccess() {
        
        String [] attAccessFields = new String []  {'Program__c', 'ServiceDate__c', 'Barcode_Scanned__c'};                                                
        Map<String, Schema.SOBjectField> mm = Schema.SOBjectType.Program_Attendance__c.fields.getMap();
        for (String fieldToCheck : attAccessFields) {
            if (!mm.get(fieldToCheck).getDescribe().isUpdateable()) {
                System.debug('Not updateable' + fieldToCheck);
                throw new System.NoAccessException();
            }
        }
    }
    
    
}