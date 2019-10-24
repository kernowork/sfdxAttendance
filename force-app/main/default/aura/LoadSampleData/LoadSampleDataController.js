({
    submit_contacts: function(component, event, helper) {
        console.log('submit contacts');
        var action = component.get("c.loadContacts");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if(state === "SUCCESS") {
                console.log('GOOD');  
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Loading Contacts",
                    "message": "Contact records have been saved successfully."
                })
                resultsToast.fire();  
            } else {
                console.log('NO GOOD!');  
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Error",
                    "message": "There was a problem saving the records."
                })
                resultsToast.fire();  
            }   
            
        });
        
        $A.enqueueAction(action); 
    },

    submit_programs: function(component, event, helper) {
        console.log('submit programs');
        var action = component.get("c.loadPrograms");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if(state === "SUCCESS") {
                console.log('GOOD');  
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Loading Programs",
                    "message": "Program records have been saved successfully."
                })
                resultsToast.fire();  
            } else {
                console.log('NO GOOD!'); 
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Error",
                    "message": "There was a problem saving the records."
                })
                resultsToast.fire();   
            }   
            
        });
        
        $A.enqueueAction(action); 
    },

    submit_sessions: function(component, event, helper) {
        console.log('submit sessions');
        var action = component.get("c.loadProgramSessions");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if(state === "SUCCESS") {
                console.log('GOOD'); 
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Loading Program Sessions",
                    "message": "Session records have been saved successfully."
                })
                resultsToast.fire();   
            } else {
                console.log('NO GOOD!'); 
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Error",
                    "message": "There was a problem saving the records."
                })
                resultsToast.fire();   
            }   
            
        });
        
        $A.enqueueAction(action); 
    },

    submit_attendance: function(component, event, helper) {
        console.log('submit attendance');
        var action = component.get("c.loadSessionAttendance");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if(state === "SUCCESS") {
                console.log('GOOD'); 
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Loading Session Attendance",
                    "message": "Attendance records have been saved successfully."
                })
                resultsToast.fire();   
            } else {
                console.log('NO GOOD!'); 
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Error",
                    "message": "There was a problem saving the records."
                })
                resultsToast.fire();   
            }   
            
        });
        
        $A.enqueueAction(action); 
    }
})
