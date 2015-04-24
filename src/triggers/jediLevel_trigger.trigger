/*
	*	This trigger will manage the values on the Jedi Levels.  
	*		@dev: creinke
	*/
trigger jediLevel_trigger on TrustJediMobile__Jedi_Level__c (before insert, before update) {
	Utility tju = new Utility();
	if (trigger.isBefore) {
		if (trigger.isInsert) {
			tju.processJediLevel_insert(trigger.new);
		}
		if (trigger.isUpdate) {
			tju.processJediLevel_update(trigger.oldMap, trigger.newMap);
		}
	}
}