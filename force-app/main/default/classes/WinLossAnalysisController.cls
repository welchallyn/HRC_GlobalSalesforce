/* ClassName: WinLossAnalysisController 
   Created By: Jenish Shingala.
   Created Date: 29th Sep,2017.
   LastModified Date: 29th Sep,2017
   Last Modified By: Jenish Shingala.
   Description: Extension for WinLossAnalysis Page.
*/
public class WinLossAnalysisController {
    Public Opportunity objOpp{get;set;}
    Public string currentOppId{get;set;}
    public WinLossAnalysisController(ApexPages.standardcontroller con){
        currentOppId = ApexPages.currentPage().getParameters().get('id');
        if(currentOppId!=null && currentOppId!=''){
            objOpp = [select id,name,Win_Loss_Analysis__c,Win_Loss_Analysis_Submission_Date__c,Price_Reasons__c,StageName,
                     Competitor2__c,Competitor_Product__c,Competitor_Price__c,Specification_Reasons__c,Quality_Reasons__c,
                     Service_Reasons__c,Relationship_Reasons__c,Loss_Comment__c from Opportunity where id=:currentOppId LIMIT 1];
        }
        else{
            apexPages.addmessage(new apexpages.message(apexpages.severity.Error, 'Opportunity id can not be null.'));
        }
    }
    
    public PageReference saveWinLossAnalysis(){
        
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