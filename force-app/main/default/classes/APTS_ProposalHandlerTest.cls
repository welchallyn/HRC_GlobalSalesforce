@isTest 
public class APTS_ProposalHandlerTest
{
    static TestMethod void TestProposalTrigger()
    {
        //create user
        User u1 = new User(
             ProfileId = [SELECT Id FROM Profile WHERE Name='Standard User' limit 1].Id,
             LastName = 'last',
             Email = 'puser000@example.com',
             Username = 'puser000@example.com' + System.currentTimeMillis(),
             CompanyName = 'TEST',
             Title = 'title',
             Alias = 'alias',
             TimeZoneSidKey = 'America/Los_Angeles',
             EmailEncodingKey = 'UTF-8',
             LanguageLocaleKey = 'en_US',
             LocaleSidKey = 'en_US',
             JDE_External_Id__c = '12345'
        );
        insert u1;
        System.assertNotEquals(u1,null);
         
        User Usr = [SELECT Phone, Id,ManagerID FROM User WHERE Id = : UserInfo.getUserId() limit 1];
        usr.ManagerID = u1.Id;
        Update usr;
        System.assertEquals(u1.ID,usr.ManagerID );
        
        //create account
        Account ApttusTestAccount = new Account(Name = 'Test Account');
        insert ApttusTestAccount;
        
       list<Pricing_Contract__c > listCon = new List<Pricing_Contract__c >();
       for(integer i=0;i<2;i++){
            Pricing_Contract__c p= new  Pricing_Contract__c(name='pc1'+i,
                                                        account__c=ApttusTestAccount.id,
                                                        //Account__c
                                                        APTS_ID_from_Sandbox__c='test'+i,
                                                        Contract__c='Test'+i,
                                                        Contract_Description__c='Test'+i,
                                                        Contract_End_Date__c=date.today().addDays(30),
                                                        Contract_Start_Date__c=date.today().addDays(1),
                                                        SubGroup__c='Test',
                                                        SubGroup_Description__c='Test'
                                                        ); 
           listCon.add(p);
       }
       insert listCon;
       System.assertNotEquals(listCon,null);

       Apttus_Config2__PriceList__c ApttusTestPriceList = new Apttus_Config2__PriceList__c(Name = 'US PriceList',Apttus_Config2__Active__c = True);
       insert ApttusTestPriceList;
        
       Pricing_Contract__c p=[select id,name from  Pricing_Contract__c limit 1];
        
       //create opportunity 
       Opportunity opp = new Opportunity();
       opp.AccountId = ApttusTestAccount.Id;
       opp.StageName = 'Inquery';
       opp.Closedate = date.today() + 7;
       opp.Name = 'Opp1';
       opp.ownerId = usr.Id; 
            
       Id RecordTypeIdOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('LIKO').getRecordTypeId();
    
       opp.recordtypeid = RecordTypeIdOpportunity;
       insert opp;
       System.assertNotEquals(opp,null);
       
       Opportunity queryOpp = [select id, name from Opportunity where id =: opp.id];
       

       //create proposal
       Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(
                                                                                         Apttus_Proposal__Account__c = ApttusTestAccount.id,
                                                                                         Apttus_Proposal__Opportunity__c = opp.Id,
                                                                                         Apttus_QPConfig__PriceListId__c = ApttusTestPriceList.id,
                                                                                         Apttus_QPConfig__ConfigurationFinalizedDate__c = date.today(),
                                                                                         APTS_Override_Contract__c=null
                                                                                        );
       insert testProposal;
       System.assertNotEquals(testProposal,null); 
           
       testProposal=[select id,name, APTS_Override_Contract__c, Level_1_Approver_ID__c, Level_2_Approver_ID__c from Apttus_Proposal__Proposal__c where id=:testProposal.id];
       testProposal.APTS_Override_Contract__c=listCon[0].id;
       update testProposal;
    }
}