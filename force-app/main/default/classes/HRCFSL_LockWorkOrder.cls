/***********************************************************************************************
* Name                             : HRCFSL_LockWorkOrder
* Author                           : Capgemini
* Date                             : August/11/2020
* Requirement/Project Name         : Hill-Rom
* Requirement/Project Description  :1. This class calls Queueable Apex (HRCFSL_LockWorkOrderQueueable) to update Lock Work Order checkbox as true
*                                   2. Calls Flow HRCFSL_Close_Service_Appointment to complete the service appointments
*                                      #SE-604
* Revison                          :
/***********************************************************************************************/
public class HRCFSL_LockWorkOrder {
    /******************************************************************************
    * Method Name: lockWorkOrder
    * Author: Capgemini
    * Date: August/11/2020
    * Params: woIds
    * Return: void
    * Requirement : This method calls Queueable Apex Class(HRCFSL_LockWorkOrderQueueable to update Lock Work Order Checkbox as true and calls flow.
    ******************************************************************************/
    @InvocableMethod(label='Lock Work Order')
    public static void lockWorkOrder(List<Id> woIds){
        System.enqueueJob(new HRCFSL_LockWorkOrderQueueable(woIds));
    }
  
}