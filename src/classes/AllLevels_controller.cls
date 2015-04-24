/*
	*	This class will display each of the Jedi Levels to the user. 
	*		@dev: creinke
	*/
public with sharing class AllLevels_controller {
	public class JediException extends Exception {}
	public TrustJediMobile__Jedi_User__c thisJediUser { get; private set; }
	public Boolean isError { get; private set; }
	public String errorMessage { get; private set; }
	public Boolean adminUser { get; private set; } //	If trust user then display additional functions

	//	Constructors
	public AllLevels_controller() {
		getCurrentUser();
		isError = false;
		errorMessage = '';
	}
	public AllLevels_controller(ApexPages.StandardController controller) {
		getCurrentUser();
		isError = false;
		errorMessage = '';
	}

	/*
	*	Method will determine if the user is a trust user, or a standard user
	*/
	public void getCurrentUser () {
		adminUser = false;
		try {
			thisJediUser = [SELECT	Id,
									TrustJediMobile__User__c,
									TrustJediMobile__User_Type__c,
									TrustJediMobile__Jedi_Level__c,
									TrustJediMobile__Jedi_Level__r.Id
								FROM TrustJediMobile__Jedi_User__c
								WHERE TrustJediMobile__User__c = :UserInfo.getUserId()];
			if(thisJediUser == null) {
				update new User(Id = UserInfo.getUserId());
			}
			if(thisJediUser.TrustJediMobile__User_Type__c == Label.TrustJediMobile_adminDesignation) {
				adminUser = true;
			} else {
				adminUser = false;
			}
		} catch (Exception ex) {
			errorMessage = Label.TrustJediMobile_errorPrefix + ex.getMessage();
			System.debug(Label.TrustJediMobile_errorPrefix + ex.getMessage());
			isError = true;
			adminUser = false;
		}
	}

	/*
	*	Wrapper holds the jedi levels and passes them to the level page
	*/
	public class jediLevelWrapper {
		public jediLevelWrapper() { }
		public Boolean isError { get; set; }
		public String jediLevelString { get; set; }
		public String errMsg { get; set; }
		public Integer numJediLevels { get; set; }
	}

	/*
	*	Wrapper holds all of the information that is directly related to this specific user
	*/
	public class initialDataWrapper {
		public initialDataWrapper () { }
		public Boolean isError { get; set; }
		public String jediUserString { get; set; }
		public String myProfileString { get; set; }
		public String jediLevelString { get; set; }
		public String errMsg { get; set; }
	}

	/*
	*	The page will hold the information related to the Jedi Levels and pass them to the page
	*		for the trust users
	*/
	@RemoteAction
	public static jediLevelWrapper getAllJediLevels () {
		jediLevelWrapper bw = new jediLevelWrapper();
		String queryString = 'SELECT	Id,' +
										'TrustJediMobile__Image_URL__c,' +
										'TrustJediMobile__Jedi_Level_Image__c,' +
										'Name,' +
										'TrustJediMobile__Points_Required__c,' +
										'TrustJediMobile__Physical_Reward__c,' +
										'TrustJediMobile__RewardName__c,' +
										'TrustJediMobile__Render_Reward__c,' +
										'TrustJediMobile__RenderWYCD__c,' +
										'TrustJediMobile__WhatYouCanDo__c' +
									' FROM TrustJediMobile__Jedi_Level__c' +
									' ORDER BY TrustJediMobile__Points_Required__c ASC';

		try {
			bw.jediLevelString = JSON.serialize(database.query(queryString));
			bw.numJediLevels = [SELECT count() FROM TrustJediMobile__Jedi_Level__c];
			if (bw.numJediLevels > 0) {
				bw.errMsg = '';
			} else {
				throw new JediException(Label.TrustJediMobile_errorPrefix + ' ' + Label.TrustJediMobile_noRecordsFound);
			}
		} catch (JediException ex) {
			bw = new jediLevelWrapper();
			bw.numJediLevels = -1;
			bw.errMsg = ex.getMessage();
		}
		return bw;
	}

	/*
	*	This page has a header section which is populated from the data returned by this
	*		method's wrapper
	*/
	@RemoteAction
	public static initialDataWrapper getInitialData () {
		initialDataWrapper idw = new initialDataWrapper();
		TrustJediMobile__Jedi_User__c jUser;
		UserProfile jProfile;
		TrustJediMobile__Jedi_Level__c jLevel;

		//	Capture the Jedi User for the current user. If the user doesn't have a Jedi User
		//		record then the system will create a new record.
		try {
			jUser = [SELECT	Id,
							TrustJediMobile__Jedi_Level_Image__c,
							TrustJediMobile__Jedi_Level__c,
							TrustJediMobile__Max_Points_Given_30_Days__c,
							Name,
							TrustJediMobile__Points__c,
							TrustJediMobile__User_Type__c,
							TrustJediMobile__User__c,
							TrustJediMobile__User__r.Phone,
							TrustJediMobile__User__r.Title,
							TrustJediMobile__User__r.Email
						FROM TrustJediMobile__Jedi_User__c
						WHERE TrustJediMobile__User__c = :UserInfo.getUserId()];

			//	Capture the user's information so that it is displayed in the app
			jProfile = [SELECT	Id,
								Title,
								Phone,
								Name,
								SmallPhotoUrl
							FROM UserProfile
							WHERE Id = :UserInfo.getUserId()];
		} catch (Exception ex) {
			idw.errMsg = Label.ErrorPrefix + ' ' + ex.getMessage();
			idw.isError = true;
		}

		//	If the user has a Jedi User then get the Jedi Level
		if(juser != null) {
			try {
				jLevel = [SELECT	TrustJediMobile__WhatYouCanDo_Dev_QA__c,
									Id,
									TrustJediMobile__Image_URL__c,
									TrustJediMobile__Jedi_Level_Image__c,
									Name,
									TrustJediMobile__Points_Required__c,
									TrustJediMobile__Physical_Reward__c,
									TrustJediMobile__WhatYouCanDo__c
								FROM TrustJediMobile__Jedi_Level__c
								WHERE Id = :jUser.TrustJediMobile__Jedi_Level__c
								LIMIT 1];
			} catch (Exception ex) {
				idw.errMsg = Label.ErrorPrefix + ' ' + ex.getMessage();
				idw.isError = true;
			}

			idw.jediUserString = JSON.serialize(jUser);
			idw.myProfileString = JSON.serialize(jProfile);
			idw.jediLevelString = JSON.serialize(jLevel);
		} else {
			jUser = new TrustJediMobile__Jedi_User__c();
			jUser.Name = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
			jUser.TrustJediMobile__Max_Points_Given_30_Days__c = 0;
			jUser.TrustJediMobile__User_Type__c = Label.TrustJediMobile_userDesignation;
			jUser.TrustJediMobile__User__c = UserInfo.getUserId();
			try {
				insert jUser;
				idw.jediUserString = JSON.serialize(jUser);
				idw.myProfileString = JSON.serialize(jProfile);
				idw.jediLevelString = JSON.serialize(jLevel);
			} catch (Exception ex) {
				idw.errMsg = Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage();
			}
		}
		return idw;
	}	//	Get the information for the user in the system
}