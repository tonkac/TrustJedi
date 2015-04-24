/*
	*	This class will pass all of the needed data to the user to display all of the rewards
	*		that could be given to users when they make a specific level.
	*		@dev: creinke
	*/
@isTest
public with sharing class AllRewards_testing {
	public static List<ID> chatterIDs = createChatterGroups();
	public AllRewards_testing() { }

	public static testMethod void testViewAllRewards () {
		//	Create the test badges and levels to be used in this process
		createBadges();
		createJediLevels();

		AllRewards_controller arc = new AllRewards_controller();
		System.assertEquals(true, arc.isError);
		System.assertNotEquals('', arc.errMsg);

		//	Create the custom settings that are used in the process
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

		//	Once the settings are created then get the clean list of them.
		existingSettings = TrustJedi_settings__c.getAll();

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
			System.assertEquals(existingSettings.get('defaultUserType').Value__c, jediUsers[0].TrustJediMobile__User_Type__c);
		} catch (Exception ex) {
			System.debug('Error: ' + ex.getMessage());
			System.assert(false);
		}

		System.runAs(testUser) {
			arc = new AllRewards_controller();
			System.assertEquals(false, arc.isError);
			System.assertEquals('', arc.errMsg);
		}

		List<TrustJediMobile__Physical_Reward__c> prl = new List<TrustJediMobile__Physical_Reward__c>();
		for (Integer i=0;i<4;i++) {
			prl.add(
				new TrustJediMobile__Physical_Reward__c(
					Name = 'physicalReward: ' + i,
					TrustJediMobile__Type__c = 'type: ' + i,
					TrustJediMobile__Visible_to_Non_Trust__c = false,
					TrustJediMobile__Short_Description__c = 'Short Description'
				)
			);
		}
		insert prl;
		for (TrustJediMobile__Physical_Reward__c pr: prl) System.assertNotEquals(null, pr.Id);

		AllRewards_controller.physicalRewardWrapper prw = AllRewards_controller.getAllRewards(true);
		System.assertEquals(4, prw.numPhysicalRewards);
		System.assertEquals(null, prw.errMsg);

		prw = AllRewards_controller.getAllRewards(false);
		System.assertEquals(0, prw.numPhysicalRewards);
		System.assertEquals(null, prw.errMsg);
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
				AllRewards_controller.initialDataWrapper idw = AllRewards_controller.getInitialData();
				System.assert(idw.errMsg.contains(Label.TrustJediMobile_errorPrefix + Label.Jedi_Level));
			}
		Test.stopTest();

		System.runAs(testUser) {
			AllRewards_controller.initialDataWrapper idw = AllRewards_controller.getInitialData();
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