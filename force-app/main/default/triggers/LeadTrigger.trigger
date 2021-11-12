/* Class:       LeadTrigger
** Created by:  OpFocus (Jason Curry) on 2021-06-21
** Description: Trigger for Leads
*/

trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    new LeadTriggerHandler().run();
}