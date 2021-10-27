({
  doInit: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    helper.getPicklistFieldValues(
      component,
      event,
      "HRCSVC_Order_Line_Item_Status__c",
      "Order_Line_Item__c",
      "v.orderLinteItemStatus"
    );
    helper.getPicklistFieldValues(
      component,
      event,
      "HRCSVC_Service_Activity_Type__c",
      "Order_Line_Item__c",
      "v.serviceActivityType"
    );
    helper.getPicklistFieldValues(
      component,
      event,
      "Cancel_Change_Reason_Code__c",
      "Order_Line_Item__c",
      "v.cancelResonCode"
    );
    helper.getPicklistFieldValues(
      component,
      event,
      "HRCSVC_Price_Method_Code__c",
      "Order_Line_Item__c",
      "v.priceMethodCodeMap"
    );
    helper.getPicklistFieldValues(
      component,
      event,
      "HRCSVC_Paging_Team__c",
      "Order_Line_Item__c",
      "v.pagingTeamMap"
    );
    //helper.getPicklistFieldValues(component, event,'HRCSVC_Team_Type_Descriptions__c','Order_Line_Item__c','v.teamTypeDescriptionMap');
    helper.getPicklistFieldValues(
      component,
      event,
      "HRCSVC_Contact_Method__c",
      "Order_Line_Item__c",
      "v.contactMethod"
    );
    if (recordId != "" && recordId != null) {
      helper.getOrderandOrderLineItems(component, event, recordId);
    } else {
      helper.getPicklistFieldValues(
        component,
        event,
        "HRCSVC_Contact_Source__c",
        "Order__c",
        "v.contactSourceMap"
      );
      //helper.getUserLocale(component, event);
      helper.addOLIRecord(component, event);
    }
  },
  addRow: function (component, event, helper) {
    var isError = component.get("v.isError");
    if (!isError) {
      helper.addOLIRecord(component, event, helper);
    }
  },
  handleSelection: function (component, event, helper) {
    helper.updateRecordsBasedOnLookupSelection(component, event, helper);
    helper.getAccountProtocol(component, event);
    helper.getCustomerRental(component, event);
  },
  removeRow: function (component, event, helper) {
    //Get the account list
    var orderLineItemList = component.get("v.orderLineItemList");
    //Get the target object
    var selectedItem = event.currentTarget;
    //Get the selected item index
    var index = selectedItem.dataset.record;
    if (index != 0) {
      orderLineItemList.splice(index, 1);
      component.set("v.orderLineItemList", orderLineItemList);
    }
  },
  save: function (component, event, helper) {
    //alert('inside save');
    //component.set("v.message", "");
    component.set("v.sheetChangeShowModal", false);
    component.set("v.adminBedMoveShowModal", false);
    helper.validateRecord(component, event);
    //helper.duplicateRecordCheck(component,event);
  },
  updateWorkOrders: function (component, event, helper) {
    var recordId = component.get("v.recordId");
    var workOrders = component.get("v.workOrders");
    for (var i = 0; i < workOrders.length; i++) workOrders[i].Status = "SC";
    component.set("v.showAdditionalWOFields", false);
    helper.showSpinner(component);
    var action = component.get("c.updateWOs");
    action.setParams({
      wos: component.get("v.workOrders")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.showAdditionalWOFields", false);
        helper.hideSpinner(component);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          title: "Success!",
          type: "success",
          message: "The record has been created successfully. Please refresh the page."
        });
        toastEvent.fire();
      } else {
        console.log('error');
        helper.hideSpinner(component);
        var errors = action.getError();
        console.log(errors);
        var admErrMsg='';
        for(let key in errors[0]){
          console.log(key);
          if(key == 'message'){
            if (errors[0].message  != undefined) {
            admErrMsg=errors[0].message;
            }
          }
          else if(key=='fieldErrors'){
            console.log(errors[0].fieldErrors.hasOwnProperty('HRCFSL_Activity_Type__c'));
            if(errors[0].fieldErrors.hasOwnProperty('HRCFSL_Activity_Type__c') === true){
              console.log('HRCFSL_Activity_Type__c');
              if (errors[0].fieldErrors.HRCFSL_Activity_Type__c[0].message != undefined) {
                admErrMsg=errors[0].fieldErrors.HRCFSL_Activity_Type__c[0].message;
              }
            }

          }
          else if (key == 'pageErrors'){
            console.log(errors[0].pageErrors.length);
            if(errors[0].pageErrors.length>0){
                if (errors[0].pageErrors[0].message != undefined) {
                 admErrMsg=errors[0].pageErrors[0].message
                }
            }
          }
        }
        if(admErrMsg!=''){
          var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type" : "error",
                        "mode" : "pester",
                        "title": "Error!",
                        "message": admErrMsg
                    });
                    toastEvent.fire();
        }
      }
    });
    $A.enqueueAction(action);
  },
  saveDuplicateRecord: function (component, event, helper) {
    helper.saveRecord(component, event);
  },
  saveSheetChangeWorkOrdes: function (component, event, helper) {
    var oliList = component.get("v.selectedOrderLineItemList");
    //call apex class method to execute further save process
  },
  cancelRecord: function (component, event, helper) {
    location.reload();
  },
  closeModel: function (component, event, helper) {
    var eligibilityModal = component.get("v.eligibilityModal");
    var isDuplicate = component.get("v.isDuplicate");
    if (eligibilityModal) {
      component.set("v.eligibilityModal", false);
      component.set("v.eligibilityMessage", "");
      component.set("v.isError", false);
    }
    if (isDuplicate) {
      component.set("v.isDuplicate", false);
      component.set("v.showDuplicateMessage", "");
      component.set("v.isError", false);
    }
    component.set("v.sheetChangeShowModal", false);
    component.set("v.buttonClicked", "");
    component.set("v.showAdditionalWOFields", false);
  },
  selectedSubstitution: function (component, event, helper) {
    var buttonName = event.getSource().get("v.label");
    component.set("v.buttonClicked", buttonName);
    var checkvalue = component.find("checkedOLI");
    var orderLineItemRecords = component.get("v.orderLineItemList");
    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        var oli = checkvalue.get("v.text");
        //update selected records
        oli.Cancel_Change_Reason_Code__c = "SB";
        oli.HRCSVC_Order_Line_Item_Status__c = "Canceled";
        //create new records.
        var newOrderLineotem = helper.createSubstitutionOnOLI(
          component,
          event,
          oli
        );
        orderLineItemRecords.push(newOrderLineotem);
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          var oli = checkvalue[i].get("v.text");
          //update selected records
          oli.Cancel_Change_Reason_Code__c = "SB";
          oli.HRCSVC_Order_Line_Item_Status__c = "Canceled";
          //create new records.
          var newOrderLineotem = helper.createSubstitutionOnOLI(
            component,
            event,
            oli
          );
          orderLineItemRecords.push(newOrderLineotem);
        }
      }
    }
    component.set("v.orderLineItemList", orderLineItemRecords);
  },
  onRemoval: function (component, event, helper) {
    var buttonName = event.getSource().get("v.label");

    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;
    component.set("v.buttonClicked", buttonName);
    var listOLI = [];
    var checkvalue = component.find("checkedOLI");
    component.set("v.sheetChangeShowModal", true);
    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        var oli = checkvalue.get("v.text");
        oli.HRCSVC_End_Date__c = today;
        //     oli.HRCSVC_Special_Instructions__c = '';
        oli.HRCSVC_Order_Line_Item_Status__c = "Completed Rental";
        listOLI.push(oli);
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          var oli = checkvalue[i].get("v.text");
          oli.HRCSVC_End_Date__c = today;
          //       oli.HRCSVC_Special_Instructions__c = '';
          oli.HRCSVC_Order_Line_Item_Status__c = "Completed Rental";
          listOLI.push(oli);
        }
      }
    }
    component.set("v.selectedOrderLineItemList", listOLI);
    component.set("v.createWORecords", true);
  },
  onSheetChange: function (component, event, helper) {
    var buttonName = event.getSource().get("v.label");

    component.set("v.buttonClicked", buttonName);
    var listOLI = [];
    var checkvalue = component.find("checkedOLI");
    component.set("v.sheetChangeShowModal", true);
    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        var oli = checkvalue.get("v.text");
        oli.HRCSVC_Special_Instructions__c = "";
        listOLI.push(oli);
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          var oli = checkvalue[i].get("v.text");
          oli.HRCSVC_Special_Instructions__c = "";
          listOLI.push(oli);
        }
      }
    }
    component.set("v.selectedOrderLineItemList", listOLI);
    component.set("v.createWORecords", true);
  },
  selectedNonRepairSwap: function (component, event, helper) {
    var buttonName = event.getSource().get("v.label");
    component.set("v.buttonClicked", buttonName);
    var checkvalue = component.find("checkedOLI");
    var orderLineItemRecords = component.get("v.orderLineItemList");

    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;

    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        var oli = checkvalue.get("v.text");
        //update selected records
        oli.HRCSVC_End_Date__c = today;
        oli.HRCSVC_Service_Activity_Type__c = "8";
        oli.HRCSVC_Order_Line_Item_Status__c = "Completed";
        //create new records.
        var newOrderLineotem = helper.createNewSwappedOli(
          component,
          event,
          oli
        );
        orderLineItemRecords.push(newOrderLineotem);
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          var oli = checkvalue[i].get("v.text");
          //update selected records
          oli.HRCSVC_End_Date__c = today;
          oli.HRCSVC_Service_Activity_Type__c = "8";
          oli.HRCSVC_Order_Line_Item_Status__c = "Completed";
          //create new records.
          var newOrderLineotem = helper.createNewSwappedOli(
            component,
            event,
            oli
          );
          orderLineItemRecords.push(newOrderLineotem);
        }
      }
    }
    component.set("v.createWORecords", true);
    component.set("v.orderLineItemList", orderLineItemRecords);
  },
  onRepairSwap: function (component, event, helper) {
    var buttonName = event.getSource().get("v.label");
    component.set("v.buttonClicked", buttonName);
    var checkvalue = component.find("checkedOLI");
    var orderLineItemRecords = component.get("v.orderLineItemList");
    var OrderRecord = component.get("v.customOrder");
    OrderRecord.HRCSVC_Status__c = "Swapped";
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;
    var listOLI = [];
    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        var oli = checkvalue.get("v.text");
        //update selected records
        oli.HRCSVC_End_Date__c = today;
        oli.HRCSVC_Service_Activity_Type__c = "7";
        oli.HRCSVC_Status__c = "Swapped";
        //create new records.
        var newOrderLineItem = helper.createNewRepairSwapOli(
          component,
          event,
          oli
        );
        orderLineItemRecords.push(newOrderLineItem);
        listOLI.push(oli);
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          var oli = checkvalue[i].get("v.text");
          //update selected records
          oli.HRCSVC_End_Date__c = today;
          oli.HRCSVC_Service_Activity_Type__c = "7";
          //create new records.
          var newOrderLineItem = helper.createNewRepairSwapOli(
            component,
            event,
            oli
          );
          orderLineItemRecords.push(newOrderLineItem);
          listOLI.push(oli);
        }
      }
    }
    component.set("v.createWORecords", true);
    component.set("v.selectedOrderLineItemList", listOLI);
    component.set("v.orderLineItemList", orderLineItemRecords);
  },
  /** SE-1303 related to Admin completion of Deliveries or removals
   * this logic will need to enable a modal pop-up with relevant fields to allow the agent to complete a Work Order
   *
   */
  onAdminComplete: function (component, event, helper) {
    var buttonName = event.getSource().get("v.label");
    component.set("v.buttonClicked", buttonName);
    var orderLineItemRecords = component.get("v.orderLineItemList");

    component.set("v.showAdditionalWOFields", true);
    component.set("v.createWORecords", true);
    var action = component.get("c.getWorkOrdersForOLIs");
    action.setParams({
      olis: component.get("v.selectedOrderLineItemList")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log(result);
        component.set("v.workOrders", result);
      }
    });
    $A.enqueueAction(action);
  },

  /** this is a method used to set the component variable that stores the list of checked Order Line Items.
   *  it is updated each and every time a button is checked or unchecked because the visibility of the admin complete
   * button is driven off of the Asset Status and Activity Type of Order Lines
   */
  updateCheckedLines: function (component, event, helper) {
    var listOLI = [];
    var checkvalue = component.find("checkedOLI");
    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        var oli = checkvalue.get("v.text");
        listOLI.push(oli);
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          var oli = checkvalue[i].get("v.text");
          listOLI.push(oli);
        }
      }
    }
    component.set("v.selectedOrderLineItemList", listOLI);
    var action = component.get("c.allowAdminComplete");
    action.setParams({
      olis: component.get("v.selectedOrderLineItemList")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        component.set("v.adminCompleteEligible", result);
      }
    });
    $A.enqueueAction(action);
  },
  onTechnicianBedMove: function (component, event, helper) {
    var buttonName = event.getSource().get("v.label");
    component.set("v.buttonClicked", buttonName);
    var checkvalue = component.find("checkedOLI");
    var orderLineItemRecords = component.get("v.orderLineItemList");
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;
    var today = new Date();
    var dd = String(today.getDate()).padStart(2, "0");
    var mm = String(today.getMonth() + 1).padStart(2, "0");
    var yyyy = today.getFullYear();
    today = yyyy + "-" + mm + "-" + dd;
    var listOLI = [];
    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        var oli = checkvalue.get("v.text");
        //update selected records
        oli.HRCSVC_End_Date__c = today;
        oli.HRCSVC_Order_Line_Item_Status__c = "Completed";
        //create new records.
        var newOrderLineItem = helper.createNewBedMoveOli(
          component,
          event,
          oli
        );
        orderLineItemRecords.push(newOrderLineItem);
        listOLI.push(oli);
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          var oli = checkvalue[i].get("v.text");
          //update selected records
          oli.HRCSVC_End_Date__c = today;
          oli.HRCSVC_Order_Line_Item_Status__c = "Completed";
          //create new records.
          var newOrderLineItem = helper.createNewBedMoveOli(
            component,
            event,
            oli
          );
          orderLineItemRecords.push(newOrderLineItem);
          listOLI.push(oli);
        }
      }
    }
    //component.set("v.createWORecords",true);
    component.set("v.selectedOrderLineItemList", listOLI);
    component.set("v.orderLineItemList", orderLineItemRecords);
  },
  selectedOnSiteRepair: function (component, event, helper) {
    /*
        var checkvalue = component.find("checkedOLI");
        var orderLineItemRecords = component.get("v.orderLineItemList");
        if(!Array.isArray(checkvalue)){
            if (checkvalue.get("v.value") == true) {
                var oli = checkvalue.get("v.text");
                //create new records.
                var newOrderLineotem = helper.createOnSiteRepairOLI(component, event,oli);
                orderLineItemRecords.push(newOrderLineotem);
            }
        }else{
            for (var i = 0; i < checkvalue.length; i++) {
                if (checkvalue[i].get("v.value") == true) {
                    var oli = checkvalue[i].get("v.text");
                    //create new records.
                    var newOrderLineotem = helper.createOnSiteRepairOLI(component, event,oli);
                    orderLineItemRecords.push(newOrderLineotem);
                }
            }
        }
        component.set("v.orderLineItemList",orderLineItemRecords);*/
  },
  // this function automatic call by aura:waiting event
  showSpinner: function (component, event, helper) {
    // make Spinner attribute true for display loading spinner
    component.set("v.Spinner", true);
  },

  // this function automatic call by aura:doneWaiting event
  hideSpinner: function (component, event, helper) {
    // make Spinner attribute to false for hide loading spinner
    component.set("v.Spinner", false);
  },
  onAdminBedMove: function (component, event, helper) {
    var buttonName = event.getSource().get("v.label");
    component.set("v.buttonClicked", buttonName);

    var listOLI = [];
    var checkvalue = component.find("checkedOLI");

    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        var oli = checkvalue.get("v.text");
        oli.HRCSVC_Paging_Team__c = "NP";
        listOLI.push(oli);
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          var oli = checkvalue[i].get("v.text");
          oli.HRCSVC_Paging_Team__c = "NP";
          listOLI.push(oli);
        }
      }
    }
    component.set("v.selectedOrderLineItemList", listOLI);

    component.set("v.adminBedMoveShowModal", true);
    component.set("v.createWORecords", true);
    console.log(component.get("v.selectedOrderLineItemList"));
    var action = component.get("c.getWOAdminBedMove");
    action.setParams({
      olis: component.get("v.selectedOrderLineItemList")
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log(result);
        component.set("v.adminBedWorkOrders", result);
      }
    });
    $A.enqueueAction(action);
  },

  closeAdminBedMoveModal: function (component, event, helper) {
    component.set("v.adminBedMoveShowModal", false);
    component.set("v.buttonClicked", "");
  }
});