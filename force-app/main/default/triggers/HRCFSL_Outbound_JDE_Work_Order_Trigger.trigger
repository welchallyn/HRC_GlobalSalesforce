/***********************************************************************************************
 * Name                             : HRCFSL_Outbound_JDE_Work_Order_Trigger
 * Author                           : Capgemini
 * Date                             : Aug/21/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  :  Trigger to
 *                                   1. sync Work order along with its related child 
 *                                   record  with  JDE server using platform event
 *                                   2. Related to #HF-67 , #HF-266
 * Revison                          : 
 ***********************************************************************************************/

trigger HRCFSL_Outbound_JDE_Work_Order_Trigger on HRCFSL_Outbound_JDE_Work_Order__e (after insert) 
{
    if (EventBus.TriggerContext.currentContext().retries < 5)
    {
        System.debug('HRCFSL_Outbound_JDE_Work_Order_Trigger');
        HRCFSL_Outbound_JDE_Work_Order_Handler woh = new HRCFSL_Outbound_JDE_Work_Order_Handler();
        woh.onAfterInsert(Trigger.newMap, Trigger.oldMap);
    }
    
}