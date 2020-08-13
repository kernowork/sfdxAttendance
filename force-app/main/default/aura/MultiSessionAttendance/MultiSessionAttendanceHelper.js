({
    showHideSpinner : function(component) {
        var showValue = component.get('v.showSpinner');
        
        if(showValue) {
            console.log('showValue'+showValue);
            var spinner = component.find("spinner");
            console.log('spinner'+spinner);
        	$A.util.removeClass(spinner, "slds-hide");
        } else {
            console.log('showValue'+showValue);
            var spinner = component.find("spinner");
            console.log('spinner'+spinner);
        	$A.util.addClass(spinner, "slds-hide");
        }
    },

    getProgramSessionDates: function (component) {
        component.set("v.showSpinner", true);
        console.log('getProgramSessionDates');
        var startDate = component.get("v.date1");
        var endDate = component.get("v.date2");

        var action = component.get("c.getSessionDateStrings");
        action.setParams({
            "startDate": startDate,
            "endDate": endDate,
            "recordId": component.get("v.recordId"),
        });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                console.log('Found something' + actionResult.getReturnValue());
                component.set("v.dates", actionResult.getReturnValue());
                component.set("v.showSpinner", false);
            } else {
                console.log('NO GOOD!');
                component.set("v.showSpinner", false);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Looking up Sessions",
                    "message": "Unable to complete this action."
                });
                resultsToast.fire();
            }
        });
        $A.enqueueAction(action);
    },

    getForm: function (component) {
        component.set("v.showSpinner", true);
        console.log('getForm for startDate' + component.get("v.date1"));
        var action = component.get("c.getRegistrantList");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "startDate": component.get("v.date1"),
            "endDate": component.get("v.date2")
        });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                console.log('Found something' + actionResult.getReturnValue());
                component.set("v.registrantList", actionResult.getReturnValue());
                component.set("v.loaded", true);
                component.set("v.startOver", false);
                component.set("v.showSpinner", false);
            } else {
                console.log('NO GOOD!');
                component.set("v.showSpinner", false);
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Getting registrant list",
                    "message": "Unable to complete this action."
                });
                resultsToast.fire();
            }
        });

        $A.enqueueAction(action);
    },

    saveEdited: function (component, event, tempIDs, days) {
        var action = component.get("c.saveChanges");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "startDate": component.get("v.date1"),
            "endDate": component.get("v.date2"),
            "tempIDs": tempIDs,
            "days": days
        });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                console.log('GOOD!');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Saving changes",
                    "message": "Attendances updated."
                });
                component.set("v.registrantList", null);
                component.set("v.date1", null);
                component.set("v.date2", null);
                component.set("v.dates", null);
                component.set("v.loaded", false);
                component.set("v.startOver", true);
                component.set("v.showSpinner", false);
            } else {
                console.log('NO GOOD!');
                var resultsToast = $A.get("e.force:showToast");
                resultsToast.setParams({
                    "title": "Changes not saved",
                    "message": "Unable to complete this action."
                });
                component.set("v.showSpinner", false);
            }
            resultsToast.fire();
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action); 
       
    },

})