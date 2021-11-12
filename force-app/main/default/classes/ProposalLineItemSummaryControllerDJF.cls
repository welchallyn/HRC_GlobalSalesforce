/*
 *  ClassName    : ProposalLineItemSummaryController
 *  CreatedOn    : 23/Jan/2017
 *  ModifiedOn   : 30/August/2017
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Dean Fischesser
 *  Description  :   
 */

public with sharing class ProposalLineItemSummaryControllerDJF{
    public string currentProposalId{get;set;}
    public List<Apttus_Proposal__Proposal_Line_Item__c> lstOfOptions{get;set;}
    public List<OrderEntryWrapper> lstOrderEntryWrapper{get;set;}
    public Map<string,DecimalWrapper> mapWrap{get;set;}
    public static Map<Decimal, lineDetails> lineMap{get;set;}
    public Decimal totalExtendedNetPrice{get;set;}
    public Decimal totalExtendedListPrice{get;set;}
    
    
    public ProposalLineItemSummaryControllerDJF(ApexPages.StandardController controller){
        mapWrap = new  Map<string,DecimalWrapper>();
        lstOfOptions = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        lstOrderEntryWrapper = new List<OrderEntryWrapper>();
        totalExtendedNetPrice = 0;
        totalExtendedListPrice = 0;
        summarizeProposalLineItems();
        
    }
    
    //Method to summarize Proposal Line Items.
    public void summarizeProposalLineItems(){
        currentProposalId = ApexPages.currentPage().getParameters().get('id');
        
          lstOfOptions = [select APTPS_Quantity__c, Unit_Net_Price__c, Extended_Net_Price_template__c, Apttus_QPConfig__ListPrice__c, 
                         Extended_List_Price__c, APTPS_Product_Code__c, Apttus_Proposal__Description__c, Apttus_QPConfig__LineNumber__c,
                         Apttus_QPConfig__HasOptions__c, Apttus_QPConfig__SummaryGroupId__c, Apttus_QPConfig__PrimaryLineNumber__c, Apttus_QPConfig__ParentBundleNumber__c from Apttus_Proposal__Proposal_Line_Item__c
                         where Apttus_Proposal__Proposal__c=:currentProposalId];
                         
// Run through all lines to create the Qty Map Table
       if(lstOfOptions!=null && lstOfOptions.size()>0){
           lineMap = new Map<Decimal, lineDetails>();
           for(Apttus_Proposal__Proposal_Line_Item__c objOption:lstOfOptions){
                lineMap.put(objOption.Apttus_QPConfig__PrimaryLineNumber__c, new lineDetails(objOption));
                }

// Clone Map to use for BOM-like explosion
           
           Map<Decimal, lineDetails> lineMap2 = lineMap.clone();     

// Iterate through initial Map to process each line

    for (Decimal key:lineMap.keySet()){
        
// if the Map item has a parent, traverse up the entire BOM to deteremine multiplier


        if (lineMap.get(key).parentLineNumber != 0){
            Boolean hasMoreParents = Boolean.valueOf('false');
            Decimal lineMap2Key = key;
            Decimal parentLineMap2Key = lineMap.get(lineMap2Key).parentLineNumber;
            Decimal newQtyMultiplier = 1;

            do{
                newQtyMultiplier = lineMap2.get(parentLineMap2Key).lineQty * newQtyMultiplier;
                if (lineMap2.get(parentLineMap2Key).parentLineNumber != 0){
                    parentLineMap2Key = lineMap2.get(parentLineMap2Key).parentLineNumber;
                    hasMoreParents = true;
                  }
                 else 
                        hasMoreParents = false;

               } while (hasMoreParents);      
            
            lineDetails templineMap = lineMap.get(key);
            templineMap.totalLineQtyMultipler = newQtyMultiplier;
            lineMap.put(key,templineMap);
            System.debug('line multiplier - ' + lineMap.get(key));
        }
    }
    
// Run through all lines to create the Order Lines

            mapWrap = new  Map<string,DecimalWrapper>();
            for(Apttus_Proposal__Proposal_Line_Item__c objOption:lstOfOptions){
                
// only write out the items that are NOT Parent/phantom items, based on the HasOptions Product field
// DJF            if(objOption.Apttus_QPConfig__HasOptions__c==false)
            if(objOption.Apttus_QPConfig__HasOptions__c==false && objOption.APTPS_Product_Code__c != null)  //djf
                     lstOrderEntryWrapper.add(new OrderEntryWrapper(objOption));
                }
            
             if(lstOrderEntryWrapper!=null && lstOrderEntryWrapper.size()>0){
                 for(OrderEntryWrapper objOrderEntryWrap:lstOrderEntryWrapper){
// djf                      mapWrap.put(objOrderEntryWrap.objPLI.APTPS_Product_Code__c,new DecimalWrapper(objOrderEntryWrap.objPLI));
                      mapWrap.put(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c,new DecimalWrapper(objOrderEntryWrap.objPLI)); //djf
                 }
                 
 // Totals by product code using the Map strucutre
 
                for(OrderEntryWrapper objOrderEntryWrap:lstOrderEntryWrapper){
                     if(mapWrap.containskey(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c)){
                         if(mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c)!=null){
                             if(objOrderEntryWrap.Extended_Net_Price_template!=null)
                                mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c).ExtendedNetPrice =  mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c).ExtendedNetPrice+objOrderEntryWrap.Extended_Net_Price_template;
                             if(objOrderEntryWrap.Extended_List_Price!=null)
                                mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c).ExtendedListPrice = mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c).ExtendedListPrice+objOrderEntryWrap.Extended_List_Price;
                             if(objOrderEntryWrap.APTPS_Quantity!=null)
                                mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c).Quantity = mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c + objOrderEntryWrap.objPLI.Unit_Net_Price__c).Quantity+ objOrderEntryWrap.APTPS_Quantity;
                         }
                     }
                    }
                    
                    for(DecimalWrapper objDecimalWrap:mapWrap.values()){
                        totalExtendedNetPrice = totalExtendedNetPrice+objDecimalWrap.ExtendedNetPrice;
                        totalExtendedListPrice = totalExtendedListPrice+objDecimalWrap.ExtendedListPrice;
                    }
                    
                }  
                    
        }

    }
    
    //Method to redirect on Quote/Proposal detail page.
    public pagereference backToOpportunity(){
        return new pagereference('/'+currentProposalId);
    }
    
    //Method to redirect on ExportProposalLineItemSummary Visualforce page, which create an excel file.
    public pagereference ExportResults(){
        return new pagereference('/apex/ExportProposalLineItemSummary?id='+currentProposalId);
    }
    
    public with sharing class OrderEntryWrapper{
        public Apttus_Proposal__Proposal_Line_Item__c objPLI{get;set;}
        public Decimal APTPS_Quantity{get;set;}
        public Decimal Extended_Net_Price_template{get;set;}
        public Decimal Extended_List_Price{get;set;}
        
        
        public OrderEntryWrapper(Apttus_Proposal__Proposal_Line_Item__c objPLI){
            this.objPLI = objPLI;
            if(objPLI.Apttus_QPConfig__HasOptions__c==false){
                    APTPS_Quantity = objPLI.APTPS_Quantity__c * lineMap.get(objPLI.Apttus_QPConfig__PrimaryLineNumber__c).totalLineQtyMultipler;
                    Extended_Net_Price_template = objPLI.Extended_Net_Price_template__c * lineMap.get(objPLI.Apttus_QPConfig__PrimaryLineNumber__c).totalLineQtyMultipler;
                    Extended_List_Price = objPLI.Extended_List_Price__c * lineMap.get(objPLI.Apttus_QPConfig__PrimaryLineNumber__c).totalLineQtyMultipler;
            }
        }
    }


//    
// Class Definitions
//
    public with sharing class DecimalWrapper{
        public Decimal ExtendedNetPrice{get;set;}
        public Decimal ExtendedListPrice{get;set;}
        public Decimal Quantity{get;set;}
        public Apttus_Proposal__Proposal_Line_Item__c objPLI{get;set;}
        public Decimal perItemDifference{get;set;}
        public Decimal perCentDifference{get;set;}
        
        
        public DecimalWrapper(Apttus_Proposal__Proposal_Line_Item__c objPLI){
            ExtendedNetPrice = 0;
            ExtendedListPrice = 0;
            Quantity = 0;
            this.objPLI = objPLI;
            if(objPLI.Apttus_QPConfig__ListPrice__c!=null && objPLI.Unit_Net_Price__c!=null)
                objPLI.Apttus_QPConfig__ListPrice__c = objPLI.Apttus_QPConfig__ListPrice__c.setScale(2);
                if(objPLI.Apttus_QPConfig__ListPrice__c!=null && objPLI.Unit_Net_Price__c!=null)
                 perItemDifference = objPLI.Apttus_QPConfig__ListPrice__c - objPLI.Unit_Net_Price__c;
            if(objPLI.Apttus_QPConfig__ListPrice__c!=null && objPLI.Apttus_QPConfig__ListPrice__c!=0 && objPLI.Unit_Net_Price__c!=null)
             perCentDifference = (1-(objPLI.Unit_Net_Price__c/ objPLI.Apttus_QPConfig__ListPrice__c))*100;
             if(perCentDifference!=null)
                perCentDifference = perCentDifference.setScale(1);
        }
    }
    
    
    // Class used to setup a Map containing the Parent Line for use in the BOM calculation
    
     public with sharing class lineDetails{
        public Decimal parentLineNumber{get;set;}
        public String  productCode{get;set;}
        public Decimal lineQty{get;set;}
        public Decimal totalLineQtyMultipler{get;set;}

        public lineDetails(Apttus_Proposal__Proposal_Line_Item__c objLineDetails){
            parentLineNumber = 0;
            lineQty = 1;
            totalLineQtyMultipler = 1;
            productCode = objLineDetails.APTPS_Product_Code__c;

          if(objLineDetails.Apttus_QPConfig__ParentBundleNumber__c !=null)
                parentLineNumber = objLineDetails.Apttus_QPConfig__ParentBundleNumber__c;

          if(objLineDetails.APTPS_Quantity__c!=null)
                lineQty = objLineDetails.APTPS_Quantity__c;
        }

        }
   
}