({
    init : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
       
        if (pageReference != null)
        {
       	 component.set("v.srcURL", pageReference.state.c__srcURL);
         component.set("v.srcURLFull", pageReference.state.c__srcURLFull);
        }
    },
    
  openPopUp: function(component, event, helper) {
    component.set("v.popUpMode", true);
  },

  closePopUp: function(component, event, helper) {
    component.set("v.popUpMode", false);
  },

  openNewWindow: function(component, event, helper) {
    window.open(component.get("v.srcURLFull"));
  },

  openApplication: function(component, event, helper) {
    window.open($A.get("$Label.c.IMC_DSP_BaseURL"));
  },

  openTab: function(component, event, helper) {
    var workspaceAPI = component.find("workspace");
    workspaceAPI
      .openTab({
          
        
        pageReference: {
          type: "standard__component",
          attributes: {
            componentName: "c__IMC_DSP_QUOTE_LIST" // c__<comp Name>
          },
          state: {
            uid: "1",
            c__srcURL: component.get("v.srcURL"),
            c__srcURLFull: component.get("v.srcURLFull"),  
            c__name: "Test" // c__<comp attribute Name>
          }
        },
        focus: true
      })
      .then(response => {
        workspaceAPI.setTabLabel({
          tabId: response,
          label: "App Name / Tab name"
        });
      })
      .catch(function(error) {
        console.log(error);
      });
  },
      
  openTabNew: function(component, event, helper) {
      	const navService = component.find('navService');
        const pageReference = component.get('v.pageReference');
        const handleUrl = (url) => {
            window.open(url);
        };
        const handleError = (error) => {
            console.log(error);
        };
        navService.generateUrl(pageReference).then(handleUrl, handleError);
  }

})