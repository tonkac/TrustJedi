/*
	*	This trigger will jedi users.  It will verify that the records are associated with a user and that
	*		the level is set correctly based on the points earned.
	*		@dev: creinke
	*/
trigger jediUser_trigger on TrustJediMobile__Jedi_User__c (before insert, before update, after insert, after update) {
	Utility tju = new Utility();
	if(trigger.isBefore) {
		if(trigger.isInsert) {
			//	This will populate the Jedi Level on new Trust Users.
			tju.processJediUser_insert(trigger.new);
		}

		if(trigger.isUpdate) {
			//	This will go through each of the modified trust users and set the correct jedi level for each.
			tju.processJediUser_update(trigger.new);
		}
	}
}