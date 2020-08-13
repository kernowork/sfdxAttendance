({
    doInit: function (component, event, helper) {
        var action = component.get("c.getProgramName");
        action.setParams({
            "recordId": component.get("v.recordId"),
        });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                console.log('Found something' + actionResult.getReturnValue());
                component.set("v.programName", actionResult.getReturnValue());
            } else {
                console.log('NO GOOD!');
            }
        });
        $A.enqueueAction(action);
    },

    spinnerDisplayHandler : function(component, event, helper) {
        console.log('show spinner value changes');
        helper.showHideSpinner(component); 
    },
    
    
    loadForm: function (component, event, helper) {
        console.log('loadForm');
        helper.getProgramSessionDates(component);
        helper.getForm(component);
    },

    startOver: function (component, event, helper) {
        component.set("v.registrantList", null);
        component.set("v.date1", null);
        component.set("v.date2", null);
        component.set("v.dates", null);
        component.set("v.loaded", false);
        component.set("v.startOver", true);
    },


    addSelected: function (component, event, helper) {
        component.set("v.showSpinner", true);

        //get all checkboxes
        var getAllId = component.find("checkBox");

        //save the ones that are checked
        if (getAllId != null) {

            //create array for temporary storage of Ids of checked participants
            var tempIDs = [];
            var days = [];

            if (!Array.isArray(getAllId) && (getAllId.get("v.checked") == true)) {
                console.log(getAllId.get("v.name"));
                tempIDs.push(getAllId.get("v.value"));  //in the unlikely case there is only one entry in the form!
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.checked") == true) {
                        tempIDs.push(getAllId[i].get("v.value"));
                        days.push(getAllId[i].get("v.name"));
                        console.log(getAllId[i].get("v.name"));
                    }
                }
            }
            helper.saveEdited(component, event, tempIDs, days);
        }
    },
})