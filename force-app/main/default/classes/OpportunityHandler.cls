/*
 *  ClassName    : OpportunityHandler
 *  CreatedOn    : 11/Nov/2016
 *  ModifiedOn   : 23/July/2018 
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  : Used for Handling all events for Opportunities (Opportunity). 
 */
public with sharing class OpportunityHandler {
    
    set<id> INTRecordtypes = new set<id>();
    //Method to collect opportunity recordtypes ids which are starting with INT.
    public void getINTRecordTypes(){
        List<Recordtype> lstINTRecordtypes = [SELECT id,Name FROM RecordType where sobjecttype='Opportunity' and name like 'INT%'];
                for(Recordtype objRecordtype:lstINTRecordtypes){
                    INTRecordtypes.add(objRecordtype.id);
                }
    }
   
    /*
     * MethodName : onBeforeInsert
     * Param      : 
     * Description: Triggers on before insert 
     */
     public void onBeforeInsert(List <Opportunity> lstOpportunityNew,Map<id,Opportunity> oldMap,Boolean isUpdate) {
            getINTRecordTypes();
            //Exclusion of INT Recordtypes.
            if(!INTRecordtypes.contains(lstOpportunityNew[0].recordtypeid)){
                 BeforeInsertUpdate(lstOpportunityNew); 
                 //Method call from Opportunity Trigger which will be deactivated
                 HRC_OpportunityNamingController.setOpportunityName(lstOpportunityNew, oldMap, isUpdate);
                 // OpportunityValidateUserCanEdit.validateUserCanEdit(lstOpportunityNew, oldMap, isUpdate) ;
            }
             
        }
        /*
         * MethodName : onAfterInsert
         * Param      : lstOpportunityNew
         * Description: Triggers on after insert 
         */

    public void onAfterInsert(List <Opportunity> lstOpportunityNew,Map<id,Opportunity> newMap,Boolean isUpdate) {
        getINTRecordTypes();
        //Exclusion of INT Recordtypes.
        if(!INTRecordtypes.contains(lstOpportunityNew[0].recordtypeid)){
            OrderToOpp(lstOpportunityNew);
            ProposalToOpp(lstOpportunityNew);
            //Method call from Opportunity Trigger which will be deactivated
            OpportunityUtil.evaluateOpportunitySharing(null,newMap,isUpdate);
        }
        
    }

    /*
     * MethodName    : onBeforeUpdate
     * Param         : lstOpportunityNew.
     * Description   : 
     */

    public void onBeforeUpdate(List<Opportunity> lstOpportunityNew,Map<id,Opportunity> oldMap,Boolean isUpdate) {
        getINTRecordTypes();
        //Exclusion of INT Recordtypes.
        if(!INTRecordtypes.contains(lstOpportunityNew[0].recordtypeid)){
            HRC_OpportunityNamingController.setOpportunityName(lstOpportunityNew, oldMap, isUpdate);
            BeforeInsertUpdate(lstOpportunityNew);
            //Method call from Opportunity Trigger which will be deactivated
            OpportunityValidateUserCanEdit.validateUserCanEdit(lstOpportunityNew, oldMap, isUpdate);
        }
        //This method will call irrespective of INT Recordtypes.
        MarkHasGenericCheck(lstOpportunityNew);
        
        
    }
    
    /*
     * MethodName    : onAfterUpdate
     * Param         : lstOpportunityNew.
     * Description   : 
     */

    public void onAfterUpdate(List<Opportunity> lstOpportunityNew,Map<id,Opportunity> oldMap,Map<id,Opportunity> newMap,Boolean isUpdate) {
        getINTRecordTypes();
        //Exclusion of INT Recordtypes.
        if(!INTRecordtypes.contains(lstOpportunityNew[0].recordtypeid)){
            OpportunityUtil.evaluateOpportunitySharing(oldMap, newMap, isUpdate);
        }
    }
     
    /*Mark isGeneric Checkbox based on Opportunity Recordtype*/
    public void MarkHasGenericCheck(List<Opportunity> lstOppNew){
        set<id> recordTypeIds = new set<id>();
       //Query on International Sales Process.
       BusinessProcess  objBusinessProcess = [SELECT Id,Name FROM BusinessProcess where name = 'International'];
       if(objBusinessProcess!=null){
           //Query on Opportunity Recordtypes which has 'International' Sales Process.
            List<RecordType> lstRecordType = [SELECT BusinessProcessId,DeveloperName,Id FROM RecordType 
                                             where sObjectType = 'Opportunity' AND BusinessProcessId = :objBusinessProcess.id];
            if(lstRecordType!=null && lstRecordType.size()>0){
                for(RecordType objRecordType:lstRecordType){
                    recordTypeIds.add(objRecordType.id);
                }
            }
        }
    
       Map<Id,opportunity> oppMap = new Map<Id,opportunity>();
       List<Id> oppId = new List<Id>();
       for(opportunity opp: lstOppNew)
       {
         opp.hasGenerics__c=false;
         oppMap.put(opp.Id,opp);
       }
     
    
       for(OpportunityLineItem oli : [select Id,Name ,isGeneric__c,opportunityId,opportunity.hasGenerics__c from OpportunityLineItem 
                                     where opportunityId IN : lstOppNew ])
       
        {
          if(oli.isGeneric__c==true)
          {
            oppId.add(oli.opportunityId); 
        
          
          }
     
        } 
        
        
        for(Id opId : oppId)
        {
         if(oppMap.get(opId).RecordTypeId!=null && recordTypeIds.contains(oppMap.get(opId).RecordTypeId))
            oppMap.get(opId).hasGenerics__c=true;
        }
    }
    
     /*Code of Previous trigger:  OrderToOpp which will we deactivated and consolidated into handler.*/
     
      public void OrderToOpp(List < Opportunity > lstOpportunityNew) {
      Set < String > stOrderId = new Set < String > ();
      Set < Id > stORLId = new Set < Id > ();
      List < OpportunityLineItem > lstOppLine = new List < OpportunityLineItem > ();
      List < Order__c > lstOrd = null;
      Map < String, Order__c > opportunityOrderMap = new Map < String, Order__c > ();
      List < Order__c > orderList = null;
      String strOppId;
      Boolean strcheck;
      Map < String, Opportunity > orderOpportunityMap = new Map < String, Opportunity > ();
      for (Opportunity o: lstOpportunityNew) {
          stOrderId.add(o.Proposal_number__C);
          strcheck = o.Converted_from_Order__c;
          orderOpportunityMap.put(o.Proposal_number__C, o);
      }
      if (strcheck == True) {
          orderList = [Select id, name from order__c where name in: stOrderId];
          if(orderList!=null && orderList.size()>0){
              for (order__c order: orderList) {
                  opportunityOrderMap.put(order.name, order);
              }
          }
          
          system.debug('set..............' + stOrderId);
          if (orderList.size() > 0) {

              List < Order_Line_Item__c > lstOrdLine = [Select id, Order__c, Quantity__c, Sys_discount__c, Package_Options__c,
                  Package_code__c, Item_Description__c, Extended_Line_Amount__c, List_price__c
                  from Order_Line_Item__c where Parent_Line__c = null and Package_code__c != null and Order__c in: orderList
              ];
              if (lstOrdLine.size() == 0) {
                  lstOpportunityNew[0].addError('Opportunity is created and line items are not added because package code\'s don\'t match any current products. Please add line items manually.');
              } else {
                  Set < String > codeSet = new Set < String > ();
                  for (Order_Line_Item__c ordline: lstOrdLine) {
                      codeSet.add(ordline.Package_code__c);
                      system.debug('############' + codeSet);
                  }
                  list < Product2 > p2 = [select Package_code__c from product2 where package_code__c in: codeSet and(NOT Family like 'APTtus_%')];
                  system.debug('####$$$$$$$$$$' + p2);
                  if (p2.size() == 0) {
                      lstOpportunityNew[0].addError('Opportunity is created and line items are not added because package code\'s don\'t match any current products. Please add line items manually.');
                      //opp.addError(workItemId);
                  } else {
                      Map < Id, Product2 > productMap = new Map < ID, Product2 > ([select id, Package_code__c from Product2 where
                          package_code__c in: codeSet and(NOT Family like 'APTtus_%')
                      ]);

                      Map < String, Product2 > packageCodeProduct2Map = new Map < String, Product2 > ();

                      for (Product2 prod: productMap.values()) {
                          packageCodeProduct2Map.put(prod.Package_code__c, prod);
                      }

                      Map < String, List < Order_Line_Item__c >> orderOrderLineItemMap = new Map < String, List < Order_Line_Item__c >> ();
                      List < Order_Line_Item__c > orderLineItemList = null;
                      for (Order_Line_Item__c oli: lstOrdLine) {

                          if (orderOrderLineItemMap.containsKey(oli.order__c)) {
                              orderOrderLineItemMap.get(oli.order__c).add(oli);
                          } else {
                              orderLineItemList = new List < Order_Line_Item__c > ();
                              orderLineItemList.add(oli);
                              orderOrderLineItemMap.put(oli.order__c, orderLineItemList);
                          }

                      }



                      List < PriceBookEntry > lstPbeId = [select Id, Product2Id, CurrencyIsoCode from PriceBookEntry where CurrencyIsoCode = 'usd'
                          and isactive = true and Pricebook2id = '01sE0000000HpytIAC' and Product2Id in: productMap.keySet()
                      ];

                      Map < String, List < PriceBookEntry >> prodPriceBookMap = new Map < String, List < PriceBookEntry >> ();
                      List < PriceBookEntry > pbeList = null;
                      if(lstPbeId!=null && lstPbeId.size()>0){
                           for (PriceBookEntry pbe: lstPbeId) {
                              if (prodPriceBookMap.containsKey(pbe.product2ID)) {
                                  prodPriceBookMap.get(pbe.product2ID).add(pbe);
                              } else {
                                  pbeList = new List < PriceBookEntry > ();
                                  pbeList.add(pbe);
                                  prodPriceBookMap.put(pbe.product2ID, pbeList);
                              }
    
                          }
                      }
                     

                      List < PriceBookEntry > orderPBEList = null;


                      for (Opportunity o: lstOpportunityNew) {
                          String orderId = opportunityOrderMap.get(o.Proposal_number__C).id;
                          orderLineItemList = orderOrderLineItemMap.get(orderId);
                          if(orderLineItemList!=null && orderLineItemList.size()>0){
                               for (Order_Line_Item__c orl: orderLineItemList) {
                              // for each pricebook entry for each product_code in the order, create an oppporturni LI
                              for (product2 pr: p2) {
                                  if (orl.Package_code__c == pr.Package_code__c) {
                                      String productId = packageCodeProduct2Map.get(orl.Package_code__c).Id;
                                      orderPBEList = prodPriceBookMap.get(productID);
                                      for (PriceBookEntry pbe: orderPBEList) {
                                          OpportunityLineItem opl = new OpportunityLineItem();
                                          opl.Quantity = orl.Quantity__c;
                                          opl.OpportunityId = o.id;
                                          //opl.discount = orl.Sys_discount__c;
                                          opl.Package_options__c = orl.Package_Options__c;
                                          opl.Line_Item_Ship_Date__c = date.today();
                                          opl.TotalPrice = orl.Extended_Line_Amount__c;
                                          opl.PricebookentryId = pbe.id;
                                          opl.List_Price_edit__c = orl.List_price__c;

                                          lstOppLine.add(opl);
                                      }
                                  }

                              }
                           }

                          }
                         
                          //insert lstOppLine;
                      }
                      try {
                          if (lstOppLine != null)
                              insert lstOppLine;
                      } catch (Exception e) {
                          system.debug('Exception occured..' + e);
                      }
                  }

              }

          }
      }

  }
  
    public void BeforeInsertUpdate(List<Opportunity> lstOpportunityNew){
    system.debug('Inside beforeinsertupdate####');
        //Query for the Opportunity record types
        List < RecordType > rtypes = [Select Name, Id From RecordType
            where sObjectType = 'Opportunity'
            and isActive = true
        ];
        
        //Create a map between the Record Type Name and Id for easy retrieval
        Map < String, String > OpportunityRecordTypes = new Map < String, String > {};
        for (RecordType rt: rtypes)
            OpportunityRecordTypes.put(rt.Name, rt.Id);
        
        Map < Id, User > VALID_PROFILE_ID = new Map < Id, User > ();
        
        for (User U: [select ProfileId, Profile.Name
                from User
                where Profile.Name IN('HRC Account Manager', 'HRC Account Executive', 'HRC Account Clinical Manager')
            ]) {
            VALID_PROFILE_ID.put(U.ProfileId, U);
        }
        List < User > u = [SELECT ProfileId FROM User WHERE Id =: UserInfo.getUserId()];
        
        Id CurrentUserProfileId = u[0].ProfileId;
        set<string> proposalNumbers = new set<string>();
        set<string> jdeProposalnames = new set<string>();
        if ((VALID_PROFILE_ID.containskey(CurrentUserProfileId))) {
            
            for(Opportunity objOpportunity:lstOpportunityNew){
                 if (objOpportunity.Proposal_Number__c != Null) {
                     if (objOpportunity.RecordTypeId == OpportunityRecordTypes.get('Capital')) {
                        proposalNumbers.add(objOpportunity.Proposal_Number__c);
                     }
                 }
            }
            
            List<JDE_Prop__c> lstJDEProp = [Select Id, Name, Proposal_Expiration_Date__c from JDE_Prop__C where Name IN :proposalNumbers];
             if(lstJDEProp!=null && lstJDEProp.size()>0){
                for(JDE_Prop__c objJDEProp:lstJDEProp){
                    jdeProposalnames.add(objJDEProp.name);
                }
             }
             
            
            for (Opportunity o:lstOpportunityNew) {
        
                if (o.Proposal_Number__c != Null) {
                    if (o.RecordTypeId == OpportunityRecordTypes.get('Capital')) {
                        /*try {
        
                            JDE_Prop__c p = [Select Id, Name, Proposal_Expiration_Date__c from JDE_Prop__C where Name =: o.Proposal_Number__c];
        
        
                        } catch (QueryException e) {
                            o.addError('Proposal Number entered by you can not be found in the list of Proposal Number. Please enter the correct Proposal Number');
                        }  */
                        
                        if(!jdeProposalnames.contains(o.Proposal_Number__c)){
                            system.debug('Not contains $$$$');
                            o.addError('Proposal Number entered by you can not be found in the list of Proposal Number. Please enter the correct Proposal Number');
                        }
                    }
                }
        
        
            }
        }
    }
  
    /*Code of Previous trigger:  ProposalToOpp which will we deactivated and consolidated into handler.*/
    
    public void ProposalToOpp(List < Opportunity > lstOpportunityNew) {
      Set < String > stProposalId = new Set < String > ();
      Set < Id > stORLId = new Set < Id > ();


      List < OpportunityLineItem > lstOppLine = new List < OpportunityLineItem > ();
      List < JDE_Prop__c > lstOrd = null;
      Map < String, JDE_Prop__c > opportunityOrderMap = new Map < String, JDE_Prop__c > ();
      List < JDE_Prop__c > ProposalList = null;
      String strOppId;
      Boolean strcheck;
      Map < String, Opportunity > orderOpportunityMap = new Map < String, Opportunity > ();

      for (Opportunity o: lstOpportunityNew) {
          stProposalId.add(o.Proposal_number__C);
          strcheck = o.Converted_from_Proposal__c;
          system.debug('####$$$$$$$$$$' + o.Converted_from_Proposal__c);
          orderOpportunityMap.put(o.Proposal_number__C, o);
      }
      if (strcheck == True) {
          //Map<Id, Order__c) orderMap  = new Map(Id, Order__c){[Select id, name from order__c where id in :stOrderId)};

          ProposalList = [Select id, name from JDE_Prop__c where name in: stProposalId];
          if(ProposalList!=null && ProposalList.size()>0){
              for (JDE_Prop__c Proposal: ProposalList) {
                  opportunityOrderMap.put(Proposal.name, Proposal);
              }
          }
          
          system.debug('set..............' + stProposalId);
          if (ProposalList.size() > 0) {

              List < JDE_Prop_Ln_Item__c > lstProposalLine = [Select id, Proposal__c, Quantity__c, Sys_discount__c, Package_Options__c,
                  Package_code__c, Item_Description__c, Extended_Line_Amount__c, List_price__c
                  from JDE_Prop_Ln_Item__c where Parent_Line__c = null and Package_code__c != null and Proposal__c in: ProposalList
              ];

              if (lstProposalLine.size() == 0) {
                  lstOpportunityNew[0].addError('Opportunity is created and line items are not added because package code\'s don\'t match any current products. Please add line items manually.');

              } else {

                  Set < String > codeSet = new Set < String > ();
                  for (JDE_Prop_Ln_Item__c Proposalline: lstProposalLine) {
                      codeSet.add(Proposalline.Package_code__c);
                      system.debug('############' + codeSet);
                  }
                  list < Product2 > p2 = [select Package_code__c from product2 where package_code__c in: codeSet and(NOT Family like 'APTtus_%')];
                  system.debug('####$$$$$$$$$$' + p2);
                  if (p2.size() == 0) {
                      lstOpportunityNew[0].addError('Opportunity is created and line items are not added because package code\'s don\'t match any current products. Please add line items manually.');
                      //opp.addError(workItemId);
                  } else {

                      Map < Id, Product2 > productMap = new Map < ID, Product2 > ([select id, Package_code__c from Product2 where
                          package_code__c in: codeSet and(NOT Family like 'APTtus_%')
                      ]);

                      Map < String, Product2 > packageCodeProduct2Map = new Map < String, Product2 > ();
                      if(productMap.values()!=null){
                          for (Product2 prod: productMap.values()) {
                              packageCodeProduct2Map.put(prod.Package_code__c, prod);
                              system.debug('############' + packageCodeProduct2Map);
                          }
                      }
                      
                      Map < String, List < JDE_Prop_Ln_Item__c >> ProposalProposalLineItemMap = new Map < String, List < JDE_Prop_Ln_Item__c >> ();
                      List < JDE_Prop_Ln_Item__c > ProposalLineItemList = null;
                      system.debug('####$$$$$$$$$$' + lstProposalLine);
                      for (JDE_Prop_Ln_Item__c pli: lstProposalLine) {

                          if (ProposalProposalLineItemMap.containsKey(pli.Proposal__c)) {
                              ProposalProposalLineItemMap.get(pli.Proposal__c).add(pli);
                          } else {
                              ProposalLineItemList = new List < JDE_Prop_Ln_Item__c > ();
                              ProposalLineItemList.add(pli);
                              ProposalProposalLineItemMap.put(pli.Proposal__c, ProposalLineItemList);
                          }

                      }



                      List < PriceBookEntry > lstPbeId = [select Id, Product2Id, CurrencyIsoCode from PriceBookEntry where CurrencyIsoCode = 'usd'
                          and isactive = true and Pricebook2id = '01sE0000000HpytIAC' and Product2Id in: productMap.keySet()
                      ];

                      Map < String, List < PriceBookEntry >> prodPriceBookMap = new Map < String, List < PriceBookEntry >> ();
                      List < PriceBookEntry > pbeList = null;
                      if(lstPbeId!=null && lstPbeId.size()>0){
                           for (PriceBookEntry pbe: lstPbeId) {
                              if (prodPriceBookMap.containsKey(pbe.product2ID)) {
                                  prodPriceBookMap.get(pbe.product2ID).add(pbe);
                              } else {
                                  pbeList = new List < PriceBookEntry > ();
                                  pbeList.add(pbe);
                                  prodPriceBookMap.put(pbe.product2ID, pbeList);
                              }
    
                          }
                      }
                     

                      List < PriceBookEntry > ProposalPBEList = null;


                      for (Opportunity o: lstOpportunityNew) {

                          String ProposalId = opportunityOrderMap.get(o.Proposal_number__C).id;
                          ProposalLineItemList = ProposalProposalLineItemMap.get(ProposalId);
                          system.debug('############' + ProposalLineItemList);

                          if(ProposalLineItemList!=null && ProposalLineItemList.size()>0){
                               for (JDE_Prop_Ln_Item__c prl: ProposalLineItemList){
                              // for each pricebook entry for each product_code in the order, create an oppporturni LI
                                  for (product2 pr: p2) {
                                      if (prl.Package_code__c == pr.Package_code__c) {
                                          system.debug('####$$$$$$$$$$' + pr.Package_code__c);
    
                                          String productId = packageCodeProduct2Map.get(prl.Package_code__c).Id;
                                          system.debug('####$$$$$$$$$$' + productId);
                                          ProposalPBEList = prodPriceBookMap.get(productID);
                                          system.debug('####$$$$$$$$$$' + ProposalPBEList);
    
                                          for (PriceBookEntry pbe: ProposalPBEList) {
                                              OpportunityLineItem opl = new OpportunityLineItem();
                                              opl.Quantity = prl.Quantity__c;
                                              opl.OpportunityId = o.id;
                                              //opl.discount = prl.Sys_discount__c;
                                              opl.Package_options__c = prl.Package_Options__c;
                                              opl.Line_Item_Ship_Date__c = date.today();
                                              opl.TotalPrice = prl.Extended_Line_Amount__c;
                                              opl.PricebookentryId = pbe.id;
                                              opl.List_Price_edit__c = prl.List_price__c;
    
                                              lstOppLine.add(opl);
                                          }
                                      }
                                  }
                          }
                          }
                         

                          //insert lstOppLine;
                      }
                      if(lstOppLine!=null){
                          try{
                              insert lstOppLine;
                          }
                          catch(Exception e){
                              system.debug('Exception Occured..'+e);
                          }
                      }
                  }
              }
          }
      }

  }

   

}