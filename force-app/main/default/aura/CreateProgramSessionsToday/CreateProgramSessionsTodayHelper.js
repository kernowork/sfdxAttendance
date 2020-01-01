({
    saveSessions: function(component, event, tempIDs, day) {
        console.log('tempIDs = ' + tempIDs);     
        var sundayDate = component.get("v.selectedDate");
        var action = component.get("c.createProgramSessions");
        action.setParams({
            "programIds": tempIDs,
            "sundayDate" : null,
            "days": day,
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('SUCCESS');
                console.log('Response: '+ response.getReturnValue());               
         		$A.get('e.force:refreshView').fire();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Creating New Sessions",
                    "message": "Sessions have been saved successfully."
                })
                
                resultsToast.fire();               
                
            } else {
                console.log('NO GOOD');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title":  "Error",
                    "message": "The sessions could not be saved."
                })
                
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    },
})