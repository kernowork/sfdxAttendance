({
	doInit : function(component, event, helper) {
		console.log('Starting doInit');
        helper.checkBrowser(component);
        helper.getRegistrations(component);                   
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
            if (!Array.isArray(getAllId) && (getAllId).get("v.value") == true) {
                tempIDs.push(getAllId.get("v.text"));
            } else {
                for (var i=0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.value") == true) {
                        tempIDs.push(getAllId[i].get("v.text"));
                    }
                } 
            }
            helper.deleteChecked(component, event, tempIDs);
            $A.get('e.force:refreshView').fire();
        }
    },
})