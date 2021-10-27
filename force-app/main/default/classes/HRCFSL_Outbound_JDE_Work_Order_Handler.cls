/***********************************************************************************************
 * Name                             : HRCFSL_Outbound_JDE_Work_Order_Handler
 * Author                           : Capgemini
 * Date                             : Aug/21/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  :  Trigger Handler class to
 *                                   1. sync Work order along with its related child 
 *                                   record  with  JDE server using platform event
 *                                   2. Related to #HF-67 , #HF-266
 * Revison                          : 
 ***********************************************************************************************/

public class HRCFSL_Outbound_JDE_Work_Order_Handler
{
    public void onAfterInsert(Map<ID, HRCFSL_Outbound_JDE_Work_Order__e> newMap, map<id, HRCFSL_Outbound_JDE_Work_Order__e> oldMap)
    {
      
        //List<String> workOrderIds = new List<String>();
        //list<String> assetIds = new list<string>();

        
        //code commented on 16th April 2021 (6 lines commented starting from the bottom one) as per SE - 1956
        /*
        for (HRCFSL_Outbound_JDE_Work_Order__e woh: newMap.values())
        {
            HRCFSL_Build_Integration_Message bim = new HRCFSL_Build_Integration_Message(new List<Id>{woh.HRCFSL_Work_Order__c});
            HRCFSL_Work_Order_Callout callout = new HRCFSL_Work_Order_Callout(bim.getMessages());
            System.enqueueJob(callout);
        }
		*/
        
        //code added on 16th April 2021 as per SE - 1956
        system.debug('HRCFSL_Outbound_JDE_Work_Order_Handler');
        /*******PV-042221 : Added logic to prevent duplicate callouts if in case platform event created for the same wo *****/
        List<HRCFSL_Outbound_JDE_Work_Order__e> events = newMap.values();
        Map<String, HRCFSL_Outbound_JDE_Work_Order__e> woEventMap = new Map<String, HRCFSL_Outbound_JDE_Work_Order__e>();
        for(HRCFSL_Outbound_JDE_Work_Order__e event : events){
            if(event.HRCFSL_IsEventForChildWO__c)
            	woEventMap.put('C-'+event.HRCFSL_Work_Order__c, event); //Event for child
            else
                woEventMap.put('P-'+event.HRCFSL_Work_Order__c, event); //Event for parent
        }
        HRCFSL_Work_Order_Callout callout = new HRCFSL_Work_Order_Callout(woEventMap.values());
        //HRCFSL_Work_Order_Callout callout = new HRCFSL_Work_Order_Callout(newMap.values());
        System.enqueueJob(callout);
            
    }
}