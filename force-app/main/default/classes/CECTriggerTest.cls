@isTest ( seealldata = true)
private class CECTriggerTest {

    static testMethod void runPositiveTestCases() {
       
        
        //Set up user
         User u1 = [SELECT Id FROM User WHERE profile.name = 'System Administrator' and isactive = true limit 1];
         contact c1 = [SELECT Id FROM contact limit 1];
        opportunity o1 = [SELECT Id FROM Opportunity order by createddate asc limit 1 ];
        opportunity o2 = [SELECT Id FROM Opportunity order by createddate desc limit 1];
        id rid = [SELECT Id FROM RecordType WHERE Name = 'Opportunity Based Commercial Air'].id;
        //Run As U1
        

            
        System.debug('Inserting 300  miles... (single record validation)');
        
        Trip__c test1a = new Trip__c(recordtypeid = rid,Host_Name_1__c = u1.id, 
                                        Host_Cell_Phone_Number__c = '1234567890',
                                        Proposed_Trip_Date__c = 'May 2012',
                                        Trip_Location__c = 'Irvine',
                                        Trip_Request_Status__c = 'Submitted',
                                        Trip_Start_Date__c = system.today(),
                                        Trip_End_Date__c =  system.today()+5,
                                        Vest__c = true, Opportunity__c = o1.id,
                                        Nearest_Major_Airport_to_Customer__c = 'Aberdeen,SD-ABR',
                                        Customer_Contact__c = c1.id);
        insert test1a;
         Trip__c test2 = new Trip__c (id = test1a.id, Opportunity__c = o1.id);
         update test2;
      
        } 
       }