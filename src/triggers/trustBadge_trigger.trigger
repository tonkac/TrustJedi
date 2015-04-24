/*
	*	This trigger will manage the trust badge object. This will make sure fields are populated correctly
	*		and any relationships are correct.
	*		@dev: creinke
	*/
trigger trustBadge_trigger on TrustJediMobile__Trust_Badge__c (before insert, before update) {
	Utility tju = new Utility();
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			tju.processTrustBadge_insert(trigger.new);
		}
		if (trigger.isUpdate) {
			tju.processTrustBadge_update(trigger.oldMap, trigger.newMap);
		}
	}
}