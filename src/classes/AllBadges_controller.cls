/*
	*	This class will manage the VF Page that displays all Trust Badges in the Salesforce1 environment. This
	*		is using JS Remote so that it doesn't take as many resources as it would if using only Apex/VF. All
	*		of the main pages will show the user's information at the top of the page. It will be the user and
	*		the Jedi User information along with the levels. 
	*		@dev: creinke
	*/
public with sharing class AllBadges_controller {
	public TrustJediMobile__Jedi_Level__c myJediLevel { get; private set; }
	public TrustJediMobile__Jedi_User__c thisJediUser { get; private set; }
	private Map<String, TrustJedi_settings__c> settings = TrustJedi_settings__c.getAll();
	public String errorMessage = '';
	public Boolean isError = false;
	public Boolean adminUser { get; private set; } //	If trust user then display additional functions

	

	// Constructors
	public AllBadges_controller() { getCurrentUser(); }
	public AllBadges_controller(ApexPages.StandardController controller) { getCurrentUser(); }

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

			myJediLevel = [SELECT	Id,
									TrustJediMobile__Points_Required__c,
									TrustJediMobile__RenderImage__c,
									TrustJediMobile__RenderReward__c,
									TrustJediMobile__Render_Reward__c,
									TrustJediMobile__RenderWYCD__c,
									TrustJediMobile__Physical_Reward__c,
									TrustJediMobile__RewardName__c,
									TrustJediMobile__WhatYouCanDo__c
			 					FROM TrustJediMobile__Jedi_Level__c
			 					WHERE Id = :thisJediUser.TrustJediMobile__Jedi_Level__r.Id];
		} catch (Exception ex) {
			errorMessage = Label.TrustJediMobile_errorPrefix + ex.getMessage();
			System.debug(Label.TrustJediMobile_errorPrefix + ex.getMessage());
			isError = true;
			adminUser = false;
		}
	}

	/*
	*	Each of the objects created below are used to pass data to the VF Pages. 
	*/
	public class initialDataWrapper {
		public initialDataWrapper () { }
		public String jediUserString { get; set; }
		public String myProfileString { get; set; }
		public String jediLevelString { get; set; }
		public String errMsg { get; set; }
	}	//	Pass all of the user's information to the VF page through the static methods below

	public class badgeWrapper {
		public badgeWrapper() { }
		public String badgeString { get; set; }
		public String errMsg { get; set; }
		public Integer numBadges { get; set; }
	}	//	Pass all of the user's information to the VF page through the static methods below

	/*
	*	Return all of the badges that are in the system. If the user is an Admin they can see
	*		badges that have Trust Use Only set to false as well as true.
	*/
	@RemoteAction
	public static badgeWrapper getAllBadges (Boolean adminUser) {
		Map<String, TrustJedi_settings__c> settings = TrustJedi_settings__c.getAll();
		String filterString = '';
		String orderString = '';
		String queryString = '';
		badgeWrapper bw = new badgeWrapper();

		//	Generate the basic queryString with Custom Fields
		queryString = 'SELECT	Id,' + 
								'Name,' +
								'TrustJediMobile__Auto_Approve_Allowed__c,' +
								'TrustJediMobile__Badge_Image__c,' +
								'TrustJediMobile__Badge_Image_URL__c,' +
								'TrustJediMobile__Trust_Points__c,' +
								'TrustJediMobile__Badge_Description_Example__c,' +
								'TrustJediMobile__RenderDescription__c,' +
								'TrustJediMobile__Trust_Use_Only__c' +
							' FROM TrustJediMobile__Trust_Badge__c';

		//	Generate the filter string to be used in above query as well as count numbers
		filterString = ' WHERE TrustJediMobile__Active__c = true ';
		if(!adminUser) {
			filterString += ' AND TrustJediMobile__Trust_Use_Only__c = false';
		}

		if (settings.containsKey('allBadgesOrderBy'))
			orderString += ' ORDER BY ' + settings.get('allBadgesOrderBy').Value__c;

		try {
			List<TrustJediMobile__Trust_Badge__c> badgeRecords = database.query(queryString + filterString + orderString);
			bw.badgeString = JSON.serialize(badgeRecords);
			bw.numBadges = badgeRecords.size();
			if(bw.numBadges == 0) {
				bw.errMsg = Label.No_Badges_Found;
			} else bw.errMsg = '';
		} catch (Exception ex) {
			bw = new badgeWrapper();
			bw.errMsg = Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage();
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