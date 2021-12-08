/*********************************************************************************************************************************************
* Trigger Name: OrderLineItemTriggerMainote
* Author: Capgemini
* Date: Nov/9/2021
*********************************************************************************************************************************************/

trigger HRCSVC21_OLI_Trigger on Order_Line_Item__c (before insert,after insert,before update,after update) {
     HRCSVC21_OLI_Handler itemHandler = new HRCSVC21_OLI_Handler ();
    


 if(trigger.isafter && trigger.isInsert ){   
   itemHandler.onAfterInsert(trigger.new, trigger.oldmap);
 }
 if(trigger.isafter && trigger.isUpdate ){   
   itemHandler.onAfterUpdate(trigger.new, trigger.oldmap);
 }

}