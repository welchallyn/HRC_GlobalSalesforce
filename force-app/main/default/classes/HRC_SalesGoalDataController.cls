public without sharing class HRC_SalesGoalDataController {
    public static void processAccessOnAccount(List<Sales_Goal_Data__c> salesGoalData) {
        for(Sales_Goal_Data__c sgd : salesGoalDAta) {
            if(sgd.Sales_User__c != null ) {
    			sgd.OwnerId = sgd.Sales_User__c;
            }
        }
        
        
    }
}