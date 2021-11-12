@isTest
public with sharing class CreateOpportunityControllerTest {

	public static testMethod void test() {
	    Account acc=new Account(Name='Test',BillingCountry='United States');
        insert acc;
         
         Order__c ord = new Order__C();
         ord.name='12345678';
         ord.Account__c =acc.id;
         insert ord;
 

       JDE_Prop__c pro = new JDE_Prop__C();
       pro.name='12345678';
       pro.Ship_To__c =acc.id;
       insert pro;
       CreateOpportunityController.getJDEprop(pro.id);
       CreateOpportunityController.getOrder(ord.id);
       CreateOpportunityController.getrecordtypeid('test');
    }

}