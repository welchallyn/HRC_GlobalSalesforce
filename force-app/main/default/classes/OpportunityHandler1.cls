/*
    *  ClassName    : OpportunityHandler
    *  CreatedOn    : 6/Oct/2015
    *  ModifiedOn   : 31/Jan/2017
    *  CreatedBy    : ESiewert
    *  ModifiedBy   : Jenish Shingala
    *  Description  : Used for populating "Has Generics" on Opportunity from child line items. 
*/
public with sharing class OpportunityHandler1 
{
    /* Start Variables */
    //private static Map<Id, List<Opportunity>> mapOppsToEvaluate;
    //public static Datetime testDatetimeNow;
     
    /* End Variables */
    
    set<id> INTRecordtypes = new set<id>();
    //Method to collect opportunity recordtypes ids which are starting with INT.
    public void getINTRecordTypes(){
        List<Recordtype> lstINTRecordtypes = [SELECT id,Name FROM RecordType where sobjecttype='Opportunity' and name like 'INT%'];
                for(Recordtype objRecordtype:lstINTRecordtypes){
                    INTRecordtypes.add(objRecordtype.id);
                }
    }
    
    /* start - constructor */ 
    public OpportunityHandler1()
    {
        //Do Nothing
    }
    /* end - constructor */ 
    
    /*
        * MethodName : onBeforeInsert
        * Param      : (nothing)
        * Description: Triggers on before insert 
    */  
    
    public void onBeforeInsert(List<Opportunity> lstOppNew)
    {
        //Do Nothing
    }
    
    /*
        * MethodName    : onBeforeUpdate
        * Param         :  
        * Description   : Triggers on before update. Evaluates whether a generic is present, flags HasGeneric as true if true, removes if false.
    */ 
    
    public void onBeforeUpdate(map<Id , Opportunity> mapIdToOppOld , List<Opportunity> lstOppNew)
    
    {
    
       //product --> Opp: 
       //1) hasGenerics logic flag Opp as hasGenerics=true when it contains 1 or more line items linked to Generic Products. 
       //2) hasRVNCamera logic flag Opp as hasCamera=true when it contains 1 or more line items linked to RetinaVue Cameras.
      
       Map<Id,opportunity> oppMap = new Map<Id,opportunity>();
       //list to store all opps w generics
       List<Id> oppId = new List<Id>();
       //list to store all opps w rvn cameras
       List<Id> oppRVNId = new List<Id>();
       for(opportunity opp: lstOppNew)
       {
         //preset values as false
         opp.hasGenerics__c=false;
         opp.hasRVNCamera__c=false;
         oppMap.put(opp.Id,opp);
       }
        
       //Issue #99 (SAVO tags) variable initialization
       set<id> opportunityids = new set<id>();
       list<string> lstOfSavoTags = new list<string>();
       set<string> setSavotags = new set<string>();       
     
       for(OpportunityLineItem oli : [select Id,Name,ProductCode,isGeneric__c,opportunityId,savo_tag__c,opportunity.hasGenerics__c
                                      from OpportunityLineItem where opportunityId IN : lstOppNew order by lastmodifieddate asc])
        {
          //check for generics
          if(oli.isGeneric__c==true)
          { 
            oppId.add(oli.opportunityId);
          }
          //system.debug(oli.ProductCode);
          //check for RVN cameras
          if(oli.ProductCode == 'RV100-B' || oli.ProductCode == '723427' || oli.ProductCode == '723468')
          { 
            oppRVNId.add(oli.opportunityId);
          }
          //check for savo tags
          opportunityids.add(oli.opportunityid); 
          if(oli.savo_tag__c!=null){
              lstOfSavoTags.add(oli.savo_tag__c);
          }                           
        }
        system.debug('oppid-->'+opportunityids);
        system.debug('opps with RVN Cameras-->'+oppRVNId);
        system.debug('opps with generics-->'+oppId);
        system.debug('savo tags-->'+lstOfSavoTags);
        
        if(lstOfSavoTags!=null){
            for(string objStr:lstOfSavoTags){
                setSavotags.add(objStr);
            }
        }
        
        if(opportunityids!=null){
            for(ID objOppId:opportunityids){
                if(oppMap.get(objOppId).First_Savo_tag__c==null){
                    if(lstOfSavoTags!=null && lstOfSavoTags.size()>0){
                        oppMap.get(objOppId).First_Savo_tag__c = lstOfSavoTags[0];
                    }
                    
                }
                
                if(setSavotags!=null && oppMap.get(objOppId).First_Savo_tag__c!=null &&
                   !setSavotags.contains(oppMap.get(objOppId).First_Savo_tag__c)){
                       if(lstOfSavoTags!=null && lstOfSavoTags.size()>0){
                            oppMap.get(objOppId).First_Savo_tag__c = lstOfSavoTags[0];
                        }
                   }
                
               
                
            }
        }
        
        if(lstOfSavoTags==null || lstOfSavoTags.size()<1)
            lstOppNew[0].First_Savo_tag__c ='';
        
        
        ///////////////////////////////////

        
        
        for(Id opId : oppId) 
        {
         oppMap.get(opId).hasGenerics__c=true;
        }
        for(Id opId : oppRVNId) 
        {
         oppMap.get(opId).hasRVNCamera__c=true;
        }
        
        updateICDateField(mapIdToOppOld,lstOppNew);
        countUnfilledDealReviewFields(lstOppNew);
        RVNOCRcheck(lstOppNew);
    }
    
    /*
        * MethodName : onAfterUpdate
        * Param      : 
        * Description: Triggers on after update. For each Opp, validate whether or not it has a generic and update as necessary.
    */ 
    
    public void onAfterUpdate(map<Id , Opportunity> mapIdToOppOld , map<Id , Opportunity> mapIdToOppNew)
    {
         //Do Nothing
    
    }
    
    /*
        * MethodName : onBeforeDelete
        * Param      :  
        * Description: Triggers on before delete 
    */ 
    
    public void onBeforeDelete(map<Id , Opportunity> mapIdToOppOld)
    {
        //Do Nothing
    }
    
    /*
        * MethodName : onAfterDelete
        * Param      :  
        * Description: Triggers on after delete 
    */  
    public void onAfterDelete(map<Id , Opportunity> mapIdToOppOld)
    {
        //Do Nothing
    }
    
    /*
        * MethodName : RVNOCRcheck
        * Param      : newOpportunity
        * Description: if hasRVNCamera is true. This method will query OpportunityContactRole for all current Opportunities. 
                       For each of these Opportunities where hasRVNCamera__c, 1 or more OpportunityContactRole must exist where
                       Role = 'Legal'. If not, set sufficient_OCRs__c = false. if true, set to true.
        
    */ 
    
    public void RVNOCRcheck(List<Opportunity> newOpportunity){
        Set<id> OpportunityIds = new Set<id>();
        Map<string,OpportunityContactRole> mapOppIDOppContactRole = new Map<string,OpportunityContactRole>();
        for(Opportunity objOpp:newOpportunity){
            if(objOpp.hasRVNCamera__c==true)
                OpportunityIds.add(objOpp.id);
        }
        if(OpportunityIds!=null && OpportunityIds.size()>0){
            List<OpportunityContactRole> lstOppContactRole = [SELECT Id,OpportunityId,Role FROM OpportunityContactRole 
                                                         where OpportunityId in :OpportunityIds and Role='Legal'];
            if(lstOppContactRole!=null && lstOppContactRole.size()>0){
                for(OpportunityContactRole objRole:lstOppContactRole){
                    mapOppIDOppContactRole.put(objRole.OpportunityId, objRole);
                }
            }
            
            for(Opportunity objOpp:newOpportunity){
                 if(objOpp.hasRVNCamera__c && mapOppIDOppContactRole.containsKey(objOpp.id))
                    objOpp.Sufficient_OCRs__c = true;
                 else
                    objOpp.Sufficient_OCRs__c = false;
            }
        }
        
        
        
    }
    
    /*
        * MethodName : countUnfilledDealReviewFields
        * Param      : 
        * Description: Method to count unfilled deal review fields.
        
    */ 
    
    public void countUnfilledDealReviewFields(List<Opportunity> newOpportunity){
        decimal totalfilledFields = 0;
        for(Opportunity objOpp:newOpportunity){
            if(objOpp.Business_Awareness__c!=null && objOpp.Business_Awareness__c!='')
                totalfilledFields+=1;
            if(objOpp.OpportunityDescription__c!=null && objOpp.OpportunityDescription__c!='')
                totalfilledFields+=1;
            if(objOpp.SAVO_Compelling_Event__c!=null && objOpp.SAVO_Compelling_Event__c!='')
                totalfilledFields+=1;
            if(objOpp.Positive_Business_Outcomes__c!=null && objOpp.Positive_Business_Outcomes__c!='')
                totalfilledFields+=1;
            if(objOpp.Minimum_Required_Capabilities__c!=null && objOpp.Minimum_Required_Capabilities__c!='')
                totalfilledFields+=1;
            if(objOpp.Metrics__c!=null && objOpp.Metrics__c!='')
                totalfilledFields+=1;
            if(objOpp.SAVO_Competitive_Situation__c!=null && objOpp.SAVO_Competitive_Situation__c!='')
                totalfilledFields+=1;
            if(objOpp.Identify_the_Mobilizers__c!=null && objOpp.Identify_the_Mobilizers__c!='')
                totalfilledFields+=1;
            if(objOpp.Identify_the_Blockers__c!=null && objOpp.Identify_the_Blockers__c!='')
                totalfilledFields+=1;
            if(objOpp.Identify_the_Champion__c!=null && objOpp.Identify_the_Champion__c!='')
                totalfilledFields+=1;
            if(objOpp.Decision_Process__c!=null && objOpp.Decision_Process__c!='')
                totalfilledFields+=1;
            if(objOpp.SAVO_Criteria_Favorable_to_WA__c!=null && objOpp.SAVO_Criteria_Favorable_to_WA__c!='')
                totalfilledFields+=1;
            if(objOpp.Value_Drivers__c!=null && objOpp.Value_Drivers__c!='')
                totalfilledFields+=1;
            if(objOpp.SAVO_Criteria_Unfavorable_to_WA__c!=null && objOpp.SAVO_Criteria_Unfavorable_to_WA__c!='')
                totalfilledFields+=1;
            if(objOpp.How_we_do_it__c!=null && objOpp.How_we_do_it__c!='')
                totalfilledFields+=1;
            if(objOpp.How_we_do_it_better__c!=null && objOpp.How_we_do_it_better__c!='')
                totalfilledFields+=1;
            if(objOpp.Resource_Utilization__c!=null && objOpp.Resource_Utilization__c!='')
                totalfilledFields+=1;
            if(objOpp.Connectivity_Information__c!=null && objOpp.Connectivity_Information__c!='')
                totalfilledFields+=1;
            if(objOpp.Contract_Information__c!=null && objOpp.Contract_Information__c!='')
                totalfilledFields+=1;
                
                objOpp.Total_Deal_Review_filled_Fields__c = totalfilledFields;
             
            
                
        }
    }
    
     /*
        * MethodName : updateICDateField
        * Param      : 
        * Description: Update IC Date field if any field change occures on Deal Review Page.
        
    */ 
    
    public void updateICDateField(map<Id,Opportunity> mapIdToOppOld,List<Opportunity> lstOpportunityNew){
        for(Opportunity objOpp:lstOpportunityNew){
            Opportunity oldOpportunity = mapIdToOppOld.get(objOpp.id);
            if(objOpp.Business_Awareness__c!=oldOpportunity.Business_Awareness__c || objOpp.OpportunityDescription__c!=oldOpportunity.OpportunityDescription__c
              || objOpp.SAVO_Compelling_Event__c!=oldOpportunity.SAVO_Compelling_Event__c || objOpp.Value_Drivers__c!=oldOpportunity.Value_Drivers__c ||
              objOpp.Positive_Business_Outcomes__c!=oldOpportunity.Positive_Business_Outcomes__c || objOpp.Minimum_Required_Capabilities__c!=oldOpportunity.Minimum_Required_Capabilities__c ||
              objOpp.Metrics__c!=oldOpportunity.Metrics__c || objOpp.SAVO_Competitive_Situation__c!=oldOpportunity.SAVO_Competitive_Situation__c ||
              objOpp.Identify_the_Mobilizers__c!=oldOpportunity.Identify_the_Mobilizers__c || objOpp.Identify_the_Blockers__c!=oldOpportunity.Identify_the_Blockers__c ||
              objOpp.Identify_the_Champion__c!=oldOpportunity.Identify_the_Champion__c || objOpp.Decision_Process__c!=oldOpportunity.Decision_Process__c ||
              objOpp.SAVO_Criteria_Favorable_to_WA__c!=oldOpportunity.SAVO_Criteria_Favorable_to_WA__c || objOpp.SAVO_Criteria_Unfavorable_to_WA__c!=oldOpportunity.SAVO_Criteria_Unfavorable_to_WA__c ||
              objOpp.How_we_do_it__c!=oldOpportunity.How_we_do_it__c|| objOpp.How_we_do_it_better__c!=oldOpportunity.How_we_do_it_better__c || 
              objOpp.Resource_Utilization__c!=oldOpportunity.Resource_Utilization__c || objOpp.Connectivity_Information__c!=oldOpportunity.Connectivity_Information__c ||
              objOpp.Contract_Information__c!=oldOpportunity.Contract_Information__c){
                objOpp.Deal_Review_IC_date__c = Datetime.now();
            }
        }
    }
    
}