public class RecordTypeUtil {
    public static Id getRecordTypeIdByName(String objName, String rTypeName) {
		Id rId;
		Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
		if(gd.get(objName) != null) {
			Map<String, Schema.RecordTypeInfo> infos = gd.get(objName).getDescribe().getRecordTypeInfosByName();
			rId = infos.get(rTypeName).getRecordTypeId();
		}
        
        return rId;
	}
}