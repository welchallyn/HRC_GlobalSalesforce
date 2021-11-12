/**
 * @class Trigger handler for APTTUS Quote/Proposal custom object
 * @author e neiman, Apttus PS
 * @date 6/12/2014; resetContract, 6/17/2014
   updatedby: VRS
 */
public  class APTPS_QuoteProposalTriggerHandler {  
    
    
    public static void setNewProposal(List<Apttus_Proposal__Proposal__c> proposals) {
        //eneiman, 6.4.2014; auto assign price list and generate available contracts.
        for (Apttus_Proposal__Proposal__c prop : proposals) {
        string sContract = '';
        for (List<Pricing_Contract__c> contrSet:[Select Name, contract_description__c FROM Pricing_Contract__c WHERE Account__c=:prop.Apttus_Proposal__Account__c order by Contract_Start_Date__c DESC]) {
            for (Pricing_Contract__c contract : contrSet ) {
                sContract = sContract + contract.name + ' - ' + contract.contract_description__c + '\n';
            }
         }
        prop.Supported_Contracts__c = sContract;
        for(List<Apttus_Config2__PriceList__c> pbs : [SELECT id FROM Apttus_Config2__PriceList__c where Apttus_Config2__Active__c = TRUE and name like '%2018%' LIMIT 1]){
             for (Apttus_Config2__PriceList__c pb : pbs){
                  prop.Apttus_QPConfig__PriceListId__c =pb.Id;
             }
        }   
        prop.APTPS_End_User_Country__c = 'US - UNITED STATES';
        }
    }
    
public static void resetContract(List<Apttus_Proposal__Proposal__c> proposals, Map<Id, Apttus_Proposal__Proposal__c> oldMap) {
   for (Apttus_Proposal__Proposal__c prop : proposals) {
       if (prop.APTS_Override_Contract__c!=oldMap.get(prop.Id).APTS_Override_Contract__c) {
                  for (List<Pricing_Contract__c> ListOfContracts : [SELECT Contract__c,Name FROM Pricing_Contract__c WHERE Id = :prop.APTS_Override_Contract__c LIMIT 1]){
                      for (Pricing_Contract__c contract : ListOfContracts ){
                          prop.Override_Contract_Number__c = contract.Contract__c;
                          prop.APTS_Contract_Number__c = contract.name;
                      }
                  }     
       }
   } 
}   


/*
Method populateApprovers modified by Chang Liu @ Apttus. Added function: when Level_1_Approver_ID__c and Level_2_Approver_ID__c are null, then use the custom metadata "Custom_Approver__mdt" to assign the approver

Modified @ Dec 21 2017 by Chang Liu @ Apttus. In addition to check "if both are null", we are also going to check "if either one is null, check the Opportunity Record Type, then pull the approver from Custom Metadata Type and apply to the one that is empty."
*/
public static void populateApprovers(List<Apttus_Proposal__Proposal__c> newlist)
{
    map<Id,User> usermap=new map<Id,User>();
    set<string> strset= new set<string>();
    for(Apttus_Proposal__Proposal__c prop:newList)
    {
         system.debug('prop.Level_1_Approver_ID__c: ' + prop.Level_1_Approver_ID__c);
         system.debug('prop.Level_2_Approver_ID__c: ' + prop.Level_2_Approver_ID__c);
        
         if(prop.Level_1_Approver_ID__c != null && prop.Level_1_Approver_ID__c != '')
             strset.add(prop.Level_1_Approver_ID__c); 
         if(prop.Level_2_Approver_ID__c != null && prop.Level_2_Approver_ID__c != '')
            strset.add(prop.Level_2_Approver_ID__c);
    }
    system.debug('*****strset: ' + strset);
       
    if(strset.size() != 0){
       usermap=new map<Id,User>([select id,name,jde_external_id__c from user where jde_external_id__c in:strset]); 
       system.debug('*****usermap: ' + usermap);
       map<string,user> jdeExtId_Map=new map<string,User>();
       for(Id userId: usermap.keyset())
       {
        user u=usermap.get(userId);  
        jdeExtId_Map.put(u.jde_external_id__c,u);  
       }
       system.debug('*****jdeExtId_Map: ' + jdeExtId_Map);
        
       for(Apttus_Proposal__Proposal__c prop:newList)
       {
        prop.Level_1_Approver__c= jdeExtId_Map.ContainsKey(prop.Level_1_Approver_ID__c)?jdeExtId_Map.get(prop.Level_1_Approver_ID__c).id:null;
        prop.Level_2_Approver__c= jdeExtId_Map.ContainsKey(prop.Level_2_Approver_ID__c)?jdeExtId_Map.get(prop.Level_2_Approver_ID__c).id:null;  
       }
    }
    
    //added by Chang Liu 
    if(strset.size() == 0 || strset.size() == 1){
        //match the "Opportunity Reocrd Type" field of lookup object Opportunity, from the proposal object.
        for(Apttus_Proposal__Proposal__c prop:newList){
            Apttus_Proposal__Proposal__c sameProp = [select id, name, Apttus_Proposal__Opportunity__r.RecordTypeId from Apttus_Proposal__Proposal__c where id = :prop.id];
            RecordType recType = [Select id, name from RecordType where id = :sameProp.Apttus_Proposal__Opportunity__r.RecordTypeId];
            system.debug('*****the opportunity record type from the proposal is: ' + recType.name);
            //DeveloperName is Custom Metadata Record Name, which is the label of LIKO, etc.
            List<Custom_Approver__mdt> customApprover = [Select Approver_ID__c, DeveloperName, NamespacePrefix from Custom_Approver__mdt where DeveloperName = :recType.name];
            
            if(prop.Level_1_Approver_ID__c == null || prop.Level_1_Approver_ID__c == ''){
                prop.Level_1_Approver__c= customApprover[0].Approver_ID__c;
            }
            if(prop.Level_2_Approver_ID__c == null || prop.Level_2_Approver_ID__c == ''){
                prop.Level_2_Approver__c= customApprover[0].Approver_ID__c;
            }   
            
            system.debug('*****prop.Level_1_Approver__c: ' + prop.Level_1_Approver__c);
            system.debug('*****prop.Level_2_Approver__c: ' + prop.Level_2_Approver__c);
        }
    }
} 

    
}