//Generates test data to use in test classes
//ManageRegistrationsControllerTest, TakeAttendanceControllerTest
@isTest
public class TestAttendanceFactory {
    public static Program__c createContactsWithAttendances(){
        List<Contact> conList = new List<Contact>{
            new Contact(FirstName='Client',LastName='Notcurrent'),
                new Contact(FirstName='Client',LastName='Current'),
                new Contact(FirstName='Client',LastName='New'),
                new Contact(FirstName='Client',LastName='Noshow')};    
                    insert conList;	
        
        Program__c wineClass = new Program__c(Name='Wine Tasting');
        insert wineClass;
        
        List<Program_Registration__c> regList = new List<Program_Registration__c>();
        for(Contact c : conList){
            Program_Registration__c r = new Program_Registration__c(Contact__c=c.id, Program__c=wineClass.Id);
            regList.add(r);
        }
        
        insert regList;
        
        List<Program_Session__c> classList = new List<Program_Session__c>();
        for(Integer i=0; i<6; i++){
            Program_Session__c sd = new Program_Session__c(Date__c=Date.today().addDays(-(i*10+5)), Program__c=wineClass.Id);
            classList.add(sd);
        } 
        
        insert classList;
        
        
        //Contacts with no attendance in last 30 days will have Registration deleted
        
        //Contact 'Client Notcurrent' has no attendance within 30 days and Registration WILL be deleted
        //Contact 'Client Current' has one attendance within 30 days and Registration will not be deleted
        //Contact 'Client New' has all attendance within 30 days and Registration will not be deleted
        //Contact 'Client Noshow' has no attendances at all but Registration is recent and will not be deleted
        
        
        
        List<Program_Attendance__c> attList = new List<Program_Attendance__c>{
            new Program_Attendance__c(Contact__c=conList[0].Id, Program_Session__c=classList[5].Id, ServiceDate__c=classList[5].Date__c, Program__c=wineclass.Id),
                new Program_Attendance__c(Contact__c=conList[0].Id, Program_Session__c=classList[4].Id, ServiceDate__c=classList[4].Date__c, Program__c=wineclass.Id),
                new Program_Attendance__c(Contact__c=conList[0].Id, Program_Session__c=classList[3].Id, ServiceDate__c=classList[3].Date__c, Program__c=wineclass.Id),
                new Program_Attendance__c(Contact__c=conList[1].Id, Program_Session__c=classList[4].Id, ServiceDate__c=classList[4].Date__c, Program__c=wineclass.Id),
                new Program_Attendance__c(Contact__c=conList[1].Id, Program_Session__c=classList[2].Id, ServiceDate__c=classList[2].Date__c, Program__c=wineclass.Id),
                new Program_Attendance__c(Contact__c=conList[1].Id, Program_Session__c=classList[1].Id, ServiceDate__c=classList[1].Date__c, Program__c=wineclass.Id),
                new Program_Attendance__c(Contact__c=conList[2].Id, Program_Session__c=classList[2].Id, ServiceDate__c=classList[2].Date__c, Program__c=wineclass.Id),
                new Program_Attendance__c(Contact__c=conList[2].Id, Program_Session__c=classList[1].Id, ServiceDate__c=classList[1].Date__c, Program__c=wineclass.Id),
                new Program_Attendance__c(Contact__c=conList[2].Id, Program_Session__c=classList[0].Id, ServiceDate__c=classList[0].Date__c, Program__c=wineclass.Id)};
                    
        try {
        		insert attList; 
        	} catch(DmlException e) {
            	System.debug('Insert failed: ' + e);
        }
              
        return wineClass;
    }	
    
}