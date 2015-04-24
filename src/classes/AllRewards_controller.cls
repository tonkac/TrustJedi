/*
	*	This class will pass all of the needed data to the user to display all of the rewards
	*		that could be given to users when they make a specific level.
	*		@dev: creinke
	*/
public with sharing class AllRewards_controller {
	public TrustJediMobile__Jedi_Level__c myJediLevel { get; private set; }
	public Boolean isError { get; private set; }
	public String errMsg { get; private set; }
	public Boolean adminUser { get; private set; } //	If trust user then display additional functions

	/*
	*	Constructors
	*/
	public AllRewards_controller() { getCurrentUser(); }
	public AllRewards_controller(ApexPages.StandardController controller) { getCurrentUser(); }

	/*
	*	Determine if the user is a Trust Admin, or is a standard user
	*/
	private void getCurrentUser () {
		isError = false;
		errMsg = '';
		try {
			TrustJediMobile__Jedi_User__c ju = [SELECT	Id,
														TrustJediMobile__User_Type__c
													FROM TrustJediMobile__Jedi_User__c
													WHERE TrustJediMobile__User__c = :UserInfo.getUserId()];
			if(ju.TrustJediMobile__User_Type__c == Label.TrustJediMobile_adminDesignation) {
				adminUser = true;
			} else {
				adminUser = false;
			} 
		} catch (Exception ex) {
			isError = true;
			errMsg = Label.TrustJediMobile_errorPrefix;
		}
	}	//	Current user information

	/*
	*	This wrapper holds all of the data that is held in the header of the page.
	*/
	public class initialDataWrapper {
		public String jediUserString { get; set; }
		public String myProfileString { get; set; }
		public String jediLevelString { get; set; }
		public String errMsg { get; set; }
		public initialDataWrapper () { }
	}	//	Wrapper that is used in the VF Pages

	/*
	*	Wrapper holds all of the reward records that are going to be displayed to the user
	*/
	public class physicalRewardWrapper {
		public physicalRewardWrapper() { }
		public String physicalRewardString { get; set; }
		public Integer numPhysicalRewards { get; set; }
		public String errMsg { get; set; }
	}	//	Wrapper that is used in the VF Pages

	/*
	*	The number of physical rewards can change if the user is a trust admin or if they
	*		are a standard user
	*/
	@RemoteAction
	public static physicalRewardWrapper getAllRewards (Boolean trustUser) {
		physicalRewardWrapper bw = new physicalRewardWrapper();
		String queryString;
		if (trustUser) {
			//	Capture all records for trust admins
			queryString = 'SELECT	Id,' +
									'Name,' +
									'TrustJediMobile__RewardImageURL__c,' +
									'TrustJediMobile__ShowRewardImage__c,' +
									'TrustJediMobile__Type__c,' +
									'TrustJediMobile__Visible_to_Non_Trust__c,' +
									'TrustJediMobile__Short_Description__c' +
								' FROM TrustJediMobile__Physical_Reward__c';
		} else {
			//	Capture all of the rewards that are visible to all users
			queryString = 'SELECT	Id,' +
									'Name,' +
									'TrustJediMobile__RewardImageURL__c,' +
									'TrustJediMobile__ShowRewardImage__c,' +
									'TrustJediMobile__Type__c,' +
									'TrustJediMobile__Visible_to_Non_Trust__c,' +
									'TrustJediMobile__Short_Description__c' +
								' FROM TrustJediMobile__Physical_Reward__c' +
								' WHERE TrustJediMobile__Visible_to_Non_Trust__c = true';
		}

		try {
			bw.physicalRewardString = JSON.serialize(database.query(queryString));
			if(trustUser) {
				bw.numPhysicalRewards = [SELECT count() FROM TrustJediMobile__Physical_Reward__c];
			} else {
				bw.numPhysicalRewards = [SELECT count() FROM TrustJediMobile__Physical_Reward__c WHERE TrustJediMobile__Visible_to_Non_Trust__c = true];
			}
		} catch (Exception ex) {
			bw = new physicalRewardWrapper();
			bw.errMsg = Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage();
			bw.numPhysicalRewards = -1;
		}
		return bw;
	}	//	Get the rewards from the sytem that are associated with this current user

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
		} catch (Exception ex) {
			idw.errMsg = Label.TrustJediMobile_errorPrefix + Label.Jedi_Level + ex.getMessage();
		}

		//	Capture the user's information so that it is displayed in the app
		if (String.isBlank(idw.errMsg)) {
			jProfile = [SELECT	Id,
								Title,
								Phone,
								Name,
								SmallPhotoUrl
							FROM UserProfile
							WHERE Id = :UserInfo.getUserId()];
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
				idw.errMsg = Label.TrustJediMobile_errorPrefix + Label.Jedi_Level + ex.getMessage();
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