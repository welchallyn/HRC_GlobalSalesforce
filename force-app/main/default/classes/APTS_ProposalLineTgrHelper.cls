public without sharing class APTS_ProposalLineTgrHelper { 
    public APTS_ProposalLineTgrHelper() {
        
    }
    
    public static void deleteBundlesandOption(Map<Id,Apttus_Proposal__Proposal_Line_Item__c> oldMap)
    {
      system.debug('*****call method deleteBundlesandOption()');
      system.debug('*****oldMap: ' + oldMap);
      List<Apttus_Proposal__Proposal_Line_Item__c> pliList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
      for(Apttus_Proposal__Proposal_Line_Item__c plItem:oldMap.values())
      {
          pliList.add(plItem);
      }
      
      if(pliList.size()>0)
      {
         delete [select id from APTS_Bundle__c where Proposal_Line_Item__c in:pliList ];  
         delete [select id from APTS_Option__c where Proposal_Line_Item__c in:pliList ];
      }
    }
    
    public static void categorizeBundlesandOptions(Map<Id,Apttus_Proposal__Proposal_Line_Item__c> newMap)
    {
      
      Id ProposalId;
      for(Apttus_Proposal__Proposal_Line_Item__c plItem:newMap.values())
      {
        ProposalId=  plItem.Apttus_Proposal__Proposal__c;
        break;
      }
      /*
      delete [select id from APTS_Bundle__c where Proposal__c =:ProposalId ];  
      delete [select id from APTS_Option__c where Proposal__c =:ProposalId  ];   
      */
      
      //Apttus_Proposal__Proposal_Line_Item__c proposalLineItem
      Map<Decimal,Id> LineNumber_BundleId=new Map<Decimal,Id>();
      list<APTS_Bundle__c> ListOfBundles= new List<APTS_Bundle__c>();
      list<APTS_Option__c> ListOfOptions= new List<APTS_Option__c>();
      string sobjType_propLineItem='Apttus_Proposal__Proposal_Line_Item__c';
      string sobjType_Bundle='APTS_Bundle__c';
      string sobjType_Options='APTS_Option__c';
      set<string> proposalLineFields= getListOfFields(sobjType_propLineItem);
      map<string,string> proposalLineFieldsWithOutNs=getFieldWithOutNameSpaces(proposalLineFields);
      set<string> bundleFields=getListOfFields(sobjType_Bundle);
      set<string> optionFields=getListOfFields(sobjType_Options);
      
      for(Apttus_Proposal__Proposal_Line_Item__c propLi:newMap.values())
      {
           string lineType=propLI.Apttus_QPConfig__LineType__c;
           if(lineType=='Product/Service')
              LineNumber_BundleId.put(propLI.Apttus_QPConfig__LineNumber__c,propLI.Id);
              
      }
        
      for(Id proposalLineId:newMap.keyset())
      {

        Apttus_Proposal__Proposal_Line_Item__c propLI = newMap.get(proposalLineId);

        string lineType=propLI.Apttus_QPConfig__LineType__c; 
        if(lineType=='Product/Service') 
        {
            //LineNumber_BundleId.put(propLI.Apttus_QPConfig__LineNumber__c,propLI.Id);
            APTS_Bundle__c bundle=new APTS_Bundle__c(Proposal_Line_Item__c=proposalLineId);
            for(string bfield:bundleFields)
            {
                if(proposalLineFieldsWithOutNs.containsKey(bfield))
                {
                    string plifield=proposalLineFieldsWithOutNs.get(bfield);                
                    bundle.put(bfield,propLI.get(plifield));  
                }

            }
            ListOfBundles.add(bundle);
        }
      }
      if(ListOfBundles.size()>0)
         insert ListOfBundles;
        
      for(APTS_Bundle__c bundle:[select id,LineNumber__c from APTS_Bundle__c where Proposal__c =:ProposalId])// =[]; 
      {
          LineNumber_BundleId.put(bundle.LineNumber__c,bundle.id);
      }
        
      for(Id proposalLineId:newMap.keyset())
      {
        Apttus_Proposal__Proposal_Line_Item__c propLI = newMap.get(proposalLineId);
        string lineType=propLI.Apttus_QPConfig__LineType__c; 
        if(lineType=='Option')
        {
            Id BundleId=LineNumber_BundleId.get(propLI.Apttus_QPConfig__LineNumber__c);
            APTS_Option__c Option=new APTS_Option__c(APTS_Bundle__c=BundleId,Proposal_Line_Item__c=proposalLineId); 
            for(string ofield:optionFields)
            {
                
                if(proposalLineFieldsWithOutNs.containsKey(ofield))
                {
                    string plifield=proposalLineFieldsWithOutNs.get(ofield);
                    Option.put(ofield,propLI.get(plifield));  
                }

            }
            ListOfOptions.add(Option); 
        }

      }
        if(ListOfOptions.size()>0)
         insert ListOfOptions;
    }


      
      
      
    

    public static set<string> getListOfFields(string sObjectType) 
    {
      //SObject s= database.query('select id from '+sObjectType+' Limit 1');
        
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectType); 
      Sobject s= targetType.newSObject(); 
      
      Schema.sObjectType t = s.getSObjectType();
      Schema.DescribeSObjectResult dsr=t.getDescribe(); 
      map<string,Schema.sObjectField> fieldMap=dsr.fields.getMap(); 
      
      set<string> setOfFields=new set<string>();
      for(string str:fieldMap.keyset())
      {
        Schema.sObjectField fieldToken=fieldMap.get(str);
        Schema.DescribeFieldResult FieldDescResult = fieldToken.getDescribe();
        
        if(!FieldDescResult.isCustom() &&
            FieldDescResult.isAutoNumber() &&
            FieldDescResult.isCalculated() &&
            FieldDescResult.isDeprecatedAndHidden() &&  
            FieldDescResult.isNameField() 
          ) 
           Continue;

          setOfFields.add(FieldDescResult.getLocalName());
      }
      return setOfFields; 
    }

    public static map<string,string> getFieldWithOutNameSpaces(set<string> strset)   
    {
      map<string,string> fieldMapWithoutNS=new map<string,string>();
      for(string str:strset)
         {
            str=str.reverse();
            list<string> splitlist= str.split('__',-1);
            string restring='';
            if(splitlist.size()>1){
                restring=splitlist[0]+'__'+splitlist[1];
            } 
            restring=restring.reverse();
            str=str.reverse();
            system.debug('--'+restring);
            fieldMapWithoutNS.put(restring,str);
            
         }
        return fieldMapWithoutNS;   
    }
    /*public static string getQuery(list<string> fieldList, string sObjectType, list<Id> recordIds)
    {
      string query='select id,name,'+string.join(fieldList,',')+' '+sObjectType+' where Id In recordIds';
      
    }*/


}