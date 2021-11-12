/* 
 * This class helps in sending remainder emails to the approvers.
 */
public with sharing class HRCCFRApprovalReminderEmails{
    
    /* This method helps in fetching the records that are 
     for approval and send emails to the approvers.*/
    public static void sendRemainderEmails(List<Capital_Requests__c> crList){
        System.debug('--crList----'+crList);
        try{
            Set<Id> crIds = new Set<Id>();
            for(Capital_Requests__c cr : crList){
                // Only CRs with the sendemailhelper checkbox true.
                if(cr.SendEmailHelper__c){
                    crIds.add(cr.Id);
                }
            }
            System.debug('--crIds----'+crIds);
            if(crIds != null && crIds.size() > 0){
                // Quering the ProcessInstance records which contains Approval info. Filtering the records with pending approval status.
                List<ProcessInstance> proInsList = [select Id, TargetObject.Name, TargetObjectID, TargetObject.Type, Status, 
                                                        (SELECT Id, Actor.email, Actor.Name, Actor.Id, ActorId FROM WorkItems) FROM ProcessInstance 
                                                         WHERE TargetObjectID =: crIds and status = 'Pending'];
                
                String userType = Schema.SObjectType.User.getKeyPrefix();// Used for filtering the records to be approved by users.
                String groupType = Schema.SObjectType.Group.getKeyPrefix();// Used for filtering the records to be approved by groups.
                
                Map<Id,Set<Id>> recordGroupIdsMap = new Map<Id,Set<Id>>();// Map used for storing recordid and its groupIds.
                Map<Id,Set<Id>> recordUserIdsMap = new Map<Id,Set<Id>>();// Map used for storing recordid and its userIds.
                
                for (ProcessInstance PI : proInsList) {
                    system.debug('\n PI : '+PI);
                    for(ProcessInstanceWorkitem WI : PI.WorkItems) {
                        system.debug('\n PI WI : '+WI);
                        if(((String)WI.ActorId).startsWith(groupType)){ //filtering the records to be approved by groups.
                            if(recordGroupIdsMap.get(PI.TargetObjectID) != null){
                                Set<Id> grpIdsTemp = recordGroupIdsMap.get(PI.TargetObjectID);
                                grpIdsTemp.add(WI.ActorId);
                                recordGroupIdsMap.put(PI.TargetObjectID, grpIdsTemp);
                            }else{
                                Set<Id> grpIdsTemp = new Set<Id>();
                                grpIdsTemp.add(WI.ActorId);
                                recordGroupIdsMap.put(PI.TargetObjectID, grpIdsTemp);
                            }
                        }else if(((String)WI.ActorId).startsWith(userType)){ //filtering the records to be approved by users.
                            if(recordUserIdsMap.get(PI.TargetObjectID) != null){
                                Set<Id> userIdsTemp = recordUserIdsMap.get(PI.TargetObjectID);
                                userIdsTemp.add(WI.ActorId);
                                recordUserIdsMap.put(PI.TargetObjectID, userIdsTemp);
                            }else{
                                Set<Id> userIdsTemp = new Set<Id>();
                                userIdsTemp.add(WI.ActorId);
                                recordUserIdsMap.put(PI.TargetObjectID, userIdsTemp);
                            }
                        }
                    }
                }
                system.debug('\n recordGroupIdsMap : '+recordGroupIdsMap);
                system.debug('\n recordUserIdsMap : '+recordUserIdsMap);
                
                Map<Id, Set<Id>> recordUserIdsFromGrp = new Map<Id, Set<Id>>();
                if(recordGroupIdsMap.keySet().size() > 0){
                    Set<Id> grpIdsList = new Set<Id>();
                    for(Set<Id> grpIds : recordGroupIdsMap.values()){
                        grpIdsList.addAll(grpIds);
                    }
                    Map<Id,Set<Id>> userGroupIdsTemp = new Map<Id,Set<Id>>();
                    Map<Id,Set<Id>> userGroupIdsParent = new Map<Id,Set<Id>>();
                    Map<Id,Set<Id>> userGroupIds = new Map<Id,Set<Id>>();
                    /*List<GroupMember> groMemList = [select UserOrGroupId, groupId From GroupMember where groupId IN : grpIdsList];
                    system.debug('\n groMemList : '+groMemList );
                    
                    for(GroupMember groMem : groMemList){
                        if(userGroupIds.get(groMem.groupId) != null){
                            Set<Id> userIdsTemp = userGroupIds.get(groMem.groupId);
                            userIdsTemp.add(groMem.UserOrGroupId);
                            userGroupIds.put(groMem.groupId, userIdsTemp);
                        }else{
                            Set<Id> userIdsTemp = new Set<Id>();
                            userIdsTemp.add(groMem.UserOrGroupId);
                            userGroupIds.put(groMem.groupId, userIdsTemp);// Map with groupid and its userids.
                        }
                    }*/
                    // Method call to fetch all the groups with its userIds and nested userIds. 
                    userGroupIds = getAllUsersFromGroups(grpIdsList, userGroupIdsTemp, userGroupIdsParent);
                    system.debug('\n userGroupIds : '+userGroupIds);
                    
                    for(Id tarObjId : recordGroupIdsMap.keySet()){
                        set<Id> grpIdsTemp = recordGroupIdsMap.get(tarObjId);
                        set<Id> userIds = new set<Id>();
                        if(grpIdsTemp != null && grpIdsTemp.size() > 0){
                            for(Id grpId :grpIdsTemp){
                                Set<Id> userIdsTemp = userGroupIds.get(grpId);
                                if(userIdsTemp != null){
                                    userIds.addAll(userIdsTemp);
                                }
                            }
                        }
                        recordUserIdsFromGrp.put(tarObjId,userIds);// Preparing map of record ids and its users of approval.
                    }
                    system.debug('\n recordUserIdsFromGrp : '+recordUserIdsFromGrp);
                }
                
                // Combining the maps of users and groups into a single final map.
                for(Id tarObjId : recordUserIdsFromGrp.keySet()){
                    if(recordUserIdsMap.containsKey(tarObjId)){
                        set<Id> userIdsTemp = recordUserIdsMap.get(tarObjId);
                        if(userIdsTemp != null && userIdsTemp.size() > 0){
                            userIdsTemp.addAll(recordUserIdsFromGrp.get(tarObjId));
                        }
                        recordUserIdsMap.put(tarObjId, userIdsTemp);
                    }else{
                        recordUserIdsMap.put(tarObjId, recordUserIdsFromGrp.get(tarObjId));
                    }
                }
                
                system.debug('\n recordUserIdsMap : '+recordUserIdsMap);
                
                if(recordUserIdsMap != null && recordUserIdsMap.values().size() >0 ){
                    Set<id> tempUserIds = new Set<id>();
                    for(Set<Id> userIds : recordUserIdsMap.values()){
                        tempUserIds.addAll(userIds);
                    }
                    system.debug('\n tempUserIds : '+tempUserIds);
                    // Quering the user records to get Name and Email for the required users.
                    Map<id,User> userMap = new Map<id,User>([select id, Name, Email from User where id IN: tempUserIds]);
                    Map<Capital_Requests__c, List<User>> finalUsersMap = new Map<Capital_Requests__c, List<User>>();
                    Map<id,Capital_Requests__c> capReqObjMap = new Map<id,Capital_Requests__c>([select id, Name, Project_Name__c from Capital_Requests__c where id =: recordUserIdsMap.keySet()]);
                    if(userMap != null){
                        for(Id targetId : recordUserIdsMap.keySet()){
                            Set<Id> userIds = recordUserIdsMap.get(targetId);
                            List<User> userList = new List<User>();
                            for(Id userId : userIds){
                                User userTemp = userMap.get(userId);
                                userList.add(userTemp);
                            }
                            // Preparing the final map with records and the corresponding userlist to which emails needs to be sent.
                            finalUsersMap.put(capReqObjMap.get(targetId), userList);
                        }
                    }
                    
                    system.debug('\n finalUsersMap : '+finalUsersMap);
                    if(finalUsersMap.keySet().size() > 0){
                        // Helper method call to send the remainder emails for the record approval.
                        sendReminderEmailHelper(finalUsersMap);
                    }
                }
            }
        }catch(Exception e){
            system.debug('Exception occured : ' + e.getMessage());  
        }
    }
    
    /* This Method helps in sending the emails to the provided users. */
    public static void sendReminderEmailHelper(Map<Capital_Requests__c, List<User>> finalUsersMap) {        
         
        // Commenting below line and the IF block corresponding to it as this Email Template is non existing also it is not used in the code 
        // Id emailTemplateID = findEmailTemplateIDByDeveloperName('CFR_Reminder_for_Approval');
     
        // Make sure this transaction won't fail due to lack of daily capacity
        Messaging.reserveSingleEmailCapacity(1);
        
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        // if(emailTemplateID != null) {
            for(Capital_Requests__c targetObj : finalUsersMap.keySet()){
                List<User> userList = finalUsersMap.get(targetObj);
                for(User userObj : userList){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();    
                    
                    // get the current salesforce instance to build the link with
                    String domain = URL.getSalesforceBaseUrl().toExternalForm();
                    String targetLink = domain + '/' + string.valueof(targetObj.Id);
                           
                    email.setToAddresses(new String[] {userObj.Email});
                       
                    // set the subject on the email
                    email.setSubject('CFR -'+targetObj.Project_Name__c +' REMINDER');
                      
                    // set the body of the email
                    email.setHTMLBody('Hello ' + userObj.Name + ',<br/><br/>' +
                                      'Your approval for \''+targetObj.Project_Name__c +'\' is requested. <br/><br/>' + 
                                      'Please ' + 
                                      '<a href=\'' + targetLink + '\'> click here </a> to view the full details.'
                    );                  

                    email.setWhatId(targetObj.Id);
                    emailList.add(email);
                    system.debug('\n email : '+email);
                }
            }
            
      //  }
        system.debug('\n emailList : '+emailList);
        
        if(emailList != null && emailList.size() > 0){
            // Calling the send email method.
            List<Messaging.SingleEmailMessage> EmailsToSend = new List<Messaging.SingleEmailMessage>(emailList);
            Messaging.sendEmail(EmailsToSend);
        }
    }
    
    /* This Method helps in returning the email template based on the name provided. */
    public static ID findEmailTemplateIDByDeveloperName(string developerName) {
        id emailTemplateID;
        List<EmailTemplate> emailTemplateResults = new List<EmailTemplate>(); 
        
        if(developerName != null){
            emailTemplateResults = [SELECT Id, Name, DeveloperName, IsActive FROM EmailTemplate WHERE DeveloperName = :developerName];
            if (emailTemplateResults.size() > 0) {
                if (emailTemplateResults[0].IsActive == true) {
                    emailTemplateID = emailTemplateResults[0].id;
                } // check for active email template
            } // check for null search results  
        } // check for blank name
        
        return emailTemplateID;
    }
    
    /* This method helps in fetching all the user ids in a group and returns a Map of groupId and its all userids. */
    public static Map<Id,Set<Id>> getAllUsersFromGroups(Set<Id> grpIdsList, Map<Id,Set<Id>> userGroupIds, Map<Id,Set<Id>> userGroupIdsParent){
        
        Set<Id> nestedGroupIds = new Set<Id>();
        system.debug('grpIdsList : '+grpIdsList);
        List<GroupMember> groMemList = [select UserOrGroupId, groupId From GroupMember where groupId IN : grpIdsList];
        system.debug('groMemList : '+groMemList);
        
        for(GroupMember groMem : groMemList){
            if ((groMem.UserOrGroupId + '').startsWith('005')){// Check if the Id starts with 005 for User.
                // Adding group users to the final map basing on the parent group.
                for(Id grpIdParent : userGroupIdsParent.keySet()){
                    Set<Id> userIdsTemp = userGroupIdsParent.get(grpIdParent);
                    if(userIdsTemp.contains(groMem.groupId)){
                        Set<Id> userIdsTemp1 = userGroupIds.get(grpIdParent);
                        if(userIdsTemp1 != null){
                            userIdsTemp1.add(groMem.UserOrGroupId);
                            userGroupIds.put(grpIdParent, userIdsTemp1);
                        }else{
                            Set<Id> userIdsTemp2 = new Set<Id>();
                            userIdsTemp2.add(groMem.UserOrGroupId);
                            userGroupIds.put(grpIdParent, userIdsTemp2);
                        }
                    }
                }
                // Adding group users to the final map.             
                if(userGroupIds.get(groMem.groupId) != null){
                    Set<Id> userIdsTemp = userGroupIds.get(groMem.groupId);
                    userIdsTemp.add(groMem.UserOrGroupId);
                    userGroupIds.put(groMem.groupId, userIdsTemp);
                }else{
                    Set<Id> userIdsTemp = new Set<Id>();
                    userIdsTemp.add(groMem.UserOrGroupId);
                    userGroupIds.put(groMem.groupId, userIdsTemp);
                }
            }else{
                // Adding group users to the parent group.
                if(userGroupIdsParent.get(groMem.groupId) != null){
                    Set<Id> userIdsTemp = userGroupIdsParent.get(groMem.groupId);
                    userIdsTemp.add(groMem.UserOrGroupId);
                    userGroupIdsParent.put(groMem.groupId, userIdsTemp);
                }else{
                    Set<Id> userIdsTemp = new Set<Id>();
                    userIdsTemp.add(groMem.UserOrGroupId);
                    userGroupIdsParent.put(groMem.groupId, userIdsTemp);
                }
                nestedGroupIds.add(groMem.UserOrGroupId);
            }
        }
        system.debug('userGroupIds inner: '+userGroupIds);
        system.debug('userGroupIdsParent: '+userGroupIdsParent);
        system.debug('nestedGroupIds : '+nestedGroupIds);
        if(nestedGroupIds.size() > 0){// Recursive call to get users in the groupId.
            userGroupIds.putAll(getAllUsersFromGroups(nestedGroupIds,userGroupIds,userGroupIdsParent));
        }
        
        return userGroupIds;
    }
}