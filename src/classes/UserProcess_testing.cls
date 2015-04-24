/*
	*	This class is a utility class that will be called from several triggers on several
	*		objects. These will update records so that they can be used in the Trust Jedi project. 
	*		@dev: creinke
	*/
@isTest
public with sharing class UserProcess_testing {
	//	Create chatter groups needed in this testing process
	public static List<ID> chatterIDs = createChatterGroups();

	//	Create all of the setting related to the testing process.
	public UserProcess_testing () { }

	/*
	*	Test an updated Jedi User
	*/
	public static testMethod void test_updateJediUser () {

	}

	/*
	*	When a user is created with a Jedi Level and the feature is enabled a Jedi User should be created.
	*/
	public static testMethod void test_insertUserWithJediLevel () {
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

		Test.startTest();
			String testEmail = String.valueOf(Math.round(Math.random() * 1000000000)) + '@salesforce.com';
			User u = new User(  Username = testEmail,
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
			insert u;
			System.assertNotEquals(null, u.Id);

			//	Create the custom setting so that the feature is enabled for org
			TrustJediMobile__Jedi_Level__c newLevel = createJediLevel(0);
			User testUser;
			List<TrustJediMobile__Jedi_User__c> jediUsers;
		Test.stopTest();

		//	With a Jedi Level the Jedi User should be created
		try {
			jediUsers = [SELECT Id,
								TrustJediMobile__User__c,
								TrustJediMobile__User_Type__c,
								TrustJediMobile__Jedi_Level__c
							FROM TrustJediMobile__Jedi_User__c];
			System.assertEquals(1, jediUsers.size());
		} catch (Exception ex) {
			System.debug('Error: ' + ex.getMessage());
			System.assert(false);
		}

		//	Update a Jedi user to verify the save works.
		try {
			jediUsers[0].TrustJediMobile__User_Type__c = 'Admin';
			update jediUsers;
			jediUsers = [SELECT Id,
								TrustJediMobile__User__c,
								TrustJediMobile__User_Type__c,
								TrustJediMobile__Jedi_Level__c
							FROM TrustJediMobile__Jedi_User__c];
			System.assertEquals('Admin', jediUsers[0].TrustJediMobile__User_Type__c);
		} catch (Exception ex) {
			System.debug('Error: ' + ex.getMessage());
			System.assert(false);
		}

		//	Delete the Jedi User and then see if it is recreated when the user record is modified
		try {
			delete jediUsers;
			jediUsers = [SELECT Id,
								TrustJediMobile__User__c,
								TrustJediMobile__User_Type__c,
								TrustJediMobile__Jedi_Level__c
							FROM TrustJediMobile__Jedi_User__c];
			System.assertEquals(0, jediUsers.size());
		} catch (Exception ex) {
			System.debug('Error: ' + ex.getMessage());
			System.assert(false);
		}
	}

	public static testMethod void test_insertWithoutEnabled () {
		List<TrustJedi_settings__c> settings = new List<TrustJedi_settings__c>();
		Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
		if(!existingSettings.containsKey('defaultUserType')) settings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
		if(!existingSettings.containsKey('featureEnabled')) settings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'false'));
		if(!existingSettings.containsKey('MaxAlertOnHomePage')) settings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
		if(!existingSettings.containsKey('MaxBadgesOnHomePage')) settings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
		if(!existingSettings.containsKey('postChatterIDs')) settings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
		if(!existingSettings.containsKey('postToChatterEnabled')) settings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
		if(!existingSettings.containsKey('postToTrustChatterGroup')) settings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
		if(!existingSettings.containsKey('UserTypes')) settings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
		if(settings.size() > 0) upsert settings;

		Test.startTest();
			String testEmail = String.valueOf(Math.round(Math.random() * 1000000000)) + '@salesforce.com';
			User u = new User(  Username = testEmail,
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
			insert u;
			System.assertNotEquals(null, u.Id);

			//	Create the custom setting so that the feature is enabled for org
			TrustJediMobile__Jedi_Level__c newLevel = createJediLevel(0);
			User testUser;
			List<TrustJediMobile__Jedi_User__c> jediUsers;
		Test.stopTest();

		//	With a Jedi Level the Jedi User should be created
		try {
			jediUsers = [SELECT Id,
								TrustJediMobile__User__c,
								TrustJediMobile__User_Type__c,
								TrustJediMobile__Jedi_Level__c
							FROM TrustJediMobile__Jedi_User__c];
			System.assertEquals(0, jediUsers.size());
		} catch (Exception ex) {
			System.debug('Error: ' + ex.getMessage());
			System.assert(false);
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
	*	Create a test user that will be used in test methods
	*/
	public static User createNewUser (String firstName, String lastName) {
		//	Create a new User to have a new Jedi User should be created
		try {
			String testEmail = String.valueOf(Math.round(Math.random() * 1000000000)) + '@salesforce.com';
			User testUser = new User (  Username = testEmail,
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
			return testUser;
		} catch (Exception ex) {
			System.debug('Error: ' + ex.getMessage());
			System.assert(false);
		}
		return null;
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
}