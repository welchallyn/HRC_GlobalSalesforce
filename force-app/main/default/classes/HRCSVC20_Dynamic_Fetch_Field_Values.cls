/***********************************************************************************************************************************************
* Name                             :  HRCSVC20_CQ_Backup_Values
* Author                           :  Capgemini
* Date                             :  November'21
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  SE-2620
/***********************************************************************************************************************************************/

public class HRCSVC20_Dynamic_Fetch_Field_Values {
public static Schema.FieldSet Fset;
public static Map<String,Schema.FieldSetMember> Allfieldsdetails;    
    
public static Map<String,Schema.FieldSetMember> ReturnSobjectFieldsetFields(Schema.FieldSet Fset)
{
Allfieldsdetails = new Map<String,Schema.FieldSetMember>();
for (FieldSetMember fields : Fset.getFields())
{
    Allfieldsdetails.put(fields.getFieldPath(),fields);
}
system.debug('Allfieldsdetails =====>'+Allfieldsdetails);    
return Allfieldsdetails;
}

    public static sobject fetchSobjectRecValues(Id RecordId,Schema.FieldSet Fset) 
    {
        String SobjectName = RecordId.getSObjectType().getDescribe().getName();
        String query = 'Select ';
        for(FieldSetMember fields : fset.getFields())
        {
            query += fields.getFieldPath()+', ';
        }
        query += 'Id FROM '+SobjectName+' WHERE id = :RecordId';
        system.debug('query '+query);
        return Database.query(query);
}

public static Map<String,Schema.FieldSetMember> ReturnFieldsetFields(String FieldsetName,Schema.FieldSet Fset)
{
return (Allfieldsdetails == null) ? ReturnSobjectFieldsetFields(Fset) : Allfieldsdetails;
}

}