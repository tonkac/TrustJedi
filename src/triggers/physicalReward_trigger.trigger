/*
	*	This trigger will manage the physical reward object. This will make sure fields are populated correctly
	*		and any relationships are correct.
	*		@dev: creinke
	*/
trigger physicalReward_trigger on TrustJediMobile__Physical_Reward__c (before insert, before update) {
	Utility tjmu = new Utility();
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			tjmu.processPhysicalRewards_insert(trigger.new);
		}

		if (trigger.isUpdate) {
			tjmu.processPhysicalRewards_update(trigger.oldMap, trigger.newMap);
		}
	}
}