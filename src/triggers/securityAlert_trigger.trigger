/*
	*	This trigger will manage the security alert object. This will make sure fields are populated correctly
	*		and any relationships are correct.
	*		@dev: creinke
	*/
trigger securityAlert_trigger on Security_Alert__c (before insert, before update) {
	Utility tjuc = new Utility();
	if(trigger.isBefore) {
		if(trigger.isInsert) {
			tjuc.processSecurityAlerts_insert(trigger.new);
		}
		if(trigger.isUpdate) {
			tjuc.processSecurityAlerts_update(trigger.oldMap, trigger.newMap);
		}
	}
}