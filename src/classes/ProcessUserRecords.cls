/*
	*	This class is a utility class that will be called from several triggers on several
	*		objects. These will update records so that they can be used in the Trust Jedi project. 
	*		@dev: creinke
	*/
public with sharing class ProcessUserRecords {
	private static final String USER_TYPE = 'Standard';
	private static Map<String, TrustJedi_settings__c> settings = TrustJedi_settings__c.getAll();

	public ProcessUserRecords(Set<ID> userIDs) { processUsers_insert(userIDs); }

	/*
	*	When a user is created by the admin team the trust user record should be created. The user will start out as a
	*		user with no points assigned. Points are created when trust users approve badges.
	*/
	@future
	public static void processUsers_insert (Set<ID> newUserId) {

		List<User> newUsers = [SELECT Id, UserType, FirstName, LastName FROM User WHERE Id IN :newUserId];

		//	Create variables
		List<ID> userIDs = new List<ID>();
		Jedi_Level__c defaultLevel;
		List<TrustJediMobile__Jedi_User__c> newJediUsers = new List<TrustJediMobile__Jedi_User__c>();
		Boolean featureEnabled = false;
		try {
			if (settings.containsKey('featureEnabled'))
				featureEnabled = Boolean.valueOf(settings.get('featureEnabled').value__c);
		} catch (Exception ex) {
			featureEnabled = false;
			System.debug(System.Label.Debug_featureNotEnabled);
		}

		if (featureEnabled) {
			try {
				//	Determine if the feature is enabled and setup correctly
				defaultLevel = [SELECT 	Id,
										Name
									FROM TrustJediMobile__Jedi_Level__c
									ORDER BY TrustJediMobile__Points_Required__c ASC LIMIT 1];
				featureEnabled = true;
			} catch (Exception ex) {
				featureEnabled = false;
				System.debug(System.Label.Error_noJediLevelsCreated);
			}
			//	Get default trust level to assign to new users

			// Only process standard users, any others are ignored.
			for (User u: newUsers) if (u.UserType == USER_TYPE) userIDs.add(u.Id);

			List<TrustJediMobile__Jedi_User__c> existingUsers = [SELECT Id,
																		TrustJediMobile__User__c,
																		TrustJediMobile__User_Type__c,
																		TrustJediMobile__Jedi_Level__c
																	FROM TrustJediMobile__Jedi_User__c
																	WHERE TrustJediMobile__User__c IN :userIDs];

			//	Go through each user and determine if they should be created or not.
			for (User u: newUsers) {
				Boolean found = false;
				for (TrustJediMobile__Jedi_User__c ju: existingUsers)
					if(ju.TrustJediMobile__User__c == u.Id && u.UserType == USER_TYPE) continue;
				if (defaultLevel != null) {
					newJediUsers.add(new TrustJediMobile__Jedi_User__c(
						TrustJediMobile__User__c = u.Id,
						TrustJediMobile__User_Type__c = 'User',
						TrustJediMobile__Jedi_Level__c = defaultLevel.Id,
						Name = u.FirstName + ' ' + u.LastName)
					);
				} else break;
			}

			//	Create the new Jedi Users based on above info
			if (newJediUsers.size() > 0) {
				try {
					insert newJediUsers;
				} catch (Exception ex) {
					System.debug(Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
				}
			}
		} else System.debug(System.Label.Debug_featureNotEnabled);
	}
}