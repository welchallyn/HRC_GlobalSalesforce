/**
*   @Only users of a certain profile can edit/add opportunities.
    Last modified by: Jenish Shingala.. Added Custom metadata types logic..
*/
public with sharing class OpportunityValidateUserCanEdit {
        
    public static void validateUserCanEdit(List<Opportunity> opportunityList, Map<Id,Opportunity> oldOpportunityMap, Boolean isUpdate) {
        
        User currentUser = [select id, profileId from user where id = :UserInfo.getUserId()] ;
        String profileName = [Select Name from Profile where id = :currentUser.ProfileId][0].Name ;
        Map<Id,RecordType> oppRecordTypes = new Map<Id,RecordType>( [select Id, DeveloperName from RecordType where isactive = true and sobjecttype = 'Opportunity'] ) ;
        
        
        if(profileName.startsWith('INT') || profileName == 'System Administrator'||profileName == 'HRC Sales Admin Power'||profileName == 'HRC Sales Admin'||profileName == 'HRC Sales Admin Global'||
        profileName == 'HRC Sales Admin Regional'||profileName == 'HRC Intl Sales Admin'||profileName == 'HRC Intl Sales Admin Power'||profileName == 'HRC RC Sales Admin'||profileName == 'HRC RC Sales Admin Power'||
        profileName =='HRC DataLoader' || profileName == 'Birlasoft System Admin' || profileName == 'HRC Marketing Manager Global' ) {
                //override
                return;
            }
            
        for(Opportunity opportunity : opportunityList) {
            
            RecordType recordType = oppRecordTypes.get(opportunity.RecordTypeId) ;

            /***Below Code Commented by Varun Gupta on 27th April 2020 as part of CR00027606***/
            // if(recordType != null && recordType.DeveloperName!=System.Label.Opp_WA_RecordType_developer_Name) {
            
                /***Modified the Error Messages to differentiate the Custom Messages. By Varun Gupta on 28th April 2020 as part of CR00027606***/
                if(recordTypeMatchesTheCheckableList(recordType.DeveloperName)) 
                {
                    if(isUpdate) 
                    {
                        if( profileAndRecordTypeMatch(opportunity, profileName, oppRecordTypes) ) {
                            
                        }else{
                            if(opportunity.OwnerId != currentUser.Id) {
                                //opportunity.addError( 'Your profile must align with the record type in order to edit this Opportunity.' );
                                opportunity.addError( 'According to current Business Rules, Your profile must align with the record type in order to edit this Opportunity.' );
                            }
                        }
                    }
                    else 
                    {
                        if(!profileAndRecordTypeMatch(opportunity, profileName, oppRecordTypes)) {
                            //opportunity.addError( 'Your profile must align with the record type in order to add an Opportunity of this type.' );
                            opportunity.addError( 'According to current Business Rules, Your profile must align with the record type in order to add an Opportunity of this type.' );
                        }
                    }
                    
                }
                else
                {
                    if(isUpdate) {
                        if(opportunity.OwnerId != currentUser.Id) {
                            //opportunity.addError( 'Only the record owner can edit this record.' );
                            opportunity.addError( 'According to current Business Rules, You need to be the owner to edit this record.' );
                        }
                    }else{
                        //nothing here unless rules change regarding who can insert "special-case recordTypes".
                    }
                    
                }
                
            //}
            
        }
        
        
        
    }
       
    /*Removed hardcoded values and added new logic.*/
    
    private static Boolean recordTypeMatchesTheCheckableList(String recordType)
    {    
         Set<string> recordtypenames = new Set<string>();
         List<Recordtype__mdt> lstmetadata = [SELECT DeveloperName FROM Recordtype__mdt LIMIT 100];
         if(lstmetadata!=null && lstmetadata.size()>0){
             for(Recordtype__mdt objRecordtype:lstmetadata){
                 recordtypenames.add(objRecordtype.DeveloperName);
             }
             if(recordtypenames.contains(recordType)){
                 return true;
             }
             else 
                 return false;
         }
        return false; 
    }
    
     
    
    /**
    *
    *   Only get edit ability if user is on the account team, they have that profile, AND if the opportunity is the record type matches the profile as follows:
    *
    *   Capital - AE, Respritory, Homecare, Capital Manager (CM), Account Clinical Manager (ACM), Marketing Specialist (MKTS), AE -International, INT Sales Direct
    *   Architectural - AE, Mobility Specialist (MBS), Architectural Specialist (AS), AE International
    *   HITS - AE, ITSE(SSE)
    *   LIKO - AE, Architectural Specialist (AS), Mobility Specialist (MBS), AE International
    *   Service Contracts - AE, Contract Sales Director (CTSD)
    *   Rental - AE, Account Clinical Director (ACD), Account Manager (ACM), AE International
    *
    *   ----TRANSLATED
    *   Capital = HRC Account Executive, HRC Respiratory, HRC Homecare, HRC Capital Manager, HRC Account Clinical Manager, HRC Marketing Specialist, HRC AE International, INT Sales Direct
    *   Architectural - HRC Account Executive, HRC Mobility Specialist, HRC Architectural Specialist, HRC AE International
    *   HITS - HRC Account Executive, HRC ITSE
    *   LIKO - HRC Account Executive, HRC Architectural Specialist, HRC Mobility Specialist, HRC AE International
    *   Service Contract - HRC Account Executive, HRC Contract Sales Director
    *   Rental - HRC Account Executive, HRC Rental Sales Specialist, HRC Account Manager, HRC AE International
    */
    
//and the other record types should follow normal rules, so only the owner should be able to edit the oppty, but anyone on the account team should have visibility for the oppty
        
    private static Boolean profileAndRecordTypeMatch(Opportunity opportunity, String profileName, Map<Id,RecordType> oppRecordTypes)
    {
        RecordType recordType = oppRecordTypes.get(opportunity.RecordTypeId) ; 
        
        map<string,set<string>> maprecordtypeprofiles = new map<string,set<string>>();
        List<Recordtype__mdt> lstmetadata = [SELECT DeveloperName,Profiles__c FROM Recordtype__mdt LIMIT 100];
        for(Recordtype__mdt objmetadata:lstmetadata){
            list<string> lstprofilenames = objmetadata.Profiles__c.split(';');
            set<string> profilenamesset = new set<string>();
            for(string objstr:lstprofilenames){
                profilenamesset.add(objstr);
            }
            maprecordtypeprofiles.put(objmetadata.DeveloperName,profilenamesset);
        }
              
        
        if(recordType != null) {
            String recordTypeString = recordType.DeveloperName ;
            if(maprecordtypeprofiles.get(recordTypeString)!=null && maprecordtypeprofiles.get(recordTypeString).contains(profilename)){
                return true;
            }
            else
                return false;           
        }
        
        return false ; 
        
    }    
}