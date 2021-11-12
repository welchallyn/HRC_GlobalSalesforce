@isTest
private class OpportunityLookupControllerTest {
	static testMethod void testOpportunityLookupController() {
		
		// Create test data.
		Account testAccount = new Account(name='Test Account 1122334455');
		insert testAccount;

		Id rtId = RecordTypeUtil.getRecordTypeIdByName('Opportunity', 'Clinical Program');

		Opportunity testCP = new Opportunity(AccountId=testAccount.id, Name='Test Clinical Program 1122334455');
		testCP.Return_Type__c = 'None';
		testCP.StageName = 'Qualified Opportunity';
		testCP.CloseDate = System.today();
		testCP.RMA_Date_1__c = System.today();
		testCP.RMA_Price_1__c = 100.00 ;
		testCP.RMA_Product_1__c = 'test product' ;
		testCP.RMA_Quantity_1__c = 10 ;
		testCP.RecordTypeId = rtId;
		insert testCP;

		// Defind page and set parameters
		PageReference pg = Page.OpportunityLookup;
		
		Test.setCurrentPage(pg);
		pg.getParameters().put('lksrch', '');
		pg.getParameters().put('oppId', testCP.Id);
		
		// Define controller
		OpportunityLookupController controller=new OpportunityLookupController();

		System.assert(controller.search() == null);
		System.assert(controller.getFormTag() == null);
		System.assert(controller.getTextBox() == null);
	}	
}