({
  addOLIRecord: function (component, event) {
    //get the account List from component
    var orderLineItemList = component.get("v.orderLineItemList");
    //please remove this as this is not required
    /*if(orderLineItemList == null || orderLineItemList == ''){
            var nonRepairSwapLines = component.get("v.nonRepairSwapLines");
            console.log('nonRepairSwapLines: '+nonRepairSwapLines);
            var action = component.get("c.parseOrderLineItemId");
            action.setParams({
                "parseThisId" : nonRepairSwapLines
            });
            action.setCallback(this, function(response) {
                console.log('State: '+response.getState());
                var state = response.getState();
                if(state === "SUCCESS") {
                    nonRepairSwapLines = response.getReturnValue();                    
                    //orderLineItemList = nonRepairSwapLines
                    console.log('orderLineItemList2: '+orderLineItemList);
                    var orderlineItem = {};
                    orderlineItem['sobjectType'] = 'Order_Line_Item__c';
                    var x;
                    for (x in nonRepairSwapLines) {
                        
                        var orderlineItem = {};
                        if(nonRepairSwapLines != null && nonRepairSwapLines.length > 0 && nonRepairSwapLines[x].HRCSVC_Contact_Name__c != null){
                            orderlineItem['HRCSVC_Contact_Name__c'] = nonRepairSwapLines[x].HRCSVC_Contact_Name__c;
                        }else{
                            orderlineItem['HRCSVC_Contact_Name__c'] = '';
                        }
                        orderlineItem['HRCSVC_Service_Activity_Type__c'] = nonRepairSwapLines[x].HRCSVC_Service_Activity_Type__c;
                        orderlineItem['Quantity__c'] = nonRepairSwapLines[x].Quantity__c;
                        orderlineItem['HRCSVC_Serial_Number__c'] = nonRepairSwapLines[x].HRCSVC_Serial_Number__c;
                        orderlineItem['HRCSVC_Start_Date__c'] = nonRepairSwapLines[x].HRCSVC_Start_Date__c;
                        orderlineItem['HRCSVC_End_Date__c'] = nonRepairSwapLines[x].HRCSVC_End_Date__c;
                        orderlineItem['HRCSVC_Equipment_On_Date__c'] = nonRepairSwapLines[x].HRCSVC_Equipment_On_Date__c;
                        orderlineItem['HRCSVC_Equipment_OFF_Date__c'] = nonRepairSwapLines[x].HRCSVC_Equipment_OFF_Date__c;
                        orderlineItem['HRCSVC_Patient_Room__c'] = nonRepairSwapLines[x].HRCSVC_Patient_Room__c;
                        orderlineItem['HRCSVC_Ward__c'] = nonRepairSwapLines[x].HRCSVC_Ward__c;
                        orderlineItem['Product__c'] = nonRepairSwapLines[x].Product__c;
                        orderlineItem['HRCSVC_Price_Method_Code__c'] = nonRepairSwapLines[x].HRCSVC_Price_Method_Code__c;
                        orderlineItem['HRCSVC_PO_Number__c'] = nonRepairSwapLines[x].HRCSVC_PO_Number__c;
                        orderlineItem['HRCSVC_Paging_Team__c'] = nonRepairSwapLines[x].HRCSVC_Paging_Team__c;
                        orderlineItem['HRCSVC_Contact_Method__c'] = nonRepairSwapLines[x].HRCSVC_Contact_Method__c;
                        orderlineItem['HRCSVC_Cancellation_Reason_Notes__c'] = nonRepairSwapLines[x].HRCSVC_Cancellation_Reason_Notes__c;
                        orderlineItem['HRCSVC_PO_Expiration_Date__c'] = nonRepairSwapLines[x].HRCSVC_PO_Expiration_Date__c;
                        orderlineItem['HRCSVC_Customer_Cost_Center__c'] = nonRepairSwapLines[x].HRCSVC_Customer_Cost_Center__c;
                        orderlineItem['Cancel_Change_Reason_Code__c'] = nonRepairSwapLines[x].Cancel_Change_Reason_Code__c;
                        orderlineItem['HRCSVC_Cancelation_Approver__c'] = nonRepairSwapLines[x].HRCSVC_Cancelation_Approver__c;
                        orderlineItem['HRCSVC_Special_Instructions__c'] = nonRepairSwapLines[x].HRCSVC_Special_Instructions__c;
                        orderlineItem['HRCSVC_Customer_Request_Date_Time__c'] = nonRepairSwapLines[x].HRCSVC_Customer_Request_Date_Time__c;
                        orderlineItem['HRCSVC_Default_Request_Date_and_Time__c'] = nonRepairSwapLines[x].HRCSVC_Default_Request_Date_and_Time__c;
                        orderLineItemList.push(orderlineItem);
                    }
                    component.set("v.orderLineItemList", orderLineItemList);
                }
            });
            $A.enqueueAction(action);
        }*/
    var orderlineItem = {};
    orderlineItem["sobjectType"] = "Order_Line_Item__c";
    if (
      orderLineItemList != null &&
      orderLineItemList.length > 0 &&
      orderLineItemList[0].HRCSVC_Contact_Name__c != null
    ) {
      orderlineItem["HRCSVC_Contact_Name__c"] =
        orderLineItemList[0].HRCSVC_Contact_Name__c;
    } else {
      orderlineItem["HRCSVC_Contact_Name__c"] = "";
    }
    orderlineItem["HRCSVC_Service_Activity_Type__c"] = "";
    orderlineItem["Quantity__c"] = "1";
    orderlineItem["HRCSVC_Serial_Number__c"] = "";
    orderlineItem["HRCSVC_Start_Date__c"] = "";
    orderlineItem["HRCSVC_End_Date__c"] = "";
    orderlineItem["HRCSVC_Equipment_On_Date__c"] = "";
    orderlineItem["HRCSVC_Equipment_OFF_Date__c"] = "";
    orderlineItem["HRCSVC_Patient_Room__c"] = "";
    orderlineItem["HRCSVC_Ward__c"] = "";
    orderlineItem["Product__c"] = "";
    orderlineItem["HRCSVC_Price_Method_Code__c"] = "";
    orderlineItem["HRCSVC_PO_Number__c"] = "";
    orderlineItem["HRCSVC_Paging_Team__c"] = "SV";
    orderlineItem["HRCSVC_Contact_Method__c"] = "Busy (booked in ServiceCloud)"; //11-02-2021, as per SE - 1555 setting default value of contact method to Busy (booked in ServiceCloud) instead of NULL
    orderlineItem["HRCSVC_Cancellation_Reason_Notes__c"] = "";
    orderlineItem["HRCSVC_PO_Expiration_Date__c"] = "";
    orderlineItem["HRCSVC_Customer_Cost_Center__c"] = "";
    orderlineItem["Cancel_Change_Reason_Code__c"] = "";
    orderlineItem["HRCSVC_Cancelation_Approver__c"] = "";
    orderlineItem["HRCSVC_Special_Instructions__c"] = "";
    orderlineItem["HRCSVC_Customer_Request_Date_Time__c"] = "";
    orderlineItem["HRCSVC_Default_Request_Date_and_Time__c"] = "";
    orderlineItem["HRCSVC_Disable_Component_Edit__c"] = false;
    orderLineItemList.push(orderlineItem);
    component.set("v.orderLineItemList", orderLineItemList);
  },

  validateRecord: function (component, event) {
    var selectedSoldTo = component.get("v.selectedSoldTo");
    var selectedShipTo = component.get("v.selectedShipTo");
    var orderLineItem = component.get("v.orderLineItemList");
    var olirowfailed = "";
    var crRowIndex;

    if (
      selectedSoldTo == "" ||
      selectedSoldTo == null ||
      Object.keys(selectedSoldTo).length === 0
    ) {
      component.set("v.showError", true);
      component.set(
        "v.message",
        "To Create an Order Record Please Provide Sold To"
      );
      component.set("v.isError", true);
      return;
    } else {
      component.set("v.showError", false);
      for (var i = 0; i < orderLineItem.length; i++) {
        crRowIndex = i + 1;
        if (
          orderLineItem[i].Product__c == null ||
          orderLineItem[i].Product__c == ""
        ) {
          olirowfailed = olirowfailed + crRowIndex + " , ";
        }
      }
      if (olirowfailed) {
        var olirowfailedstr = olirowfailed.slice(0, olirowfailed.length - 2);
        component.set(
          "v.tableMessage",
          "Please Select a Valid Product on LINE# " + olirowfailedstr
        );
        component.set("v.showTableError", true);
        return;
      }
      component.set("v.showTableError", false);
      var showError = false;
      var action = component.get("c.checkCustomerEligibility");
      action.setParams({
        selectedShipTo: selectedShipTo
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        var returnAccount = response.getReturnValue();
        var message =
          "<p>This is an entity and not eligible for a new rental sales order. It failed because :</p>";
        if (state === "SUCCESS") {
          if (returnAccount != null && returnAccount != "") {
            if (returnAccount.Billing_Type__c == "Bill-To Only") {
              message = message + "<p>Billing Type is <b>Bill-To Only</b></p>";
              showError = true;
            }
            if (returnAccount.HRCSVC_Customer_Type__c == "Inactive") {
              message = message + "<p>Customer Type is <b>Inactive</b></p>";
              showError = true;
            }
            if (returnAccount.HRCSVC_Credit_Type__c == "Credit Hold") {
              message = message + "<p>Credit Type is <b>Credit Hold</b></p>";
              showError = true;
            }
          }
          if (showError) {
            component.set("v.eligibilityModal", true);
            component.set("v.eligibilityErrorMessage", message);
            component.set("v.isError", true);
          } else if (!showError) {
            component.set("v.eligibilityModal", false);
            component.set("v.eligibilityErrorMessage", " ");
            component.set("v.isError", false);
            component.set("v.showError", false);
            var recId = component.get("v.recordId");
            if (recId === undefined) {
              this.duplicateRecordCheck(component, event);
            } else {
              this.saveRecord(component, event);
            }
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
  saveRecord: function (component, event) {
    var orderLineItems = component.get("v.orderLineItemList");
    var customOrder = component.get("v.customOrder");
    var selectedShipTo = component.get("v.selectedShipTo");
    var selectedSoldTo = component.get("v.selectedSoldTo");
    var selectedContact = component.get("v.selectedContact");
    var isDuplicate = component.get("v.isDuplicate");
    if (isDuplicate) {
      component.set("v.isDuplicate", false);
      component.set("v.showDuplicateMessage", "");
      component.set("v.isError", false);
    }
    this.showSpinner(component);
    debugger;
    var createWORecords = component.get("v.createWORecords");
    if (createWORecords) {
      this.createWorkOrderRecords(component, event);
    }
    else {
      //Call Apex class and pass account list parameters
      var action = component.get("c.saveOrderandOLIRecord");
      action.setParams({
        oliRecList: orderLineItems,
        orderRecord: customOrder,
        selectedShipTo: selectedShipTo,
        selectedSoldTo: selectedSoldTo,
        selectedContact: selectedContact
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var navEvent = $A.get("e.force:navigateToURL");
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success!",
            type: "success",
            message: "The record has been created successfully."
          });
          toastEvent.fire();
          this.hideSpinner(component);
          var returnValforOpp = response.getReturnValue();
          if (returnValforOpp != " " || returnValforOpp != null) {
            navEvent.setParams({
              url: "/" + returnValforOpp
            });
            navEvent.fire();
          }
        } else if (state === "ERROR") {
          var errors = action.getError();
          if (errors) {
            var toastEvent = $A.get("e.force:showToast");
            this.hideSpinner(component);
            toastEvent.setParams({
              type: "error",
              mode: "pester",
              title: "Error!",
              message: errors[0].message
            });
            toastEvent.fire();
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
  createWorkOrderRecords: function (component, event) {
    debugger;
    var orderLineItems = component.get("v.orderLineItemList");
    var customOrder = component.get("v.customOrder");
    var selectedShipTo = component.get("v.selectedShipTo");
    var selectedSoldTo = component.get("v.selectedSoldTo");
    var selectedContact = component.get("v.selectedContact");
    
    var orderLineItem = component.get("v.selectedOrderLineItemList");
    var action = component.get("c.createWOByOLI");
    var buttonName = component.get("v.buttonClicked");
    var workorders = component.get("v.adminBedWorkOrders");
    if (orderLineItem.length > 0 && orderLineItem != null && buttonName != "") {
      action.setParams({
        oliRecList: orderLineItem,
        buttonType: buttonName,
        adminwos: workorders
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var actionSaveOOLI = component.get("c.saveOrderandOLIRecord");
          actionSaveOOLI.setParams({
            oliRecList: orderLineItems,
            orderRecord: customOrder,
            selectedShipTo: selectedShipTo,
            selectedSoldTo: selectedSoldTo,
            selectedContact: selectedContact
          });
          actionSaveOOLI.setCallback(this, function (response) {
            var stateSaveOOLI = response.getState();
            if (stateSaveOOLI === "SUCCESS") {
              var navEvent = $A.get("e.force:navigateToURL");
              var toastEvent = $A.get("e.force:showToast");
              toastEvent.setParams({
                title: "Success!",
                type: "success",
                message: "The record has been created successfully."
              });
              toastEvent.fire();
              this.hideSpinner(component);
              var returnValforOpp = response.getReturnValue();
              if (returnValforOpp != " " || returnValforOpp != null) {
                navEvent.setParams({
                  url: "/" + returnValforOpp
                });
                navEvent.fire();
              }
            } else if (stateSaveOOLI === "ERROR") {
              var errors = actionSaveOOLI.getError();
              if (errors) {
                var toastEvent = $A.get("e.force:showToast");
                this.hideSpinner(component);
                toastEvent.setParams({
                  type: "error",
                  mode: "pester",
                  title: "Error!",
                  message: errors[0].message
                });
                toastEvent.fire();
              }
            }
          });
          $A.enqueueAction(actionSaveOOLI);
        }
        else if (state === "ERROR") {
          var errors = action.getError();
          if (errors) {
            var toastEvent = $A.get("e.force:showToast");
            this.hideSpinner(component);
            toastEvent.setParams({
              type: "error",
              mode: "pester",
              title: "Error!",
              message: errors[0].message
            });
            toastEvent.fire();
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
  duplicateRecordCheck: function (component, event) {
    var orderLineItems = component.get("v.orderLineItemList");
    var customOrder = component.get("v.customOrder");

    //Call Apex class and pass account list parameters
    var action = component.get("c.checkDupOrderRecord");
    if (
      customOrder.HRCSVC_Patient_Last_Name__c != null &&
      customOrder.HRCSVC_Patient_Last_Name__c != "" &&
      customOrder.HRCSVC_Medical_Record_ID__c != null &&
      customOrder.HRCSVC_Medical_Record_ID__c != ""
    ) {
      action.setParams({
        oliRecList: orderLineItems,
        orderRecord: customOrder
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var returnValforOpp = response.getReturnValue();
          if (
            returnValforOpp.DupOrderErrormsg != null &&
            returnValforOpp.DupOrderErrormsg != ""
          ) {
            component.set("v.isDuplicate", true);
            component.set(
              "v.showDuplicateMessage",
              returnValforOpp.DupOrderErrormsg
            );
            component.set("v.isError", true);
          }
          var isDuplicate = component.get("v.isDuplicate");
          if (!isDuplicate) {
            this.saveRecord(component, event);
          }
        } else if (state === "ERROR") {
          var errors = action.getError();
          if (errors) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
              type: "error",
              mode: "pester",
              title: "Error!",
              message: errors[0].message
            });
            toastEvent.fire();
          }
        }
      });
      $A.enqueueAction(action);
    } else {
      this.saveRecord(component, event);
    }
  },
  createNewSwappedOli: function (component, event, oli) {
    var tomorrow = new Date();
    tomorrow.setDate(new Date().getDate() + 1);
    var dd1 = String(tomorrow.getDate()).padStart(2, "0");
    var mm1 = String(tomorrow.getMonth() + 1).padStart(2, "0");
    var yyyy1 = tomorrow.getFullYear();
    tomorrow = yyyy1 + "-" + mm1 + "-" + dd1;
    var newOLI = {};
    newOLI["HRCSVC_Contact_Name__c"] = oli.HRCSVC_Contact_Name__c;
    newOLI["HRCSVC_Service_Activity_Type__c"] = "6";
    newOLI["Quantity__c"] = oli.Quantity__c;
    newOLI["HRCSVC_Serial_Number__c"] = oli.HRCSVC_Serial_Number__c;
    newOLI["HRCSVC_Start_Date__c"] = tomorrow;
    newOLI["HRCSVC_End_Date__c"] = "";
    newOLI["HRCSVC_Equipment_On_Date__c"] = oli.HRCSVC_Equipment_On_Date__c;
    newOLI["HRCSVC_Equipment_OFF_Date__c"] = oli.HRCSVC_Equipment_OFF_Date__c;
    newOLI["HRCSVC_Patient_Room__c"] = oli.HRCSVC_Patient_Room__c;
    newOLI["HRCSVC_Ward__c"] = oli.HRCSVC_Ward__c;
    newOLI["Product__c"] = "";
    newOLI["HRCSVC_Price_Method_Code__c"] = oli.HRCSVC_Price_Method_Code__c;
    newOLI["HRCSVC_PO_Number__c"] = oli.HRCSVC_PO_Number__c;
    newOLI["HRCSVC_PO_Expiration_Date__c"] = oli.HRCSVC_PO_Expiration_Date__c;
    newOLI["HRCSVC_Customer_Cost_Center__c"] =
      oli.HRCSVC_Customer_Cost_Center__c;
    newOLI["Cancel_Change_Reason_Code__c"] = oli.Cancel_Change_Reason_Code__c;
    newOLI["HRCSVC_Cancelation_Approver__c"] =
      oli.HRCSVC_Cancelation_Approver__c;
    newOLI["HRCSVC_Special_Instructions__c"] = "";
    newOLI["HRCSVC_Customer_Request_Date_Time__c"] =
      oli.HRCSVC_Customer_Request_Date_Time__c;
    newOLI["HRCSVC_Default_Request_Date_and_Time__c"] =
      oli.HRCSVC_Default_Request_Date_and_Time__c;
    newOLI["HRCSVC_Paging_Team__c"] = oli.HRCSVC_Paging_Team__c;
    newOLI["HRCSVC_Contact_Method__c"] = oli.HRCSVC_Contact_Method__c;
    newOLI["HRCSVC_Cancellation_Reason_Notes__c"] =
      oli.HRCSVC_Cancellation_Reason_Notes__c;
    newOLI["HRCSVC_Disable_Component_Edit__c"] = false;
    newOLI["HRCSVC_Standing_PO__c"] = oli.HRCSVC_Standing_PO__c;
    return newOLI;
  },
  createNewRepairSwapOli: function (component, event, oli) {
    var tomorrow = new Date();
    tomorrow.setDate(new Date().getDate() + 1);
    var dd1 = String(tomorrow.getDate()).padStart(2, "0");
    var mm1 = String(tomorrow.getMonth() + 1).padStart(2, "0");
    var yyyy1 = tomorrow.getFullYear();
    tomorrow = yyyy1 + "-" + mm1 + "-" + dd1;
    var newOLI = {};
    newOLI["HRCSVC_Contact_Name__c"] = oli.HRCSVC_Contact_Name__c;
    newOLI["HRCSVC_Service_Activity_Type__c"] = "6";
    newOLI["Quantity__c"] = oli.Quantity__c;
    newOLI["HRCSVC_Serial_Number__c"] = oli.HRCSVC_Serial_Number__c;
    newOLI["HRCSVC_Start_Date__c"] = tomorrow;
    newOLI["HRCSVC_End_Date__c"] = "";
    newOLI["HRCSVC_Equipment_On_Date__c"] = oli.HRCSVC_Equipment_On_Date__c;
    newOLI["HRCSVC_Equipment_OFF_Date__c"] = oli.HRCSVC_Equipment_OFF_Date__c;
    newOLI["HRCSVC_Patient_Room__c"] = oli.HRCSVC_Patient_Room__c;
    newOLI["HRCSVC_Ward__c"] = oli.HRCSVC_Ward__c;
    newOLI["Product__c"] = oli.Product__c;
    newOLI["HRCSVC_Price_Method_Code__c"] = oli.HRCSVC_Price_Method_Code__c;
    newOLI["HRCSVC_PO_Number__c"] = oli.HRCSVC_PO_Number__c;
    newOLI["HRCSVC_PO_Expiration_Date__c"] = oli.HRCSVC_PO_Expiration_Date__c;
    newOLI["HRCSVC_Customer_Cost_Center__c"] =
      oli.HRCSVC_Customer_Cost_Center__c;
    newOLI["Cancel_Change_Reason_Code__c"] = oli.Cancel_Change_Reason_Code__c;
    newOLI["HRCSVC_Cancelation_Approver__c"] =
      oli.HRCSVC_Cancelation_Approver__c;
    newOLI["HRCSVC_Special_Instructions__c"] = "";
    newOLI["HRCSVC_Customer_Request_Date_Time__c"] =
      oli.HRCSVC_Customer_Request_Date_Time__c;
    newOLI["HRCSVC_Default_Request_Date_and_Time__c"] =
      oli.HRCSVC_Default_Request_Date_and_Time__c;
    newOLI["HRCSVC_Paging_Team__c"] = oli.HRCSVC_Paging_Team__c;
    newOLI["HRCSVC_Contact_Method__c"] = oli.HRCSVC_Contact_Method__c;
    newOLI["HRCSVC_Cancellation_Reason_Notes__c"] =
      oli.HRCSVC_Cancellation_Reason_Notes__c;
    newOLI["HRCSVC_Disable_Component_Edit__c"] = false;
    newOLI["HRCSVC_Standing_PO__c"] = oli.HRCSVC_Standing_PO__c;
    return newOLI;
  },
  createNewBedMoveOli: function (component, event, oli) {
    var tomorrow = new Date();
    tomorrow.setDate(new Date().getDate() + 1);
    var dd1 = String(tomorrow.getDate()).padStart(2, "0");
    var mm1 = String(tomorrow.getMonth() + 1).padStart(2, "0");
    var yyyy1 = tomorrow.getFullYear();
    tomorrow = yyyy1 + "-" + mm1 + "-" + dd1;
    var newOLI = {};
    newOLI["HRCSVC_Contact_Name__c"] = oli.HRCSVC_Contact_Name__c;
    newOLI["HRCSVC_Service_Activity_Type__c"] = "B";
    newOLI["Quantity__c"] = oli.Quantity__c;
    newOLI["HRCSVC_Serial_Number__c"] = oli.HRCSVC_Serial_Number__c;
    newOLI["HRCSVC_Start_Date__c"] = tomorrow;
    newOLI["HRCSVC_End_Date__c"] = "";
    newOLI["HRCSVC_Equipment_On_Date__c"] = oli.HRCSVC_Equipment_On_Date__c;
    newOLI["HRCSVC_Equipment_OFF_Date__c"] = oli.HRCSVC_Equipment_OFF_Date__c;
    newOLI["HRCSVC_Patient_Room__c"] = "";
    newOLI["HRCSVC_Ward__c"] = "";
    newOLI["Product__c"] = oli.Product__c;
    newOLI["HRCSVC_Price_Method_Code__c"] = oli.HRCSVC_Price_Method_Code__c;
    newOLI["HRCSVC_PO_Number__c"] = oli.HRCSVC_PO_Number__c;
    newOLI["HRCSVC_PO_Expiration_Date__c"] = oli.HRCSVC_PO_Expiration_Date__c;
    newOLI["HRCSVC_Customer_Cost_Center__c"] =
      oli.HRCSVC_Customer_Cost_Center__c;
    newOLI["Cancel_Change_Reason_Code__c"] = oli.Cancel_Change_Reason_Code__c;
    newOLI["HRCSVC_Cancelation_Approver__c"] =
      oli.HRCSVC_Cancelation_Approver__c;
    var specialInstructions = "";
    newOLI["HRCSVC_Standing_PO__c"] = oli.HRCSVC_Standing_PO__c;
    if (oli.HRCSVC_Ward__c) {
      if (oli.HRCSVC_Patient_Room__c) {
        specialInstructions =
          "Ward : " +
          oli.HRCSVC_Ward__r.Name +
          " Room : " +
          oli.HRCSVC_Patient_Room__c;
      } else {
        specialInstructions = "Ward : " + oli.HRCSVC_Ward__r.Name;
      }
    } else if (oli.HRCSVC_Ward_Floor__c) {
      if (oli.HRCSVC_Patient_Room__c) {
        specialInstructions =
          "Ward/Floor : " +
          oli.HRCSVC_Ward_Floor__c +
          " Room : " +
          oli.HRCSVC_Patient_Room__c;
      } else {
        specialInstructions = "Ward/Floor : " + oli.HRCSVC_Ward_Floor__c;
      }
    } else if (oli.HRCSVC_Patient_Room__c) {
      specialInstructions = " Room : " + oli.HRCSVC_Patient_Room__c;
    }

    newOLI["HRCSVC_Special_Instructions__c"] = specialInstructions;
    newOLI["HRCSVC_Customer_Request_Date_Time__c"] =
      oli.HRCSVC_Customer_Request_Date_Time__c;
    newOLI["HRCSVC_Default_Request_Date_and_Time__c"] =
      oli.HRCSVC_Default_Request_Date_and_Time__c;
    newOLI["HRCSVC_Paging_Team__c"] = oli.HRCSVC_Paging_Team__c;
    newOLI["HRCSVC_Contact_Method__c"] = oli.HRCSVC_Contact_Method__c;
    newOLI["HRCSVC_Cancellation_Reason_Notes__c"] =
      oli.HRCSVC_Cancellation_Reason_Notes__c;
    newOLI["HRCSVC_Standing_PO__c"] = oli.HRCSVC_Standing_PO__c;
    newOLI["HRCSVC_Disable_Component_Edit__c"] = false;
    return newOLI;
  },
  createSubstitutionOnOLI: function (component, event, oli) {
    var newOLI = {};
    newOLI["HRCSVC_Contact_Name__c"] = oli.HRCSVC_Contact_Name__c;
    newOLI["HRCSVC_Service_Activity_Type__c"] = "D";
    newOLI["Quantity__c"] = oli.Quantity__c;
    newOLI["HRCSVC_Serial_Number__c"] = oli.HRCSVC_Serial_Number__c;
    newOLI["HRCSVC_Start_Date__c"] = oli.HRCSVC_Start_Date__c;
    newOLI["HRCSVC_End_Date__c"] = oli.HRCSVC_End_Date__c;
    newOLI["HRCSVC_Equipment_On_Date__c"] = oli.HRCSVC_Equipment_On_Date__c;
    newOLI["HRCSVC_Equipment_OFF_Date__c"] = oli.HRCSVC_Equipment_OFF_Date__c;
    newOLI["HRCSVC_Patient_Room__c"] = oli.HRCSVC_Patient_Room__c;
    newOLI["HRCSVC_Ward__c"] = oli.HRCSVC_Ward__c;
    newOLI["Product__c"] = oli.Product__c;
    newOLI["HRCSVC_Price_Method_Code__c"] = oli.HRCSVC_Price_Method_Code__c;
    newOLI["HRCSVC_PO_Number__c"] = oli.HRCSVC_PO_Number__c;
    newOLI["HRCSVC_PO_Expiration_Date__c"] = oli.HRCSVC_PO_Expiration_Date__c;
    newOLI["HRCSVC_Customer_Cost_Center__c"] =
      oli.HRCSVC_Customer_Cost_Center__c;
    newOLI["Cancel_Change_Reason_Code__c"] = "";
    newOLI["HRCSVC_Cancelation_Approver__c"] =
      oli.HRCSVC_Cancelation_Approver__c;
    newOLI["HRCSVC_Special_Instructions__c"] = "";
    newOLI["HRCSVC_Customer_Request_Date_Time__c"] =
      oli.HRCSVC_Customer_Request_Date_Time__c;
    newOLI["HRCSVC_Default_Request_Date_and_Time__c"] =
      oli.HRCSVC_Default_Request_Date_and_Time__c;
    newOLI["HRCSVC_Paging_Team__c"] = oli.HRCSVC_Paging_Team__c;
    newOLI["HRCSVC_Contact_Method__c"] = oli.HRCSVC_Contact_Method__c;
    newOLI["HRCSVC_Cancellation_Reason_Notes__c"] =
      oli.HRCSVC_Cancellation_Reason_Notes__c;
    newOLI["HRCSVC_Disable_Component_Edit__c"] = false;
    newOLI["HRCSVC_Standing_PO__c"] = oli.HRCSVC_Standing_PO__c;

    //this part is for determining if the override reason and override code should be prepopulated based on the logic defined
    //in se-1188
    var action = component.get("c.getSubstitutionCode");
    action.setParams({
      productId: oli.Product__c
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();

        if (result != null) {
          newOLI["HRCSVC_Override_Reason__c"] = "SUB - SUBSTITUTION";
          if (result == "PAO")
            newOLI["HRCSVC_Override_Code__c"] = "PAO - PRICE AS ORDERED";
        }
      }
    });
    $A.enqueueAction(action);
    return newOLI;
  },
  createOnSiteRepairOLI: function (component, event, oli) {
    /*
        var newOLI = {};
        newOLI['HRCSVC_Contact_Name__c'] = oli.HRCSVC_Contact_Name__c;
        newOLI['HRCSVC_Service_Activity_Type__c'] = oli.HRCSVC_Service_Activity_Type__c;
        newOLI['Quantity__c'] = oli.Quantity__c;
        newOLI['HRCSVC_Serial_Number__c'] =  oli.HRCSVC_Serial_Number__c;
        newOLI['HRCSVC_Start_Date__c'] = oli.HRCSVC_Start_Date__c;
        newOLI['HRCSVC_End_Date__c'] =  oli.HRCSVC_End_Date__c;
        newOLI['HRCSVC_Equipment_On_Date__c'] = oli.HRCSVC_Equipment_On_Date__c  ;
        newOLI['HRCSVC_Equipment_OFF_Date__c'] = oli.HRCSVC_Equipment_OFF_Date__c;
        newOLI['HRCSVC_Patient_Room__c'] =  oli.HRCSVC_Patient_Room__c;
        newOLI['HRCSVC_Ward__c'] =  oli.HRCSVC_Ward__c;
        newOLI['Product__c'] = oli.Product__c;
        newOLI['HRCSVC_Price_Method_Code__c'] =  oli.HRCSVC_Price_Method_Code__c;
        newOLI['HRCSVC_PO_Number__c'] =  oli.HRCSVC_PO_Number__c;
        newOLI['HRCSVC_PO_Expiration_Date__c'] =  oli.HRCSVC_PO_Expiration_Date__c;
        newOLI['HRCSVC_Customer_Cost_Center__c'] =  oli.HRCSVC_Customer_Cost_Center__c;
        newOLI['Cancel_Change_Reason_Code__c'] =  oli.Cancel_Change_Reason_Code__c;
        newOLI['HRCSVC_Cancelation_Approver__c'] =  oli.HRCSVC_Cancelation_Approver__c;
        newOLI['HRCSVC_Special_Instructions__c'] =  oli.HRCSVC_Special_Instructions__c;
        newOLI['HRCSVC_Customer_Request_Date_Time__c'] =  oli.HRCSVC_Customer_Request_Date_Time__c;
        newOLI['HRCSVC_Default_Request_Date_and_Time__c'] = oli.HRCSVC_Default_Request_Date_and_Time__c;
        newOLI['HRCSVC_Paging_Team__c'] = oli.HRCSVC_Paging_Team__c;
        newOLI['HRCSVC_Contact_Method__c'] = oli.HRCSVC_Contact_Method__c;
        newOLI['HRCSVC_Cancellation_Reason_Notes__c'] = oli.HRCSVC_Cancellation_Reason_Notes__c;
        return newOLI;
        */
  },
  getPicklistFieldValues: function (
    component,
    event,
    fieldName,
    objectName,
    mapAttribute
  ) {
    var action = component.get("c.getPickListValuesIntoList");
    action.setParams({
      selectedField: fieldName,
      objectName: objectName
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var returnPicklistValues = [];
        for (var key in result) {
          returnPicklistValues.push({ key: key, value: result[key] });
        }
        component.set(mapAttribute, returnPicklistValues);
        //To set default value in contact source
        if (fieldName === "HRCSVC_Contact_Source__c") {
          window.setTimeout(
            $A.getCallback(function () {
              // Now set our preferred value
              component.find("contSource").set("v.value", "Telephone");
            })
          );
        }
        /*if(fieldName === 'HRCSVC_Paging_Team__c'){
                    window.setTimeout(
                        $A.getCallback( function() {
                            // Now set our preferred value
                            component.find("pagingTeam").set("v.value","SV" );
                        }));
                }
                if(fieldName === 'HRCSVC_Contact_Method__c'){
                    window.setTimeout(
                        $A.getCallback( function() {
                            // Now set our preferred value
                            component.find("contMethod").set("v.value","Busy (booked in ServiceCloud)" );
                        }));
                }*/
      }
    });
    $A.enqueueAction(action);
  },
  validateAccount: function (component, event) {
    var selectedShipTo = component.get("v.selectedShipTo");
    var action = component.find("");
  },
  deleteSelectedHelper: function (component, event, deleteRecordsIds) {
    //call apex class method
    // pass the all selected record's Id's to apex method
  },
  /*getUserLocale : function(component, event){/
            var action = component.get("c.setDefaultTeamType");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result === 'en_US'){
                        window.setTimeout(
                            $A.getCallback( function() {
                                // Now set our preferred value
                                component.find("teamT").set("v.value","Telephone" );
                            }));
                    }
                }
            });
            $A.enqueueAction(action);
        },*/
  showSpinner: function (component, event, helper) {
    var spinner = component.find("mySpinner");
    $A.util.removeClass(spinner, "slds-hide");
  },

  hideSpinner: function (component, event, helper) {
    var spinner = component.find("mySpinner");
    $A.util.addClass(spinner, "slds-hide");
  },
  getOrderandOrderLineItems: function (component, event, recordId) {
    var action = component.get("c.getOrderAndOrderLineItems");
    action.setParams({
      orderRecordId: recordId
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        var orderRecord = result.ordRec;
        component.set("v.customOrder", orderRecord);
        component.set("v.selectedSoldTo", result.soldTo);
        component.set("v.selectedShipTo", result.shipTo);
        component.set("v.orderLineItemList", result.oliRecList);
        if (
          result.addAccRec != null &&
          result.addAccRec != "" &&
          result.addAccRec.HRCSVC_Account_Protocol__c != null
        ) {
          component.set(
            "v.accountProtocol",
            result.addAccRec.HRCSVC_Account_Protocol__c
          );
        }
      }
    });
    $A.enqueueAction(action);
  },

  updateRecordsBasedOnLookupSelection: function (component, event, helper) {
    var uniqueId = event.getParam("uniqueId");
    var order = component.get("v.customOrder");
    var onloadevt = event.getParam("OnLoadEvt");
    //'wo' is the prefix for when we instantiate a custom lookup from the modal popup for the 'Admin Complete' scenario.
    //we apply logic that takes the record which is returned from the custom lookup and set the Work Order's asset to
    //the asset that was selected.
    if (uniqueId != null && uniqueId.startsWith("wo")) {
      var woindex = uniqueId.substring(2);
      var workOrders = component.get("v.workOrders");
      var workOrder = workOrders[woindex];
      var asset = event.getParam("selectedRecord");
      if (asset != null) workOrder.AssetId = asset.Id;
      else workOrder.AssetId = null;
    } else if (
      uniqueId != null &&
      uniqueId.startsWith("product") &&
      onloadevt === false
    ) {
      var oliIndex = uniqueId.substring(7);
      var orderLines = component.get("v.orderLineItemList");
      var oli = orderLines[oliIndex];
      var product = event.getParam("selectedRecord");
      if (product != null) oli.Product__c = product.Id;
      else oli.Product__c = null;
      console.log("invoking apex action for oli: " + oli);
      var action = component.get("c.getDueDate");
      action.setParams({
        oli: oli,
        order: component.get("v.customOrder")
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        console.log("response " + response.getReturnValue());
        if (state === "SUCCESS") {
          if (response != null) {
            orderLines[
              oliIndex
            ].HRCSVC_Default_Request_Date_and_Time__c = response.getReturnValue();
            orderLines[
              oliIndex
            ].HRCSVC_Customer_Request_Date_Time__c = response.getReturnValue();
            component.set("v.orderLineItemList", orderLines);
          }
        }
      });
      $A.enqueueAction(action);
    } else if (uniqueId != null && uniqueId == "shipto") {
      var location = event.getParam("selectedRecord");
      if (location != null) order.HRCSVC_Ship_To_Location__c = location.Id;
      else order.HRCSVC_Ship_To_Location__c = null;
    } else if (uniqueId != null && uniqueId.startsWith("admwo")) {
      console.log("asset selected");
      let admasset = event.getParam("selectedRecord");
      if (admasset != null) {
        console.log(admasset.Id);
        let admwoindex = uniqueId.substring(5);
        console.log(admwoindex);
        let admworkOrders = component.get("v.adminBedWorkOrders");
        let admworkOrder = admworkOrders[admwoindex];
        console.log(admworkOrder);
        let asset = event.getParam("selectedRecord");
        if (asset != null) admworkOrder.AssetId = asset.Id;
      }
    }
    component.set("v.customOrder", order);
  },
  getCustomerRental: function (component, event) {
    if (event.getParam("label") == "Product") {
      var selectedSoldTo = component.get("v.selectedSoldTo");
      var selectedShipTo = component.get("v.selectedShipTo");
      var index = event.getParam("Index");
      var selectedrec = event.getParam("selectedRecord");
      var onloadevt = event.getParam("OnLoadEvt");
      var Soldtoid = "";
      var shipToid = "";
      if (selectedSoldTo) {
        Soldtoid = selectedSoldTo["Id"];
      }
      if (selectedShipTo) {
        shipToid = selectedShipTo["Id"];
      }
      if (selectedrec && onloadevt === false) {
        var action = component.get("c.FetchRentalOrder");
        action.setParams({
          oli: event.getParam("AssociatedRec"),
          OrderShipto: shipToid,
          OrderSoldto: Soldtoid
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            if (result === false) {
              var result1 = confirm(
                "This product is not on the customer approved list. Are you sure you want to proceed?"
              );
              // alert('the result is'+result1);
              if (result1 === false) {
                // var proid='Prod';
                // var myproid=proid.concat(index);
                var childCmp = component.find("Productlkupid");
                var res = Array.isArray(childCmp);
                if (res === true) {
                  childCmp[index].clearLookup();
                } else {
                  childCmp.clearLookup();
                }
                // alert('the child component is '+childCmp);
                var orderLineItemRecordstemp = component.get(
                  "v.orderLineItemList"
                );
                orderLineItemRecordstemp[index]["Product__c"] = "";
                orderLineItemRecordstemp[
                  index
                ].HRCSVC_Default_Request_Date_and_Time__c = null;
                orderLineItemRecordstemp[
                  index
                ].HRCSVC_Customer_Request_Date_Time__c = null;
                //orderLineItemRecordstemp[index]['HRCSVC_Standing_PO__c']="test po";
                component.set("v.orderLineItemList", orderLineItemRecordstemp);
              }
            }
            // orderLineItemRecordstemp[index]['HRCSVC_Standing_PO__c']=result;
            // component.set("v.orderLineItemList", orderLineItemRecordstemp);
          }
        });
        $A.enqueueAction(action);
      }
    }
  },
  getAccountProtocol: function (component, event) {
    if (event.getParam("label") == "Ship To") {
      //account protocol logic
      if (event.getParam("selectedRecord") == null) {
        component.set("v.accountProtocol", null);
      } else {
        var action = component.get("c.findAdditionalRecordInfo");
        action.setParams({
          locationRecord: event.getParam("selectedRecord")
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            var record = result[0];
            if (record != null)
              component.set(
                "v.accountProtocol",
                record.HRCSVC_Account_Protocol__c
              );
          }
        });
        $A.enqueueAction(action);
      }
    } else if (
      event.getParam("label") == "Product" ||
      event.getParam("label") == "Ward"
    ) {
      //(event.getParam("label") == "Ward"))){
      console.log("product or ward changed");
      // alert(event.getParam("selectedRecord"));
      // alert(event.getParam("uniqueId"));
      var index = event.getParam("Index");
      var oli = event.getParam("AssociatedRec");
      var recid = component.get("v.recordId");
      var onloadevt = event.getParam("OnLoadEvt");
      var Soldtoid = "";
      var shipToid = "";
      var selectedSoldTo = component.get("v.selectedSoldTo");
      var selectedShipTo = component.get("v.selectedShipTo");
      if (selectedSoldTo) {
        Soldtoid = selectedSoldTo["Id"];
      }
      if (selectedShipTo) {
        shipToid = selectedShipTo["Id"];
      }
      if (onloadevt === false) {
        var orderLineItemRecordstemp = component.get("v.orderLineItemList");
        var action = component.get("c.FetchOLIStandingPO");
        action.setParams({
          oli: event.getParam("AssociatedRec"),
          OrderShipto: shipToid,
          OrderSoldto: Soldtoid,
          selectedRecord: event.getParam("selectedRecord")
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var result = response.getReturnValue();
            orderLineItemRecordstemp[index]["HRCSVC_Standing_PO__c"] = result;
            component.set("v.orderLineItemList", orderLineItemRecordstemp);
          }
        });
        $A.enqueueAction(action);
      }
    }
    /* if (event.getParam("label") == 'Sold To'){
            //account protocol logic
            if (event.getParam("selectedRecord") == null){
                component.set("v.accountProtocol", null);
            }else{
                var action = component.get("c.findAdditionalRecordInfo");
                action.setParams({
                    "accountRecord" :  event.getParam("selectedRecord")
                });
                action.setCallback(this, function(response){
                    var state = response.getState();
                    if (state === "SUCCESS") 
                    { 
                        var result = response.getReturnValue();
                        var record = result[0];
                        if(record != null)
                            component.set("v.accountProtocol", record.HRCSVC_Account_Protocol__c);
                    }
                });
                $A.enqueueAction(action);  
            }
        }*/
  }
});