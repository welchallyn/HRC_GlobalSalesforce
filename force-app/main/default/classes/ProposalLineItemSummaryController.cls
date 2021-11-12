/*
 *  ClassName    : ProposalLineItemSummaryController
 *  CreatedOn    : 23/Jan/2017
 *  ModifiedOn   : 14/March/2017
 *  CreatedBy    : Jenish Shingala
 *  ModifiedBy   : Jenish Shingala
 *  Description  :   
 */
public with sharing class ProposalLineItemSummaryController{
    public string currentProposalId{get;set;}
    public List<Apttus_Proposal__Proposal_Line_Item__c> lstOfOptions{get;set;}
    public List<OrderEntryWrapper> lstOrderEntryWrapper{get;set;}
    public Map<string,DecimalWrapper> mapWrap{get;set;}
    public Decimal totalExtendedNetPrice{get;set;}
    public Decimal totalExtendedListPrice{get;set;}
    
    
    public ProposalLineItemSummaryController(ApexPages.StandardController controller){
         mapWrap = new  Map<string,DecimalWrapper>();
        lstOfOptions = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        lstOrderEntryWrapper = new List<OrderEntryWrapper>();
        totalExtendedNetPrice = 0;totalExtendedListPrice = 0;
        summarizeProposalLineItems();
        
    }
    
    //Method to summarize Proposal Line Items.
    public void summarizeProposalLineItems(){
        currentProposalId = ApexPages.currentPage().getParameters().get('id');
        
          lstOfOptions = [select APTPS_Quantity__c, Unit_Net_Price__c, Extended_Net_Price_template__c, Apttus_QPConfig__ListPrice__c, 
                         Extended_List_Price__c, APTPS_Product_Code__c, Apttus_Proposal__Description__c, Apttus_QPConfig__LineNumber__c,
                         Apttus_QPConfig__HasOptions__c, Apttus_QPConfig__SummaryGroupId__c from Apttus_Proposal__Proposal_Line_Item__c
                         where Apttus_Proposal__Proposal__c=:currentProposalId];
                         
         
        
        if(lstOfOptions!=null && lstOfOptions.size()>0){
            mapWrap = new  Map<string,DecimalWrapper>();
            for(Apttus_Proposal__Proposal_Line_Item__c objOption:lstOfOptions){
                
                   if(objOption.Apttus_QPConfig__SummaryGroupId__c!=null && objOption.Apttus_QPConfig__HasOptions__c==false)
                     lstOrderEntryWrapper.add(new OrderEntryWrapper(objOption));
                    else if(objOption.Apttus_QPConfig__SummaryGroupId__c==null && objOption.Apttus_QPConfig__HasOptions__c==false)
                     lstOrderEntryWrapper.add(new OrderEntryWrapper(objOption));
                     
                    
            }
            
             if(lstOrderEntryWrapper!=null && lstOrderEntryWrapper.size()>0){
                 for(OrderEntryWrapper objOrderEntryWrap:lstOrderEntryWrapper){
                      mapWrap.put(objOrderEntryWrap.objPLI.APTPS_Product_Code__c,new DecimalWrapper(objOrderEntryWrap.objPLI));
                 }
                 
                 
                for(OrderEntryWrapper objOrderEntryWrap:lstOrderEntryWrapper){
                    
                     if(mapWrap.containskey(objOrderEntryWrap.objPLI.APTPS_Product_Code__c)){
                         if(mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c)!=null){
                             if(objOrderEntryWrap.Extended_Net_Price_template!=null)
                                mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c).ExtendedNetPrice =  mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c).ExtendedNetPrice+objOrderEntryWrap.Extended_Net_Price_template;
                             if(objOrderEntryWrap.Extended_List_Price!=null)
                                mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c).ExtendedListPrice = mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c).ExtendedListPrice+objOrderEntryWrap.Extended_List_Price;
                             if(objOrderEntryWrap.APTPS_Quantity!=null)
                                mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c).Quantity = mapWrap.get(objOrderEntryWrap.objPLI.APTPS_Product_Code__c).Quantity+ objOrderEntryWrap.APTPS_Quantity;
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
            if(objPLI.Apttus_QPConfig__SummaryGroupId__c!=null && objPLI.Apttus_QPConfig__HasOptions__c==false){
                    APTPS_Quantity = objPLI.APTPS_Quantity__c* (objPLI.Apttus_QPConfig__LineNumber__c+1);
                    Extended_Net_Price_template = objPLI.Extended_Net_Price_template__c*(objPLI.Apttus_QPConfig__LineNumber__c+1);
                    Extended_List_Price = objPLI.Extended_List_Price__c*(objPLI.Apttus_QPConfig__LineNumber__c+1);
            }
            else if(objPLI.Apttus_QPConfig__SummaryGroupId__c==null && objPLI.Apttus_QPConfig__HasOptions__c==false){
                APTPS_Quantity = objPLI.APTPS_Quantity__c;
                Extended_Net_Price_template = objPLI.Extended_Net_Price_template__c;
                Extended_List_Price = objPLI.Extended_List_Price__c;
            }
            
        }
    }
    
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
    
    
}