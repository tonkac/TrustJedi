/*
    *   This trigger will manage the relationship between a trust badge and a jedi user. 
    *       @dev: creinke
    */
trigger badgeToUser_trigger on B2JU__c (before insert, before update, after update, after insert) {
    Utility tjuc = new Utility();

    if(trigger.isBefore) {
        if(trigger.isInsert) {
            tjuc.processBadgeToUser_insert(trigger.new);
        }
        if(trigger.isUpdate) {
            tjuc.processBadgeToUser_update(trigger.oldMap, trigger.newMap);
        }
    }

    if(trigger.isAfter) {
        if(trigger.isInsert) {
            tjuc.processBadgeToUser_after_insert(trigger.new);
        }
        if (trigger.isUpdate) {
            tjuc.chatterPost_update(trigger.oldMap, trigger.newMap);
        }
    }
}