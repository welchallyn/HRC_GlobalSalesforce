({
   doInit: function(component, event, helper) {
      var nameofprop;
      var shiptoidofprop;
      var accountname;
      var checkfromorder = true;
        var todaydate =$A.localizationService.formatDate(new Date(), "yyyy-MM-dd");
      //var todaydate = new Date();
      var recordtypeid;
      window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 1000 
        );
      console.log('Onload function call V32'); 
         var action2 = component.get("c.getrecordtypeid");
                   action2.setParams({
                    "test": 'test'
                });
                 action2.setCallback(this, function(response2) {
                    var state2 = response2.getState();
                     if(component.isValid() && state2 === "SUCCESS"){
                         recordtypeid = response2.getReturnValue();
                         console.log('RECORDTYPE ID-1->'+recordtypeid);
                     }
                     else {
                            console.log('Problem getting Case, response state: ' + state2);
                        }
                     
                });
       $A.enqueueAction(action2);
       
        var action = component.get("c.getJDEprop");
        action.setParams({"propid": component.get("v.recordId")});
       // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.jdeprop", response.getReturnValue());
                nameofprop = component.get("v.jdeprop.Name");
                shiptoidofprop = component.get("v.jdeprop.Ship_To__c");
                accountname = component.get("v.jdeprop.Ship_To__r.Name");
                console.log(accountname);
                console.log('RECORDTYPE ID-->'+recordtypeid);
                
                 var createRecordEvent = $A.get("e.force:createRecord");
                  createRecordEvent.setParams({
                     "entityApiName": "Opportunity",
                      "recordTypeId": recordtypeid,
                      "defaultFieldValues": { 
                          'StageName':'2- Qualify',
                          'Converted_from_Proposal__c':checkfromorder,
                          'Proposal_Number__c':nameofprop,
                          'Name':accountname,
                          'AccountId':shiptoidofprop,
                          'CloseDate':todaydate
                    }
                  });
                  createRecordEvent.fire();
                 
            } else {
                console.log('Problem getting Case, response state: ' + state);
            }
        });

        $A.enqueueAction(action);
   }
})