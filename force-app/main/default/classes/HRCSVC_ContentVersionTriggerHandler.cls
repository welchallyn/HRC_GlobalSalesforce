/**********************************************************************************************************************************************
* Name                             :  HRCSVC_ContentVersionTriggerHandler
* Author                           :  Kushagra Bansal
* Date                             :  March/23/2021
* Requirement/Project Name         :  Hill-Rom
* Requirement/Project Description  :  Helper class for the HRCSVC_ContentVersionTrigger, part of the components developed for SE-1770,SE-1904.
* Revision						   :  Added handlePublicLinkGeneration method on June/29/2021 as part of SE-1904.
/**********************************************************************************************************************************************/
public class HRCSVC_ContentVersionTriggerHandler {
    
    /*****************************************************************************************************************
* Method Name: handleAEMVisibility
* Author: Kushagra Bansal
* Date: March/23/2021
* Params: List<ContentVersion>  
* Return: n/a (void method)
* Requirement :SE-1770 :  to pre-populate the AEM Visibility field
******************************************************************************************************************/
    public static void handleAEMVisibility(List<ContentVersion> cvList){
        Id profileId = UserInfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        
        list<HRCFSL_Organization_Settings__mdt> caseManagementUserslist = new list<HRCFSL_Organization_Settings__mdt>();
        caseManagementUserslist=[Select Id,DeveloperName,HRCFSL_Component_Detail_Long__c From HRCFSL_Organization_Settings__mdt WHERE DeveloperName =: 'HRCSVC_Case_Management_User_Profiles'];
        HRCFSL_Organization_Settings__mdt caseManagementUsers = caseManagementUserslist.size()>0 ? caseManagementUserslist[0] : null;
        
        for( ContentVersion cv : cvList){
            if(cv.HRCSVC_AEM_Visibility__c == null && caseManagementUsers!=null && (caseManagementUsers.HRCFSL_Component_Detail_Long__c.contains(profileName) == false)){
                cv.HRCSVC_AEM_Visibility__c = 'Private';
            }
        }
    }
    /*****************************************************************************************************************
* Method Name: handlePublicLinkGeneration
* Author: Kushagra Bansal
* Date: June/29/2021
* Params: List<ContentVersion>  
* Return: n/a (void method)
* Requirement :SE-1904 :  to generate public link if AEM Visibility is public
******************************************************************************************************************/
    public static void handlePublicLinkGeneration(List<ContentVersion> cvList){
        List<ContentDistribution> cdList = new List<ContentDistribution>();
        for( ContentVersion cv : cvList){
            if(cv.HRCSVC_AEM_Visibility__c == 'Public'){
                ContentDistribution cd = new ContentDistribution();
                cd.Name = 'Test';
                cd.ContentVersionId = cv.id;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                cdList.add(cd);
            }
        }
        if(cdList.size() > 0) insert cdList;
    }
}