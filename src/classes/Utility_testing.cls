/*
    *   This class is a utility class that will be called from several triggers on several
    *       objects. These will update records so that they can be used in the Trust Jedi project. 
    *       @dev: creinke
    */
@isTest
public with sharing class Utility_testing {
    private static String LONG_DESC =    'This is a long description that will be shortened by the system. Anything above 75 characters will be cropped in short fields.';
    private static String SHORT_DESC =   'This is a long description that will be shortened by the system. Anything a...';
    private static String LONG_DESC_2 =  'Change: This is a long description that will be shortened by the system. Anything above 75 characters will be cropped in short fields.';
    private static String SHORT_DESC_2 = 'Change: This is a long description that will be shortened by the system. An...';
    private static String MINI_DESC = 'This is a short description that should not be modified';
    public static List<ID> chatterIDs = createChatterGroups();
    public Utility_testing() { }

    /*
    *   Process through the creation of a new trust issue
    */
    public static testMethod void createNewTrustIssue () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        TrustJediMobile__Trust_Issue__c newIssue = new TrustJediMobile__Trust_Issue__c (
            TrustJediMobile__Description__c = LONG_DESC,
            TrustJediMobile__Subject__c = LONG_DESC,
            TrustJediMobile__Type__c = 'Badge Surfing'
        );

        try {
            insert newIssue;
            System.assertNotEquals(null, newIssue.Id);
            newIssue = [SELECT  Id,
                                TrustJediMobile__Date_Reported__c,
                                TrustJediMobile__Description__c,
                                TrustJediMobile__Formatted_Date__c,
                                TrustJediMobile__Short_Description__c,
                                TrustJediMobile__Short_Subject__c,
                                TrustJediMobile__Status__c,
                                TrustJediMobile__Subject__c,
                                TrustJediMobile__submittedDate__c,
                                TrustJediMobile__Type__c
                            FROM TrustJediMobile__Trust_Issue__c
                            WHERE Id = :newIssue.Id];
            System.assertEquals(SHORT_DESC, newIssue.TrustJediMobile__Short_Description__c);
            System.assertEquals(SHORT_DESC, newIssue.TrustJediMobile__Short_Subject__c);
            System.assertEquals(Date.today(), newIssue.TrustJediMobile__Date_Reported__c);
            System.assertEquals('Submitted', newIssue.TrustJediMobile__Status__c);
            System.assertEquals(Date.today().format(), newIssue.TrustJediMobile__submittedDate__c);
        } catch (Exception ex) {
            System.assert(false);
            System.debug('Error: ' + ex.getMessage());
        }

        newIssue = new TrustJediMobile__Trust_Issue__c (
            TrustJediMobile__Description__c = MINI_DESC,
            TrustJediMobile__Subject__c = MINI_DESC,
            TrustJediMobile__Type__c = 'Badge Surfing'
        );

        try {
            insert newIssue;
            System.assertNotEquals(null, newIssue.Id);
            newIssue = [SELECT  Id,
                                TrustJediMobile__Date_Reported__c,
                                TrustJediMobile__Description__c,
                                TrustJediMobile__Formatted_Date__c,
                                TrustJediMobile__Short_Description__c,
                                TrustJediMobile__Short_Subject__c,
                                TrustJediMobile__Status__c,
                                TrustJediMobile__Subject__c,
                                TrustJediMobile__submittedDate__c,
                                TrustJediMobile__Type__c
                            FROM TrustJediMobile__Trust_Issue__c
                            WHERE Id = :newIssue.Id];
            System.assertEquals(MINI_DESC, newIssue.TrustJediMobile__Short_Description__c);
            System.assertEquals(MINI_DESC, newIssue.TrustJediMobile__Short_Subject__c);
            System.assertEquals(Date.today(), newIssue.TrustJediMobile__Date_Reported__c);
            System.assertEquals('Submitted', newIssue.TrustJediMobile__Status__c);
            System.assertEquals(Date.today().format(), newIssue.TrustJediMobile__submittedDate__c);
        } catch (Exception ex) {
            System.assert(false);
            System.debug('Error: ' + ex.getMessage());
        }

        newIssue.TrustJediMobile__Description__c = LONG_DESC;
        newIssue.TrustJediMobile__Subject__c = LONG_DESC;

        try {
            update newIssue;
            System.assertNotEquals(null, newIssue.Id);
            newIssue = [SELECT  Id,
                                TrustJediMobile__Date_Reported__c,
                                TrustJediMobile__Description__c,
                                TrustJediMobile__Formatted_Date__c,
                                TrustJediMobile__Short_Description__c,
                                TrustJediMobile__Short_Subject__c,
                                TrustJediMobile__Status__c,
                                TrustJediMobile__Subject__c,
                                TrustJediMobile__submittedDate__c,
                                TrustJediMobile__Type__c
                            FROM TrustJediMobile__Trust_Issue__c
                            WHERE Id = :newIssue.Id];
            System.assertEquals(SHORT_DESC, newIssue.TrustJediMobile__Short_Description__c);
            System.assertEquals(SHORT_DESC, newIssue.TrustJediMobile__Short_Subject__c);
            System.assertEquals(Date.today(), newIssue.TrustJediMobile__Date_Reported__c);
            System.assertEquals('Submitted', newIssue.TrustJediMobile__Status__c);
            System.assertEquals(Date.today().format(), newIssue.TrustJediMobile__submittedDate__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            System.assert(false);
        }
    }

    /*
    *   Insert and update security alerts
    */
    public static testMethod void test_insertUpdateSecurityAlerts () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Create a new alert with descriptions that are longer than what should be displayed to the user
        try {
            //  Create a new security alert
            TrustJediMobile__Security_Alert__c newAlert = new TrustJediMobile__Security_Alert__c(
                TrustJediMobile__AlertImageURL__c = '/img/samples/flag_green.gif',
                TrustJediMobile__Date_Start__c = Date.today().addDays(-5),
                TrustJediMobile__Date_End__c = Date.today().addDays(5),
                TrustJediMobile__Description__c = LONG_DESC,
                TrustJediMobile__Subject__c = LONG_DESC,
                TrustJediMobile__Trust_Contact__c = UserInfo.getUserId(),
                TrustJediMobile__Type__c = 'Alert'
            );
            insert newAlert;

            //  Verify that the alert is successfully created
            System.assertNotEquals(null, newAlert.Id);
            newAlert = [SELECT  Id,
                                TrustJediMobile__Short_Description__c,
                                TrustJediMobile__Short_Subject__c
                            FROM TrustJediMobile__Security_Alert__c WHERE Id = :newAlert.Id];
            //  Shortend fields are verified below
            System.assertEquals(SHORT_DESC, newAlert.TrustJediMobile__Short_Description__c);
            System.assertEquals(SHORT_DESC, newAlert.TrustJediMobile__Short_Subject__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            System.assert(false);
        }

        //  Testing to make sure that updates with the longer names also shortents the desplay value
        try {
            //  Create a new security alert
            TrustJediMobile__Security_Alert__c newAlert = new TrustJediMobile__Security_Alert__c(
                TrustJediMobile__AlertImageURL__c = '/img/samples/flag_green.gif',
                TrustJediMobile__Date_Start__c = Date.today().addDays(-5),
                TrustJediMobile__Date_End__c = Date.today().addDays(5),
                TrustJediMobile__Description__c = 'short desc',
                TrustJediMobile__Subject__c = 'short subject',
                TrustJediMobile__Trust_Contact__c = UserInfo.getUserId(),
                TrustJediMobile__Type__c = 'Alert'
            );
            insert newAlert;

            //  Shortend fields are verified below
            newAlert.TrustJediMobile__Description__c = LONG_DESC;
            newAlert.TrustJediMobile__Subject__c = LONG_DESC;
            update newAlert;

            newAlert = [SELECT  Id,
                                TrustJediMobile__Short_Description__c,
                                TrustJediMobile__Short_Subject__c
                            FROM TrustJediMobile__Security_Alert__c WHERE Id = :newAlert.Id];
            System.assertEquals(SHORT_DESC, newAlert.TrustJediMobile__Short_Description__c);
            System.assertEquals(SHORT_DESC, newAlert.TrustJediMobile__Short_Subject__c);

            newAlert.TrustJediMobile__Description__c = 'short desc';
            newAlert.TrustJediMobile__Subject__c = 'short subject';
            update newAlert;
            newAlert = [SELECT  Id,
                                TrustJediMobile__Short_Description__c,
                                TrustJediMobile__Short_Subject__c
                            FROM TrustJediMobile__Security_Alert__c WHERE Id = :newAlert.Id];
            System.assertEquals('short desc', newAlert.TrustJediMobile__Short_Description__c);
            System.assertEquals('short subject', newAlert.TrustJediMobile__Short_Subject__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            System.assert(false);
        }
    }

    /*
    *   Process the update of a jedi level to make sure that the fields are populated and shown correctly
    */
    public static testMethod void test_processUpdateJediLevels () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Create a test reward and a test level to be used
        TrustJediMobile__Physical_Reward__c testReward = createPhysicalReward('T-Shirt', LONG_DESC, true);
        System.assertNotEquals(null, testReward.Id);
        TrustJediMobile__Jedi_Level__c testLevel = createJediLevel(0);
        System.assertNotEquals(null, testLevel.Id);

        //  Update the jedi level so that it will render the fields in the app
        testLevel.TrustJediMobile__Physical_Reward__c = testReward.Id;
        testLevel.TrustJediMobile__WhatYouCanDo__c = 'here is what you can do.';
        update testLevel;
        System.assertNotEquals(null, testLevel.Id);
        testLevel = [SELECT Id,
                            TrustJediMobile__Render_Reward__c,
                            TrustJediMobile__RenderWYCD__c,
                            TrustJediMobile__RenderImage__c
                        FROM TrustJediMobile__Jedi_Level__c WHERE Id = :testLevel.Id];
        System.assertEquals(true, testLevel.TrustJediMobile__Render_Reward__c);
        System.assertEquals(true, testLevel.TrustJediMobile__RenderWYCD__c);
        System.assertEquals(true, testLevel.TrustJediMobile__RenderImage__c);

        //  Update the level without values to hide the fields that are in the app
        try {
            testLevel = createJediLevel(1000);
            testLevel.TrustJediMobile__WhatYouCanDo__c = '';
            testLevel.TrustJediMobile__Image_URL__c = '';
            testLevel.TrustJediMobile__Physical_Reward__c = null;
            update testLevel;
            testLevel = [SELECT Id,
                                TrustJediMobile__Render_Reward__c,
                                TrustJediMobile__RenderWYCD__c,
                                TrustJediMobile__RenderImage__c
                            FROM TrustJediMobile__Jedi_Level__c WHERE Id = :testLevel.Id];
            System.assertEquals(false, testLevel.TrustJediMobile__Render_Reward__c);
            System.assertEquals(false, testLevel.TrustJediMobile__RenderWYCD__c);
            System.assertEquals(false, testLevel.TrustJediMobile__RenderImage__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
    }

    /*
    *   Process through the insertion of a new Jedi Level
    */
    public static testMethod void test_processInsertJediLevel () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Test a new level that should not populate the fields in the S1 App
        TrustJediMobile__Jedi_Level__c testLevel = createJediLevel(1000);
        testLevel.TrustJediMobile__Image_URL__c = null;
        update testLevel;

        testLevel = [SELECT Id,
                            TrustJediMobile__Render_Reward__c,
                            TrustJediMobile__RenderWYCD__c,
                            TrustJediMobile__RenderImage__c
                        FROM TrustJediMobile__Jedi_Level__c WHERE Id = :testLevel.Id];
        System.assertEquals(false, testLevel.TrustJediMobile__Render_Reward__c);
        System.assertEquals(false, testLevel.TrustJediMobile__RenderWYCD__c);
        System.assertEquals(false, testLevel.TrustJediMobile__RenderImage__c);
        delete testLevel;

        //  Test that the fields would be shown when the fields are populated
        try {
            TrustJediMobile__Physical_Reward__c testReward = createPhysicalReward('T-Shirt', LONG_DESC, true);
            System.assertNotEquals(null, testReward.Id);

            testLevel = createJediLevel(1000);
            testLevel.TrustJediMobile__Points_Required__c = 1000;
            testLevel.TrustJediMobile__WhatYouCanDo__c = 'What You Can Do';
            testLevel.TrustJediMobile__Image_URL__c = '/img/samples/flag_green.gif';
            testLevel.TrustJediMobile__Physical_Reward__c = testReward.Id;
            update testLevel;

            testLevel = [SELECT Id,
                                TrustJediMobile__Render_Reward__c,
                                TrustJediMobile__RenderWYCD__c,
                                TrustJediMobile__RenderImage__c
                            FROM TrustJediMobile__Jedi_Level__c WHERE Id = :testLevel.Id];
            System.assertEquals(true, testLevel.TrustJediMobile__Render_Reward__c);
            System.assertEquals(true, testLevel.TrustJediMobile__RenderWYCD__c);
            System.assertEquals(true, testLevel.TrustJediMobile__RenderImage__c);
            delete testLevel;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
    }

    /*
    *   Process through the trust badge insert process
    */
    public static testMethod void test_processInsertTrustBadges () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        ID badgeID;
        //  Create a new Trust Badge to make sure values are populated correctly
        TrustJediMobile__Trust_Badge__c newBadge = createBadge();
        System.assertNotEquals(null, newBadge.Id);

        //  This save should go through without issue and then verify the render field is set to false without a description.
        //      The min and max values should also default to the value in the Trust Points.
        try {
            newBadge.TrustJediMobile__Badge_Description_Example__c = null;
            update newBadge;
            badgeID = newBadge.Id;
            newBadge = [SELECT  Id,
                                TrustJediMobile__RenderDescription__c,
                                TrustJediMobile__Min_Points__c,
                                TrustJediMobile__Max_Points__c
                            FROM TrustJediMobile__Trust_Badge__c
                            WHERE Id = :badgeID];
            System.assertNotEquals(null, newBadge.Id);
            System.assertEquals(false, newBadge.TrustJediMobile__RenderDescription__c);
            System.assertEquals(100, newBadge.TrustJediMobile__Min_Points__c);
            System.assertEquals(100, newBadge.TrustJediMobile__Max_Points__c);
            delete newBadge;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }

        //  Create a new badge that will be used as an insert and will have errors each time
        //  The minimum points should not be greater than the minimum points
        try {
            newBadge = createBadge();
            System.assertNotEquals(null, newBadge.Id);
            newBadge.TrustJediMobile__Min_Points__c = 150;
            newBadge.TrustJediMobile__Max_Points__c = 100;
            update newBadge;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Error: Minimum Points should not be larger then Max Points.'));
            newBadge.TrustJediMobile__Min_Points__c = 100;
        }

        //  The number of trust points cannot be greater than the maximum when populated
        try {
            newBadge = createBadge();
            System.assertNotEquals(null, newBadge.Id);
            newBadge.TrustJediMobile__Trust_Points__c = 150;
            update newBadge;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Error: Points should be less than the Maximum.'));
            newBadge.TrustJediMobile__Trust_Points__c = 100;
        }

        //  The number of trust points cannot be less than the minimum value
        try {
            newBadge = createBadge();
            System.assertNotEquals(null, newBadge.Id);
            newBadge.TrustJediMobile__Trust_Points__c = 50;
            update newBadge;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Error: Points should be greater than the Minimum.'));
            newBadge.TrustJediMobile__Trust_Points__c = 100;
        }
    }

    /*
    *   Process through the Trust Badge update process
    */
    public static testMethod void test_processUpdateTrustBadges () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Create a new Trust Badge to make sure values are populated correctly
        TrustJediMobile__Trust_Badge__c newBadge = createBadge();
        System.assertNotEquals(null, newBadge.Id);
        ID badgeID = newBadge.Id;


        //  The maximum points cannot be smaller than the minimum points field
        try {
            newBadge.TrustJediMobile__Max_Points__c = 50;
            update newBadge;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Error: Minimum Points should not be larger then Max Points.'));
        }

        //  The Trust Points should not be less than minimum points
        try {
            newBadge.TrustJediMobile__Max_Points__c = 100;
            newBadge.TrustJediMobile__Min_Points__c = 100;
            newBadge.TrustJediMobile__Trust_Points__c = 10;
            update newBadge;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Error: Points should be greater than the Minimum.'));
        }

        //  The Trust Points should not be less than minimum points
        try {
            newBadge.TrustJediMobile__Max_Points__c = 100;
            newBadge.TrustJediMobile__Min_Points__c = 100;
            newBadge.TrustJediMobile__Trust_Points__c = 1000;
            update newBadge;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Error: Points should be less than the Maximum.'));
            newBadge.TrustJediMobile__Trust_Points__c = 100;
        }

        //  When saving a record the minimum and maximum fields should be populated with a value.
        try {
            newBadge.TrustJediMobile__Max_Points__c = null;
            newBadge.TrustJediMobile__Min_Points__c = null;
            update newBadge;
        } catch (Exception ex) {
            System.assert(ex.getMessage().contains('Error: Minimum and Maximum values required.'));
        }

        //  Save the badge with the correct information and successfully save the record.
        try {
            newBadge.TrustJediMobile__Max_Points__c = 100;
            newBadge.TrustJediMobile__Min_Points__c = 100;
            update newBadge;
            System.assert(true);
        } catch (Exception ex) {
            System.assert(false);
            System.assertEquals('', ex.getMessage());
        }

        //  Verify that when a user modifies the badge description the render description is populated. If the
        //      field is blank the field should not be shown in the app.

        //  Get the record and verify that the render field is populated correctly
        try {
            newBadge = [SELECT Id, TrustJediMobile__RenderDescription__c FROM TrustJediMobile__Trust_Badge__c WHERE Id = :badgeID];
            System.assertNotEquals(null, newBadge.Id);
            System.assertEquals(true, newBadge.TrustJediMobile__RenderDescription__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }

        //  Get the record and verify that the render field is false when the badge description is blanked out
        try {
            newBadge.TrustJediMobile__Badge_Description_Example__c = '';
            update newBadge;
            newBadge = [SELECT Id, TrustJediMobile__RenderDescription__c FROM TrustJediMobile__Trust_Badge__c WHERE Id = :badgeID];
            System.assertNotEquals(null, newBadge.Id);
            System.assertEquals(false, newBadge.TrustJediMobile__RenderDescription__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }

        //  Get the record and verify that the render field is true again when it is updated with a description again
        try {
            newBadge.TrustJediMobile__Badge_Description_Example__c = 'Badge description will help the user determine if this badge should be awarded to an employee.';
            update newBadge;
            newBadge = [SELECT Id, TrustJediMobile__RenderDescription__c FROM TrustJediMobile__Trust_Badge__c WHERE Id = :badgeID];
            System.assertNotEquals(null, newBadge.Id);
            System.assertEquals(true, newBadge.TrustJediMobile__RenderDescription__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
    }

    /*
    *   Process multiple attachments when added to a parent object that is included in the Trust Jedi application. These
    *       objects are currently a Physical Rewards and Security Alerts.
    */
    public static testMethod void test_multiAttachmentsInsertAndDelete_physicalReward () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Create a physical reward to manage attachments.
        TrustJediMobile__Physical_Reward__c newReward = createPhysicalReward('T-Shirt', LONG_DESC, true);
        ID newRewardID = newReward.Id;

        //  Create a test Attachment to verify that the fields with the URLs are updated as needed.
        StaticResource testAttach = [SELECT Id, Body, ContentType, Description, Name FROM StaticResource WHERE Name = 'TestAttachment' LIMIT 1];

        Attachment attach00 = new Attachment(
            Body = testAttach.Body,
            ContentType = testAttach.ContentType,
            Name = testAttach.Name,
            ParentId = newRewardID
        );

        Attachment attach01 = new Attachment(
            Body = testAttach.Body,
            ContentType = testAttach.ContentType,
            Name = testAttach.Name,
            ParentId = newRewardID
        );
        
        //  Attempt the insert when the record is attached to the Physical reward
        try {
            insert attach00;
            insert attach01;
            System.assertNotEquals(null, attach00.Id);
            System.assertNotEquals(null, attach01.Id);
            newReward = [SELECT Id, TrustJediMobile__RewardImageURL__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :newRewardID];
            System.assertNotEquals(null, newReward.TrustJediMobile__RewardImageURL__c);
        } catch (Exception ex) {
            System.assertEquals(null, attach00.Id);
            System.assertEquals(null, attach01.Id);
            System.debug('Error: ' + ex.getMessage());
        }

        //  Delete one of the attachments and make sure that the URL of the other attachment is included in the URL field
        try {
            delete attach00;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
        
        //  Verify that the second attachment is listed as the image
        newReward = createPhysicalReward('T-Shirt', LONG_DESC, true);
        newReward = [SELECT Id, TrustJediMobile__RewardImageURL__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :newRewardID];
        System.assert(newReward.TrustJediMobile__RewardImageURL__c.contains(attach01.Id));

        //  Delete the second attachment to make sure that the URL field is blanked out
        try {
            delete attach01;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }

        //  Verify that the URL field is blanked out
        newReward = createPhysicalReward('T-Shirt', LONG_DESC, true);
        newReward = [SELECT Id, TrustJediMobile__RewardImageURL__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :newRewardID];
        System.assertEquals(null, newReward.TrustJediMobile__RewardImageURL__c);
    }

    /*
    *   Process new attachments when added to a parent object that is included in the Trust Jedi application. These
    *       objects are currently setup a Physical Rewards and Security Alerts.
    */
    public static testMethod void test_singleAttachmentsInsertAndDelete_physicalReward () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Create a physical reward to manage attachments.
        TrustJediMobile__Physical_Reward__c newReward = createPhysicalReward('T-Shirt', LONG_DESC, true);

        //  Create a test Attachment to verify that the fields with the URLs are updated as needed.
        StaticResource testAttach = [SELECT Id, Body, ContentType, Description, Name FROM StaticResource WHERE Name = 'TestAttachment' LIMIT 1];

        Attachment att = new Attachment(
            Body = testAttach.Body,
            ContentType = testAttach.ContentType,
            Name = testAttach.Name,
            ParentId = newReward.Id
        );

        //  Attempt the insert when the record is attached to the Physical reward
        try {
            insert att;
            System.assertNotEquals(null, att.Id);
            newReward = [SELECT Id, TrustJediMobile__RewardImageURL__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :newReward.Id];
            System.assertNotEquals(null, newReward.TrustJediMobile__RewardImageURL__c);
        } catch (Exception ex) {
            System.assertEquals(null, att.Id);
            System.debug('Error: ' + ex.getMessage());
        }

        //  Make sure that the URL field is blanked out if there is only one attached image
        try {
            delete att;
            newReward = createPhysicalReward('T-Shirt', LONG_DESC, true);
            newReward = [SELECT Id, TrustJediMobile__RewardImageURL__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :newReward.Id];
            System.assertEquals(null, newReward.TrustJediMobile__RewardImageURL__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
    }

    /*
    *   Process multiple attachments when added to a parent object that is included in the Trust Jedi application. These
    *       objects are currently a Physical Rewards and Security Alerts.
    */
    public static testMethod void test_multiAttachmentsInsertAndDelete_securityAlert () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Create a physical reward to manage attachments.
        TrustJediMobile__Security_Alert__c newAlert = createSecurityAlerts();
        ID newAlertID = newAlert.Id;

        //  Create a test Attachment to verify that the fields with the URLs are updated as needed.
        StaticResource testAttach = [SELECT Id, Body, ContentType, Description, Name FROM StaticResource WHERE Name = 'TestAttachment' LIMIT 1];

        Attachment attach00 = new Attachment(
            Body = testAttach.Body,
            ContentType = testAttach.ContentType,
            Name = testAttach.Name,
            ParentId = newAlertID
        );

        Attachment attach01 = new Attachment(
            Body = testAttach.Body,
            ContentType = testAttach.ContentType,
            Name = testAttach.Name,
            ParentId = newAlertID
        );

        //  Attempt the insert when the record is attached to the Security Alert
        try {
            insert attach00;
            insert attach01;
            System.assertNotEquals(null, attach00.Id);
            System.assertNotEquals(null, attach01.Id);
            newAlert = [SELECT Id, TrustJediMobile__AlertImageURL__c FROM TrustJediMobile__Security_Alert__c WHERE Id = :newAlertID];
            System.assertNotEquals(null, newAlert.TrustJediMobile__AlertImageURL__c);
        } catch (Exception ex) {
            System.assertEquals(null, attach00.Id);
            System.assertEquals(null, attach01.Id);
            System.debug('Error: ' + ex.getMessage());
        }

        //  Delete one of the attachments and make sure that the URL of the other attachment is included in the URL field
        try {
            delete attach00;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
        
        //  Verify that the second attachment is listed as the image
        newAlert = new TrustJediMobile__Security_Alert__c();
        newAlert = [SELECT Id, TrustJediMobile__AlertImageURL__c FROM TrustJediMobile__Security_Alert__c WHERE Id = :newAlertID];
        System.assert(newAlert.TrustJediMobile__AlertImageURL__c.contains(attach01.Id));

        //  Delete the second attachment to make sure that the URL field is blanked out
        try {
            delete attach01;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }

        //  Verify that the URL field is blanked out
        newAlert = new TrustJediMobile__Security_Alert__c();
        newAlert = [SELECT Id, TrustJediMobile__AlertImageURL__c FROM TrustJediMobile__Security_Alert__c WHERE Id = :newAlertID];
        System.assertEquals(null, newAlert.TrustJediMobile__AlertImageURL__c);
    }

    /*
    *   Process new attachments when added to a parent object that is included in the Trust Jedi application. These
    *       objects are currently setup a Physical Rewards and Security Alerts.
    */
    public static testMethod void test_singleAttachmentsInsertAndDelete_securityAlert () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Create the Security Alert needed to attach the image
        TrustJediMobile__Security_Alert__c securityAlert = createSecurityAlerts();

        //  Create a test Attachment to verify that the fields with the URLs are updated as needed.
        StaticResource testAttach = [SELECT Id, Body, ContentType, Description, Name FROM StaticResource WHERE Name = 'TestAttachment' LIMIT 1];

        Attachment att = new Attachment(
            Body = testAttach.Body,
            ContentType = testAttach.ContentType,
            Name = testAttach.Name,
            ParentId = securityAlert.Id
        );

        //  Attempt the insert when the record is attached to the Security Alert
        try {
            insert att;
            System.assertNotEquals(null, att.Id);
            securityAlert = [SELECT Id, TrustJediMobile__AlertImageURL__c FROM TrustJediMobile__Security_Alert__c WHERE Id = :securityAlert.Id];
            System.assertNotEquals(null, securityAlert.TrustJediMobile__AlertImageURL__c);
        } catch (Exception ex) {
            System.assertEquals(null, att.Id);
            System.debug('Error: ' + ex.getMessage());
        }

        //  Make sure that the URL field is blanked out if there is only one attached image
        try {
            delete att;
            securityAlert = new TrustJediMobile__Security_Alert__c();
            securityAlert = [SELECT Id, TrustJediMobile__AlertImageURL__c FROM TrustJediMobile__Security_Alert__c WHERE Id = :securityAlert.Id];
            System.assertEquals('', securityAlert.TrustJediMobile__AlertImageURL__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
    }

    /*
    *   Process all of the Physical Rewards. This will happen if a reward is inserted or updated and will shorten
    *       long descriptions to be displayed on the page.
    */
    public static testMethod void test_PhysicalReward_insertAndUpdate () {
        Map<String, TrustJedi_settings__c> existingSettings = TrustJedi_settings__c.getAll();
        List<TrustJedi_settings__c> testSettings = new List<TrustJedi_settings__c>();
        if(!existingSettings.containsKey('defaultUserType')) testSettings.add(new TrustJedi_settings__c(Name = 'defaultUserType', Value__c = 'User'));
        if(!existingSettings.containsKey('featureEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'featureEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('MaxAlertOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxAlertOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('MaxBadgesOnHomePage')) testSettings.add(new TrustJedi_settings__c(Name = 'MaxBadgesOnHomePage', Value__c = '3'));
        if(!existingSettings.containsKey('postChatterIDs')) testSettings.add(new TrustJedi_settings__c(Name = 'postChatterIDs', Value__c = String.valueOf(chatterIDs)));
        if(!existingSettings.containsKey('postToChatterEnabled')) testSettings.add(new TrustJedi_settings__c(Name = 'postToChatterEnabled', Value__c = 'true'));
        if(!existingSettings.containsKey('postToTrustChatterGroup')) testSettings.add(new TrustJedi_settings__c(Name = 'postToTrustChatterGroup', Value__c = 'true'));
        if(!existingSettings.containsKey('UserTypes')) testSettings.add(new TrustJedi_settings__c(Name = 'UserTypes', Value__c = 'Standard'));
        if(testSettings.size() > 0) upsert testSettings;

        //  Populate the physical reward record with current information
        TrustJediMobile__Physical_Reward__c pr = createPhysicalReward('T-Shirt', LONG_DESC, true);
        TrustJediMobile__Physical_Reward__c pr2 = createPhysicalReward('Hoodie', MINI_DESC, true);

        //  Insert the physical reward. If the description is long the system should populate a short description field
        //      with a shortened version of description.
        try {
            insert pr;
            pr = [SELECT Id, TrustJediMobile__Short_Description__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :pr.Id];
            System.assertEquals(SHORT_DESC, pr.TrustJediMobile__Short_Description__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }

        try {
            insert pr2;
            pr2 = [SELECT Id, TrustJediMobile__Short_Description__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :pr2.Id];
            System.assertEquals(MINI_DESC, pr2.TrustJediMobile__Short_Description__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }

        //  Update the physical reward. If the description is long the system should populate a short description field
        //      with a shortened version of description.
        pr.TrustJediMobile__Description__c = LONG_DESC_2;
        try {
            update pr;
            pr = [SELECT Id, TrustJediMobile__Short_Description__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :pr.Id];
            System.assertEquals(SHORT_DESC_2, pr.TrustJediMobile__Short_Description__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }

        //  Update the physical reward. If the description is long the system should populate a short description field
        //      with a shortened version of description.
        pr.TrustJediMobile__Description__c = MINI_DESC;
        try {
            update pr;
            pr = [SELECT Id, TrustJediMobile__Short_Description__c FROM TrustJediMobile__Physical_Reward__c WHERE Id = :pr.Id];
            System.assertEquals(MINI_DESC, pr.TrustJediMobile__Short_Description__c);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
        }
    }

/* ---------------------------------------- End tests and create records below ---------------------------------------- */
    /*
    *   Create security alerts that will be displayed on the user's front page when viewing the Jedi App
    */
    public static TrustJediMobile__Security_Alert__c createSecurityAlerts () {

        TrustJediMobile__Security_Alert__c newAlert = new TrustJediMobile__Security_Alert__c(
            TrustJediMobile__Date_Start__c = Date.today().addDays(-5),
            TrustJediMobile__Date_End__c = Date.today().addDays(5),
            TrustJediMobile__Description__c = 'Test Alert',
            TrustJediMobile__Subject__c = 'Test Subject',
            TrustJediMobile__Type__c = 'Alert',
            TrustJediMobile__AlertImageURL__c = '/img/samples/flag_green.gif'
        );

        try {
            insert newAlert;
            return newAlert;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            return null;
        }
    }

    /*
    *   Create a physical reward record to be used in testing
    */
    public static TrustJediMobile__Physical_Reward__c createPhysicalReward (String type, String description, Boolean visible) {

        TrustJediMobile__Physical_Reward__c newReward = new TrustJediMobile__Physical_Reward__c(
            TrustJediMobile__Description__c = description,
            TrustJediMobile__Type__c = type,
            TrustJediMobile__Visible_to_Non_Trust__c = visible
        );

        try {
            insert newReward;
            return newReward;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            return null;
        }
    }

    /*
    *   Create a test user that will be used in test methods
    */
    public static User createNewUser (String firstName, String lastName) {

        //  Create a new User to have a new Jedi User should be created
        User testUser;
        try {
            String testEmail = String.valueOf(Math.round(Math.random() * 1000000000)) + '@salesforce.com';
            testUser = new User(
                Username = testEmail,
                IsActive = true,
                Email = testEmail,
                LastName = lastName,
                FirstName = firstName,
                Alias = firstName.left(1) + lastName.left(5),
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'ISO-8859-1',
                ProfileId = UserInfo.getProfileId(),
                LanguageLocaleKey = 'en_US',
                ManagerId = UserInfo.getUserId()
            );
            insert testUser;
            System.assertNotEquals(null, testUser.Id);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            System.assert(false);
        }
        return testUser;
    }

    /*
    *   Create a Jedi Level for testing purposes
    */
    public static TrustJediMobile__Jedi_Level__c createJediLevel (Integer pointsRequired) {
        TrustJediMobile__Jedi_Level__c newLevel;
        //  Create a new Jedi Level to be assigned to a new Jedi User record
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
    *   Create a new Trust Badge for testing purposes
    */
    public static TrustJediMobile__Trust_Badge__c createBadge () {

        //  Create a new Trust Badge to make sure values are populated correctly
        TrustJediMobile__Trust_Badge__c newBadge = new TrustJediMobile__Trust_Badge__c(
            TrustJediMobile__Active__c = true,
            TrustJediMobile__Auto_Approve_Allowed__c = true,
            TrustJediMobile__Badge_Description_Example__c = 'An example of what needs to be done.',
            TrustJediMobile__Badge_Image_URL__c = '/img/samples/flag_green.gif',
            TrustJediMobile__Max_Points__c = 100,
            TrustJediMobile__Min_Points__c = 100,
            TrustJediMobile__Trust_Points__c = 100,
            TrustJediMobile__Trust_Use_Only__c = false
        );

        //  This save should go through without issue and then verify the render field is set to false without a description
        try {
            insert newBadge;
            System.assertNotEquals(null, newBadge.Id);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            System.assert(false);
        }
        return newBadge;
    }

    /*
    *   Create a new chatter group that will have the awards displayed so company can see when users get
    *       a new badge approved.
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
}