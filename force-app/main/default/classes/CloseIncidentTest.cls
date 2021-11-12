@istest(SeeAlldata=true)
public class CloseIncidentTest {

 
    
    static  testmethod void testThisClass() {
        
         User userRec = new User(LastName='Pissani',Username='alice.pissani@hillrom.com',Email='alice.pissani@hillrom.com',Alias='APissani',TimeZoneSidKey= 'America/Los_Angeles'
                               ,LocaleSidKey='en_US',EmailEncodingKey='UTF-8',ProfileId='00eE0000000lrRK',LanguageLocaleKey='en_US',isActive=true);
        insert userRec;
        test.startTest();
        Account testAccount = new Account(name='test account34');
        insert testAccount;
    
         BMCServiceDesk__Incident__c testIncident = new BMCServiceDesk__Incident__c();
        //testIncident.Due_Date_Closed__c=today();
          //testIncident.IsResolved__c= true;
        //testIncident.BMCServiceDesk__ClosureCategory__c ='Configuration Issue';
        testIncident.BMCServiceDesk__incidentResolution__c ='Test';
        testIncident.BMCServiceDesk__FKAccount__c = '001E000000g5VZyIAM' ;
        testIncident.BMCServiceDesk__FKClient__c ='0050L000009l4HJQAY';
        testIncident.BMCServiceDesk__queueName__c='HRC-CDW-ECC';
        insert testIncident;
        
         testIncident.BMCServiceDesk__Approved__c = true;
        //testIncident.BMCServiceDesk__ClosureCategory__c ='Configuration Issue';
        Update testIncident;
        
       // BMCServiceDesk__Incident__c testIncident = [Select Id from BMCServiceDesk__Incident__c where BMCServiceDesk__incidentResolution__c='Test'];
        
       // Delete testIncident;
       // 
      
        List<BMCServiceDesk__Incident__c> listings = new List<BMCServiceDesk__Incident__c>();

    /*    for(Integer i = 0; i < 200; i++) {
            listings.add(new BMCServiceDesk__Incident__c (
                BMCServiceDesk__incidentResolution__c= 'Auction',
                BMCServiceDesk__FKAccount__c= '001E000000g5VZyIAM',
                BMCServiceDesk__FKClient__c= '0050L000009l4HJQAY',
                BMCServiceDesk__queueName__c= 'HRC-CDW-ECC'  
            ));
        }

        insert listings;  */

      

    		 List<BMCServiceDesk__Incident__c> incidents = [Select Id From BMCServiceDesk__Incident__c Where BMCServiceDesk__FKAccount__c = '001E000000g5VZyIAM' limit 5];

    // 1st STEP --> Here I check the list which should not be null  
    //System.assert(true, incidents!=null); 

  
      
            delete incidents;            
        
    
      Test.stopTest();  
       
        
    }
    
 
   
    
}