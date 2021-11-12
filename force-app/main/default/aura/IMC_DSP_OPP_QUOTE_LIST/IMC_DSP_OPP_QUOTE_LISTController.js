({
    // do init to initialize code at the time component gets intialized.
    doInit : function(component, event, helper) {
        var metaPop = $A.get("$Label.c.IMC_DSP_MetadataPopUp");
        console.log('meta data PopUp ===>'+metaPop);
        if(metaPop != 'False'){
            component.set("v.metadataPopUpVar", true);
        }else{
            component.set("v.metadataPopUpVar", false);
        }
    },
    
    // Loading the fields for the event
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
            console.log("Record is loaded successfully.");
            var rcid = component.get("v.recordId");
            console.log(
                "You loaded a record in " +
                component.get("v.opportunityRecord.AccountId") +
                "opp id===>" +
                rcid
            );
            var accId = component.get("v.opportunityRecord.AccountId");
            var oppName =component.get("v.opportunityRecord.Name");
            var baseURL = $A.get("$Label.c.IMC_DSP_BaseURL");
            var extURL1 =
                "?uiModeEmbedded=true&objectId=" +
                rcid +
                "&objectName=" +
                oppName +
                "&objectType=Opportunity" +        
                "&extAccId=" +
                accId +
                "#/quotelist";
            
            var extURL2 = "index.html#/quote?tab=quotes&uiModeEmbedded=false&objectId="+rcid+
                "&objectName="+oppName +
                "&objectType=Opportunity" +        
                "&extAccId="+accId;
            
            var srcURL = baseURL + extURL1;
            var srcURLFull = baseURL + extURL2;
            console.log("srcURL===>" + srcURL);
            component.set("v.srcURL", srcURL);
            component.set("v.srcURLFull", srcURLFull);
        } else if (eventParams.changeType === "CHANGED") {
            // record is changed
        } else if (eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if (eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    
    //Setting the boolean Variable as true.     
    metaDataPopUp: function(component, event, helper) {
        var unsaved = component.find("unsaved");
        unsaved.setUnsavedChanges(true, {label:"Quote"});
    },
    
    // when changed : nevigate to new tab.
    moveToNewPage: function(cmp, evt, helper) {
        cmp.set("v.goodToGo",true);
        var unsaved = cmp.find("unsaved");
        if (cmp.get("v.goodToGo") != true) {
            unsaved.setUnsavedChanges(true);
        }
        else {
            unsaved.setUnsavedChanges(false);
        }
    }
});