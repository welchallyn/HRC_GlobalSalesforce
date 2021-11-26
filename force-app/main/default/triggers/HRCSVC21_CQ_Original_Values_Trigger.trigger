/***********************************************************************************************************************************************
* Name                             :  HRCSVC21_CQ_Original_Values_Trigger
* Author                           :  Capgemini
* Date                             :  November'21
* Purpose                          :  This Trigger will update the translated value to the Parent Complaint Qualification record, 
									  All the logic is handled in the HRCSV21_CQ_Original_Values_Handler Apex Class
									  This event only happens on the AfterUpdate trigger
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  SE-2620
/***********************************************************************************************************************************************/
trigger HRCSVC21_CQ_Original_Values_Trigger on HRCSVC20_CQ_Original_Values__c (before insert,after insert,before update, after update) 
{
if(Trigger.isupdate && trigger.isafter)
{
SYSTEM.debug('trigger newmap '+trigger.newmap.values());    
new HRCSV21_CQ_Original_Values_Handler().run();
}
}