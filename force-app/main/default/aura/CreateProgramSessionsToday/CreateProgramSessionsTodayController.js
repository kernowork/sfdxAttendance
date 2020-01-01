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
        console.log('addSelected');
        //create array for temporary storage of Ids of checked participants

        var boxes = ["checkBox0", "checkBox1", "checkBox2", "checkBox3", "checkBox4"];

        //get all checkboxes
        // for (var n = 0; n < 1; n++) {
            var tempIDs = [];
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
                helper.saveSessions(component, event, tempIDs, 1);
            }
            console.log('getAllId is null');
        // }
    },



})