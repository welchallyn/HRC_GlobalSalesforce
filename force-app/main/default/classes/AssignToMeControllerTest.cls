@isTest 
public class AssignToMeControllerTest {
 
    @isTest static void caseAfterUpdateTest() {
        Case c = new Case(Status ='New', Priority = 'Medium',Origin ='Phone',ownerid='0050L000009l4HJ');
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Scaletronix Service').getRecordTypeId();
        c.RecordTypeId =  devRecordTypeId;
        insert c;
        Test.startTest();
        AssignToMeController.getCase(c.Id);
        Test.stopTest();
    }
}