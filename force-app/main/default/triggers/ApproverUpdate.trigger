/* Last modified by: Jenish Shingala 22th Nov,2016*/
trigger ApproverUpdate on Evaluation_Form__c(Before Insert) {
    String currentUserId = UserInfo.getUserRoleId();
    String level1ManagerId;
    String approverForTenItemsid;
    String legalDepartmentUser;
    if(currentUserId!=null){
        String ID1 = [select parentroleid from userrole where id =: currentUserId limit 1].parentroleid;
         String ID2 = [select parentroleid from userrole where id =: ID1 limit 1].parentroleid;
         if(Id1!=null){
              level1ManagerId = [Select id from user where UserRoleId =: id1 limit 1].id;
         }
         else {
                trigger.new[0].adderror('User role is not assigned for your profile. Please contact your Administrator');
            }
        if(ID2!=null){
           approverForTenItemsid = [Select id from user where UserRoleId =: id2 limit 1].id;
           legalDepartmentUser = [Select id from user where Name = 'Carol Prickel' limit 1].id;
        }
        else{
            trigger.new[0].adderror('User role is not assigned for your profile. Please contact your Administrator');
        }
        
    }
    
    for (Evaluation_Form__c EF: Trigger.new) {
      
            if (level1ManagerId != Null) {
                EF.level_1_manager__c = level1ManagerId;
            } else {
                EF.adderror('User role is not assigned for your profile. Please contact your Administrator');
            }
            if (approverForTenItemsid != Null && legalDepartmentUser!=null) {
                EF.Approver_for_items_more_than_ten__c = approverForTenItemsid;
                System.debug('Approver_for_items_more_than_ten__c' + EF.Approver_for_items_more_than_ten__c);
                ef.Legal_Department_User__c = legalDepartmentUser;
            } else {
                EF.adderror('User role is not assigned for your profile. Please contact your Administrator');
            }
      
    }
}