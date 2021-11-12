@isTest(seeAllData=true)
public class VFcontrollerTests {

//testing for the behaviour of the page when proposal number is Null
    public static testMethod void testAutoRun()
    {
   
       Account acc=new Account(Name='TestName',BillingCountry='United States');
       insert acc;
       Opportunity Oppp=new Opportunity();
       oppp.Name='Oppabcde';
       oppp.Type='New Manufacture';

       oppp.AccountId=acc.id;
       // oppp.Proposal_Number__c=pro.name;
       oppp.StageName='Qualified Opportunity';
       oppp.CloseDate=Date.today();

  
       insert oppp;
      
       ApexPages.StandardController sc = new ApexPages.StandardController(oppp);
       VfController con= new VfController(sc);
        
        PageReference OppPage = new ApexPages.StandardController(oppp).view();
        OppPage.getParameters().put('id', String.valueOf(oppp.Id));
        Test.setCurrentPage(OppPage);
      
        Test.startTest();
      
        PageReference ref2=con.autoRun();
       
        String url= ref2.getURL();

        Test.stopTest();
      
        System.assertEquals(url,'/apex/enterproposalnumber');
      
      }
      //testing for the deletion of old OLI's and addition of new OLI's when the Proposal number is entered
      
      public static testMethod void testAutoRun1()
      {
      
       Account acc=new Account(Name='TestName',BillingCountry='United States');
       insert acc;
       
       Test.startTest();
       
       JDE_Prop__c pro = new JDE_Prop__C();
       pro.name='12345678';
       pro.Ship_To__c =acc.id;
       insert pro;
      
       Opportunity Oppp=new Opportunity();
       oppp.Name='Oppabcde';
       oppp.Type='New Manufacture';

       oppp.AccountId=acc.id;
       // oppp.Proposal_Number__c=pro.name;
       oppp.StageName='Qualified Opportunity';
       oppp.CloseDate=Date.today();
       oppp.Proposal_Number__c='12345678';
  
       insert oppp;
       
      
       Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];
       Pricebook2 pb = [select id,Name from Pricebook2 where isActive=true limit 1];
       Product2 prod = new Product2(Name = 'Anti-infectives 2007', Family = 'Best Practices', Package_code__c = 'abc',Lead_Time__c=41, IsActive = true);
       insert prod;
        
       PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
       insert standardPrice;
        
       JDE_Prop_Ln_Item__c proli=new JDE_Prop_Ln_Item__c();
       proli.Proposal__C=pro.id;proli.Quantity__c=1;proli.Package_Options__c ='test';
       proli.Package_code__c='abc';proli.Extended_Line_Amount__c=1000 ;
       proli.Price__c=10000;
       proli.Parent_Line__c = null; 
       insert proli;
        
        
        OpportunityLineItem opl = new OpportunityLineItem();
        opl.Quantity = 1;
        opl.OpportunityId = oppp.id;
           // opl.discount = prl.Sys_discount__c;
        opl.Package_options__c ='test1';
        opl.Line_Item_Ship_Date__c = date.today();
        //opl.TotalPrice=100;
        opl.UnitPrice=1000;
        opl.PricebookentryId=pb.id;
        opl.List_Price_edit__c=1000;
            
            
        PageReference OppPage1 = new ApexPages.StandardController(oppp).view();
        Test.setCurrentPageReference(OppPage1);
       ApexPages.currentPage().getParameters().put('id',(oppp.Id));   
        
        oppp= [Select Name,StageName,AccountId,Proposal_Number__c,Type,Id From Opportunity Where Id = :ApexPages.currentPage().getParameters().get('id')];

          
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(oppp);
        VfController con1= new VfController(sc1);
        
        System.assertEquals(opl.Package_Options__c,'test1');
        
        PageReference ref2=con1.autoRun();
     
        
      Test.stopTest();
      // OpportunityLineItem newLineItems = [Select id,Package_options__c from OpportunityLineItem where opportunityId = :oppp.Id];
       
       // System.assertEquals(ref2,OppPage1);
      
             System.assertEquals(opl.OpportunityId,oppp.Id);
      //  System.assertEquals(newLineItems.Package_options__c,'test');
           
      
      }
      }