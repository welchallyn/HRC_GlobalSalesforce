/* ClassName: StrategicDealInformation 
   Created By: Jenish Shingala.
   Created Date: 16th Feb,2017.
   LastModified Date: 16th Feb,2017
   Last Modified By: Jenish Shingala.
   Description: Extension for StrategicDealInformation Page.
*/
   
public with sharing class StrategicDealInfoController {
    
    Public Opportunity objOpp{get;set;}
    Public string currentOppId{get;set;}
    Public static Map<String,String> localeToDateTimeFmtMap;
    Public string currentUserDateFormat{get;set;}
    
    public StrategicDealInfoController(ApexPages.standardcontroller con){
        currentOppId = ApexPages.currentPage().getParameters().get('id');
        if(currentOppId!=null && currentOppId!=''){
            objOpp = [select id,name,Customer_Decision_Date__c,Tender_Due_Date__c,Governance_Support_Needed__c,Maximum_Tender_Price__c,
            Price_Weight__c,Price_HRC_Rating__c,Specification_Weight__c,Specification_HRC_Rating__c,Service_Weight__c,Service_HRC_Rating__c,
            Relationship_Weight__c,Quality_HRC_Rating__c,Quality_Weight__c,SWOT_Details__c,Customer_Specification__c,Relationship_HRC_Rating__c,
            Hill_Rom_Proposal__c from Opportunity where id=:currentOppId LIMIT 1];
        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Opportunity id can not be null.'));
        }
        
         
    }
    
    public PageReference saveDealReview(){
        
      try{
            if(objOpp!=null)
                update objOpp;
            return new PageReference('/'+currentOppId);
        }
        catch(Exception e){
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, e.getmessage()));
            return null;
        }
        
        
    }
    
}