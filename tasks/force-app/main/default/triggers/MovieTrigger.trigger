trigger MovieTrigger on Movie__c (before insert, before update) {
    if (Trigger.isInsert || Trigger.isUpdate) {
        MovieTriggerHandler.handleBeforeInsertOrUpdate(Trigger.oldMap, Trigger.new);
    }
}
