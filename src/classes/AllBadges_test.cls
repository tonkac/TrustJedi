/*
	*	This class will test the VF Page that displays all Trust Badges in the Salesforce1 environment. 
	*		@dev: creinke
	*/
@isTest
public with sharing class AllBadges_test {
	public static List<ID> chatterIDs = createChatterGroups();
	public AllBadges_test () { }

	/*
	*	Test the controller when called from a VF Page
	*/
	public static testMethod void testWithVFPage () {
		Trust_Badge__c testBadge = new Trust_Badge__c();
		PageReference pageRef = Page.AllBadges;
		Test.setCurrentPage(pageRef);
		ApexPages.StandardController stdCntr = new ApexPages.StandardController(testBadge);
		AllBadges_controller controller = new AllBadges_controller(stdCntr);
	}

	/*AllBadges_cont
	*	Create the user without having a jedi level or a jedi user
	*/
	public static testMethod void testWithoutData () {
		//	Create the test badges and levels to be used in this process
		createBadges();
		createJediLevels();

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

		//	Utilize the start and stop test to allow the future code to process the creation of the
		//		jedi user when saving a user.
		Test.startTest();
			String testEmail = String.valueOf(Math.round(Math.random() * 1000000000)) + '@salesforce.com';
			User testUser = new User(  Username = testEmail,
				IsActive = true,
				Email = testEmail,
				LastName = 'lName',
				FirstName = 'fName',
				Alias = 'alias',
				TimeZoneSidKey = 'America/Los_Angeles',
				LocaleSidKey = 'en_US',
				EmailEncodingKey = 'ISO-8859-1',
				ProfileId = UserInfo.getProfileId(),
				LanguageLocaleKey = 'en_US'
			);
			insert testUser;
			System.assertNotEquals(null, testUser.Id);
		Test.stopTest();

		//	With a Jedi Level the Jedi User should be created
		try {
			List<TrustJediMobile__Jedi_User__c> jediUsers = [SELECT Id,
																	TrustJediMobile__User__c,
																	TrustJediMobile__User_Type__c,
																	TrustJediMobile__Jedi_Level__c,
																	TrustJediMobile__Jedi_Level__r.Id
																FROM TrustJediMobile__Jedi_User__c];
			System.assertEquals(1, jediUsers.size());
			System.assertNotEquals(null, jediUsers[0].TrustJediMobile__Jedi_Level__c);
		} catch (Exception ex) {
			System.debug('Error: ' + ex.getMessage());
			System.assert(false);
		}

		//	Verify that the jedi user and jedi level are populated in the badge controller.
		System.runAs(testUser) {
			AllBadges_controller abc = new AllBadges_controller();
			abc.getCurrentUser();
			System.assertNotEquals(null, abc.thisJediUser.Id);
			System.assertNotEquals(null, abc.myJediLevel.Id);
		}
	}

	/*
	*	Verify that the error is generated if there isn't a jedi level in the system.
	*/
	public static testMethod void testWithoutLevels () {
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
		AllBadges_controller controller = new AllBadges_controller();
		System.assertEquals(Label.TrustJediMobile_errorPrefix + 'List has no rows for assignment to SObject', controller.errorMessage);

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

		System.runAs(testUser) {
			controller = new AllBadges_controller();
			System.assertEquals(Label.TrustJediMobile_errorPrefix + 'List has no rows for assignment to SObject', controller.errorMessage);
		}
	}

	/*
	*	Query the badges wrapper is populated with the correct information no matter if they system
	*		has an error or all data is correct
	*/
	public static testMethod void testBadgeResults () {
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
		AllBadges_controller controller = new AllBadges_controller();
		System.assertEquals(Label.TrustJediMobile_errorPrefix + 'List has no rows for assignment to SObject', controller.errorMessage);

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

		TrustJediMobile__Jedi_User__c ju = [SELECT Id, TrustJediMobile__User_Type__c FROM TrustJediMobile__Jedi_User__c WHERE TrustJediMobile__User__c = :testUser.Id];
		System.assertEquals('User', ju.TrustJediMobile__User_Type__c);

		//	Verify that the badge controller is showing the error because it didn't find any badges
		controller = new AllBadges_controller();
		System.assertEquals(Label.TrustJediMobile_errorPrefix + 'List has no rows for assignment to SObject', controller.errorMessage);

		//	Test the user to make sure info is displayed correctly
		System.runAs(testUser) {
			AllBadges_controller.badgeWrapper bw = AllBadges_controller.getAllBadges(true);
			System.assertEquals(0, bw.numBadges);
			System.assertEquals(Label.No_Badges_Found, bw.errMsg);
		}

		//	Create four badges in the system to make sure they are displayed during hte loading of page
		List<TrustJediMobile__Trust_Badge__c> newBadges = new List<TrustJediMobile__Trust_Badge__c>();
		for (Integer i=0;i<4;i++) {
			newBadges.add(
				new TrustJediMobile__Trust_Badge__c(
					Name = 'badge number: ' + i,
					TrustJediMobile__Auto_Approve_Allowed__c = false,
					TrustJediMobile__Trust_Points__c = 100,
					TrustJediMobile__Badge_Description_Example__c = 'You can do this',
					TrustJediMobile__Trust_Use_Only__c = false
				)
			);
		}
		insert newBadges;

		//	Test to make sure badges are created and their is no errors
		System.runAs(testUser) {
			AllBadges_controller.badgeWrapper bw = AllBadges_controller.getAllBadges(false);
			System.assertEquals(4, bw.numBadges);
			System.assertEquals('', bw.errMsg);
		}

		//	Update a badge to be set to true and verify that the user only sees the three.
		newBadges[0].TrustJediMobile__Trust_Use_Only__c = true;
		update newBadges;
		
		System.runAs(testUser) {
			AllBadges_controller.badgeWrapper bw = AllBadges_controller.getAllBadges(false);
			System.assertEquals(3, bw.numBadges);
			System.assertEquals('', bw.errMsg);
		}

		System.runAs(testUser) {
			AllBadges_controller.badgeWrapper bw = AllBadges_controller.getAllBadges(true);
			System.assertEquals(4, bw.numBadges);
			System.assertEquals('', bw.errMsg);
		}
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
		AllBadges_controller controller = new AllBadges_controller();
		System.assertEquals(Label.TrustJediMobile_errorPrefix + 'List has no rows for assignment to SObject', controller.errorMessage);

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

		System.runAs(testUser) {
			AllBadges_controller.initialDataWrapper idw = AllBadges_controller.getInitialData();
			System.assertNotEquals('', idw.jediUserString);
			System.assertNotEquals('', idw.myProfileString);
			System.assertNotEquals('', idw.jediLevelString);
			System.assertEquals(null, idw.errMsg);
		}
	}

	/*
	*	Test the system to make sure that the initial data wrapper will be populated with the
	*		correct information.
	*/
	public static testMethod void testInitialDataWithoutJediUser () {
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

		//	Utilize the start and stop test to allow the future code to process the creation of the
		//		jedi user when saving a user.
		String testEmail = String.valueOf(Math.round(Math.random() * 1000000000)) + '@salesforce.com';
		Test.startTest();
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
			System.runAs(testUser) {
				AllBadges_controller.initialDataWrapper idw = AllBadges_controller.getInitialData();
				System.assert(idw.errMsg.contains(Label.TrustJediMobile_errorPrefix + Label.Jedi_Level));
			}
		Test.stopTest();

		System.runAs(testUser) {
			AllBadges_controller.initialDataWrapper idw = AllBadges_controller.getInitialData();
			System.assert(idw.errMsg.contains(Label.TrustJediMobile_errorPrefix + Label.Jedi_Level));
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
		insert jl;

		jl = new TrustJediMobile__Jedi_Level__c(
			Name = 'level 1',
			TrustJediMobile__Max_Points_Given_Limit__c = 0,
			TrustJediMobile__Points_Required__c = 100,
			TrustJediMobile__WhatYouCanDo__c = 'do this'
		);
		insert jl;

		jl = new TrustJediMobile__Jedi_Level__c(
			Name = 'level 1',
			TrustJediMobile__Max_Points_Given_Limit__c = 0,
			TrustJediMobile__Points_Required__c = 200,
			TrustJediMobile__WhatYouCanDo__c = 'do this'
		);
		insert jl;
	}

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
		insert tb;

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
		insert tb;
	}
}