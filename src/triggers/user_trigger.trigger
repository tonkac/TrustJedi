/*
    *   This trigger will manage the user object. This will make review the Jedi User and
    *       make sure that there is one, and only one, Jedi User record.
    *       @dev: creinke
    */
trigger user_trigger on User (after insert, after update) {
    if(trigger.isAfter) {
    	new ProcessUserRecords(trigger.newMap.keySet());
    }
}