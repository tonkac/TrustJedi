/*
	*	This trigger will manage the attachments object. This will make sure fields on the physical
	*		rewards or security alerts records have the correct URLs for thier attached images.
	*		@dev: creinke
	*/
trigger attachment_trigger on Attachment (after insert, after delete, before delete) {
	Utility tjmu = new Utility();
	if (trigger.isAfter) {
		if (trigger.isInsert) {
			tjmu.processAttachment_insert(trigger.new);
		}
		if (trigger.isDelete) {
			tjmu.processAttachment_delete_after(trigger.old);
		}
	}
	if (trigger.isBefore) {
		if (trigger.isDelete) {
			tjmu.processAttachment_delete_before(trigger.old);
		}
	}

}