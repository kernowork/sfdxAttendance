({
	doInit : function(component, event, helper) {
        console.log('Starting doInit');
        helper.checkBrowser(component);
        helper.getSessionForEdit(component, event);
        
    },
    
    spinnerDisplayHandler : function(component, event, helper) {
        helper.showHideSpinner(component); 
    },
    
    addSelected: function(component, event, helper) {
        //create array for temporary storage of Ids of checked participants
    	var tempIDs = [];
        
        //get all checkboxes
        var getAllId = component.find("checkBox");
        
        //save the ones that are checked
        if(getAllId != null) {
            component.set("v.showSpinner", true);
            if (!Array.isArray(getAllId) && (getAllId).get("v.checked") == true) {
                tempIDs.push(getAllId.get("v.value"));  //in the unlikely case there is only one entry in the form!
            } else {
                for (var i=0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.checked") == true) {
                        tempIDs.push(getAllId[i].get("v.value"));
                    }
                } 
            }
            
            console.log(tempIDs);
            helper.saveEdited(component, event, tempIDs);        
        }
    },
        
})