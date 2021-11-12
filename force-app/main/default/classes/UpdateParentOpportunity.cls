public class UpdateParentOpportunity {

public static void updateFromAttachment(Attachment[] att) {
Opportunity opp = new Opportunity(Id = att[0].ParentId, Attachment_Last_Update__c=Date.TODAY());
update(opp);
}

public static void updateFromEvent(Event[] evt) {
Opportunity opp = new Opportunity(Id = evt[0].WhatId, Activity_Last_Update__c=Date.TODAY());
update(opp);
}

public static void updateFromNote(Note[] nt) {
Opportunity opp = new Opportunity(Id = nt[0].ParentId, Note_Last_Update__c=Date.TODAY());
update(opp);
}

public static void updateFromTask(Task[] ts) {
Opportunity opp = new Opportunity(Id = ts[0].WhatId, Activity_Last_Update__c=Date.TODAY());
update(opp);
}
}