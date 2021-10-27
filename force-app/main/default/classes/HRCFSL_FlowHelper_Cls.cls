/***********************************************************************************************
 * Name                             : HRCFSL_FlowHelper_Cls
 * Author                           : Capgemini
 * Date                             : August/28/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  :  Class to
 *                                   1. update and associate  child WO's related Product consumed  
 *                                    and WOLI records with main parent WO (#HF292)
 *                                   2. to be Used in HRCFSL_Multisign flow
 * Revison                          :
/***********************************************************************************************/

public with sharing class HRCFSL_FlowHelper_Cls {

    /******************************************************************************
     * Method Name: updateRelatedChildRecords
     * Author: Capgemini
     * Date: August/28/2019
     * Params:flowInputWrapper class
     * Return: void
     * Requirement : 1. update and associate  child WO's related Product consumed  
     *                  and WOLI records with main parent WO (#HF292)
     *               2. to be Used in HRCFSL_Multisign flow
     ******************************************************************************/
     @InvocableMethod(label='UpdateRelatedChildRecords' description='This action will update the related Product consumed and WOLI record associated with Selected Work orderid')
  public static void updateRelatedChildRecords(list<flowInputWrapper> fi_Wraplst) {
      flowInputWrapper fi_Wrap = new flowInputWrapper();
    // fi_Wrap=fi_Wraplst.isEmpty() ? fi_wrap : fi_Wraplst[0];
    Map<Id, String> inputMap = new Map<Id, String>();
     if(!fi_Wraplst.isEmpty()){     
        for(flowInputWrapper fiw:fi_Wraplst ){
            inputMap.put(fiw.selectedChildWOId,fiw.ParentWOId);
        }
     }
      
    List<productconsumed> pc_lsttobeupdated = new List<productconsumed>();
    list<WorkOrderLineItem> woli_lsttobeupdated = new list<WorkOrderLineItem>();
        for (ProductConsumed pc : [select id,WorkOrderId,HRCFSL_Root_Work_Order__c from productconsumed where WorkOrderId IN :inputMap.keySet() ]) {
        pc.HRCFSL_Root_Work_Order__c=inputMap.get(pc.WorkOrderId);
        pc_lsttobeupdated.add(pc);
        }
        if(pc_lsttobeupdated.size()>0){
            update pc_lsttobeupdated;
        }
        for (WorkOrderLineItem woli : [select id,WorkOrderId,HRCFSL_Root_Work_Order__c from WorkOrderLineItem where WorkOrderId IN :inputMap.keySet()]) {
        woli.HRCFSL_Root_Work_Order__c=inputMap.get(woli.WorkOrderId);
        woli_lsttobeupdated.add(woli);
        }
        if(woli_lsttobeupdated.size()>0){
            update woli_lsttobeupdated;
        }
  }
  /****************************************************
    Wrapper class for holding Flow Input variables   
  *****************************************************/
  public class flowInputWrapper{
    @InvocableVariable(label='ParentWOId')
    public String ParentWOId;
 
    @InvocableVariable(label='SelectedChildWOId')
    public Id selectedChildWOId;
  }
}