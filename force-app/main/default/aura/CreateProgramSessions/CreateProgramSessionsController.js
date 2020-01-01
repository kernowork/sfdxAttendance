({
    doInit: function (component, event, helper) {
        component.set("v.programList", []);
        component.set("v.loaded", false);
        helper.setOptions(component, event, helper);
    },

    getProgramList: function (component, event, helper) {

        var action = component.get("c.getSessionGrid");
        action.setParams({"sunday": component.get("v.selectedDate")});
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

        var boxes = ["checkBox0", "checkBox1", "checkBox2", "checkBox3", "checkBox4", "checkBox6", "checkBox6"];

        //get all checkboxes
        for (var n = 0; n < 7; n++) {
            console.log(boxes[n]);
            var tempIDs = [];
            var getAllId = component.find(boxes[n]);

            //save the ones that are checked
            if (getAllId != null) {
                if (!Array.isArray(getAllId) && (getAllId).get("v.checked") == true && getAllId[i].get("v.disabled") == false) {
                    tempIDs.push(getAllId.get("v.value"));  //in the unlikely case there is only one entry in the form!
                } else {
                    for (var i = 0; i < getAllId.length; i++) {
                        console.log('Checked: ' + getAllId[i].get("v.checked"));
                        if (getAllId[i].get("v.checked") == true && getAllId[i].get("v.disabled") == false) {
                            tempIDs.push(getAllId[i].get("v.value"));
                        }
                    }
                }

                console.log(tempIDs);
                helper.saveSessions(component, event, tempIDs, n);
            }
        }
    },

})