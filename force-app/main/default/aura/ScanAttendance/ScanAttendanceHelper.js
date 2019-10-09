({
    getPeople : function(cmp, event) {
        var action = cmp.get("c.getContacts");
        action.setParams({"barcode" : cmp.get("v.barcode")});
        
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if(state === "SUCCESS") {
                console.log('GOOD');  
                cmp.set("v.contact", actionResult.getReturnValue()); 
                cmp.set("v.found", true);
            } else {
                console.log('NO GOOD!');  
                alert("No contact found with this barcode!")
                cmp.set("v.barcode", null);
            }   
            
        });
        
        $A.enqueueAction(action); 
    },
    
    saveThis : function(cmp, event) {
        var action = cmp.get("c.saveAttendance");
        action.setParams({"con" : cmp.get("v.contact"),
                          "recordId" : cmp.get("v.recordId")});       
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if(state === "SUCCESS") {
                console.log('GOOD');  
                cmp.set("v.found", false);
                cmp.set("v.barcode", null);
                $A.get('e.force:refreshView').fire();
                var resultsToast = $A.get("e.force:showToast");               
                resultsToast.setParams({
                    "title": "Program Attendance.",
                    "message": "The record has been saved."
                })
                resultsToast.fire(); 
            } else {
                console.log('NO GOOD!'); 
                var err = actionResult.getReturnValue();
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Unknown Problem",
                    "message": "No record saved."
                })
                resultsToast.fire();
            }   
        });
        
        $A.enqueueAction(action); 
    },
        
})