trigger HRC_SalesGoalData on Sales_Goal_Data__c (before insert, before update) {
    HRC_SalesGoalDataController.processAccessOnAccount(Trigger.new);
}