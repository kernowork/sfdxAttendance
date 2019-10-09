({
	submit : function(cmp, event, helper) {
        var validity = cmp.find("barcode").get("v.validity");
        var bc = cmp.get("v.barcode");
        console.log(validity.valid);
        console.log('barcode: ' + bc);
        if(validity.valid && bc != null) {
            helper.getPeople(cmp, helper);
        }
    },
    
    enter : function(cmp, event, helper) {
        helper.saveThis(cmp, helper);
    },
    
    clear : function(cmp, event, helper) {
        cmp.set("v.barcode", null);
        cmp.set("v.found", false);      
    }
})