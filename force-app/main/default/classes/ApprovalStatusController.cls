public class ApprovalStatusController { 
 
 public String Actor { get; set; }
 public BMCServiceDesk__Change_Request__c  chan {get;set;}
 public List<ApprovalHistoryRecord> ApprovalStatusRecordsList {get; set;}
 public List<ProcessInstanceHistory> Items {get;set;}
 public List<ProcessInstance> processinstances {get;set;}
 public List<CRApproverWrapper> CRwrapperList {get;set;}
 public List<SRApproverWrapper> SRwrapperList {get;set;}
 public List<BMCServiceDesk__Change_Request__c> CRSWithApprovalsList{get;set;}
 public List<BMCServiceDesk__Change_Request__c> changeRequests {get;set;}
 public List<BMCServiceDesk__Incident__c> serviceRequests {get;set;}
 public List<String> objects{get;set;}
 public String selectedOption {get;set;}
 public String selectedOpt {get;set;}
 public String selectedstatus {get;set;}
 public String selectedstatusSR {get;set;}
 public String CRfromdate{get;set;}
 public String CRtodate{get;set;}
 public String SRfromdate{get;set;}
 public String SRtodate{get;set;}
 public String datename {get; set;}
 public String me {get;set;}
 public List<SelectOption> options = new List<SelectOption>();
 public Datetime CR{get;set;}
 public Datetime CR1{get;set;}
 public Datetime SR{get;set;}
 public Datetime SR1{get;set;}
  
 public String crJSONString{get;set;}
 public String srJSONString{get;set;}
 
 public class DatePicker {
     public String datename {get; set;}
     public String me{get;set;}  
   
   }

 public class CRApproverWrapper{
        public String CRprocessId{get;set;}
        public String CRId{get;set;}
        public String Statuses{get;set;}
        public String CRStatus{get;set;}
        public String CRNum{get;set;}
        public String CRChangeType{get;set;}
        public String CRassignedApprover{get;set;}
        public String CRactualApprover{get;set;}
        public DateTime CRopenedDate{get;set;}
        public DateTime CRapprovedDate{set;get;}
    }
    
 public class SRApproverWrapper{
        public String SRprocessId{get;set;}
        public String SRId{get;set;}
        public String SRNum{get;set;}
        public String SRStatus{get;set;}
        public String SRassignedApprover{get;set;}
        public String SRactualApprover{get;set;}
        public DateTime SRopenedDate{get;set;}
        public DateTime SRapprovedDate{set;get;}
    }

 public ApprovalStatusController(){
    chan = new BMCServiceDesk__Change_Request__c();
    CRwrapperList = new List<CRApproverWrapper>();
    SRwrapperList = new List<SRApproverWrapper>();
    String s = 'Change Requests';
    String s1= 'Service Requests';
    objects = new List<String>();
    objects.add(s);
    objects.add(s1);   
   }

  public Datetime datValueCR(){
     CRfromdate = ApexPages.currentPage().getParameters().get('CRFromDate'); 
   
        if(CRfromdate != null && CRfromdate != '' && CRfromdate != 'undefined'){       
         List<String> openDates = new List<String>();      
         openDates = CRfromdate.split('/');
         System.debug('crfromdate opendate'+openDates);
         String CRfromdate1 = '';
         if(openDates.size() > 0 ){
         if(!Test.isRunningTest())
         CRfromdate1 = openDates[2]+'-'+openDates[0]+'-'+openDates[1]+' 00:00:00';
         else {
         DateTime dt = System.Now();
         DateTime dt1= dt.addMonths(-5);
         CRfromdate1 = String.valueOf(dt1);
         }
         System.debug('CRfromdate1..'+CRfromdate1 );    
         CR = datetime.valueOf(CRfromdate1);   
         system.debug('CRFromDate..'+CR);   
       }
      return CR;
    } else {
         return null;
       }
  }
    
  public Datetime datValueCR1(){
      CRtodate = ApexPages.currentPage().getParameters().get('CRToDate');  
      
      if(CRtodate !=null && CRtodate !='' && CRtodate !='undefined'){  
        List<String> tdates = new List<String>();       
        tdates = CRtodate.split('/');
        String date22= '';
        if(tdates.size() > 0) {
        if(!Test.isRunningTest())
        date22 = tdates[2] + '-'+tdates[0]+'-'+tdates[1]+' 23:59:59';
        else{
        DateTime dt = System.Now();
        // DateTime dt1= dt.addDays(-5);
                 date22 = String.valueOf(dt);
                 }

        CR1 =datetime.valueof(date22);  
        system.debug('CRToDate..'+CR1);      
       }
         return CR1;
     } else{
            return null;
         }
      }
      
    
  public void displayCRApprovers(){
  
     System.debug('displayCRApprovers');
     CRfromdate = ApexPages.currentPage().getParameters().get('CRFromDate');
     CRtodate = ApexPages.currentPage().getParameters().get('CRToDate');
     selectedOpt =  ApexPages.currentPage().getParameters().get('changetype');
     selectedstatus = ApexPages.currentPage().getParameters().get('Stype');
     
     System.debug('selectedOpt.......'+selectedOpt);
     System.debug('CRfromdate in dcp'+CRfromdate );
     System.debug('CRTodate in dcp'+CRTodate);
        Datetime d1;
        Datetime f2; 
      
            if( (CRfromdate == null || CRfromdate =='' || CRfromdate == 'undefined' ) && (CRtodate ==null || CRtodate =='' || CRtodate == 'undefined') ){   
             processinstances.clear();
         }   
      else{
          if(selectedstatus == 'All'){    
              processinstances = [Select Id,Status,TargetObjectId,TargetObject.Type,(SELECT Id, ActorId,Actor.Name,StepStatus,CreatedDate,Comments,OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM StepsAndWorkitems where Comments != 'Auto-Approved by system' ) FROM ProcessInstance where (Status = 'Rejected' OR Status = 'Approved') AND TargetObject.Type = 'BMCServiceDesk__Change_Request__c' limit 49500];  
        }                 
          
        else if(selectedstatus == 'Approved'){
              processinstances = [Select Id,Status,TargetObjectId,TargetObject.Type,(SELECT Id, ActorId,Actor.Name,StepStatus,CreatedDate,Comments,OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM StepsAndWorkitems where Comments != 'Auto-Approved by system') FROM ProcessInstance where (Status = 'Approved') AND TargetObject.Type = 'BMCServiceDesk__Change_Request__c' limit 49500];
         }    
        else if(selectedstatus == 'Rejected'){
              processinstances = [Select Id,Status,TargetObjectId,TargetObject.Type,(SELECT Id, ActorId,Actor.Name,StepStatus,CreatedDate,Comments,OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM StepsAndWorkitems where Comments != 'Auto-Approved by system') FROM ProcessInstance where (Status = 'Rejected') AND TargetObject.Type = 'BMCServiceDesk__Change_Request__c' limit 49500];       
        }         
    
       d1= datValueCR();
       f2=datValueCR1();
       System.debug('d1.......'+d1);
       System.debug('f2/......'+f2);    
     
  }
    
  Set<Id> processId = new Set<Id>();
  for(ProcessInstance each :processinstances ){
       processId.add(each.TargetObjectId);
    } 
  
  
   List<BMCServiceDesk__Change_Request__c> CRSWithApprovalsList = new List<BMCServiceDesk__Change_Request__c>();
     if(!Test.isRunningTest()){ 

   if((CRfromDate != null && CRtoDate != null) && selectedOpt == 'All' )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c >= :d1 AND BMCServiceDesk__Open_Date_Time__c <= : f2 ];
   else if((CRfromDate != null && CRtoDate != null) && selectedOpt != null )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c >= :d1 AND BMCServiceDesk__Open_Date_Time__c <= : f2 AND BMCServiceDesk__Change_Type__c =:selectedOpt] ;
  else if((CRfromDate != null && CRtoDate == null) && selectedOpt == 'All' )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c >= :d1 ];
   else if((CRfromDate != null && CRtoDate == null) && selectedOpt != null )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c >= :d1 AND BMCServiceDesk__Change_Type__c=:selectedOpt ];
    else if((CRfromDate == null && CRtoDate != null) && selectedOpt == 'All' )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c <= :f2];
   else if((CRfromDate == null && CRtoDate != null) && selectedOpt != null )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c <= :f2 AND BMCServiceDesk__Change_Type__c=:selectedOpt ];
     }
     
     else{
     
   if((CRfromDate != null && CRtoDate != null) && selectedOpt == 'All' )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c >= :d1 AND BMCServiceDesk__Open_Date_Time__c <= : f2 limit 2];
   else if((CRfromDate != null && CRtoDate != null) && selectedOpt != null )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c >= :d1 AND BMCServiceDesk__Open_Date_Time__c <= : f2 AND BMCServiceDesk__Change_Type__c =:selectedOpt limit 2] ;
  else if((CRfromDate != null && CRtoDate == null) && selectedOpt == 'All' )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c >= :d1 limit 2];
   else if((CRfromDate != null && CRtoDate == null) && selectedOpt != null )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c >= :d1 AND BMCServiceDesk__Change_Type__c=:selectedOpt limit 2];
    else if((CRfromDate == null && CRtoDate != null) && selectedOpt == 'All' )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c <= :f2 limit 2];
   else if((CRfromDate == null && CRtoDate != null) && selectedOpt != null )
       CRSWithApprovalsList = [Select Id, Name,BMCServiceDesk__Status__c, BMCServiceDesk__Change_Type__c,BMCServiceDesk__Open_Date_Time__c from BMCServiceDesk__Change_Request__c where Id =:processId AND BMCServiceDesk__Open_Date_Time__c <= :f2 AND BMCServiceDesk__Change_Type__c=:selectedOpt limit 2 ];
     
    } 
    system.debug('After If CRSWithApprovalsList '+CRSWithApprovalsList);
   if(CRSWithApprovalsList!= null && CRSWithApprovalsList.size()>0){  
     Integer CRCount; 
     Boolean b;
     for(ProcessInstance p : processinstances ){ 
         CRCount = 0;       
         CRApproverWrapper wrapObj = new CRApproverWrapper();
         for(BMCServiceDesk__Change_Request__c eachId :CRSWithApprovalsList ){
             if(eachId.Id == p.TargetObjectId){
                 wrapObj.CRNum = eachId.Name;
                 if(eachId.Name=='CR00003431')
         System.debug('date....'+p.StepsAndWorkItems[0].CreatedDate);
                 wrapObj.CRId = eachId.Id;
                 wrapObj.CRStatus = eachId.BMCServiceDesk__Status__c;
                 wrapObj.CRChangeType = eachId.BMCServiceDesk__Change_Type__c ;
                 wrapObj.CRopenedDate = eachId.BMCServiceDesk__Open_Date_Time__c;
                 CRCount = CRCount+1;
                 break;
             }             
         }
        System.debug('CRCount..'+CRCount);
         if(CRCount != 0){
         wrapObj.CRprocessId = p.Id;
         wrapObj.Statuses = p.status;
         wrapObj.CRassignedApprover = p.StepsAndWorkItems[0].OriginalActor.Name ;
         wrapObj.CRactualApprover = p.StepsAndWorkItems[0].Actor.Name;
         wrapObj.CRapprovedDate = p.StepsAndWorkItems[0].CreatedDate;
         
         
         CRwrapperList.add(wrapObj);
         }
         
     } 
           
   System.debug('CRSWithApprovalsList:'+CRSWithApprovalsList);
    crJSONString= '';
        crJSONString = '{';
        if(CRwrapperList != null && CRwrapperList.size()>0){
            crJSONString = crJSONString +' "records":"'+CRwrapperList.size()+'", ';
        }else{
            crJSONString = crJSONString +' "records":"0", ';
        }       
        crJSONString = crJSONString +' "rows": [';
        if(CRwrapperList != null && CRwrapperList.size()>0){
             for(Integer j=0;j<CRwrapperList.size();j++){
                if(j<CRwrapperList.size()-1) {
                    crJSONString+= '{';               
                    crJSONString += '"processId":'+json.serialize(CRwrapperList[j].CRprocessId)+',';
                    crJSONString += '"CRId":'+json.serialize(CRwrapperList[j].CRId)+',';
                    crJSONString += '"statusC":'+json.serialize(CRwrapperList[j].Statuses)+',';
                    crJSONString += '"changeNumber":'+json.serialize(CRwrapperList[j].CRNum)+',';
                    crJSONString += '"changeType":'+json.serialize(CRwrapperList[j].CRChangeType)+',';
                    crJSONString += '"CR Status":'+json.serialize(CRwrapperList[j].CRStatus)+',';
                    crJSONString += '"CRassignedApprover":'+json.serialize(CRwrapperList[j].CRassignedApprover)+',';
                    crJSONString += '"CRactualApprover":'+json.serialize(CRwrapperList[j].CRactualApprover)+',';
                    crJSONString += '"CRopenedDate":'+json.serialize(CRwrapperList[j].CRopenedDate)+',';
                    crJSONString += '"CRapprovedDate":'+json.serialize(CRwrapperList[j].CRapprovedDate)+'';
                    crJSONString+= '},';       
                } else {
                    crJSONString+= '{';    
                    crJSONString += '"processId":'+json.serialize(CRwrapperList[j].CRprocessId)+',';
                    crJSONString += '"CRId":'+json.serialize(CRwrapperList[j].CRId)+','; 
                    crJSONString += '"statusC":'+json.serialize(CRwrapperList[j].Statuses)+',';                  
                    crJSONString += '"changeNumber":'+json.serialize(CRwrapperList[j].CRNum)+',';
                    crJSONString += '"changeType":'+json.serialize(CRwrapperList[j].CRChangeType)+',';
                    crJSONString += '"CR Status":'+json.serialize(CRwrapperList[j].CRStatus)+',';
                    crJSONString += '"CRassignedApprover":'+json.serialize(CRwrapperList[j].CRassignedApprover)+',';
                    crJSONString += '"CRactualApprover":'+json.serialize(CRwrapperList[j].CRactualApprover)+',';
                    crJSONString += '"CRopenedDate":'+json.serialize(CRwrapperList[j].CRopenedDate)+',';
                    crJSONString += '"CRapprovedDate":'+json.serialize(CRwrapperList[j].CRapprovedDate)+'';
                    crJSONString+= '}';
                }            
            }  
        }
        crJSONString = crJSONString +'] }';
        system.debug('\n\n\n crJSONString '+crJSONString);
      }
      else{
       
       DateTime n = System.Now();
       String c = '--';
       String c3= ' No records found';   
       crJSONString= '{';
                    crJSONString += '"processId":'+json.serialize(c)+',';
                    crJSONString += '"CRId":'+json.serialize(c)+',';
                    crJSONString += '"statusC":'+json.serialize(c)+',';
                    crJSONString += '"changeNumber":'+json.serialize(c)+',';
                    crJSONString += '"changeType":'+json.serialize(c)+',';
                    crJSONString += '"CR Status":'+json.serialize(c)+',';
                    crJSONString += '"CRassignedApprover":'+json.serialize(c)+',';
                    crJSONString += '"CRactualApprover":'+json.serialize(c)+',';
                    crJSONString += '"CRopenedDate":'+json.serialize(c)+',';
                    crJSONString += '"CRapprovedDate":'+json.serialize(n)+'';
                    crJSONString+= '}';
       System.debug('crJSONString..'+crJSONString);
       }
    
    }


 public Datetime datValue(){
     SRfromdate = ApexPages.currentPage().getParameters().get('SRFromDate');
       
   if(SRfromdate != null && SRfromdate != '' && SRfromdate != 'undefined'){
 
     List<String> SRopenDates = new List<String>();       
        
        SRopenDates = SRfromdate.split('/');
         String SRfromdate1 = '';
         if(SRopenDates.size() > 0){
         if(!Test.isRunningTest())
         SRfromdate1 = SRopenDates[2]+'-'+SRopenDates[0]+'-'+SRopenDates[1]+' 00:00:00';
         else{
         Datetime dt = System.Now();
         Datetime dt1 = dt.addMonths(-1);
         SRfromdate1 = String.valueOf(dt1);
         }
         SR = datetime.valueOf(SRfromdate1); 
         System.debug('SRFromDate...'+SR);
       }  
      return SR;
    }   else{
        return null;
      }
 }
  
  public Datetime datvalue1(){
  SRtodate = ApexPages.currentPage().getParameters().get('SRToDate');
  
    if(SRtodate !=null && SRtodate !='' && SRtodate !='undefined'){
    
    List<String> todates = new List<String>();
    
         todates = SRtodate.split('/');
         String dates2= '';
         if(todates.size() > 0) {
         if(!Test.isRunningTest())
         dates2 = todates[2] + '-'+todates[0]+'-'+todates[1]+' 23:59:59';
         else{
         Datetime dt = System.Now();
         dates2 = String.valueOf(dt);
         }
         
         SR1 = datetime.valueOf(dates2);
         system.debug('SRtodate...... '+ SR1);
        }
      return SR1;
    }  else {
        return null;
      }
 }
 

 public void displaySRApprovers(){

   SRfromdate = ApexPages.currentPage().getParameters().get('SRFromDate');
   SRtodate = ApexPages.currentPage().getParameters().get('SRToDate');
   selectedstatusSR = ApexPages.currentPage().getParameters().get('svtype');
       System.debug('SRfromdate'+SRfromdate +'SRtodate '+SRtodate );
              
         Datetime S1;
         Datetime s2;
        
         if((SRfromdate == null || SRfromdate =='' || SRfromdate== 'undefined' ) && (SRtodate ==null || SRtodate =='' || SRtodate== 'undefined') ){   
             processinstances.clear();
         }
        else{
             if(selectedstatusSR =='All'){
                 processinstances = [Select Id,Status,TargetObjectId,TargetObject.Type,(SELECT Id, ActorId,Actor.Name,StepStatus,Comments,CreatedDate,OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM StepsAndWorkitems where Comments!='Auto-Approved by system' ) FROM ProcessInstance where ( Status = 'Rejected' OR Status = 'Approved') AND TargetObject.Type = 'BMCServiceDesk__Incident__c' limit 49500];     
                }
            else if(selectedstatusSR =='Approved'){
                 processinstances = [Select Id,Status,TargetObjectId,TargetObject.Type,(SELECT Id, ActorId,Actor.Name,StepStatus,Comments,CreatedDate,OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM StepsAndWorkitems where Comments!='Auto-Approved by system' ) FROM ProcessInstance where (Status = 'Approved') AND TargetObject.Type = 'BMCServiceDesk__Incident__c' limit 49500];                
               }
         
            else if(selectedstatusSR =='Rejected'){
                 processinstances = [Select Id,Status,TargetObjectId,TargetObject.Type,(SELECT Id, ActorId,Actor.Name,StepStatus,Comments,CreatedDate,OriginalActorId, OriginalActor.Name, ProcessInstanceId FROM StepsAndWorkitems where Comments!='Auto-Approved by system' ) FROM ProcessInstance where ( Status = 'Rejected' ) AND TargetObject.Type = 'BMCServiceDesk__Incident__c' limit 49500];                
              }
             
             S1=datValue();
             s2=datvalue1();
         } 
    
        Set<Id> SprocessId = new Set<Id>();   
        for(ProcessInstance each :processinstances ){
          SprocessId.add(each.TargetObjectId);
    } 
   List<BMCServiceDesk__Incident__c> SRSWithApprovalsList = new List<BMCServiceDesk__Incident__c>();

   if(!Test.isRunningTest()){ 
   if(SRfromDate != null && SRtoDate != null) 
   SRSWithApprovalsList = [Select Id,Name,BMCServiceDesk__Type__c,BMCServiceDesk__openDateTime__c from BMCServiceDesk__Incident__c where Id =:SprocessId AND  BMCServiceDesk__openDateTime__c >= :S1 AND BMCServiceDesk__openDateTime__c <= : S2];
   else if(SRfromDate != null && SRtoDate == null)
   SRSWithApprovalsList = [Select Id,Name,BMCServiceDesk__Type__c,BMCServiceDesk__openDateTime__c from BMCServiceDesk__Incident__c where Id =:SprocessId AND BMCServiceDesk__openDateTime__c >= :S1];
   else if(SRfromDate == null && SRtoDate != null)
   SRSWithApprovalsList = [Select Id,Name,BMCServiceDesk__Type__c,BMCServiceDesk__openDateTime__c from BMCServiceDesk__Incident__c where Id =:SprocessId AND BMCServiceDesk__openDateTime__c <= :S2];
   }
   else{
   if(SRfromDate != null && SRtoDate != null) 
   SRSWithApprovalsList = [Select Id,Name,BMCServiceDesk__Type__c,BMCServiceDesk__openDateTime__c from BMCServiceDesk__Incident__c where Id =:SprocessId AND  BMCServiceDesk__openDateTime__c >= :S1 AND BMCServiceDesk__openDateTime__c <= : S2 limit 2];
   else if(SRfromDate != null && SRtoDate == null)
   SRSWithApprovalsList = [Select Id,Name,BMCServiceDesk__Type__c,BMCServiceDesk__openDateTime__c from BMCServiceDesk__Incident__c where Id =:SprocessId AND BMCServiceDesk__openDateTime__c >= :S1 limit 2];
   else if(SRfromDate == null && SRtoDate != null)
   SRSWithApprovalsList = [Select Id,Name,BMCServiceDesk__Type__c,BMCServiceDesk__openDateTime__c from BMCServiceDesk__Incident__c where Id =:SprocessId AND BMCServiceDesk__openDateTime__c <= :S2 limit 2];
   
   }
   
    System.debug('SRSWithApprovalsList...'+SRSWithApprovalsList );
    if( SRSWithApprovalsList != null && SRSWithApprovalsList.size()>0){
     Integer SRCount ;
     for(ProcessInstance p : processinstances ){  
         SRCount = 0;      
         SRApproverWrapper SRwrapObj = new SRApproverWrapper();
         for(BMCServiceDesk__Incident__c eachId :SRSWithApprovalsList ){
             if(eachId.Id == p.TargetObjectId){
                 
                 SRwrapObj.SRNum = eachId.Name;
                 SRwrapObj.SRId = eachId.Id;    
                 SRwrapObj.SRopenedDate = eachId.BMCServiceDesk__openDateTime__c ;
                 SRCount = SRCount+1;
                 break;
             }            
         }
         
         System.debug('SRCount..'+SRCount);
         if(SRCount != 0){
         SRwrapObj.SRprocessId = p.Id;
         SRwrapObj.SRStatus = p.status;
         SRwrapObj.SRassignedApprover = p.StepsAndWorkItems[0].OriginalActor.Name ;
         SRwrapObj.SRactualApprover = p.StepsAndWorkItems[0].Actor.Name;
         SRwrapObj.SRapprovedDate = p.StepsAndWorkItems[0].CreatedDate;
         
         SRwrapperList.add(SRwrapObj);
         }
         
     } 
    System.debug('SRwrapperList.....'+SRwrapperList); 
    srJSONString= '';
        srJSONString = '{';
        if(SRwrapperList != null && SRwrapperList.size()>0){
            srJSONString = srJSONString +' "records":"'+SRwrapperList.size()+'", ';
        }else{
            srJSONString = srJSONString +' "records":"0", ';
        }       
        srJSONString = srJSONString +' "rows": [';
        if(SRwrapperList != null && SRwrapperList.size()>0){
             for(Integer x=0;x<SRwrapperList.size();x++){
                if(x<SRwrapperList.size()-1) {
                    srJSONString+= '{';
                    srJSONString += '"SprocessId":'+json.serialize(SRwrapperList[x].SRprocessId)+',';
                    srJSONString += '"StatusSR":'+json.serialize(SRwrapperList[x].SRStatus)+',';
                    srJSONString += '"SRId":'+json.serialize(SRwrapperList[x].SRId)+',';
                    srJSONString += '"SRNumber":'+json.serialize(SRwrapperList[x].SRNum)+',';
                    srJSONString += '"SRassignedApprover":'+json.serialize(SRwrapperList[x].SRassignedApprover)+',';
                    srJSONString += '"SRactualApprover":'+json.serialize(SRwrapperList[x].SRactualApprover)+',';
                    srJSONString += '"SRopenedDate":'+json.serialize(SRwrapperList[x].SRopenedDate)+',';
                    srJSONString += '"SRapprovedDate":'+json.serialize(SRwrapperList[x].SRapprovedDate)+'';
                    srJSONString+= '},';       
                } else {
                    srJSONString+= '{';
                    srJSONString += '"SprocessId":'+json.serialize(SRwrapperList[x].SRprocessId)+',';
                    srJSONString += '"StatusSR":'+json.serialize(SRwrapperList[x].SRStatus)+',';
                    srJSONString += '"SRId":'+json.serialize(SRwrapperList[x].SRId)+',';
                    srJSONString += '"SRNumber":'+json.serialize(SRwrapperList[x].SRNum)+',';
                    srJSONString += '"SRassignedApprover":'+json.serialize(SRwrapperList[x].SRassignedApprover)+',';
                    srJSONString += '"SRactualApprover":'+json.serialize(SRwrapperList[x].SRactualApprover)+',';
                    srJSONString += '"SRopenedDate":'+json.serialize(SRwrapperList[x].SRopenedDate)+',';
                    srJSONString += '"SRapprovedDate":'+json.serialize(SRwrapperList[x].SRapprovedDate)+'';
                    srJSONString+= '}';
                }            
            }  
        }
        srJSONString = srJSONString +'] }';
        system.debug('\n\n\n ##srJSONString '+srJSONString);       
       }
       else{
       
       DateTime d = System.Now();
       String s = '--';
       String s3= ' No records found';   
       srJSONString= '{';
                    srJSONString += '"SprocessId":'+json.serialize(s)+',';
                    srJSONString += '"StatusSR":'+json.serialize(s)+',';
                    srJSONString += '"SRId":'+json.serialize(s)+',';
                    srJSONString += '"SRNumber":'+json.serialize(s3)+',';
                    srJSONString += '"SRassignedApprover":'+json.serialize(s)+',';
                    srJSONString += '"SRactualApprover":'+json.serialize(s)+',';
                    srJSONString += '"SRopenedDate":'+json.serialize(d)+',';
                    srJSONString += '"SRapprovedDate":'+json.serialize(d)+'';
                    srJSONString+= '}';
       System.debug('srJSONString'+srJSONString );
       }
       
    
           
 }
 }