global without sharing class BatchAlignOpportunityOwner1 implements Database.Batchable<Sobject>{
    
    private DateTime startDateTime;
    
    global BatchAlignOpportunityOwner1(){
         
        this.startDateTime = System.Now();
       
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id, AccountId, RecordType.Name, OwnerId 
                                           from Opportunity
                                          where 
                                          //id = '006E0000003nJHD'                                          
                                          RecordType.Name in :Opportunity_Record_Type_Position_Map__c.getAll().keySet() AND ReAssign_Owner__c=TRUE]);                                           
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
           // OwnerIds.add(o.ownerid);
           // rectypename.add(o.recordtype.name);
            //system.debug('********'+o.size());
             CurrentPositionMap.put(o.AccountId+'-'+o.Id, o.ownerid);
        }
        
     /** 
         for(Account_Team_Role__c atr1 :[Select a.UserId__c, a.Position__c, a.AccountId__c 
                                         From Account_Team_Role__c a
                                        where AccountId__c in :accountIds and UserId__c in :OwnerIds ])
        {
            //map the user to account-position
            CurrentPositionMap.put(atr1.AccountId__c+'-'+atr1.Position__c, atr1.UserId__c);
            
        }
        
       **/
       
        
        //Map the related accounts to users and Positions
        for(Account_Team_Role__c atr :[Select a.UserId__c, a.Position__c, a.AccountId__c 
                                         From Account_Team_Role__c a
                                        where AccountId__c in :accountIds])
        {
            //map the user to account-position
            userPositionMap.put(atr.AccountId__c+'-'+atr.Position__c, atr.UserId__c);
            
        }
        list <Opportunity> opportunities1 = new list <Opportunity>();
        list <Opportunity> opportunities2 = new list <Opportunity>();

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
                if (userPositionMap.get(o.AccountId+'-'+s) == CurrentPositionMap.get(o.AccountId+'-'+o.Id) && CurrentPositionMap.get(o.AccountId+'-'+o.Id) != null)
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
      /**  
        for(Opportunity st : opportunities1)
        {
        list<String> positions1 = Opportunity_Record_Type_Position_Map__c.getInstance(st.RecordType.Name).Positions__c.split(',');
        for(String s1 : positions1)
        {
        if (st.OwnerId != CurrentPositionMap.get(st.AccountId+'-'+s1))
        {
        opportunities2.add(st);
        break;
        }
        }
        }**/

        
        list <Database.Saveresult> results = Database.update( opportunities1, false );
            
        
        //Error Logging
        list<Error_Log__c> logs = new list<Error_Log__c>();
        Integer recordnum = 0;
        for(Database.Saveresult res : results)
        {
            if(!res.isSuccess())
            {
                Error_Log__c log = new Error_Log__c(Class_name__c = 'BatchAlignOpportunityOwner1'
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
    
    
}