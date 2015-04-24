/*
	*	This class will display each of the Jedi Levels to the user. 
	*		@dev: creinke
	*/
@isTest
public with sharing class ChatterPosting_testing {
	public ChatterPosting_testing() { }
	//	Create the chatter IDs that are used when the system posts a chatter feed item when approved.
	public static List<ID> chatterIDs = createChatterGroups();

	public static testMethod void test_addChatterPost () {
		//	Create the custom settings required in the testing as they are not visible in tests without
		//		view all.
		List<TrustJedi_settings__c> settings = new List<TrustJedi_settings__c>();
		Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
		if(!existingSettings.containsKey('defaultUserType')) settings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
		if(!existingSettings.containsKey('featureEnabled')) settings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
		if(!existingSettings.containsKey('MaxAlertOnHomePage')) settings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
		if(!existingSettings.containsKey('MaxBadgesOnHomePage')) settings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
		if(!existingSettings.containsKey('postChatterIDs')) settings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
		if(!existingSettings.containsKey('postToChatterEnabled')) settings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
		if(!existingSettings.containsKey('postToTrustChatterGroup')) settings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
		if(!existingSettings.containsKey('UserTypes')) settings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
		if(settings.size() > 0) upsert settings;

		AllLevels_controller alc = new AllLevels_controller();
		AllLevels_controller.jediLevelWrapper jlw = AllLevels_controller.getAllJediLevels();
		System.assertEquals(-1, jlw.numJediLevels);
		System.assertEquals(Label.TrustJediMobile_errorPrefix + ' ' + Label.TrustJediMobile_noRecordsFound, jlw.errMsg);

		Map<String, String> postMapping = new Map<String, String>();
		postMapping.put('recipient', UserInfo.getUserId());
		postMapping.put('requestor', UserInfo.getUserId());

		String postString = 'Congratulations <.recipient>, you have been given Trust Points! \n' +
							'Recipient: <.recipient> \n' +
							'Requestor: <.requestor>';
		ChatterPosting cp = new ChatterPosting();
		ConnectApi.FeedItemInput fi = cp.createPost(postString, UserInfo.getUserId(), postMapping, chatterIDs);
	}

	public static testMethod void test_noChatterGroups () {
		AllLevels_controller alc = new AllLevels_controller();
		AllLevels_controller.jediLevelWrapper jlw = AllLevels_controller.getAllJediLevels();
		System.assertEquals(-1, jlw.numJediLevels);
		System.assertEquals(Label.TrustJediMobile_errorPrefix + ' ' + Label.TrustJediMobile_noRecordsFound, jlw.errMsg);
	}

/* ----------------------------------------- Non-Test Methods ----------------------------------------- */
	/*
	*	Create a new chatter group that will have the awards displayed so company can see when users get
	*		a new badge approved.
	*/
	public static List<ID> createChatterGroups () {

		List<CollaborationGroup> groups = new List<CollaborationGroup>();
		CollaborationGroup g = new CollaborationGroup (
			Name = 'group1',
			CollaborationType = 'public',
			OwnerId = UserInfo.getUserId()
		);

		groups.add(g);

		g = new CollaborationGroup (
			Name = 'group2',
			CollaborationType = 'public',
			OwnerId = UserInfo.getUserId()
		);

		groups.add(g);

		List<ID> localChatterIDs = new List<ID>();
		insert groups;
		localChatterIDs.add(groups.get(0).Id);
		localChatterIDs.add(groups.get(1).Id);
		return localChatterIDs;
	}
}