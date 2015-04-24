/*
	*	This class will test the class that manages the level page. This will show all badges to the admins,
	*		and only the ones that are not trust use only. 
	*		@dev: creinke
	*/
@isTest
public with sharing class AllLevels_test {
	//	Constructor
	public AllLevels_test() { }

	//	Create the chatter IDs that are used when the system posts a chatter feed item when approved.
	public static List<ID> chatterIDs = createChatterGroups();

	public static testMethod void testWithoutJediLevels () {
		User testUser;
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

		//	Create the controller and verify that there is an error. Without the jedi user you will have an
		//		error without a jedi user
		AllLevels_controller controller = new AllLevels_controller();
		System.assertEquals(false, controller.isError);
		System.assertEquals('', controller.errorMessage);

		//	Without any levels the system will display an error to the user when opening this page.
		AllLevels_controller.jediLevelWrapper jlw = AllLevels_controller.getAllJediLevels();
		System.assertEquals(-1, jlw.numJediLevels);
		System.assertNotEquals('', jlw.errMsg);
	}

	/*
	*	Process the controller during the calling of a page
	*/
	public static testMethod void testWithVFPage () {
		Jedi_Level__c jl = new Jedi_Level__c();
		PageReference pageRef = Page.AllLevels;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdCntr = new ApexPages.StandardController(jl);
		AllLevels_controller controller = new AllLevels_controller(stdCntr);
	}

	/*
	*	Test that the initial data is populated with valid information and is working as expected.
	*/
	public static testMethod void testGetInitialData () {
		User testUser;
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

		//	Create the controller and verify that there is an error. Without the jedi user you will have an
		//		error without a jedi user
		AllLevels_controller controller = new AllLevels_controller();
		System.assertEquals(false, controller.isError);
		System.assertEquals('', controller.errorMessage);

		//	Test the initial data feature without a jedi user or level
		AllLevels_controller.initialDataWrapper idw = AllLevels_controller.getInitialData();
		System.assertEquals(1, [SELECT count() FROM TrustJediMobile__Jedi_User__c WHERE TrustJediMobile__User__c = :UserInfo.getUserId()]);
		idw = AllLevels_controller.getInitialData();
		System.assertNotEquals(null, idw.jediLevelString);

		//	Create the three jedi levels which should hold the user in the default record.
		createJediLevel(0);
		createJediLevel(100);
		createJediLevel(200);

		//	Utilize the start and stop test to allow the future code to process the creation of the
		//		jedi user when saving a user.
		Test.startTest();
			String testEmail = String.valueOf(Math.round(Math.random() * 1000000000)) + '@salesforce.com';
			testUser = new User(
				Username = testEmail,
				IsActive = true,
				Email = testEmail,
				LastName = 'lastName',
				FirstName = 'firstName',
				Alias = 'firstName'.left(1) + 'lastName'.left(5),
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'ISO-8859-1',
				ProfileId = UserInfo.getProfileId(),
				LanguageLocaleKey = 'en_US',
				ManagerId = UserInfo.getUserId()
			);
			insert testUser;
			System.assertNotEquals(null, testUser.Id);
		Test.stopTest();

		//	As long as there are levels the system will return strings and no error messages
		System.runAs(testUser) {
			idw = AllLevels_controller.getInitialData();
			System.assertNotEquals('', idw.jediUserString);
			System.assertNotEquals('', idw.myProfileString);
			System.assertNotEquals('', idw.jediLevelString);
			System.assertEquals(null, idw.errMsg);
		}

		//	Verify that the number of records returned is three and no error is returned.
		System.runAs(testUser) {
			AllLevels_controller.jediLevelWrapper jlw = AllLevels_controller.getAllJediLevels();
			System.assertEquals(3, jlw.numJediLevels);
			System.assert(String.isBlank(jlw.errMsg));
		}
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

	/*
	*	Create a Jedi Level for testing purposes
	*/
	public static TrustJediMobile__Jedi_Level__c createJediLevel (Integer pointsRequired) {
		TrustJediMobile__Jedi_Level__c newLevel;
		//	Create a new Jedi Level to be assigned to a new Jedi User record
		try {
			newLevel = new TrustJediMobile__Jedi_Level__c(
				Name = 'Test Jedi Level: ' + String.valueOf(pointsRequired),
				TrustJediMobile__Image_URL__c = '/img/samples/flag_green.gif',
				TrustJediMobile__Max_Points_Given_Limit__c = 0,
				TrustJediMobile__Points_Required__c = pointsRequired,
				TrustJediMobile__WhatYouCanDo__c = ''
			);
			insert newLevel;
			System.assertNotEquals(null, newLevel.Id);
		} catch (Exception ex) {
			System.debug('Error: ' + ex.getMessage());
			System.assert(false);
		}
		return newLevel;
	}

	/*
	*	Create new Jedi Levels that the user will be assigned to.
	*/
	public static void createJediLevels () {
		TrustJediMobile__Jedi_Level__c jl = new TrustJediMobile__Jedi_Level__c(
			Name = 'level 0',
			TrustJediMobile__Max_Points_Given_Limit__c = 0,
			TrustJediMobile__Points_Required__c = 0,
			TrustJediMobile__WhatYouCanDo__c = 'do this'
		);

		try {
			insert jl;
		} catch (Exception ex) {
			System.debug(System.Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
		}

		jl = new TrustJediMobile__Jedi_Level__c(
			Name = 'level 1',
			TrustJediMobile__Max_Points_Given_Limit__c = 0,
			TrustJediMobile__Points_Required__c = 100,
			TrustJediMobile__WhatYouCanDo__c = 'do this'
		);

		try {
			insert jl;
		} catch (Exception ex) {
			System.debug(System.Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
		}

		jl = new TrustJediMobile__Jedi_Level__c(
			Name = 'level 1',
			TrustJediMobile__Max_Points_Given_Limit__c = 0,
			TrustJediMobile__Points_Required__c = 200,
			TrustJediMobile__WhatYouCanDo__c = 'do this'
		);

		try {
			insert jl;
		} catch (Exception ex) {
			System.debug(System.Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
		}
	}

	/*
	*	Create badges for the testing process
	*/
	public static void createBadges () {
		TrustJediMobile__Trust_Badge__c tb = new TrustJediMobile__Trust_Badge__c(
			Name = 'TestBadge01',
			TrustJediMobile__Active__c = true,
			TrustJediMobile__Auto_Approve_Allowed__c = true,
			TrustJediMobile__Badge_Description_Example__c = 'description here',
			TrustJediMobile__Max_Points__c = 100,
			TrustJediMobile__Min_Points__c = 100,
			TrustJediMobile__Trust_Points__c = 100,
			TrustJediMobile__Trust_Use_Only__c = false
		);

		try {
			insert tb;
		} catch (Exception ex) {
			System.debug(System.Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
		}

		tb = new TrustJediMobile__Trust_Badge__c(
			Name = 'TestBadge02',
			TrustJediMobile__Active__c = true,
			TrustJediMobile__Auto_Approve_Allowed__c = true,
			TrustJediMobile__Badge_Description_Example__c = 'description here',
			TrustJediMobile__Max_Points__c = 100,
			TrustJediMobile__Min_Points__c = 100,
			TrustJediMobile__Trust_Points__c = 100,
			TrustJediMobile__Trust_Use_Only__c = false
		);

		try {
			insert tb;
		} catch (Exception ex) {
			System.debug(System.Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
		}
	}
}