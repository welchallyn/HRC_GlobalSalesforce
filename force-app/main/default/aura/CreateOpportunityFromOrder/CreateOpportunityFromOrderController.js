({
   doInit: function(component, event, helper) {
      var checkfromorder = true;
      var todaydate = new Date();
      var recordtypeid;
      window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), 1000 
        );
      console.log('Onload function call V2'); 
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
       
       
        var action = component.get("c.getOrder");
        action.setParams({"orderid": component.get("v.recordId")});
       // Configure response handler
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.order", response.getReturnValue());
                 var createRecordEvent = $A.get("e.force:createRecord");
                  createRecordEvent.setParams({
                     "entityApiName": "Opportunity",
                      "recordTypeId": recordtypeid,
                      "defaultFieldValues": { 
                          'StageName':'Qualify',
                          'Converted_from_Order__c':checkfromorder,
                          'Proposal_Number__c':component.get("v.order.Name"),
                          'Name':component.get("v.order.Account__r.Name"),
                          'AccountId':component.get("v.order.Account__c"),
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