({      
    checkBrowser: function(component) {
    	var device = $A.get("$Browser.formFactor");
        if(device === "DESKTOP") {
            component.set("v.mobileView", false);
        }
    },

    showHideSpinner : function(component) {
        var showValue = component.get('v.showSpinner');
        if(showValue) {
            var spinner = component.find("spinner");
        	$A.util.removeClass(spinner, "slds-hide");
        } else {
            var spinner = component.find("spinner");
        	$A.util.addClass(spinner, "slds-hide");
        }
    },
    
    
    //****** get the Program and Registrants of the Session Date to be edited
    getSessionForEdit : function(component, event) {
        var action = component.get("c.getSessionAttendanceForEdit");
        action.setParams({"sd": component.get("v.recordId")});
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if(state === "SUCCESS") {
                console.log('Found something' + actionResult.getReturnValue());            
                component.set("v.registrantList", actionResult.getReturnValue());
                component.set("v.loaded", true);
            } else {
                console.log('NO GOOD!');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Program Registrations not loaded",
                    "message": "Unable to complete this action."
                })
                
                resultsToast.fire();
        	}
    	});
        
        $A.enqueueAction(action);      
    },
    
    saveEdited: function(component, event, tempIDs) {
        console.log('tempIDs = ' + tempIDs);     
        var action = component.get("c.saveEditedAttendance");
        action.setParams({
            "sd": component.get("v.recordId"),
            "regIds": tempIDs 
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('SUCCESS');
                console.log('Response: '+ response.getReturnValue());       
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saving/updating Attendances",
                    "message": "Attendance records have been saved/updated for this session."
                })
                component.set("v.showSpinner", false);
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
            } else {
                console.log('NO GOOD');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Attendance not saved",
                    "message": "Unable to complete this action."
                })
                component.set("v.showSpinner", false);
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);

        
    },
    
    
})