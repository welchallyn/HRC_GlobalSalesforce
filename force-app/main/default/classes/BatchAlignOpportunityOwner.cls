global without sharing class BatchAlignOpportunityOwner implements Database.Batchable<Sobject>{
    
    private DateTime startDateTime;
    
    global BatchAlignOpportunityOwner(){
         
        this.startDateTime = System.Now();
       
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id, AccountId, RecordType.Name, OwnerId 
                                           from Opportunity
                                          where   RecordType.Name in :Opportunity_Record_Type_Position_Map__c.getAll().keySet()]);

                                            //and Account.BillingCountry in ('US', 'CA')]); Commented as per Doug request.
    }
    global void execute(Database.BatchableContext BC, List<Sobject> scope){
        
        set<Id> accountIds = new set<Id>();
        list<Opportunity> opportunities = (List<Opportunity>)scope;
        map<String, Id> userPositionMap = new map<String, Id>();
        map<String, Id> CurrentPositionMap = new map<String, Id>();
        set<Id> OwnerIds = new set<Id>();
        set <string> rectype = Opportunity_Record_Type_Position_Map__c.getAll().keySet();
       // set <string> rectypename;
        system.debug('********'+opportunities.size());
        //get the account Ids associated with each Opportunity in the batch
        for(Opportunity o : opportunities)
        {
            accountIds.add(o.AccountId);
            OwnerIds.add(o.ownerid);
           // rectypename.add(o.recordtype.name);
            //system.debug('********'+o.size());
        }
               //Map the related accounts to users and Positions
        for(Account_Team_Role__c atr :[Select a.UserId__c, a.Position__c, a.AccountId__c 
                                         From Account_Team_Role__c a
                                        where AccountId__c in :accountIds])
        {
            //map the user to account-position
            userPositionMap.put(atr.AccountId__c+'-'+atr.Position__c, atr.UserId__c);
            
        }
        list <Opportunity> opportunities1 = new list <Opportunity>();

        //get position from record type on the opportunity
        for(Opportunity o : opportunities)
        {
            system.debug ('##$$'+o.id);
            if(Opportunity_Record_Type_Position_Map__c.getInstance(o.RecordType.Name) != null)
      {
              list<String> positions = Opportunity_Record_Type_Position_Map__c.getInstance(o.RecordType.Name).Positions__c.split(',');
              system.debug ('######'+positions);
              for(String s : positions)
              {
              system.debug ('######'+s);
                if(userPositionMap.containsKey(o.AccountId+'-'+s))
                {
                system.debug ('$$$$$$'+userPositionMap.get(o.AccountId+'-'+s));
              system.debug ('######'+CurrentPositionMap.get(o.AccountId+'-'+s));
                if (userPositionMap.get(o.AccountId+'-'+s) == o.ownerid)
                {
                break;
                }
                else 
                {
                  o.OwnerId = userPositionMap.get(o.AccountId+'-'+s);
                  opportunities1.add(o);
                  break;
                  
                  }
        }
        }
        }   
        }
              list <Database.Saveresult> results = Database.update( opportunities1, false );
        
        //Error Logging
        list<Error_Log__c> logs = new list<Error_Log__c>();
        Integer recordnum = 0;
        for(Database.Saveresult res : results)
        {
            if(!res.isSuccess())
            {
                Error_Log__c log = new Error_Log__c(Class_name__c = 'BatchAlignOpportunityOwner'
                                                   ,Date_time_started__c = startDateTime
                                                   ,Date_time_ended__c = System.now()
                                                   ,Error_message__c = res.getErrors()[0].getMessage()
                                                   ,Record_Id__c = opportunities[recordnum].id );
                logs.add(log);
            }
            recordnum ++;
            
        }
        
        //insert log files when there are errors
        if(logs.size() > 0)
          insert logs;
        
        
    }
    global void finish(Database.BatchableContext BC){       
    }
    
    //Test Method
    static testmethod void testThisClass() {
        
        
        //create the data for the test
        Account testAccount = new Account(name='test account');
        insert testAccount;
        
        Account_Team_Role__c atr = new Account_Team_Role__c(AccountId__c = testAccount.id
                                                           ,UserId__c = UserInfo.getUserId()
                                                           ,Position__c = 'test-y');
        insert atr;
        
        
        Opportunity testOpp = new Opportunity(AccountId=testAccount.id, Name='Test Opportunity234343');
        testOpp.Return_Type__c = 'None';
        testOpp.StageName = 'Qualified Opportunity';
        testOpp.CloseDate = system.today();
        testOpp.RMA_Date_1__c = system.today();
        testOpp.RMA_Price_1__c = 100.00 ;
        testOpp.RMA_Product_1__c = 'test product' ;
        testOpp.RMA_Quantity_1__c = 10 ;
        insert testOpp;
        
        //retrieve the default record type
        testOpp = [select Id, RecordType.Name from Opportunity where id = :testOpp.Id];
        
        //add the custom setting record
        Opportunity_Record_Type_Position_Map__c orp = new Opportunity_Record_Type_Position_Map__c(name = testOpp.RecordType.Name
                                                                                                 ,positions__c = 'test-x,test-y,test-z');
         
        insert orp;
        
        //Run the batch job
        Test.startTest();
        
        BatchAlignOpportunityOwner b = new BatchAlignOpportunityOwner();
        database.executebatch(b);
        
        Test.stopTest();
        
        //verify that the opportunity owner is set appropriatly
        System.AssertEquals(UserInfo.getUserId(), [Select OwnerId from Opportunity where id = :testOpp.Id].OwnerId);
        
    
    }
}