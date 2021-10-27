/***************************************************************************************************************************************************
* Name                             :  HRCSVC_ContentVersionTrigger
* Author                           :  Kushagra Bansal
* Date                             :  March/19/2021
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  Trigger to pre-populate AEM visibility field on ContentVersion record as per the requirements given in SE-1770.
/**************************************************************************************************************************************************/
trigger HRCSVC_ContentVersionTrigger on ContentVersion (before insert,before update,after insert,after update) {
    if (Trigger.isBefore) {
        	HRCSVC_ContentVersionTriggerHandler.handleAEMVisibility(Trigger.new);
    }
    if (Trigger.isAfter) {
        HRCSVC_ContentVersionTriggerHandler.handlePublicLinkGeneration(Trigger.new);
    }
    
}