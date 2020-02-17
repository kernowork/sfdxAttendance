public with sharing class CrudMethods {

    public static void checkObjectReadAccess(String type) {
        // this is the only way I could get a "false" value from isAccessible() etc. for test user without permissions
        String[] types = new String[]{};
        types.add(type);
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        if(!results[0].isAccessible()) {
            throw new System.NoAccessException();
        }
    }

    public static void checkFieldReadAccess(Schema.DescribeSObjectResult dsr, String [] accessFields) {
        Map<String, Schema.SOBjectField> mm = dsr.fields.getMap();
        for (String fieldToCheck : accessFields) {
            if (!mm.get(fieldToCheck).getDescribe().isAccessible()) {
                throw new System.NoAccessException();
            }
        }
    }


    public static void checkObjectCreateAccess(String type) {
        String[] types = new String[]{};
        types.add(type);
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        if(!results[0].isCreateable()) {
            throw new System.NoAccessException();
        }
    }

    public static void checkObjectUpdateAccess(String type) {
        String[] types = new String[]{};
        types.add(type);
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        if(!results[0].isUpdateable()) {
            throw new System.NoAccessException();
        }
    }

    public static void checkFieldUpdateAccess(Schema.DescribeSObjectResult dsr, String [] accessFields) {
        Map<String, Schema.SOBjectField> mm = dsr.fields.getMap();
        for (String fieldToCheck : accessFields) {
            if (!mm.get(fieldToCheck).getDescribe().isUpdateable()) {
                throw new System.NoAccessException();
            }
        }
    }


    public static void checkDeleteAccess(String type) {
        String[] types = new String[]{};
        types.add(type);
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        if(!results[0].isDeletable()) {
            throw new System.NoAccessException();
        }
    }
}