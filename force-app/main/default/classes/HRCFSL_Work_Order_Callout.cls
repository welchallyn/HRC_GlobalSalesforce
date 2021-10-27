/***********************************************************************************************
 * Name                             : HRCFSL_Work_Order_Callout
 * Author                           : Capgemini
 * Date                             : Aug/21/2019
 * Requirement/Project Name         : Hill-Rom
 * Requirement/Project Description  :  Webservice class to
 *                                   1. sync Work order along with its related child 
 *                                   record  with  JDE server using platform event
 *                                   2. Related to #HF-67 , #HF-266
 * Revison                          : As per SE - 1956 19-04-2021, including the build logic inside async logic in order to avoid bulk issues and governor limit errors
 ***********************************************************************************************/


//The code prior to the revisions made as per 1956(on 19-04-2021) is commented and can be found after the acual class ends
//code added on 19-04-2021
public class HRCFSL_Work_Order_Callout implements Queueable, Database.AllowsCallouts {
    public List<HRCFSL_Outbound_JDE_Work_Order__e> publishEvents;
    public HRCFSL_Work_Order_Callout (List<HRCFSL_Outbound_JDE_Work_Order__e> publishEvents)
    {
        system.debug('HRCFSL_Work_Order_Callout - constructor');
        this.publishEvents = publishEvents;
    }
    public void execute (QueueableContext context)
    {
        system.debug('HRCFSL_Work_Order_Callout - execute');        
        doCallout(this.publishEvents);
    }
    
    private static void doCallout(List<HRCFSL_Outbound_JDE_Work_Order__e> publishEvents)
    {
        system.debug('HRCFSL_Work_Order_Callout - doCallout');   
        
        list<HRCFSL_Organization_Settings__mdt> urlLst= [select developername, HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt
                                                             where DeveloperName in ('JDE_External_Url')];
        string mainUrl=urlLst.isempty() ? 'https://use4-cai.dm-us.informaticacloud.com/active-bpel/public/rt/4gemf4dyWD9ieqj9lKPdi4/Process_Workorder_FSL_to_JDE_-_Copy?swagger'
                : urlLst[0].HRCFSL_Component_Detail__c;

        for (HRCFSL_Outbound_JDE_Work_Order__e woh: publishEvents){
            HRCFSL_Build_Integration_Message bim = new HRCFSL_Build_Integration_Message(new List<Id>{woh.HRCFSL_Work_Order__c});
            List<String> messagesToSend;
            if(woh.HRCFSL_IsEventForChildWO__c)
            	messagesToSend = bim.getChildMessages();
            else 
            	messagesToSend = bim.getMessages();
            
            Http h = new Http();
            //string testbody='<root> <!--Optional:--> <ActionCode>A</ActionCode> <!--Optional:--> <CallID>3656802170921124656</CallID> <!--Optional:--> <TaskType>Y</TaskType> <!--Optional:--> <HrRequiredSkill>SE</HrRequiredSkill> <!--Optional:--> <HrStatus>SC</HrStatus> <!--Optional:--> <District>90219</District> <!--Optional:--> <HrCostCenter>99707</HrCostCenter> <!--Optional:--> <StartDate>2017-09-21</StartDate> <!--Optional:--> <StartTime>125400</StartTime> <!--Optional:--> <FinishDate>2017-09-21</FinishDate> <!--Optional:--> <FinishTime>131100</FinishTime> <!--Optional:--> <AssignedEngineers>3656802</AssignedEngineers> <!--Optional:--> <EngineerNetworkID>THOMPSD</EngineerNetworkID> <!--Optional:--> <CurrantEngineerNetworkID>THOMPSD</CurrantEngineerNetworkID> <!--Optional:--> <HrPO>328511</HrPO> <!--Optional:--> <UnitsTransactionQty>10</UnitsTransactionQty> <!--Optional:--> <ModelDescription>VERSACARE BED</ModelDescription> <!--Optional:--> <HrCustomer>607230</HrCustomer> <!--Optional:--> <HrContactFirstName>DONALD R</HrContactFirstName> <!--Optional:--> <HrContactLastName>THOMPSON II</HrContactLastName> <!--Optional:--> <ContactPhoneNumber>9518921894</ContactPhoneNumber> <!--Optional:--> <AssetID>4184921</AssetID> <!--Optional:--> <HrSerialNumber>J114AD5544</HrSerialNumber> <!--Optional:--> <HrAssetTypes>086</HrAssetTypes> <!--Optional:--> <HrItemNumber>1231476</HrItemNumber> <!--Optional:--> <HrItemNumberLong>P3200G000035</HrItemNumberLong> <!--Optional:--> <PatientTitle></PatientTitle> <!--Optional:--> <PatientFirstName></PatientFirstName> <!--Optional:--> <PatientLastName></PatientLastName> <!--Optional:--> <WardFloor></WardFloor> <!--Optional:--> <PatientRoomNo></PatientRoomNo>       <!--Optional:--> <HrSalesOrderNumber>0</HrSalesOrderNumber> <!--Optional:--> <HrSOLineNumber>0</HrSOLineNumber> <!--Optional:--> <Tech>3656802</Tech> <!--Optional:--> <LaborType>SVUS040</LaborType> <!--Optional:--> <LaborHours>0.5</LaborHours> <!--Optional:--> <Sequence>400</Sequence> <!--Optional:--> <TypeRouting>REP</TypeRouting> <!--Optional:--> <LaborDescription>Value Added Activity</LaborDescription> <!--Optional:--> <ShortItem>95246</ShortItem> <!--Optional:--> <LaborDate>2017-09-21</LaborDate> <!--Optional:--> <PartType>1168799</PartType> <!--Optional:--> <QuantityUsed>1</QuantityUsed> <!--Optional:--> <DispositionCode>RPL</DispositionCode> <!--Optional:--> <ItemDescription>FOAM, COMFORT FILLER ASSY</ItemDescription> <!--Optional:--> <TypeBill></TypeBill> <!--Optional:--> <Comment></Comment> <!--Optional:--> <FoundPMBPIYN>Yes</FoundPMBPIYN> <!--Optional:--> <MalfEvent>Foam comfort filler is damaged</MalfEvent> <!--Optional:--> <TestPerfFunct>1</TestPerfFunct> <!--Optional:--> <TestPerfVisual>1</TestPerfVisual> <!--Optional:--> <TestPerfAudible>0</TestPerfAudible> <!--Optional:--> <PartSerialNumRev></PartSerialNumRev> <!--Optional:--> <OccurLocation></OccurLocation> <!--Optional:--> <InjuryDeathYN></InjuryDeathYN> <!--Optional:--> <Country></Country> <!--Optional:--> <SecondDeviceYN></SecondDeviceYN> <!--Optional:--> <SecondDeviceDetails></SecondDeviceDetails> <!--Optional:--> <PrevMaintStickerYN></PrevMaintStickerYN> <!--Optional:--> <PrevMaintStickerDate></PrevMaintStickerDate> <!--Optional:--> <ImpactedName></ImpactedName> <!--Optional:--> <ImpactedAge></ImpactedAge> <!--Optional:--> <ImpactedHeight></ImpactedHeight> <!--Optional:--> <ImpactedWeight></ImpactedWeight> <!--Optional:--> <ImpactedGender></ImpactedGender> <!--Optional:--> <MedicalInterventionYN></MedicalInterventionYN> <!--Optional:--> <InterventionDes></InterventionDes> <!--Optional:--> <PreExisting></PreExisting> <!--Optional:--> <PreExistingDesc></PreExistingDesc> <!--Optional:--> <Outcome></Outcome> <!--Optional:--> <DeviceCaused></DeviceCaused> <!--Optional:--> <DeviceCausedDesc></DeviceCausedDesc> <!--Optional:--> <FollowUpName></FollowUpName> <!--Optional:--> <FollowUpTitle></FollowUpTitle> <!--Optional:--> <FollowUpPhone></FollowUpPhone> <!--Optional:--> <DocRMA></DocRMA> <!--Optional:--> <CompleteDAS>No</CompleteDAS> <!--Optional:--> <DocNum></DocNum> <!--Optional:--> <RevNum></RevNum> <!--Optional:--> <GroundResist></GroundResist> <!--Optional:--> <LeakCurrent></LeakCurrent> <!--Optional:--> <Other1></Other1> <!--Optional:--> <Other2></Other2> <!--Optional:--> <Other3></Other3> <!--Optional:--> <Other4></Other4> <!--Optional:--> <Other5></Other5> <!--Optional:--> <MalfFound></MalfFound> <!--Optional:--> <MalfDescription></MalfDescription> <!--Optional:--> <MalfunctionYN></MalfunctionYN> <!--Optional:--> <CompainionSerialNo></CompainionSerialNo> <!--Optional:--> <S120reptMalfYN>No</S120reptMalfYN> <!--Optional:--> <S120descrMalf></S120descrMalf> <!--Optional:--> <S120injDeathYN>No</S120injDeathYN> <!--Optional:--> <S120partDamageYN>No</S120partDamageYN> <!--Optional:--> <S120missingDescr></S120missingDescr> <!--Optional:--> <CancReason></CancReason> <!--Optional:--> <CancAuthorized></CancAuthorized> <!--Optional:--> <CancReasonDescription></CancReasonDescription> <!--Optional:--> <HrMegaTaskYN></HrMegaTaskYN> <!--Optional:--> <HrContactTitle>Tech</HrContactTitle> <!--Optional:--> <HrSigneeEmail></HrSigneeEmail> <!--Optional:--> <TroubCauseResol>nspected bed, found mattress foam comfort filler is damaged and need to be replaced, replaced mattress comfort filler</TroubCauseResol> <!--Optional:--> <FunctionAsDesignedYN>Yes</FunctionAsDesignedYN> <!--Optional:--> <HrSigneeName>Donald Thompson</HrSigneeName> <!--Optional:--> <HrSigneeTitle>Fsr</HrSigneeTitle> <!--Optional:--> <HrSubstitutionCode></HrSubstitutionCode> <!--Optional:--> <MalfExplain></MalfExplain> </root>';
            for (string messageToSend: messagesToSend)
            {
                HttpRequest req = new HttpRequest();
        		system.debug('HRCFSL_Work_Order_Callout - post - '+woh.HRCFSL_Work_Order__c);                  
                //req.setEndpoint(mainUrl);
                req.setEndpoint('callout:HRCFSL_JDE_Server');
                req.setMethod('POST');
                req.setheader('Content-Type','application/xml;charset=UTF-8');
                
                req.setBody(messageToSend);
                HttpResponse res;
                if(!test.isRunningTest()){
                    res = h.send(req);
                }
                string response=test.isRunningTest() ? 'test class response' : res.getBody();
               // system.debug('response status is '+res.getStatusCode() + ' - ' + res.getStatus());
                system.debug('the response is'+response);
            }
        }  
    }
}

//This was the original class which was commented on 19-04-2021. 
/*public class HRCFSL_Work_Order_Callout implements Queueable, Database.AllowsCallouts
{   
    public List<string> messages;
    public HRCFSL_Work_Order_Callout (List<String> messages)
    {
        this.messages = messages;
    }
    public void execute (QueueableContext context)
    {
        doCallout(this.messages);
    }
	
    private static void doCallout(List<String> messagesToSend)
    {
        Http h = new Http();
        //string testbody='<root> <!--Optional:--> <ActionCode>A</ActionCode> <!--Optional:--> <CallID>3656802170921124656</CallID> <!--Optional:--> <TaskType>Y</TaskType> <!--Optional:--> <HrRequiredSkill>SE</HrRequiredSkill> <!--Optional:--> <HrStatus>SC</HrStatus> <!--Optional:--> <District>90219</District> <!--Optional:--> <HrCostCenter>99707</HrCostCenter> <!--Optional:--> <StartDate>2017-09-21</StartDate> <!--Optional:--> <StartTime>125400</StartTime> <!--Optional:--> <FinishDate>2017-09-21</FinishDate> <!--Optional:--> <FinishTime>131100</FinishTime> <!--Optional:--> <AssignedEngineers>3656802</AssignedEngineers> <!--Optional:--> <EngineerNetworkID>THOMPSD</EngineerNetworkID> <!--Optional:--> <CurrantEngineerNetworkID>THOMPSD</CurrantEngineerNetworkID> <!--Optional:--> <HrPO>328511</HrPO> <!--Optional:--> <UnitsTransactionQty>10</UnitsTransactionQty> <!--Optional:--> <ModelDescription>VERSACARE BED</ModelDescription> <!--Optional:--> <HrCustomer>607230</HrCustomer> <!--Optional:--> <HrContactFirstName>DONALD R</HrContactFirstName> <!--Optional:--> <HrContactLastName>THOMPSON II</HrContactLastName> <!--Optional:--> <ContactPhoneNumber>9518921894</ContactPhoneNumber> <!--Optional:--> <AssetID>4184921</AssetID> <!--Optional:--> <HrSerialNumber>J114AD5544</HrSerialNumber> <!--Optional:--> <HrAssetTypes>086</HrAssetTypes> <!--Optional:--> <HrItemNumber>1231476</HrItemNumber> <!--Optional:--> <HrItemNumberLong>P3200G000035</HrItemNumberLong> <!--Optional:--> <PatientTitle></PatientTitle> <!--Optional:--> <PatientFirstName></PatientFirstName> <!--Optional:--> <PatientLastName></PatientLastName> <!--Optional:--> <WardFloor></WardFloor> <!--Optional:--> <PatientRoomNo></PatientRoomNo>       <!--Optional:--> <HrSalesOrderNumber>0</HrSalesOrderNumber> <!--Optional:--> <HrSOLineNumber>0</HrSOLineNumber> <!--Optional:--> <Tech>3656802</Tech> <!--Optional:--> <LaborType>SVUS040</LaborType> <!--Optional:--> <LaborHours>0.5</LaborHours> <!--Optional:--> <Sequence>400</Sequence> <!--Optional:--> <TypeRouting>REP</TypeRouting> <!--Optional:--> <LaborDescription>Value Added Activity</LaborDescription> <!--Optional:--> <ShortItem>95246</ShortItem> <!--Optional:--> <LaborDate>2017-09-21</LaborDate> <!--Optional:--> <PartType>1168799</PartType> <!--Optional:--> <QuantityUsed>1</QuantityUsed> <!--Optional:--> <DispositionCode>RPL</DispositionCode> <!--Optional:--> <ItemDescription>FOAM, COMFORT FILLER ASSY</ItemDescription> <!--Optional:--> <TypeBill></TypeBill> <!--Optional:--> <Comment></Comment> <!--Optional:--> <FoundPMBPIYN>Yes</FoundPMBPIYN> <!--Optional:--> <MalfEvent>Foam comfort filler is damaged</MalfEvent> <!--Optional:--> <TestPerfFunct>1</TestPerfFunct> <!--Optional:--> <TestPerfVisual>1</TestPerfVisual> <!--Optional:--> <TestPerfAudible>0</TestPerfAudible> <!--Optional:--> <PartSerialNumRev></PartSerialNumRev> <!--Optional:--> <OccurLocation></OccurLocation> <!--Optional:--> <InjuryDeathYN></InjuryDeathYN> <!--Optional:--> <Country></Country> <!--Optional:--> <SecondDeviceYN></SecondDeviceYN> <!--Optional:--> <SecondDeviceDetails></SecondDeviceDetails> <!--Optional:--> <PrevMaintStickerYN></PrevMaintStickerYN> <!--Optional:--> <PrevMaintStickerDate></PrevMaintStickerDate> <!--Optional:--> <ImpactedName></ImpactedName> <!--Optional:--> <ImpactedAge></ImpactedAge> <!--Optional:--> <ImpactedHeight></ImpactedHeight> <!--Optional:--> <ImpactedWeight></ImpactedWeight> <!--Optional:--> <ImpactedGender></ImpactedGender> <!--Optional:--> <MedicalInterventionYN></MedicalInterventionYN> <!--Optional:--> <InterventionDes></InterventionDes> <!--Optional:--> <PreExisting></PreExisting> <!--Optional:--> <PreExistingDesc></PreExistingDesc> <!--Optional:--> <Outcome></Outcome> <!--Optional:--> <DeviceCaused></DeviceCaused> <!--Optional:--> <DeviceCausedDesc></DeviceCausedDesc> <!--Optional:--> <FollowUpName></FollowUpName> <!--Optional:--> <FollowUpTitle></FollowUpTitle> <!--Optional:--> <FollowUpPhone></FollowUpPhone> <!--Optional:--> <DocRMA></DocRMA> <!--Optional:--> <CompleteDAS>No</CompleteDAS> <!--Optional:--> <DocNum></DocNum> <!--Optional:--> <RevNum></RevNum> <!--Optional:--> <GroundResist></GroundResist> <!--Optional:--> <LeakCurrent></LeakCurrent> <!--Optional:--> <Other1></Other1> <!--Optional:--> <Other2></Other2> <!--Optional:--> <Other3></Other3> <!--Optional:--> <Other4></Other4> <!--Optional:--> <Other5></Other5> <!--Optional:--> <MalfFound></MalfFound> <!--Optional:--> <MalfDescription></MalfDescription> <!--Optional:--> <MalfunctionYN></MalfunctionYN> <!--Optional:--> <CompainionSerialNo></CompainionSerialNo> <!--Optional:--> <S120reptMalfYN>No</S120reptMalfYN> <!--Optional:--> <S120descrMalf></S120descrMalf> <!--Optional:--> <S120injDeathYN>No</S120injDeathYN> <!--Optional:--> <S120partDamageYN>No</S120partDamageYN> <!--Optional:--> <S120missingDescr></S120missingDescr> <!--Optional:--> <CancReason></CancReason> <!--Optional:--> <CancAuthorized></CancAuthorized> <!--Optional:--> <CancReasonDescription></CancReasonDescription> <!--Optional:--> <HrMegaTaskYN></HrMegaTaskYN> <!--Optional:--> <HrContactTitle>Tech</HrContactTitle> <!--Optional:--> <HrSigneeEmail></HrSigneeEmail> <!--Optional:--> <TroubCauseResol>nspected bed, found mattress foam comfort filler is damaged and need to be replaced, replaced mattress comfort filler</TroubCauseResol> <!--Optional:--> <FunctionAsDesignedYN>Yes</FunctionAsDesignedYN> <!--Optional:--> <HrSigneeName>Donald Thompson</HrSigneeName> <!--Optional:--> <HrSigneeTitle>Fsr</HrSigneeTitle> <!--Optional:--> <HrSubstitutionCode></HrSubstitutionCode> <!--Optional:--> <MalfExplain></MalfExplain> </root>';
        list<HRCFSL_Organization_Settings__mdt> urlLst= [select developername, HRCFSL_Component_Detail__c from HRCFSL_Organization_Settings__mdt
                                                         where DeveloperName in ('JDE_External_Url')];
        string mainUrl=urlLst.isempty() ? 'https://use4-cai.dm-us.informaticacloud.com/active-bpel/public/rt/4gemf4dyWD9ieqj9lKPdi4/Process_Workorder_FSL_to_JDE_-_Copy?swagger'
            : urlLst[0].HRCFSL_Component_Detail__c;
        for (string messageToSend: messagesToSend)
        {
            HttpRequest req = new HttpRequest();

            //req.setEndpoint(mainUrl);
            req.setEndpoint('callout:HRCFSL_JDE_Server');
            req.setMethod('POST');
            req.setheader('Content-Type','application/xml;charset=UTF-8');
            
            req.setBody(messageToSend);
            HttpResponse res;
            if(!test.isRunningTest()){
              res = h.send(req);
            }
            string response=test.isRunningTest() ? 'test class response' : res.getBody();
            system.debug('the response is'+response);
        }
        
        
    }
}*/