/**
*  Trigger Name   : SL_TerritoryMapping
*  CreatedOn      : 15/MAY/2015
*  ModifiedBy     : Nrusingh 
*  Description    : The trigger is used for Territory Mapping
*/

trigger SL_TerritoryMapping on Account (after insert, after update) 
{
	SL_TerritoryMappingHandler objSL_TerritoryMappingHandler = new SL_TerritoryMappingHandler ();
	
	// Handler Method called on after insert  
    if(Trigger.IsAfter && Trigger.IsInsert) 
    {
        objSL_TerritoryMappingHandler.OnAfterInsert(Trigger.newMap);
    }
    
    // Handler Method called on after update  
    if(Trigger.IsAfter && Trigger.IsUpdate) 
    {
        objSL_TerritoryMappingHandler.OnAfterUpdate(Trigger.newMap, Trigger.oldMap);
    }
}