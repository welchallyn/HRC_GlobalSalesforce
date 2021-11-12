@isTest
public with sharing class StrategicDealInfoControllerTest{

	public static testMethod void test() {
         //Insert an Account.
        Account objAccount= new Account();
        objAccount.name = 'Test Account';
        objAccount.BillingCity = 'Pune';
        objAccount.BillingCountry = 'India';
        objAccount.BillingPostalCode = '411033';
        insert objAccount;
        
        //Insert a Contact.
        Contact objContact = new Contact();
        objContact.lastname = 'test last name';
        objContact.accountid = objAccount.id;
        objContact.Department_UK__c = 'Finance';
        objContact.Role__c = 'Administrator';
        objContact.Phone = '+918123412345';
        insert objContact;
        
        //Insert Opportunity.
        Opportunity objOpp = new Opportunity();
        objOpp.accountid = objAccount.id;
        objOpp.name = 'Test name';
        objOpp.StageName = 'Developing Opportunity';
        objOpp.CloseDate = Date.today().adddays(1);
        objOpp.Project_Type_Rental__c = 'Asset Advantage';
        objOpp.Order_Contact__c = objContact.id;
        insert objOpp;
        system.assertEquals(objOpp.name,'Test name');
        ApexPages.StandardController con = new ApexPages.StandardController(objOpp);
        ApexPages.currentPage().getParameters().put('id',objOpp.id);
        
        StrategicDealInfoController objCls = new StrategicDealInfoController(con);
        objCls.saveDealReview();
        
        WinLossAnalysisController objCls1 = new WinLossAnalysisController(con);
        objCls1.saveWinLossAnalysis();
          
	}
	
	public static testMethod void test2() {
         //Insert an Account.
        Account objAccount= new Account();
        objAccount.name = 'Test Account';
        objAccount.BillingCity = 'Pune';
        objAccount.BillingCountry = 'India';
        objAccount.BillingPostalCode = '411033';
        insert objAccount;
        
        //Insert a Contact.
        Contact objContact = new Contact();
        objContact.lastname = 'test last name';
        objContact.accountid = objAccount.id;
        objContact.Department_UK__c = 'Finance';
        objContact.Role__c = 'Administrator';
         objContact.Phone = '+918123412345';
        insert objContact;
        
        //Insert Opportunity.
        Opportunity objOpp = new Opportunity();
        objOpp.accountid = objAccount.id;
        objOpp.name = 'Test name';
        objOpp.StageName = 'Developing Opportunity';
        objOpp.CloseDate = Date.today().adddays(1);
        objOpp.Project_Type_Rental__c = 'Asset Advantage';
        objOpp.Order_Contact__c = objContact.id;
        insert objOpp;
        
        system.assertEquals(objOpp.name,'Test name');
        
        ApexPages.StandardController con = new ApexPages.StandardController(objOpp);
        //ApexPages.currentPage().getParameters().put('id',objOpp.id);
        
        StrategicDealInfoController objCls = new StrategicDealInfoController(con);
        objCls.saveDealReview();
        
        WinLossAnalysisController objCls1 = new WinLossAnalysisController(con);
        objCls1.saveWinLossAnalysis();
          
	}

}