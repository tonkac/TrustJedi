/*
    *   This Visualforce Page controls the initial page of the Trust Jedi application. It returns the
    *       jedi user, jedi level, user info, security alerts, and badges assigned to this user.
    *       @project: Trust Jedi
    *       @dev: creinke
    */
@isTest
public with sharing class HomePage_testing {
    // Values that are used in the testing process
    private static TrustJediMobile__Jedi_User__c jUser;
    private static TrustJediMobile__Jedi_Level__c jLevel;

    //  Constructor
    public HomePage_testing() { }


    /*
    *   Create trust badges that have been assigned to the current user.
    */
    public static void createTrustBadges () {
        //  Verify that there is a Trust User record and it is set to Admin for the current user.
        try {
            jUser = [SELECT Id, TrustJediMobile__User__c FROM TrustJediMobile__Jedi_User__c WHERE TrustJediMobile__User__c = :UserInfo.getUserId()];
            if (jUser.Id != null) {
                if (jUser.TrustJediMobile__User__c == 'User') {
                    jUser.TrustJediMobile__User__c = 'Admin';
                    try {
                        update jUser;
                    } catch (Exception ex2) {
                        System.debug('Error: ' + ex2.getMessage());
                    }
                }
            }
        } catch (Exception ex) {
            jUser = new TrustJediMobile__Jedi_User__c();
            jUser.Name = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            jUser.TrustJediMobile__Max_Points_Given_30_Days__c = 0;
            jUser.TrustJediMobile__User_Type__c = 'Admin';
            jUser.TrustJediMobile__User__c = UserInfo.getUserId();
 
            try {
                insert jUser;
            } catch (Exception ex3) {
                System.debug('Error: ' + ex3.getMessage());
            }

            //  Create new Jedi Badges to be given out
            TrustJediMobile__Trust_Badge__c tb = new TrustJediMobile__Trust_Badge__c(
                TrustJediMobile__Active__c = true,
                TrustJediMobile__Auto_Approve_Allowed__c = true,
                TrustJediMobile__Badge_Description_Example__c = 'Example of what a user needs to do to get a badge',
                TrustJediMobile__Badge_Image_URL__c = '/img/samples/flag_green.gif',
                TrustJediMobile__Max_Points__c = 100,
                TrustJediMobile__Min_Points__c = 100,
                TrustJediMobile__Trust_Points__c = 100,
                TrustJediMobile__Trust_Use_Only__c = false
            );

            try {
                insert tb;
            } catch (Exception ex4) {
                System.debug('Error: ' + ex4.getMessage());
            }

            TrustJediMobile__B2JU__c trustBadge = new TrustJediMobile__B2JU__c(
                TrustJediMobile__Jedi_User__c = jUser.Id,
                TrustJediMobile__Points_Requested__c = 100,
                TrustJediMobile__Description__c = 'Description of what the user did to earn badge',
                TrustJediMobile__Trust_Badge__c = tb.Id
            );

            try {
                insert trustBadge;
            } catch (Exception ex5) {
                System.debug('Error: ' + ex5.getMessage());
            }
        }
    }

    /*
    *   Create security alerts that will be displayed on the user's front page when viewing the Jedi App
    */
    public static List<TrustJediMobile__Security_Alert__c> createSecurityAlerts () {
        List<TrustJediMobile__Security_Alert__c> newAlerts = new List<TrustJediMobile__Security_Alert__c>();
        for (Integer i=0;i < 3;i++) {
            TrustJediMobile__Security_Alert__c temp = new TrustJediMobile__Security_Alert__c(
                TrustJediMobile__Date_Start__c = Date.today().addDays(-5),
                TrustJediMobile__Date_End__c = Date.today().addDays(5),
                TrustJediMobile__Description__c = 'Test Alert: ' + String.valueOf(i),
                TrustJediMobile__Subject__c = 'Test Subject: ' + String.valueOf(i),
                TrustJediMobile__Type__c = 'Alert',
                TrustJediMobile__AlertImageURL__c = '/img/samples/flag_green.gif'
            );
            newAlerts.add(temp);
        }

        try {
            insert newAlerts;
            return newAlerts;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            return null;
        }
    }

    /*
    *   Before the system will function correctly there should be Jedi Levels that users can work towards.
    *       If they do not have a level, this system will create a new Level for testing purposes.
    */
    public static TrustJediMobile__Jedi_Level__c createJediLevel () {
        try {
            jLevel = [SELECT    TrustJediMobile__WhatYouCanDo_Dev_QA__c,
                                Id,
                                TrustJediMobile__Image_URL__c,
                                TrustJediMobile__Jedi_Level_Image__c,
                                Name,
                                TrustJediMobile__Points_Required__c,
                                TrustJediMobile__Physical_Reward__c,
                                TrustJediMobile__WhatYouCanDo__c
                            FROM TrustJediMobile__Jedi_Level__c ORDER BY TrustJediMobile__Points_Required__c ASC LIMIT 1];
            System.debug('in jlevel');
            return jLevel;
        } catch (Exception ex) {
            jLevel = new TrustJediMobile__Jedi_Level__c();
            jLevel.TrustJediMobile__Image_URL__c = '/img/samples/flag_green.gif';
            jLevel.Name = 'Level 0: Beginner';
            jLevel.TrustJediMobile__Points_Required__c = 0;
            jLevel.TrustJediMobile__WhatYouCanDo__c = 'Populate with valid information';
            insert jLevel;
            System.debug('out jlevel: ' + jLevel.Id);
            return jLevel;
        }
    }

    /*
    *   Method will create a new Jedi User for testing purpose. Testing needs to be done for both of the possible
    *       scenarios
    */
    public static TrustJediMobile__Jedi_User__c createJediUser (String userType) {
        try {
            jUser = [SELECT Id,
                            Name,
                            TrustJediMobile__Max_Points_Given_30_Days__c,
                            TrustJediMobile__User_Type__c,
                            TrustJediMobile__User__c
                        FROM TrustJediMobile__Jedi_User__c WHERE TrustJediMobile__User__c = :UserInfo.getUserId()];
            return jUser;
        } catch (Exception ex) {
            jUser = new TrustJediMobile__Jedi_User__c();
            jUser.Name = UserInfo.getFirstName() + ' ' + UserInfo.getLastName();
            jUser.TrustJediMobile__Max_Points_Given_30_Days__c = 0;
            jUser.TrustJediMobile__User_Type__c = userType;
            jUser.TrustJediMobile__User__c = UserInfo.getUserId();
            insert jUser;
            return jUser;
        }
    }

    //  Verify that when the items are setup correctly there are no errors and the number of badges
    //      are noted at five records.
    public static testMethod void testProcessingCode () {
        //  Verify that there is even an existing Jedi Level, or create a new one if you are using SeeAllData= false
        createJediLevel();

        //  Check the initial data that is being used. In this test all data is not visible so
        //      the test code will initially return no Jedi Users
        HomePage_controller hpc = new HomePage_controller();
        System.assertEquals('List has no rows for assignment to SObject', hpc.errMsg);

        jUser = createJediUser('User');
        System.assertNotEquals(null, jUser.Id);

        //  Create a Jedi User and then verify that it is found
        hpc = new HomePage_controller();
        System.assertEquals(null, hpc.errMsg);

        //  As a default the user should be shown the first page and badges to be shown should
        //      be set as 5. 
        System.assertEquals(0, hpc.startingPage);
        System.assertEquals(5, hpc.badgesToShow);
    }

    /*
    *   This test method will test the initial settings of the VF Page and the controller. Once beyond it will
    *       then test each of the @RemoteAction methods used to capture data for the VF Page that will be 
    *       displayed to the user running the app.
    */
    public static testMethod void testCurrentPageCode () {
        //  Verify that there is even an existing Jedi Level, or create a new one if you are using SeeAllData= false
        createJediLevel();

        //  Create the VF Page and controller. This will also create a new Jedi User with the User permissions
        PageReference pageRef = Page.HomePage;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdCntr = new ApexPages.StandardController(createJediUser('User'));
        HomePage_controller controller = new HomePage_controller(stdCntr);

        //  Assert each of the controller values
        System.assertEquals(0, controller.startingPage);
        System.assertEquals(5, controller.badgesToShow);
        System.assertEquals(false, controller.trustUser);
        System.assertEquals(null, controller.errMsg);
        System.assertEquals(jUser.Id, controller.ju.Id);

        //  Capture values from the Initial Data 
        HomePage_controller.initialDataWrapper idw = new HomePage_controller.initialDataWrapper();
        HomePage_controller hpc = new HomePage_controller();
        idw = HomePage_controller.getInitialData();
        System.assertNotEquals('', idw.jediUserString);

        //  Get the JSON user record and parse it to a custom object. Then verify that it is displaying the correct jedi user
        TrustJediMobile__Jedi_User__c jsonJediUser = (TrustJediMobile__Jedi_User__c) JSON.deserialize(idw.jediUserString, TrustJediMobile__Jedi_User__c.class);
        System.assertEquals(jUser.Id, jsonJediUser.Id);

        //  Get the JSON user's profile record to get information to display on the Jedi Page
        UserProfile jsonUserProfile = (UserProfile) JSON.deserialize(idw.myProfileString, UserProfile.class);
        System.assertNotEquals(null, jsonUserProfile.Id);

        //  Get the JSON jedi level to make sure the correct one  is associated with the user
        TrustJediMobile__Jedi_Level__c jsonJediLevel = (TrustJediMobile__Jedi_Level__c) JSON.deserialize(idw.jediLevelString, TrustJediMobile__Jedi_Level__c.class);
        System.assertNotEquals(null, jsonJediLevel.Id);
        System.assertEquals(jLevel.Id, jsonJediLevel.Id);
    }

    /*
    *   When a user is created without a Jedi User record the system will automatically create the Jedi User.
    */
    public static testMethod void testWithoutExistingUser () {
        //  Capture values from the Initial Data 
        HomePage_controller.initialDataWrapper idw = new HomePage_controller.initialDataWrapper();
        HomePage_controller hpc = new HomePage_controller();
        idw = HomePage_controller.getInitialData();
        System.assertNotEquals('', idw.jediUserString);

        //  Get the JSON user record and parse it to a custom object. Then verify that it is displaying the correct jedi user
        TrustJediMobile__Jedi_User__c jsonJediUser = (TrustJediMobile__Jedi_User__c) JSON.deserialize(idw.jediUserString, TrustJediMobile__Jedi_User__c.class);
        System.assertNotEquals(null, jsonJediUser.Id);
    }

    /*
    *   Once a user is created and exists the next step to see if there are any security alerts. The first test
    *       will test without any alerts.
    */
    public static testMethod void testAlertsWithout () {
        //  Capture values from the Initial Data 
        HomePage_controller.securityAlertWrapper saw = new HomePage_controller.securityAlertWrapper();
        HomePage_controller hpc = new HomePage_controller();
        saw = HomePage_controller.getAlerts();

        //  Testing the values in the wrapper
        System.assertEquals(null, saw.alertString);
        System.assertNotEquals(null, saw.errMsg);
        System.assertEquals(false, saw.showAlerts);
    }

    /*
    *   Once a user is created and exists the next step to see if there are any security alerts. This test will be testing
    *       when there are security alerts being shown.
    */
    public static testMethod void testAlertsWith () {
        //  Create new security alerts to be displayed on home page.
        createSecurityAlerts();

        //  Capture values from the Initial Data 
        HomePage_controller.securityAlertWrapper saw = new HomePage_controller.securityAlertWrapper();
        HomePage_controller hpc = new HomePage_controller();
        saw = HomePage_controller.getAlerts();

        //  Testing the values in the wrapper
        List<TrustJediMobile__Security_Alert__c> alerts = (List<TrustJediMobile__Security_Alert__c>) JSON.deserialize(saw.alertString, List<TrustJediMobile__Security_Alert__c>.class);
        System.assertEquals(3, alerts.size());
        System.assertEquals(null, saw.errMsg);
        System.assertEquals(true, saw.showAlerts);
    }

    /*
    *   Process through trust badges to verify they are being displayed on the page. Initial testing without any badges.
    */
    public static testMethod void testWithoutBadges () {
        HomePage_controller.badgeListWrapper blw = new HomePage_controller.badgeListWrapper();
        blw = HomePage_controller.getBadges(5);

        //  Testing the values in the wrapper without any record
        System.assertEquals('', blw.badgeString);
        System.assertNotEquals('', blw.errMsg);
        System.assertEquals('0', blw.totalBadges);
    }
    
    /*
    *   Process through multiple badges that have been assigned to this user
    */
    public static testMethod void testWithBadges () {
        //  Create trust badges
        createTrustBadges();
        HomePage_controller.badgeListWrapper blw = new HomePage_controller.badgeListWrapper();
        blw = HomePage_controller.getBadges(5);

        Integer cnt = [SELECT count() FROM TrustJediMobile__B2JU__c WHERE TrustJediMobile__Jedi_User__r.User__c = :UserInfo.getUserId()];
        System.assertEquals(1, cnt);
        System.assertNotEquals('', blw.badgeString);
        System.assertEquals(null, blw.errMsg);
        System.assertEquals('1', blw.totalBadges);
    }
}