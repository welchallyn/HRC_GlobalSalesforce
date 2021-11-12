/**
  *  Class Name     : SL_AppAdministrationController
  *  CreatedOn      : 18/MAY/2015
  *  ModifiedBy     : Nrusingh 
  *  Description    : The class is used for page Controller to call the batch from the page
*/
public with sharing class SL_AppAdministrationController 
{
  /*Start Variables */
  public String strBatchRunningError       {  get;set;  }
  public String strBatchRunning         {  get;set;  }
    private static final String strLimitExceedErrorMsg = 'Attempted to schedule too many concurrent batch jobs. Limit is 5';
    private static final String strInfoMessage = 'Batch is processed to run. Please view the below link to see the apex job logs.';
    /*End Variables */
    
    /* Start Constructor */
    public SL_AppAdministrationController()
    {
      strBatchRunning = '';
      strBatchRunningError = '';
    }
    
      /**
        @MethodName : createTerritoryMappingBatch
        @param      : NA
        @Description: This method is called from the page
    */
    public void createTerritoryMappingBatch()
    {
        if([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] >= 5)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,strLimitExceedErrorMsg));
          strBatchRunningError = 'error';
            strBatchRunning = 'Click here to see the progress of the batch running.';
        }
        else
        {
            Database.executeBatch(new SL_Batch_TerritoryMapping(),200);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, strInfoMessage));
            strBatchRunning = 'Click here to see the progress of the batch running.';
        }
    }
}