@isTest (seeAllData=true)
private Class ProposalToOpp
{

public static testmethod void testOpportunityTrigger()
{

// In your testmethod you need to create first Account & Opportunity record like
 
Account acc=new Account(Name='Test',BillingCountry='United States');


insert acc;
  JDE_Prop__c pro = new JDE_Prop__C();
 pro.name='12345678';
 pro.Ship_To__c =acc.id;
 insert pro;


//retrieving the objects I need for creating the OLI.
Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true];

        //Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        //insert pb;
        Pricebook2 pb = [select id,Name from Pricebook2 where IsActive = true limit 1];
        system.debug('############'+pb);
        Product2 prod = new Product2(Name = 'Anti-infectives 2007', Family = 'Best Practices', Package_code__c = 'abc',  IsActive = true);
        insert prod;

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        insert standardPrice;

        //PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
        //insert pbe;

// Next, it inserted__c a new 2 opportunity product
JDE_Prop_Ln_Item__c proli=new JDE_Prop_Ln_Item__c();
 proli.Proposal__C=pro.id;proli.Quantity__c=1;proli.Package_Options__c ='test';
 proli.Package_code__c=prod.Package_code__c;proli.Extended_Line_Amount__c=10000 ;
 insert proli;

 test.startTest();
Opportunity Oppp=new Opportunity();
oppp.Name='Oppabc';
oppp.Type='New Manufacture';
/**oppp.RFQ_Received__c=date.today();**/
oppp.AccountId=acc.id;
oppp.Converted_from_Proposal__c=true;
oppp.Proposal_Number__c=pro.name;

oppp.StageName='Qualified Opportunity';
oppp.CloseDate=Date.today();
/**oppp.Send_Quote_By__c=date.today();**/

insert oppp;

test.stopTest();
}

}