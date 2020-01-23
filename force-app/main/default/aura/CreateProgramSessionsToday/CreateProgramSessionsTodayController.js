({

    doInit: function (component, event, helper) {
        component.set("v.programList", []);
        component.set("v.loaded", false);

    },

    getProgramList: function (component, event, helper) {

        var action = component.get("c.getSessionGrid");
        action.setParams({ "sunday": null });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                console.log('Found something' + actionResult.getReturnValue());
                var result = actionResult.getReturnValue();
                component.set("v.programList", result);
                component.set("v.loaded", true);
            } else {
                console.log('NO GOOD!');
            }
        });

        $A.enqueueAction(action);

    },


    addSelected: function (component, event, helper) {
        //create array for temporary storage of Ids of checked participants
        var tempIDs = [];

        //get all checkboxes
        var getAllId = component.find('checkBox0');

        //save the ones that are checked
        if (getAllId != null) {
            if (!Array.isArray(getAllId) && (getAllId.get("v.checked") == true && getAllId.get("v.disabled") == false)) {
                tempIDs.push(getAllId.get("v.value"));  //in the unlikely case there is only one entry in the form!
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    if (getAllId[i].get("v.checked") == true && getAllId[i].get("v.disabled") == false) {
                        tempIDs.push(getAllId[i].get("v.value"));
                    }
                }
            }

            console.log(tempIDs);
            if(tempIDs.length > 0) {
                helper.saveSessions(component, event, tempIDs, 1);
            }
        }
        console.log('getAllId is null');

    },



})