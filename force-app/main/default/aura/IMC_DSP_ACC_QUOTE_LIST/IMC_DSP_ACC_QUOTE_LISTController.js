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
    
    // this JS method is used to create the URL for each account record that needs to be embidded from MX side.
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if (eventParams.changeType === "LOADED") {
            var rcid = component.get("v.recordId");
            var accId = component.get("v.acountRecord.AccountId");
            var baseURL = $A.get("$Label.c.IMC_DSP_BaseURL");
            var extURL = "?uiModeEmbedded=true&extAccId=" + rcid + "#/quotelist";
            var extURLFull = "index.html#/quote?tab=quotes&uiModeEmbedded=false&extAccId=" + rcid;
            
            var srcURL = baseURL + extURL;
            var srcURLFull = baseURL + extURLFull;
            console.log("srcURL account===>" + srcURL);
            component.set("v.srcURL", srcURL);
            component.set("v.srcURLFull", srcURLFull);
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
            /*var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                    title : 'Unsaved Data were Lost',
                    message: 'Unsaved data of IMC-DSP-SmartQuote was lost on nevigating from Account',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'info',
                    mode: 'pester'
             });
             toastEvent.fire();
             */
        }
    }
})