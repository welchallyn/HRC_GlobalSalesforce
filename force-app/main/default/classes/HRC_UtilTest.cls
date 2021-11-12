@isTest
private class HRC_UtilTest {
    static testMethod void testUtil() {
        HRC_Util.getAeRoleWhere('');
         
        HRC_Util.getAeUsers('AE', '', null, 1);
        HRC_Util.getAeUsers('COM', '', null, 1);
        HRC_Util.getAeUsers('Specialist', '', null, 1);
        HRC_Util.getAeUsers('AVP', '', null, 2);
        
        /*HRC_Util.getAeUsers('RVP', '', null, 3);
        HRC_Util.getAeUsers('VP', '', null, 4, true);*/
        
        HRC_Util.getAVPRoleWhere('');
        HRC_Util.getComRoleWhere('');
        HRC_Util.getIsAVPDVPUser();
        HRC_Util.getIsAVPUser();
        HRC_Util.getIsRVPUser();
        HRC_Util.getIsVPUser();
        HRC_Util.getIsProfileValidForOppTypes();
        HRC_Util.getOppRecordTypes();
        HRC_Util.getRoles();
        HRC_Util.getRVPRoles();
        HRC_Util.getRVPRoleWhere('');
        HRC_Util.getSpRoleWhere('');
        HRC_Util.getTerritories();
        HRC_Util.getTerritoryCodesByLevel(1, 'First', 'Last', 'Open', 'AVP',false);
        HRC_Util.getTerritoryCodesByLevel(2, 'First', 'Last', 'Open', 'COM',false);
        HRC_Util.getTerritoryCodesByLevel(3, 'First', 'Last', 'Open', 'Specialist',false);
        HRC_Util.getTerritoryCodesByLevel(4, 'First', 'Last', 'Open', 'Account Executive',false);
        
        HRC_Util.getTerritoyWhere('', 'Open', 1, 'First', 'Last', null);
        HRC_Util.getTerritoyWhere('', 'Open', 2, 'First', 'Last', null);
        HRC_Util.getTerritoyWhere('', 'Open', 3, 'First', 'Last', null);
        HRC_Util.getTerritoyWhere('', 'Open', 4, 'First', 'Last', null);
        HRC_Util.getUsersByParentRoleId(UserInfo.getUserRoleId());
        HRC_Util.getVPRoles();
        HRC_Util.getWhereClause('First', 'Last', 'Open', 'F-L', 'AE', '', '', '', '', '', '', 1);
        HRC_Util.getWhereClause('First', 'Last', 'Open', 'F-L', 'Specialist', '', '', '', '', '', '', 1);
        HRC_Util.getWhereClause('First', 'Last', 'Open', 'F-L', 'COM', '', '', '', '', '', '', 1);
        HRC_Util.getWhereClause('First', 'Last', 'Open', 'F-L', 'AVP', '', '', '', '', '', '', 2);
        HRC_Util.getWhereClause('First', 'Last', 'Open', 'F-L', 'RVP', '', '', '', '', '', '', 3);
        HRC_Util.getWhereClause('First', 'Last', 'Open', 'F-L', 'VP', '', '', '', '', '', '', 4);
    }
}