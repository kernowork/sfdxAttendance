({
    checkBrowser: function(component) {
    	var device = $A.get("$Browser.formFactor");
        if(device === "DESKTOP") {
            component.set("v.mobileView", false);
        }
    },
    
    /*errorHandlingController.js*/

    checkInput : function(component) {
        if (!Number.isInteger(+component.get("v.months"))) {
            alert("Please enter whole number!");
         } 
    },

    getRegistrations : function(component) {
        var action = component.get("c.showRegistrations");
        action.setParams({"programID": component.get("v.recordId"),
                          "nMonths" : component.get("v.months")});
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            var result = actionResult.getReturnValue();
            if(state === "SUCCESS" && result !=null) {               
                console.log('Found something' + result);            
                component.set("v.registrantList", result);
                component.set("v.numRegs",result.length);                
            } else {
                console.log('NO GOOD!');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Getting Program Registrations",
                    "message": "Unable to retrieve registrations."
                })
                
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
    	});
        
        $A.enqueueAction(action); 
    },
    
	inactivateChecked : function(component, event, tempIDs) {
        console.log('tempIDs: ' + tempIDs);
        var action = component.get("c.inactivateRegs");
        action.setParams({"regIDs" : tempIDs});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('SUCCESS');
                console.log('Response: '+response.getReturnValue());
                var resultsToast = $A.get("e.force:showToast");
                if (response.getReturnValue() === true) {
                    resultsToast.setParams({
                        "title": "Inactivating Registrations",
                        "message": "Registration records have been inactivated for this program."
                    })
                } else {
                    resultsToast.setParams({
                        "title": "Check Registrations List",
                        "message": "No registrations inactivated this time."
                    })
                }
                
                resultsToast.fire();
                $A.get('e.force:refreshView').fire();
                $A.get("e.force:closeQuickAction").fire();
                
            } else {
                console.log('NO GOOD');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Inactivating Registrations",
                    "message": "Insufficient access privileges for this action."
                })
                
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
	}
})