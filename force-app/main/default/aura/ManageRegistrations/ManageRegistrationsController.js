({
	doInit : function(component, event, helper) {
		console.log('Starting doInit');
        helper.checkBrowser(component);
        helper.getRegistrations(component);                   
    },

    spinnerDisplayHandler : function(component, event, helper) {
        helper.showHideSpinner(component); 
    },
    
    showRegs : function(component, event, helper) {
        helper.checkInput(component);
        helper.getRegistrations(component);
    },
    
    deleteRegistrations: function(component, event, helper) {
        //create array for temporary storage of Ids of checked participants
    	var tempIDs = [];
        
        //get all checkboxes
        var getAllId = component.find("checkBox");
        
        //save the ones that are checked
        if(getAllId != null) {
            component.set("v.showSpinner", true);
            if (!Array.isArray(getAllId) && (getAllId).get("v.checked") == true) {
                tempIDs.push(getAllId.get("v.value"));
            } else {
                for (var i=0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.checked") == true) {
                        tempIDs.push(getAllId[i].get("v.value"));
                    }
                } 
            }
            helper.deleteChecked(component, event, tempIDs);
        } else {
            var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "No registrations selected",
                    "message": "Refresh Look Back List with smaller month value."
                })
                resultsToast.fire();
        }
    },
})