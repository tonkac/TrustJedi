/*
	*	This trigger will manage the trust issue object. This will make sure fields are populated correctly
	*		and any relationships are correct.
	*		@dev: creinke
	*/
trigger trustIssue_trigger on Trust_Issue__c (before insert, before update) {
	Utility tjuc = new Utility();

	if(trigger.isBefore) {
		if(trigger.isInsert) {
			tjuc.updateTrustIssue_insert(trigger.new);
		}
		if(trigger.isUpdate) {
			tjuc.updateTrustIssue_ti_update(trigger.oldMap, trigger.newMap);
		}
	}
}