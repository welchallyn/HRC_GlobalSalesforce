@isTest(SeeAllData=true)
global class PSPNoteTriggerTest {
    private static testmethod void  TestPSPTrigger() {
    
    BMCServiceDesk__Incident__c myInc = new BMCServiceDesk__Incident__c();
    myInc.Vendor_Ticket_Number__c = 'INC';
    myInc.BMCServiceDesk__queueName__c = 'HRC-CDW-ECC';
    insert myInc;
    
    Note note = new Note();
    note.Body = 'Test';
    note.ParentId = myInc.Id;
    note.Title = 'Test';
    insert note;
    
    update myInc;
    
    }
}