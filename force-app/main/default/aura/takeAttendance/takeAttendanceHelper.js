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
                    "title": "Getting Program Registrations",
                    "message": "Insufficient access privileges for this action."
                })
                
                resultsToast.fire();
                $A.get("e.force:closeQuickAction").fire();
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
         		$A.get('e.force:refreshView').fire();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saving/updating Attendances",
                    "message": "Attendance records have been saved/updated for this session."
                })
            } else {
                console.log('NO GOOD');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saving/updating Attendances",
                    "message": "Insufficient access privileges for this action."
                })
            }
        });
        $A.enqueueAction(action);

        component.set("v.showSpinner", false);
        resultsToast.fire();
        $A.get("e.force:closeQuickAction").fire();
    },
    
    
})