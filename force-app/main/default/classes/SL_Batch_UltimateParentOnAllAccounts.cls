/**
	ClassName    : SL_Batch_UltimateParentOnAllAccounts
	JIRATicket   : WADVDSC-2 
	CreatedOn    : 02/06/2015
	ModifiedBy   : Nrusingh
	Description  : This is a one time batch that assigns the Ultimate Parent field to all the account records			
*/
public with sharing class SL_Batch_UltimateParentOnAllAccounts implements Database.Batchable<sObject>
{
	/*Start Constructor*/
	public void SL_Batch_UltimateParentOnAllAccounts()
	{
		//Do Nothing
	}
	/*End Constructor*/
	
	/*
		MethodName: start 
		param : Database.BatchableContext BC
		Description: It is overriden method of Database.BatchableContext interface.
	*/
	public Database.QueryLocator start(Database.BatchableContext BC) 
	{
		//In the start method query all the reqired CA fields and send the list to the execute method
		String strQuery = 'SELECT Id,ParentId,Name,Meta_Parent__c, Ultimate_Parent_Id__c FROM Account where ParentId = Null';
		return Database.getQueryLocator(strQuery); 
	}
	
	/*  
		MethodName: execute
		param : Database.BatchableContext BC,List<Account> lstAccount
		Description: It is overriden method of Database.BatchableContext interface.
	*/
	public void execute(Database.BatchableContext BC,List<Account> lstAccountRecords)
	{
		// Calling updateUltimateParentOnUpdate method
		updateUltimateParentOnUpdate(lstAccountRecords);
	}
	
	/*
	    MethodName : updateUltimateParentOnUpdate
	    param      : list<Account> lstAccountRecords
	    Description: Update ultimate parent field on child records. 
    */
    private void updateUltimateParentOnUpdate(list<Account> lstAccountRecords)
    {
    	Set<Id> setParentId = new Set<Id>(); //Set Parent Account Id to Updated Account record.
		Map<Id, Account> mapIdToAccount = new Map<Id, Account>();//Map to contain Account Id to Object Account.
		
		//get all the parent Ids here
		for(Account objAccount :lstAccountRecords)
			setParentId.add(objAccount.Id);
		
		//getting the utimate id to get all the related child records.
		for(Account objAccount :[SELECT Id,
										Ultimate_Parent_Id__c,
										Meta_Parent__c,
										ParentId 
								 FROM Account 
								 WHERE ParentId IN :setParentId])
		{
			objAccount.Meta_Parent__c = objAccount.ParentId;
			mapIdToAccount.put(objAccount.Id, objAccount);
		}
		
		//update the first level of the Account Hierarchy
		if(!mapIdToAccount.isEmpty())
		{
			update mapIdToAccount.values();
			
			// Calling updateUltimateParent method 
			updateUltimateParent(mapIdToAccount);   
		}
    }
    
    /*
		MethodName : updateUltimateParent 
		param 	    : map of account, set of parent ids and set of ultimate parent ids.
		Description: Update ultimate parent field on child records. 
	*/
	private void updateUltimateParent(Map<Id, Account> mapIdToAccount)           
	{
		Map<Id, Account> mapAccountToUpdate = new Map<Id, Account> (); //List to Update the updated Account
		
		for(Account objAccount : [SELECT Id, 
										 Ultimate_Parent_Id__c, 
										 ParentId,
										 Meta_Parent__c,
										 Parent.Ultimate_Parent_Id__c
									FROM Account     
								    WHERE ParentId IN: mapIdToAccount.keySet()])
		{
			objAccount.Meta_Parent__c = objAccount.Parent.Ultimate_Parent_Id__c;
			mapAccountToUpdate.put(objAccount.Id, objAccount);
		}
		
		//Update the Account and its child record with the Ultimate Parent Id and its Parent Id.
		if(!mapAccountToUpdate.isEmpty())
		{
			update mapAccountToUpdate.values();
			updateUltimateParent(mapAccountToUpdate);
		} 
		
	}
	/* End */
	
	/*
		MethodName : finish 
		param 	    : Database.BatchableContext BC
		Description: called at the end all the batch job are completed
	*/
	public void finish(Database.BatchableContext BC)
	{
		// Do nothing
	} 
}