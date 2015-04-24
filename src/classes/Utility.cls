/*
$Id$
$Header$
$Date$
$DateTime$
$Change$
$File$
$Revision$
$Author$
*/

/*
    *   This class is a utility class that will be called from several triggers on several
    *       objects. These will update records so that they can be used in the Trust Jedi project. 
    *       @dev: creinke
    */
public with sharing class Utility {
    //  Items being used in this class only
    private final Integer TRIM_VALUE = 75;
    private final String POST_LOCATION = 'Internal';
    private final String APPROVED_STATUS = System.Label.TrustJediMobile_approved;
    private final String USER_TYPE = 'Standard';
    private final String IMAGE_PREFIX = 'image/';
    private Map<String, TrustJedi_settings__c> settings = TrustJedi_settings__c.getAll();
    private List<TrustJediMobile__Jedi_Level__c> jLevels;
    private Boolean trustUser = false;
    private Boolean postToChatterEnabled = false;

    //  Constructor
    public Utility () { }

    /*
    *   This method will process inserts and updates for Badge to User records. If this is an insert
    *       it is referenced from the trigger. If they are updates the method is called from the Update
    *       method within the class. That will filter out any records that are approved.
    */
    public void chatterPost_insert (List<TrustJediMobile__B2JU__c> newBadges) {
        //  Capture the chatter group IDs that need to be populated
        List<String> chatterGroupIDs = new List<String>();
        if (settings.containsKey('postChatterIDs') && !String.isBlank(settings.get('postChatterIDs').Value__c)) {
            chatterGroupIDs = settings.get('postChatterIDs').Value__c.split(';');
        }

        List<TrustJediMobile__B2JU__c> approvedRecords = new List<TrustJediMobile__B2JU__c>();
        List<ID> badgeIDs = new List<ID>();
        List<String> userIDs = new List<String>();

        for (TrustJediMobile__B2JU__c b2ju: newBadges) {
            if (b2ju.TrustJediMobile__Approval_Status__c == APPROVED_STATUS) {
                approvedRecords.add(b2ju);
                badgeIDs.add(b2ju.TrustJediMobile__Trust_Badge__c);
                userIDs.add(b2ju.TrustJediMobile__User_ID__c);
            }
        }

        //  Create a map of Users to capture the Manager's ID
        Map<ID, User> userMap = new Map<ID, User>();
        userMap.putAll([SELECT Id, ManagerId FROM User WHERE Id IN :userIDs]);

        //  create a map of Badges so that the Name of the badge can be displayed in Chatter post
        Map<ID, TrustJediMobile__Trust_Badge__c> badgeMap = new Map<ID, TrustJediMobile__Trust_Badge__c>();
        badgeMap.putAll([SELECT Id, Name FROM TrustJediMobile__Trust_Badge__c WHERE Id IN :badgeIDs]);

        //  Create the chatter posts and use data from the system to mention and notify specific users
        //      or groups
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        for (TrustJediMobile__B2JU__c b2ju: approvedRecords) {
            Map<String, String> postMapping = new Map<String, String>();
            postMapping.put('@recipient', b2ju.TrustJediMobile__User_ID__c);
            postMapping.put('@giver', b2ju.CreatedById);
            postMapping.put('@manager', b2ju.TrustJediMobile__Manager_ID__c);
            postMapping.put('@approver', b2ju.TrustJediMobile__Approving_User__c);
            postMapping.put('_bname', badgeMap.get(b2ju.TrustJediMobile__Trust_Badge__c).Name);
            postMapping.put('_points', String.valueOf(b2ju.TrustJediMobile__Trust_Points__c));

            //  Add the post to a list of posts to be made
            ChatterPosting cp = new ChatterPosting();
            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(cp.createPost(System.Label.BadgeToUser_chatter, b2ju.Id, postMapping, chatterGroupIDs));
            batchInputs.add(batchInput);
        }

        //  If there are posts in the batchInput item then create them in the org.
        if (batchInputs.size() > 0) {
            ConnectApi.BatchResult[] batchResults = ConnectApi.ChatterFeeds.postFeedElementBatch(POST_LOCATION, batchInputs);
            for (ConnectApi.BatchResult br: batchResults) {
                if (!br.isSuccess()) {
                    System.debug(System.Label.TrustJediMobile_errorPrefix + ' ' + br.getErrorMessage());
                }
            }
        }
    }

    /*
    *   This method will process inserts for Badge to User records. Updates to badges will call
    *       the insert method but will filter out any records that are not approved.
    */
    public void chatterPost_update (Map<ID, TrustJediMobile__B2JU__c> oldMap, Map<ID, TrustJediMobile__B2JU__c> newMap) {
        //  If the badge to user record is approved then the system should create a new chatter post.
        List<TrustJediMobile__B2JU__c> approvedRecords = new List<TrustJediMobile__B2JU__c>();
        for (ID i: newMap.keySet()) {
            if (oldMap.get(i).TrustJediMobile__Approval_Status__c != APPROVED_STATUS && newMap.get(i).TrustJediMobile__Approval_Status__c == APPROVED_STATUS) {
                approvedRecords.add(newMap.get(i));
            }
        }

        //  If number of approved records is more than one then go to the Insert process.
        if (approvedRecords.size() > 0) {
            chatterPost_insert(approvedRecords);
        }
    }

    /*
    *   Go through each badge and determine if it needs to be auto-approved, or setup to request approval by
    *       the trust team.
    */
    public void processBadgeToUser_after_insert (List<TrustJediMobile__B2JU__c> newBadges) {
        //  Capture the IDs of all of the users Requesting a Badge be given.
        List<ID> userIDs = new List<ID>();
        List<ID> currentBadgeIDs = new List<ID>();
        for (TrustJediMobile__B2JU__c b: newBadges) {
            userIDs.add(b.TrustJediMobile__Requesting_User__c);
            currentBadgeIDs.add(b.Id);
        } 

        //  Capture all of the Jedi Users that are requesting that a Trust Badge be given to a user.
        Map<ID, Integer> userToMaxPointMap = new Map<ID, Integer>();
        for (TrustJediMobile__Jedi_User__c ju :[SELECT  Id,
                                                        TrustJediMobile__Jedi_Level__c,
                                                        TrustJediMobile__User__c,
                                                        TrustJediMobile__Jedi_Level__r.TrustJediMobile__Max_Points_Given_Limit__c
                                                    FROM TrustJediMobile__Jedi_User__c
                                                    WHERE TrustJediMobile__User__c IN :userIDs]) {
            userToMaxPointMap.put(ju.TrustJediMobile__User__c, Integer.valueOf(ju.TrustJediMobile__Jedi_Level__r.TrustJediMobile__Max_Points_Given_Limit__c));
        }

        //  Determine how many points a user has given in the last 30 days
        Map<ID, TrustJediMobile__B2JU__c> badgeToUserLinkMap = new Map<ID, TrustJediMobile__B2JU__c>();
        badgeToUserLinkMap.putAll([SELECT   Id,
                                            TrustJediMobile__Points_Requested__c,
                                            TrustJediMobile__Points_Granted__c,
                                            TrustJediMobile__Requesting_User__c
                                        FROM TrustJediMobile__B2JU__c
                                        WHERE TrustJediMobile__Requesting_User__c IN :userIDs
                                        AND Id NOT IN :currentBadgeIDs]);

        //  If the users have given out their limit of points then the system will block the approval
        List<Approval.ProcessSubmitRequest> arList = new List<Approval.ProcessSubmitRequest>();
        for (Integer i=0;i<newBadges.size();i++) {
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(newBadges.get(i).Id);
            arList.add(req1);
        }

        try {
            String errString = '';
            Approval.ProcessResult[] result = Approval.process(arList, false);
            // Go through and make sure that there are no errors.
            for (Approval.ProcessResult res: result) if (!res.isSuccess()) errString += res.getErrors();
            if (errString != '') System.debug(System.Label.TrustJediMobile_errorPrefix + ' ' + errString);
        } catch (Exception ex) {
            System.debug(Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
        }

        //  If chatter is enabled for system then generate the chatter posts for each new Badge to User record
        List<TrustJediMobile__B2JU__c> approvedRecords = new List<TrustJediMobile__B2JU__c>();
        for (TrustJediMobile__B2JU__c b2j: newBadges) {
            if (b2j.TrustJediMobile__Approval_Status__c == APPROVED_STATUS) approvedRecords.add(b2j);
        }
    }

    /*
    *   When a new Physical Reward is created the system will create a Short Description that will be used
    *       within the S1 application. In the org it is not displayed. If the Description is longer than 75
    *       characters then the description is shortened, add ..., and put in Short Description field.
    */
    public void processPhysicalRewards_insert (List<TrustJediMobile__Physical_Reward__c> newRewards) {
        for (TrustJediMobile__Physical_Reward__c pr: newRewards) {
            if (pr.TrustJediMobile__Description__c != null && pr.TrustJediMobile__Description__c != '') {
                pr.TrustJediMobile__Short_Description__c = clipString(pr.TrustJediMobile__Description__c);
            } else {
                pr.TrustJediMobile__Short_Description__c = null;
            }
        }
    }   

    /*
    *   When a physical reward is updated the system will populate a short version of the description field.
    *       The first TRIM_VALUE characters will be shown followed by an ellipsis
    */
    public void processPhysicalRewards_update (Map<ID, TrustJediMobile__Physical_Reward__c> oldMap, Map<ID, TrustJediMobile__Physical_Reward__c> newMap) {
        for (ID prId: newMap.keySet()) {
            if (oldMap.get(prId).TrustJediMobile__Description__c != newMap.get(prId).TrustJediMobile__Description__c) {
                String shortDesc = newMap.get(prId).TrustJediMobile__Description__c;
                if (shortDesc.length() > TRIM_VALUE) {
                    newMap.get(prId).TrustJediMobile__Short_Description__c = shortDesc.left(TRIM_VALUE) + Label.TrustJediMobile_ellipsis;
                } else {
                    newMap.get(prId).TrustJediMobile__Short_Description__c = shortDesc;
                }
            }
        }
    }

    /*
    *   Process through deleted attachments. If an attachment was deleted then go through each parent record
    *       to determine if there is another image associated with the parent records.
    */
    public void processAttachment_delete_after (List<Attachment> delAttachments) {
        List<ID> parentIDs = new List<ID>();
        List<ID> alertIDs = new List<ID>();
        List<ID> rewardIDS = new List<ID>();
        for (Attachment a: delAttachments) {
            parentIDs.add(a.ParentId);
            if (a.ParentId.getSObjectType().getDescribe().getName() == 'TrustJediMobile__Security_Alert__c') {
                alertIDs.add(a.ParentId);
            }
            if (a.ParentId.getSObjectType().getDescribe().getName() == 'TrustJediMobile__Physical_Reward__c') {
                rewardIDS.add(a.ParentId);
            }
        }

        //  Get the attachments that are images and associated with the parents of the current deleted attachments
        List<Attachment> allAttachments = [SELECT   Id,
                                                    ParentId,
                                                    ContentType
                                                FROM Attachment
                                                WHERE ParentId IN:parentIDs
                                                AND ContentType LIKE :'image/%'
                                                ORDER BY CreatedDate ASC];

        //  Go through each parent and determine if there are other attachments to these parents
        Map<ID, List<ID>> existingAttachments = new Map<ID, List<ID>>();
        if (allAttachments.size() > 0) {
            for (Attachment a: allAttachments) {
                if (existingAttachments.containsKey(a.ParentId)) {
                    existingAttachments.get(a.ParentId).add(a.Id);
                } else {
                    List<ID> tempList = new List<ID>();
                    tempList.add(a.Id);
                    existingAttachments.put(a.ParentId, tempList);
                }
            }

            //  Update the alerts with new URL
            List<TrustJediMobile__Security_Alert__c> alertList = new List<TrustJediMobile__Security_Alert__c>();
            for (TrustJediMobile__Security_Alert__c sa: [SELECT Id FROM TrustJediMobile__Security_Alert__c WHERE Id IN: existingAttachments.keySet()]) {
                List<ID> attList = existingAttachments.get(sa.Id);
                sa.TrustJediMobile__AlertImageURL__c = Label.TrustJediMobile_imageServletValue + attList[0];
                alertList.add(sa);
            }

            //  Update the rewards with new URL
            List<TrustJediMobile__Physical_Reward__c> rewardList = new List<TrustJediMobile__Physical_Reward__c>();
            for (TrustJediMobile__Physical_Reward__c pr: [SELECT Id FROM TrustJediMobile__Physical_Reward__c WHERE Id IN: existingAttachments.keySet()]) {
                List<ID> rewList = existingAttachments.get(pr.Id);
                pr.TrustJediMobile__RewardImageURL__c = Label.TrustJediMobile_imageServletValue + rewList[0];
                rewardList.add(pr);
            }

            //  Update the Alerts and Rewards with new data
            try {
                update alertList;
                update rewardList;
            } catch (Exception ex) {
                System.debug(Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
            }
        }
    }

    /*
    *   Process through each attachment that is deleted from the system. If the image is deleted then
    *       the related parent record's URL field should be cleared.
    */
    public void processAttachment_delete_before (List<Attachment> delAttachments) {
        List<ID> securityAlertParentIDs = new List<ID>();
        Map<ID, ID> securityAlertAttachToParent = new Map<ID, ID>();

        List<ID> physicalRewardParentIDs = new List<ID>();
        Map<ID, ID> physicalRewardAttachToParent = new Map<ID, ID>();

        List<ID> trustBadgeParentIDs = new List<ID>();
        Map<ID, ID> trustBadgeAttachToParent = new Map<ID, ID>();

        //  Determine which Alert and Rewards need to be updated.
        for (Attachment a: delAttachments) {
            //  If the attachment is an image then clearn image URL to point to nothing.
            if (a.ContentType.contains(IMAGE_PREFIX)) {
                if (a.ParentId.getSObjectType().getDescribe().getName() == 'TrustJediMobile__Security_Alert__c') {
                    securityAlertParentIDs.add(a.ParentId);
                    securityAlertAttachToParent.put(a.ParentId, a.Id);
                }

                if (a.ParentId.getSObjectType().getDescribe().getName() == 'TrustJediMobile__Physical_Reward__c') {
                    physicalRewardParentIDs.add(a.ParentId);
                    securityAlertAttachToParent.put(a.ParentId, a.Id);
                }

                if (a.ParentId.getSObjectType().getDescribe().getName() == 'TrustJediMobile__Trust_Badge__c') {
                    trustBadgeParentIDs.add(a.ParentId);
                    trustBadgeAttachToParent.put(a.ParentId, a.Id);
                }
            }
        }

        //  Process through the Alerts to clear out the URL Field.
        if (securityAlertParentIDs.size() > 0) {
            List<TrustJediMobile__Security_Alert__c> blankedAlerts = new List<TrustJediMobile__Security_Alert__c>();
            for (TrustJediMobile__Security_Alert__c sa: [SELECT Id,
                                                                TrustJediMobile__AlertImageURL__c
                                                            FROM TrustJediMobile__Security_Alert__c
                                                            WHERE Id IN: securityAlertParentIDs]) {

                if (sa.TrustJediMobile__AlertImageURL__c != null &&
                    sa.TrustJediMobile__AlertImageURL__c != '' &&
                    sa.TrustJediMobile__AlertImageURL__c.contains(securityAlertAttachToParent.get(sa.Id))) {
                    sa.TrustJediMobile__AlertImageURL__c = '';
                    blankedAlerts.add(sa);
                } 
            }

            try {
                update blankedAlerts;
            } catch (Exception ex) {
                System.debug(Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
            }
        }

        //  Process through the physical rewards and make sure the image URL is updated as needed
        if (physicalRewardParentIDs.size() > 0) {
            List<TrustJediMobile__Physical_Reward__c> blankedRewards = new List<TrustJediMobile__Physical_Reward__c>();
            for (TrustJediMobile__Physical_Reward__c pr: [SELECT Id,
                                                                TrustJediMobile__RewardImageURL__c
                                                            FROM TrustJediMobile__Physical_Reward__c
                                                            WHERE Id IN: physicalRewardParentIDs]) {

                if (pr.TrustJediMobile__RewardImageURL__c != null &&
                    pr.TrustJediMobile__RewardImageURL__c != '' &&
                    pr.TrustJediMobile__RewardImageURL__c.contains(securityAlertAttachToParent.get(pr.Id))) {
                    pr.TrustJediMobile__RewardImageURL__c = '';
                    blankedRewards.add(pr);
                } 
            }

            try {
                update blankedRewards;
            } catch (Exception ex) {
                System.debug(Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
            }
        }

        //  Process through the trust badges and make sure the image URL is updated as needed
        if (trustBadgeParentIDs.size() > 0) {
            List<TrustJediMobile__Trust_Badge__c> blankedBadges = new List<TrustJediMobile__Trust_Badge__c>();
            for (TrustJediMobile__Trust_Badge__c badge: [SELECT     Id,
                                                                    TrustJediMobile__Badge_Image_URL__c
                                                                FROM TrustJediMobile__Trust_Badge__c
                                                                WHERE Id IN: trustBadgeParentIDs]) {

                //  If the badge has a value in the URL field it should be cleared when the image is attached
                if (badge.TrustJediMobile__Badge_Image_URL__c != null &&
                    badge.TrustJediMobile__Badge_Image_URL__c != '' &&
                    badge.TrustJediMobile__Badge_Image_URL__c.contains(trustBadgeAttachToParent.get(badge.Id))) {
                    badge.TrustJediMobile__Badge_Image_URL__c = '';
                    blankedBadges.add(badge);
                } 
            }

            try {
                update blankedBadges;
            } catch (Exception ex) {
                System.debug(Label.TrustJediMobile_errorPrefix + ' ' + ex.getMessage());
            }
        }
    }

    /*
    *   Whenever an attachment is added to the Notes & Attachments and it is a JPG the code should update
    *       the URL field on the Alert to set the image URL so the picture can be displayed on in the Jedi
    *       mobile application.
    */
    public void processAttachment_insert (List<Attachment> newAttachments) {
        List<ID> securityAlertParentIDs = new List<ID>();
        Map<ID, ID> securityAlertAttachToParent = new Map<ID, ID>();

        List<ID> physicalRewardParentIDs = new List<ID>();
        Map<ID, ID> physicalRewardAttachToParent = new Map<ID, ID>();

        List<ID> trustBadgeParentIDs = new List<ID>();
        Map<ID, ID> trustBadgeAttachToParent = new Map<ID, ID>();

        for (Attachment a: newAttachments) {
            //  If the attachment is an image then update the image URL to point to the new attachment.
            if (a.ContentType.contains(IMAGE_PREFIX)) {
                if (a.ParentId.getSObjectType().getDescribe().getName() == 'TrustJediMobile__Security_Alert__c') {
                    securityAlertParentIDs.add(a.ParentId);
                    securityAlertAttachToParent.put(a.ParentId, a.Id);
                }

                if (a.ParentId.getSObjectType().getDescribe().getName() == 'TrustJediMobile__Physical_Reward__c') {
                    physicalRewardParentIDs.add(a.ParentId);
                    physicalRewardAttachToParent.put(a.ParentId, a.Id);
                }
    
                if (a.ParentId.getSObjectType().getDescribe().getName() == 'TrustJediMobile__Trust_Badge__c') {
                    trustBadgeParentIDs.add(a.ParentId);
                    trustBadgeAttachToParent.put(a.ParentId, a.Id);
                }
            }
        }

        //  query all alerts and update the image URL field.
        if (securityAlertParentIDs.size() > 0) {
            List<TrustJediMobile__Security_Alert__c> alerts = [SELECT   Id,
                                                                        TrustJediMobile__AlertImageURL__c
                                                                    FROM TrustJediMobile__Security_Alert__c
                                                                    WHERE Id IN: securityAlertParentIDs];
            for (TrustJediMobile__Security_Alert__c sa: alerts) {
                if(String.isBlank(sa.TrustJediMobile__AlertImageURL__c))
                    sa.TrustJediMobile__AlertImageURL__c = Label.TrustJediMobile_imageServletValue + securityAlertAttachToParent.get(sa.Id);
            }
            update alerts;
        }

        //  query all alerts and update the image URL field.
        if (physicalRewardParentIDs.size() > 0) {
            List<TrustJediMobile__Physical_Reward__c> rewards = [SELECT     Id,
                                                                            TrustJediMobile__RewardImageURL__c
                                                                        FROM TrustJediMobile__Physical_Reward__c
                                                                        WHERE Id IN: physicalRewardParentIDs];
            for (TrustJediMobile__Physical_Reward__c pr: rewards) {
                if(String.isBlank(pr.TrustJediMobile__RewardImageURL__c))
                    pr.TrustJediMobile__RewardImageURL__c = Label.TrustJediMobile_imageServletValue + physicalRewardAttachToParent.get(pr.Id);
            }
            update rewards;
        }

        //  query all alerts and update the image URL field.
        if (trustBadgeParentIDs.size() > 0) {
            List<TrustJediMobile__Trust_Badge__c> badges = [SELECT  Id,
                                                                    TrustJediMobile__Badge_Image_URL__c
                                                                FROM TrustJediMobile__Trust_Badge__c
                                                                WHERE Id IN: trustBadgeParentIDs];
            for (TrustJediMobile__Trust_Badge__c pr: badges) {
                if(String.isBlank(pr.TrustJediMobile__Badge_Image_URL__c))
                    pr.TrustJediMobile__Badge_Image_URL__c = Label.TrustJediMobile_imageServletValue + trustBadgeAttachToParent.get(pr.Id);
            }
            update badges;
        }
    }

    /*
    *   When new trust badges are created then they need to have the checkbox populated that
    *       determines if the description is going to be displayed to the users.
    */
    public void processTrustBadge_insert (List<TrustJediMobile__Trust_Badge__c> newList) {
        for (TrustJediMobile__Trust_Badge__c tb: newList) {
            if (String.isBlank(tb.TrustJediMobile__Badge_Description_Example__c)) {
                tb.TrustJediMobile__RenderDescription__c = false;
            } else tb.TrustJediMobile__RenderDescription__c = true;

            //  Trust points must be greater than zero to be modified
            if (tb.TrustJediMobile__Trust_Points__c <= 0) {
                tb.TrustJediMobile__Trust_Points__c.addError(System.Label.Error_pointsLessThanZero);
            }

            //  Validate that the Min Points, Max Points, and Trust Points are valid
            if (tb.TrustJediMobile__Max_Points__c == null && tb.TrustJediMobile__Min_Points__c == null && tb.TrustJediMobile__Trust_Points__c > 0) {
                tb.TrustJediMobile__Max_Points__c = tb.TrustJediMobile__Trust_Points__c;
                tb.TrustJediMobile__Min_Points__c = tb.TrustJediMobile__Trust_Points__c;
            } else {
                if (tb.TrustJediMobile__Max_Points__c == null|| tb.TrustJediMobile__Min_Points__c == null) {
                    tb.addError(System.Label.Error_minMaxRequired);
                } else if (tb.TrustJediMobile__Min_Points__c > tb.TrustJediMobile__Max_Points__c) {
                    tb.addError(System.Label.Error_minPointsHigherThanMax);
                } else if (tb.TrustJediMobile__Min_Points__c > tb.TrustJediMobile__Trust_Points__c) {
                    tb.addError(System.Label.Error_pointsLessThanMin);
                } else if (tb.TrustJediMobile__Trust_Points__c > tb.TrustJediMobile__Max_Points__c) {
                    tb.addError(System.Label.Error_pointsMoreThanMax);
                }
            }
        }
    }

    /*
    *   When new trust badges are updated then they need to have the checkbox populated that
    *       determines if the description is going to be displayed to the users.
    */
    public void processTrustBadge_update (Map<ID, TrustJediMobile__Trust_Badge__c> oldMap, Map<ID, TrustJediMobile__Trust_Badge__c> newMap) {
        for (ID i: newMap.keySet()) {
            if (oldMap.get(i).TrustJediMobile__Badge_Description_Example__c != newMap.get(i).TrustJediMobile__Badge_Description_Example__c) {
                if (String.isBlank(newMap.get(i).TrustJediMobile__Badge_Description_Example__c)) {
                    newMap.get(i).TrustJediMobile__RenderDescription__c = false;
                } else newMap.get(i).TrustJediMobile__RenderDescription__c = true;
            }

            //  Trust points must be greater than zero to be modified
            if (newMap.get(i).TrustJediMobile__Trust_Points__c <= 0) {
                newMap.get(i).TrustJediMobile__Trust_Points__c.addError(System.Label.Error_pointsLessThanZero);
            }

            //  Validate that the Min Points, Max Points, and Trust Points are valid
            if (newMap.get(i).TrustJediMobile__Max_Points__c == null && newMap.get(i).TrustJediMobile__Min_Points__c == null &&
                newMap.get(i).TrustJediMobile__Trust_Points__c > 0) {
                    newMap.get(i).TrustJediMobile__Max_Points__c = newMap.get(i).TrustJediMobile__Trust_Points__c;
                    newMap.get(i).TrustJediMobile__Min_Points__c = newMap.get(i).TrustJediMobile__Trust_Points__c;
            } if (newMap.get(i).TrustJediMobile__Max_Points__c == null|| newMap.get(i).TrustJediMobile__Min_Points__c == null) {
                newMap.get(i).addError(System.Label.Error_minMaxRequired);
            } else if (newMap.get(i).TrustJediMobile__Min_Points__c > newMap.get(i).TrustJediMobile__Max_Points__c) {
                newMap.get(i).addError(System.Label.Error_minPointsHigherThanMax);
            } else if (newMap.get(i).TrustJediMobile__Min_Points__c > newMap.get(i).TrustJediMobile__Trust_Points__c) {
                newMap.get(i).addError(System.Label.Error_pointsLessThanMin);
            } else if (newMap.get(i).TrustJediMobile__Trust_Points__c > newMap.get(i).TrustJediMobile__Max_Points__c) {
                newMap.get(i).addError(System.Label.Error_pointsMoreThanMax);
            }
        }
    }

    /*
    *   The jedi level needs to have the two checkboxes populated that determine if the what you can do and
    *       reward fields are shown in the s1 app.
    */
    public void processJediLevel_insert (List<TrustJediMobile__Jedi_Level__c> newList) {
        //  What You Can Do to get more points
        for (TrustJediMobile__Jedi_Level__c jl: newList) {
            if (String.isBlank(jl.TrustJediMobile__WhatYouCanDo__c)) {
                jl.TrustJediMobile__RenderWYCD__c = false;
            } else jl.TrustJediMobile__RenderWYCD__c = true;
            //  Is there an image attached?
            if (jl.TrustJediMobile__Image_URL__c == null) {
                jl.TrustJediMobile__RenderImage__c = false;
            } else jl.TrustJediMobile__RenderImage__c = true;
        }
    }

    /*
    *   The jedi level needs to have the two checkboxes populated that determine if the what you can do and
    *       reward fields are shown in the s1 app.
    */
    public void processJediLevel_update (Map<ID, TrustJediMobile__Jedi_Level__c> oldMap, Map<ID, TrustJediMobile__Jedi_Level__c> newMap) {
        //  What You Can Do to get more points
        for (ID i: newMap.keySet()) {
            if (newMap.get(i).TrustJediMobile__WhatYouCanDo__c != oldMap.get(i).TrustJediMobile__WhatYouCanDo__c) {
                if (String.isBlank(newMap.get(i).TrustJediMobile__WhatYouCanDo__c)) {
                    newMap.get(i).TrustJediMobile__RenderWYCD__c = false;
                } else newMap.get(i).TrustJediMobile__RenderWYCD__c = true;
            }

            //  Is there an image associated with this jedi level?
            if (oldMap.get(i).TrustJediMobile__Image_URL__c != newMap.get(i).TrustJediMobile__Image_URL__c) {
                if (newMap.get(i).TrustJediMobile__Image_URL__c == null) {
                    newMap.get(i).TrustJediMobile__RenderImage__c = false;
                } else newMap.get(i).TrustJediMobile__RenderImage__c = true;
            }
        }
    }

    /*
    *   Review the security alerts and populate the short subject and description if they are populated.
    */
    public void processSecurityAlerts_insert (List<TrustJediMobile__Security_Alert__c> alerts) {
        for (TrustJediMobile__Security_Alert__c sa: alerts) {
            //  Subject
            if (sa.TrustJediMobile__Subject__c != '' && sa.TrustJediMobile__Subject__c.length() > TRIM_VALUE) {
                sa.TrustJediMobile__Short_Subject__c = sa.TrustJediMobile__Subject__c.subString(0, TRIM_VALUE).trim() + Label.TrustJediMobile_ellipsis;
            } else sa.TrustJediMobile__Short_Subject__c = sa.TrustJediMobile__Subject__c;
        
            //  Description
            if (sa.TrustJediMobile__Description__c != '' && sa.TrustJediMobile__Description__c.length() > TRIM_VALUE) {
                sa.TrustJediMobile__Short_Description__c = sa.TrustJediMobile__Description__c.subString(0, TRIM_VALUE).trim() + Label.TrustJediMobile_ellipsis;
            } else sa.TrustJediMobile__Short_Description__c =  sa.TrustJediMobile__Description__c;
        }
    }

    /*
    *   Review the security alerts and populate the short subject and description if they are populated.
    */
    public void processSecurityAlerts_update (Map<ID, TrustJediMobile__Security_Alert__c> oldMap, Map<ID, TrustJediMobile__Security_Alert__c> newMap) {
        for (ID i: newMap.keySet()) {
            //  Subject
            if (oldMap.get(i).TrustJediMobile__Subject__c != newMap.get(i).TrustJediMobile__Subject__c) {
                if (newMap.get(i).TrustJediMobile__Subject__c.length() > TRIM_VALUE) {
                    newMap.get(i).TrustJediMobile__Short_Subject__c = newMap.get(i).TrustJediMobile__Subject__c.subString(0, TRIM_VALUE).trim() + Label.TrustJediMobile_ellipsis;
                } else newMap.get(i).TrustJediMobile__Short_Subject__c = newMap.get(i).TrustJediMobile__Subject__c;
            }

            //  Description
            if (oldMap.get(i).TrustJediMobile__Description__c != newMap.get(i).TrustJediMobile__Description__c) {
                if (newMap.get(i).TrustJediMobile__Description__c.length() > TRIM_VALUE ) {
                    newMap.get(i).TrustJediMobile__Short_Description__c = newMap.get(i).TrustJediMobile__Description__c.subString(0, TRIM_VALUE).trim() + Label.TrustJediMobile_ellipsis;
                } else newMap.get(i).TrustJediMobile__Short_Description__c = newMap.get(i).TrustJediMobile__Description__c;
            }
        }
    }





    /*
    *   Go through all of the Badge to User records and make sure that the data is populated correctly.
    */
    public void processBadgeToUser_insert (List<TrustJediMobile__B2JU__c> badges) {
        List<ID> badgeIDs = new List<ID>();
        List<ID> userIDs = new List<ID>();

        for (TrustJediMobile__B2JU__c b: badges) {
            //  Populate the short description with the information from the description field. If it is '' or null
            //      then nothing will be changed.
            if (!String.isBlank(b.TrustJediMobile__Description__c)) {
                if (b.TrustJediMobile__Description__c.length() > TRIM_VALUE) {
                    b.TrustJediMobile__Short_Description__c = b.TrustJediMobile__Description__c.substring(0, TRIM_VALUE) + Label.TrustJediMobile_ellipsis;
                } else {
                    b.TrustJediMobile__Short_Description__c = b.TrustJediMobile__Description__c;
                }
            } else {
                b.TrustJediMobile__Description__c.addError(Label.TrustJediMobile_descWhyBadge);
            }

            //  Add the values from the jedi user and trust badge are populated correctly.
            if (!String.isBlank(b.TrustJediMobile__Jedi_User__c)) {
                badgeIDs.add(b.TrustJediMobile__Trust_Badge__c);
                userIDs.add(b.TrustJediMobile__Jedi_User__c);
            } else {
                if (b.TrustJediMobile__Jedi_User__c == null) b.TrustJediMobile__Jedi_User__c.addError(Label.TrustJediMobile_errorRequired);
                if (b.TrustJediMobile__Trust_Badge__c == null) b.TrustJediMobile__Trust_Badge__c.addError(Label.TrustJediMobile_errorRequired);
            }
        }

        //  Get all of the users and badges to be used next
        Map<ID, TrustJediMobile__Trust_Badge__c> badgeMap = new Map<ID, TrustJediMobile__Trust_Badge__c>([SELECT    Id,
                                                                                                                    Name,
                                                                                                                    TrustJediMobile__Active__c,
                                                                                                                    TrustJediMobile__Trust_Points__c,
                                                                                                                    TrustJediMobile__Auto_Approve_Allowed__c,
                                                                                                                    TrustJediMobile__Trust_Use_Only__c
                                                                                                                FROM TrustJediMobile__Trust_Badge__c
                                                                                                                WHERE Id IN: badgeIDs
                                                                                                                AND TrustJediMobile__Active__c = :true]);

        Map<ID, TrustJediMobile__Jedi_User__c> userMap = new Map<ID, TrustJediMobile__Jedi_User__c>([SELECT Id,
                                                                                                            Name,
                                                                                                            TrustJediMobile__User_Type__c,
                                                                                                            TrustJediMobile__User__c,
                                                                                                            TrustJediMobile__Jedi_Level__c,
                                                                                                            TrustJediMobile__Jedi_Level__r.Name,
                                                                                                            TrustJediMobile__Jedi_Level__r.TrustJediMobile__Max_Points_Given_Limit__c
                                                                                                        FROM TrustJediMobile__Jedi_User__c
                                                                                                        WHERE Id IN: userIDs
                                                                                                        OR TrustJediMobile__User__c = :UserInfo.getUserId()]);

        //  Get Jedi User record for current user
        TrustJediMobile__Jedi_User__c thisJediUser;
        for (ID i: userMap.keySet()) {
            if (userMap.get(i).TrustJediMobile__User__c == UserInfo.getUserId()) thisJediUser = userMap.get(i);
        }

        for (TrustJediMobile__B2JU__c b: badges) {
            if (!String.isBlank(b.TrustJediMobile__Jedi_User__c) && !String.isBlank(b.TrustJediMobile__Trust_Badge__c)) {
                b.Name = b.TrustJediMobile__Trust_Badge__c + ': ' + b.TrustJediMobile__Jedi_User__c;
            } else {
                if (String.isBlank(b.TrustJediMobile__Jedi_User__c)) b.TrustJediMobile__Jedi_User__c.addError('Required Field.');
                if (String.isBlank(b.TrustJediMobile__Trust_Badge__c)) b.TrustJediMobile__Trust_Badge__c.addError('Required Field.');
            }
        }

        //  Populate the points for the badges based on the Badge that the user has chosen
        for (TrustJediMobile__B2JU__c b: badges) {
            if (b.TrustJediMobile__Jedi_User__c != null && b.TrustJediMobile__Trust_Badge__c != null) {
               // b.TrustJediMobile__Points_Requested__c = badgeMap.get(b.TrustJediMobile__Trust_Badge__c).TrustJediMobile__Trust_Points__c;
                b.TrustJediMobile__Trust_Points__c = badgeMap.get(b.TrustJediMobile__Trust_Badge__c).TrustJediMobile__Trust_Points__c;
                b.TrustJediMobile__Points_Granted__c = badgeMap.get(b.TrustJediMobile__Trust_Badge__c).TrustJediMobile__Trust_Points__c;
                b.TrustJediMobile__Date_Requested__c = Date.today();

                //  Populate the records if the status is approved.
                if (b.TrustJediMobile__Approval_Status__c == Label.TrustJediMobile_approved) {
                    b.TrustJediMobile__Approving_User__c = UserInfo.getUserId();
                    b.TrustJediMobile__Date_Rewarded__c = Date.today();
                }
            }

            //  If a badge is created by a Trust User then they can assign the Requesting User to anyone they choose.
            if (b.TrustJediMobile__Requesting_User__c == null) b.TrustJediMobile__Requesting_User__c = UserInfo.getUserId();
        }

        //  Determine if auto-approve is allowed for badges
        Date last30Days = Date.today().addDays(-30);
        Integer pointsLast30Days = 0;
        for (TrustJediMobile__B2JU__c b2u: [SELECT  Id,
                                                    CreatedById,
                                                    CreatedDate,
                                                    TrustJediMobile__Trust_Points__c,
                                                    TrustJediMobile__Trust_Badge__c,
                                                    TrustJediMobile__Trust_Badge__r.Name,
                                                    TrustJediMobile__Trust_Badge__r.TrustJediMobile__Auto_Approve_Allowed__c
                                                FROM TrustJediMobile__B2JU__c
                                                WHERE CreatedById = :UserInfo.getUserId()]) {
            if (b2u.TrustJediMobile__Trust_Points__c != null) {
                pointsLast30Days = (pointsLast30Days + Integer.valueOf(b2u.TrustJediMobile__Trust_Points__c));
            }
        }

        if (thisJediUser.TrustJediMobile__User_Type__c == 'Admin') {
            for (TrustJediMobile__B2JU__c b2u: badges) {
                b2u.TrustJediMobile__AutoApproveAllowed__c = true;
            }
        } else {
            for (TrustJediMobile__B2JU__c b2u: badges) {
                if (b2u.TrustJediMobile__Jedi_User__c != thisJediUser.TrustJediMobile__User__c &&
                    badgeMap.get(b2u.TrustJediMobile__Trust_Badge__c).TrustJediMobile__Auto_Approve_Allowed__c &&
                    b2u.TrustJediMobile__Points_Requested__c + pointsLast30Days < Integer.valueOf(thisJediUser.TrustJediMobile__Jedi_Level__r.TrustJediMobile__Max_Points_Given_Limit__c)) {
                    b2u.TrustJediMobile__AutoApproveAllowed__c = true;
                    pointsLast30Days += Integer.valueOf(b2u.TrustJediMobile__Points_Requested__c);
                }
            }
        }
    }

    /*
    *   Go through all of the badge to user records and make sure that the values are set correctly.
    */
    public void processBadgeToUser_update (Map<ID, TrustJediMobile__B2JU__c> oldMap, Map<ID, TrustJediMobile__B2JU__c> newMap) {
        List<ID> badgeIDs = new List<ID>();
        List<ID> userIDs = new List<ID>();

        //  Go through each of the badges one at a time
        for (ID i: newMap.keySet()) {

            //  Go through the description and set the value of the Short description value based on it
            //      As long as field is not null then value in short needs to be updated
            if (oldMap.get(i).TrustJediMobile__Description__c != newMap.get(i).TrustJediMobile__Description__c ) {
                if (!String.isBlank(newMap.get(i).TrustJediMobile__Description__c)) {
                    newMap.get(i).TrustJediMobile__Short_Description__c = clipString(newMap.get(i).TrustJediMobile__Description__c);
                } else {
                    newMap.get(i).TrustJediMobile__Short_Description__c = null;
                    newMap.get(i).TrustJediMobile__Description__c.addError(Label.TrustJediMobile_descWhyBadge);
                }
            }

            //  Create a list of all of the badges and users that are associated with these records
            if (newMap.get(i).TrustJediMobile__Jedi_User__c != null && newMap.get(i).TrustJediMobile__Trust_Badge__c != null) {
                badgeIDs.add(newMap.get(i).TrustJediMobile__Trust_Badge__c);
                userIDs.add(newMap.get(i).TrustJediMobile__Jedi_User__c);
            } 

            //  If requesting user is not chosen then requester will be the user that created the badge request
            if (newMap.get(i).TrustJediMobile__Requesting_User__c == null) newMap.get(i).TrustJediMobile__Requesting_User__c = newMap.get(i).CreatedById;

            //  If the badge is approved during an update then the approver and approver date need to be populated
            if (oldMap.get(i).TrustJediMobile__Approval_Status__c != Label.TrustJediMobile_approved && newMap.get(i).TrustJediMobile__Approval_Status__c == Label.TrustJediMobile_approved) {
                newMap.get(i).TrustJediMobile__Approving_User__c = UserInfo.getUserId();
                newMap.get(i).TrustJediMobile__Date_Rewarded__c = Date.today();
            }

            //  If the badge has the approved removed then set value to not approved and the other fields set to null
            if (newMap.get(i).TrustJediMobile__Approval_Status__c != Label.TrustJediMobile_approved) {
                newMap.get(i).TrustJediMobile__Approving_User__c = null;
                newMap.get(i).TrustJediMobile__Date_Rewarded__c = null;
            }
        }

        //  Capture the badges and jedi users that are associated with these user to badge records
        Map<ID, TrustJediMobile__Trust_Badge__c> thisBadgeMap = new Map<ID, TrustJediMobile__Trust_Badge__c>(
            [SELECT Id,
                    Name,
                    TrustJediMobile__Trust_Points__c
                FROM TrustJediMobile__Trust_Badge__c
                WHERE Id IN: badgeIDs
                AND TrustJediMobile__Active__c = :true]
        );
        Map<ID, TrustJediMobile__Jedi_User__c> thisUserMap = new Map<ID, TrustJediMobile__Jedi_User__c>(
            [SELECT Id,
                    Name
                FROM TrustJediMobile__Jedi_User__c
                WHERE Id IN: userIDs]
        );

        //  Go through each of the badges and make sure that the badges have the trust badge record information
        for (ID i: newMap.keySet()) {
            if (!String.isBlank(newMap.get(i).TrustJediMobile__Jedi_User__c) && !String.isBlank(newMap.get(i).TrustJediMobile__Trust_Badge__c)) {
                newMap.get(i).Name = thisBadgeMap.get(newMap.get(i).TrustJediMobile__Trust_Badge__c).Name + ': ' + thisUserMap.get(newMap.get(i).TrustJediMobile__Jedi_User__c).Name;
                if (newMap.get(i).TrustJediMobile__Points_Requested__c == null)
                    newMap.get(i).TrustJediMobile__Points_Requested__c = thisBadgeMap.get(newMap.get(i).TrustJediMobile__Trust_Badge__c).TrustJediMobile__Trust_Points__c;
                if (newMap.get(i).TrustJediMobile__Trust_Points__c == null)
                    newMap.get(i).TrustJediMobile__Trust_Points__c = thisBadgeMap.get(newMap.get(i).TrustJediMobile__Trust_Badge__c).TrustJediMobile__Trust_Points__c;
                if (newMap.get(i).TrustJediMobile__Points_Granted__c == null)
                    newMap.get(i).TrustJediMobile__Points_Granted__c = thisBadgeMap.get(newMap.get(i).TrustJediMobile__Trust_Badge__c).TrustJediMobile__Trust_Points__c;
            }
        }
    }

    /*
    *   Update all of the users after the badges have been processed. This will make sure the users are allways
    *       up to date in the standard UI and in S1
    */
    public void processJediUser_insert (List<TrustJediMobile__Jedi_User__c> newRecords) {
        List<TrustJediMobile__Jedi_Level__c> jlList = [SELECT   Id,
                                                                TrustJediMobile__Points_Required__c
                                                            FROM TrustJediMobile__Jedi_Level__c
                                                            ORDER BY TrustJediMobile__Points_Required__c ASC];

        if (jlList.size() > 0) {
            for (TrustJediMobile__Jedi_User__c ju: newRecords) {
                ju.TrustJediMobile__Jedi_Level__c = jlList.get(0).Id;
            }
        } else {
            for (TrustJediMobile__Jedi_User__c ju: newRecords) {
                ju.TrustJediMobile__Jedi_Level__c.addError(Label.TrustJediMobile_errorPrefix + ' No Jedi Levels Found.');
            }
        }
    }

    /*
    *   Update all of the users after the badges have been processed. This will make sure the users are allways
    *       up to date in the standard UI and in S1
    */
    public void processJediUser_update (List<TrustJediMobile__Jedi_User__c> changedRecords) {
        //  Go through each of the users that were modified and make sure that the Jedi Level is set correctly
        List<TrustJediMobile__Jedi_Level__c> jlList = [SELECT   Id,
                                                                TrustJediMobile__Points_Required__c
                                                            FROM TrustJediMobile__Jedi_Level__c
                                                            ORDER BY TrustJediMobile__Points_Required__c ASC];
        for (TrustJediMobile__Jedi_User__c ju: changedRecords) {
            for (TrustJediMobile__Jedi_Level__c jl: jlList) {
                if (ju.TrustJediMobile__Points__c >= jl.TrustJediMobile__Points_Required__c) ju.TrustJediMobile__Jedi_Level__c = jl.Id;
            }
        }
    }

    /*
    *   This method will update the short resolution and the resolution date to be displayed in
    *       the S1 app for new Trust Issue records.
    */
    public void updateTrustIssue_insert (List<TrustJediMobile__Trust_Issue__c> trustIssues) {
        for (TrustJediMobile__Trust_Issue__c ti: trustIssues) {
            ti.TrustJediMobile__Short_Description__c = clipString(ti.TrustJediMobile__Description__c);
            ti.TrustJediMobile__Short_Subject__c = clipString(ti.TrustJediMobile__Subject__c);
            ti.submittedDate__c = Date.today().format();
        }
    }

    /*
    *   Trim any value that is greater or equal to the trim value with a shortened version.
    */
    private String clipString (String longValue) {
        if (longValue.length() <= TRIM_VALUE || String.isBlank(longValue))
            return longValue;
        else
            return longValue.subString(0, TRIM_VALUE) + Label.TrustJediMobile_ellipsis;
    }

    /*
    *   This method will update the short resolution and the resolution date to be displayed in
    *       the S1 app for existing Trust Issue records.
    */
    public void updateTrustIssue_ti_update (Map<ID, TrustJediMobile__Trust_Issue__c> oldMap, Map<ID, TrustJediMobile__Trust_Issue__c> newMap) {
        for (ID i: newMap.keySet()) {
            newMap.get(i).TrustJediMobile__Short_Description__c = clipString(newMap.get(i).TrustJediMobile__Description__c);
            newMap.get(i).TrustJediMobile__Short_Subject__c = clipString(newMap.get(i).TrustJediMobile__Subject__c);
        }
    }
}