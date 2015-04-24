/*
	*	This Visualforce Page Controller manages the initial page of the Trust Jedi application. It returns the
	*		jedi user, jedi level, user info, security alerts, and badges assigned to this user.
	*		@dev: creinke
	*/
 
public with sharing class HomePage_controller {
	public Integer startingPage { get; set; } //	Starting page. If not set then use page 0
	public Integer badgesToShow { get; set; } //	Default number of badges to show on the page
	public Boolean adminUser { get; private set; } //	If trust user then display additional functions
	public String errMsg { get; private set; }
	public TrustJediMobile__Jedi_User__c ju;

	//	Constructors
	public HomePage_controller () { processStartingCode(); }
	public HomePage_controller (ApexPages.StandardController controller) { processStartingCode(); }

	/*
	*	Code below is processed whenever the page is loaded. It sets default value and determines if the user
	*		is an admin, or a standard user.
	*/
	private void processStartingCode () {
		badgesToShow = 5;
		startingPage = 0;
		getCurrentUser();
		if (Label.TrustJediMobile_badgesToShow != null && Label.TrustJediMobile_badgesToShow != '') {
			try {
				badgesToShow = Integer.valueOf(Label.TrustJediMobile_badgesToShow);
			} catch (Exception ex) {
				badgesToShow = 5;
			}
		}

		//	If there is a value in the URL for Start Page it allows the user to navigate to it instead of the
		//		default page of zero
		if(ApexPages.currentPage().getParameters().get('startPage') != null) {
			try {
				startingPage = Integer.valueOf(ApexPages.currentPage().getParameters().get('startPage'));
			} catch (Exception ex) {
				startingPage = 0;
			}
		}
	}

	/*
	*	get the user's Jedi User record to determine if the user is an admin, or a standard user
	*/
	private void getCurrentUser () {
		try {
			ju = [SELECT	Id,
								TrustJediMobile__User_Type__c,
								TrustJediMobile__Jedi_Level__c
							FROM TrustJediMobile__Jedi_User__c
							WHERE TrustJediMobile__User__c = :UserInfo.getUserId()];
			if(ju.TrustJediMobile__User_Type__c == Label.TrustJediMobile_adminDesignation) {
				adminUser = true;
			} else {
				adminUser = false;
			} 
		} catch (Exception ex) {
			errMsg = ex.getMessage();
		}
	}

	/*
	*	This section will capture all of the header data that is used by the S1 application. The wrapper
	*		users JS Remoting and uses a single object that the VF Page can access.
	*/
	public class initialDataWrapper {
		public String jediUserString { get; set; }
		public String myProfileString { get; set; }
		public String jediLevelString { get; set; }
		public String errMsg { get; set; }

		public initialDataWrapper () { }
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

		//	Capture the user's information so that it is displayed in the app
		jProfile = [SELECT	Id,
							Title,
							Phone,
							Name,
							SmallPhotoUrl
						FROM UserProfile WHERE Id = :UserInfo.getUserId()];

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
						FROM TrustJediMobile__Jedi_User__c WHERE TrustJediMobile__User__c = :UserInfo.getUserId()];
		} catch (Exception ex) {
			jUser = new TrustJediMobile__Jedi_User__c();
			jUser.Name = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
			jUser.TrustJediMobile__Max_Points_Given_30_Days__c = 0;
			jUser.TrustJediMobile__User_Type__c = Label.TrustJediMobile_userDesignation;
			jUser.TrustJediMobile__User__c = UserInfo.getUserId();
			try {
				insert jUser;
			} catch (Exception ex2) {
				System.debug('Error: ' + ex2.getMessage());
			}
		}

		//	If the user has a Jedi User then get the Jedi Level
		if(jUser.TrustJediMobile__Jedi_Level__c != null) {
			jLevel = [SELECT	TrustJediMobile__WhatYouCanDo_Dev_QA__c,
								Id,
								TrustJediMobile__Image_URL__c,
								TrustJediMobile__Jedi_Level_Image__c,
								Name,
								TrustJediMobile__Points_Required__c,
								TrustJediMobile__Physical_Reward__c,
								TrustJediMobile__Physical_Reward__r.Name,
								TrustJediMobile__WhatYouCanDo__c
							FROM TrustJediMobile__Jedi_Level__c WHERE Id = :jUser.TrustJediMobile__Jedi_Level__c LIMIT 1];
		} else {
			try {
				jLevel = [SELECT	TrustJediMobile__WhatYouCanDo_Dev_QA__c,
									Id,
									TrustJediMobile__Image_URL__c,
									TrustJediMobile__Jedi_Level_Image__c,
									Name,
									TrustJediMobile__Points_Required__c,
									TrustJediMobile__Physical_Reward__c,
									TrustJediMobile__Physical_Reward__r.Name,
									TrustJediMobile__WhatYouCanDo__c
								FROM TrustJediMobile__Jedi_Level__c ORDER BY TrustJediMobile__Points_Required__c ASC LIMIT 1];
			} catch (Exception ex) {
				System.debug('Error: ' + ex.getMessage());
			}
		}

		try {
			idw.jediUserString = JSON.serialize(jUser);
			idw.myProfileString = JSON.serialize(jProfile);
			System.debug('level: ' + [select count() from TrustJediMobile__Jedi_Level__c]);
			idw.jediLevelString = JSON.serialize(jLevel);
		} catch (Exception ex) {
			idw.errMsg = Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage();
		}
		return idw;
	}	//	Get the information for the user in the system

	/*
	*	This section will capture all of the security alerts that need to be added to the S1 app to be displayed
	*		to the user.
	*/
	public class securityAlertWrapper {
		public securityAlertWrapper() { }
		public String alertString { get; set; }
		public String errMsg { get; set; }
		public Boolean showAlerts { get; set; }
	}

	/*
	*	This section will capture all of the badges that have been given to the user.
	*/
	public class badgeListWrapper {
		public badgeListWrapper() { }
		public badgeListWrapper(List<TrustJediMobile__B2JU__c> badgeList) { badges = badgeList; }
		public List<TrustJediMobile__B2JU__c> badges { get; set; }
		public String errMsg { get; set; }
		public String badgeString { get; set; }
		public String totalBadges { get; set; }
	}

	/*
	*	Get all alerts from the sytem that should be displayed at the current date. Admins can set start and end
	*		dates to automatically add and remove alerts.
	*/
	@RemoteAction
	public static securityAlertWrapper getAlerts () {
		securityAlertWrapper saw = new securityAlertWrapper();
		List<TrustJediMobile__Security_Alert__c> alerts = new List<TrustJediMobile__Security_Alert__c>();
		alerts = [SELECT	Id,
							TrustJediMobile__Date_End__c,
							TrustJediMobile__Date_Start__c,
							TrustJediMobile__Description__c,
							TrustJediMobile__Display__c,
							TrustJediMobile__Documentation_Link__c,
							TrustJediMobile__Flag__c,
							TrustJediMobile__showContact__c,
							TrustJediMobile__showLink__c,
							TrustJediMobile__Subject__c,
							TrustJediMobile__Trust_Contact__c,
							TrustJediMobile__Type__c,
							Name,
							TrustJediMobile__AlertImageURL__c,
							TrustJediMobile__ShowAlertImage__c,
							TrustJediMobile__Short_Subject__c,
							TrustJediMobile__Short_Description__c
						FROM TrustJediMobile__Security_Alert__c
						WHERE TrustJediMobile__Display__c = true
						ORDER BY CreatedDate DESC];

		if(alerts.size() > 0) {
			saw.alertString = JSON.serialize(alerts);
			saw.showAlerts = true;
		} else {
			saw.errMsg = Label.TrustJediMobile_noRecordsFound + ' Security Alerts';
			saw.showAlerts = false;
		}
		return saw;
	}

	/*
	*	Capturing all of the badges that have been assigned to the current user. If there are more
	*		badges than the default value then the user can choose to add more badges to the list.
	*/
	@RemoteAction
	public static badgeListWrapper getBadges (Integer numRecords) {
		List<TrustJediMobile__B2JU__c> approvedBadges = new List<TrustJediMobile__B2JU__c>();
		List<TrustJediMobile__B2JU__c> pendingBadges = new List<TrustJediMobile__B2JU__c>();
		List<TrustJediMobile__B2JU__c> allBadges = new List<TrustJediMobile__B2JU__c>();
		String limitNumber = '';
		badgeListWrapper blw = new badgeListWrapper();
		blw.errMsg = '';
		blw.badgeString = '';
		blw.totalBadges = '0';
		blw.badges = new List<TrustJediMobile__B2JU__c>();
		ID userId = UserInfo.getUserId();
		String queryString = 'SELECT	Id,' + 
										'Name,' +
										'TrustJediMobile__Approval_Status__c,' +
										'TrustJediMobile__Approving_User__c,' +
										'TrustJediMobile__Approving_User__r.Name,' +
										'TrustJediMobile__Auto_Approved_Allowed__c,' +
										'TrustJediMobile__Date_Rewarded__c,' +
										'TrustJediMobile__Description__c,' +
										'TrustJediMobile__Manager_ID__c,' +
										'TrustJediMobile__Trust_Points__c,' +
										'TrustJediMobile__Requesting_User__c,' +
										'TrustJediMobile__Requesting_User__r.Name,' +
										'TrustJediMobile__Points_Granted__c,' +
										'TrustJediMobile__Trust_Badge__c,' +
										'TrustJediMobile__Trust_Badge__r.Name,' +
										'TrustJediMobile__Trust_Badge__r.Badge_Image_URL__c,' +
										'TrustJediMobile__User_ID__c,' +
										'TrustJediMobile__Jedi_User__c,' +
										'TrustJediMobile__Short_Description__c ' +
									' FROM TrustJediMobile__B2JU__c ' +
									' WHERE TrustJediMobile__Jedi_User__r.TrustJediMobile__User__c = :userId ' +
									' ORDER BY TrustJediMobile__Approval_Status__c ASC';

		if(numRecords != -1) { queryString += ' LIMIT ' + numRecords; }
		Integer cnt = [SELECT count() FROM TrustJediMobile__B2JU__c WHERE TrustJediMobile__Jedi_User__r.User__c = :userId];

		if (cnt == 0) {
			blw.errMsg = Label.TrustJediMobile_noRecordsFound + ' Badge (to Trust User)';
		} else { 
			try {
				for(TrustJediMobile__B2JU__c b: database.query(queryString)) {
					if(b.TrustJediMobile__Approval_Status__c == 'Approved') {
						approvedBadges.add(b);
					} else {
						pendingBadges.add(b);
					}
				}
				allBadges.addAll(approvedBadges);
				allBadges.addAll(pendingBadges);
				blw = new badgeListWrapper(allBadges);
				blw.badgeString = JSON.serialize(blw.badges);
				blw.totalBadges = String.valueOf(cnt);
			} catch (Exception ex) {
				blw = new badgeListWrapper();
				blw.errMsg = Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage();
			}
		}
		return blw;
	}
}