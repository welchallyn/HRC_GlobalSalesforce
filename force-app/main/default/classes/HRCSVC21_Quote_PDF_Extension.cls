public class HRCSVC21_Quote_PDF_Extension {
public List<Account_Team_Role__c> ListofAccountTeamRole{get;set;}
public HRCSVC21_Quote_PDF_Extension(ApexPages.standardController sc)
{
        system.debug('Quote Id ---> '+(id)sc.getRecord().id);
        Id quoteid= (id)sc.getRecord().id;
        Id AccId = [select id,accountid,opportunityid from quote where id=:quoteid][0].AccountId;
    	system.debug('ACCID '+AccId);
		for(Account a  : [SELECT id,(SELECT UserId__r.Name,UserId__r.MobilePhone,UserId__r.Email, Position__c FROM Account_Team_Roles__r  WHERE Position__c = 'CCE'  ORDER BY CreatedDate ASC LIMIT 1) FROM Account WHERE Id = :AccId])
        {
        system.debug('INSIDE ACCOUNT');      
        ListofAccountTeamRole = new List<Account_Team_Role__c>();
            if (!a.Account_Team_Roles__r.isEmpty()){
                ListofAccountTeamRole.add(a.Account_Team_Roles__r);
      	        system.debug('ListofAccountTeamRole -> '+ListofAccountTeamRole[0].UserId__r.Name);    
            }
               
        }     
}    
}