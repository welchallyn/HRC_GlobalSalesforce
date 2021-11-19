/***********************************************************************************************************************************************
* Name                             :  HRCSVC20_CQ_Backup_Values
* Author                           :  Capgemini
* Date                             :  November'21
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  SE-2620
/***********************************************************************************************************************************************/

public class HRCSVC20_Dynamic_Fetch_Field_Values {
public static Schema.FieldSet Fset;
public static List<String> Allfields;
public static Map<String,String> AllfieldLabels;    
    
public static List<String> ReturnSobjectFieldsetFields(String FieldsetName,Schema.FieldSet Fset)
{
Allfields = new List<String>();
AllfieldLabels = new map<string,String>();    
system.debug('fset=====>'+Fset);
for (FieldSetMember fields : Fset.getFields())
{
    Allfields.add(fields.getFieldPath());
    AllfieldLabels.put(fields.getFieldPath(),fields.getLabel());
}
return Allfields;
}

    
public static sobject fetchSobjectValues(Id RecordId,String FieldSetName,Schema.FieldSet Fset) 
    {
        String SobjectName = RecordId.getSObjectType().getDescribe().getName();
        String query = 'Select ';
        for(String s : ReturnSobjectFieldsetFields(FieldsetName,fset))
        {
            query += s+', ';
        }
        system.debug('Input Record Id '+RecordId);
        query += 'Id FROM '+SobjectName+' WHERE id = :RecordId';
        system.debug('query '+query);
        return Database.query(query);
}

public static List<String> ReturnFieldsetFields(String FieldsetName,Schema.FieldSet Fset)
{
return (Allfields == null) ? ReturnSobjectFieldsetFields(FieldsetName,Fset) : Allfields;
}

public static map<string,String> ReturnFieldsetLabels()
{
return AllfieldLabels;
}    
}