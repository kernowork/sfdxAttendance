({
    setOptions : function(component, event, helper) {
        var action = component.get("c.getSundays");
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                console.log('Found something' + actionResult.getReturnValue());
                var result = actionResult.getReturnValue();
                component.set("v.dates", result);
                component.set("v.selectedDate", result[0]);
            } else {
                console.log('NO GOOD!');
            }
        });

        $A.enqueueAction(action);
    },

    saveSessions: function(component, event, tempIDs, day) {
        console.log('tempIDs = ' + tempIDs);     
        var sundayDate = component.get("v.selectedDate");
        var action = component.get("c.createProgramSessions");
        action.setParams({
            "programIds": tempIDs,
            "sundayDate" : sundayDate,
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