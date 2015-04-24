/*
	*	This class will pass all of the needed data to the user to display all of the rewards
	*		that could be given to users when they make a specific level.
	*		@dev: creinke
	*/
public without sharing class ChatterPosting {
	//	Type of map item to be displayed to the user
	public ChatterPosting () { }

	public ConnectApi.FeedItemInput createPost(String postText, String subjectId, Map<String, String> postMapping, List<ID> addedGroupIDs) {
		//	The post string should be split up in different segments. If the individual item starts with an @
		//		character then it should be replaced with an @mention segment.
		ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
		List<String> postArray = postText.split(';');

		//  messageBodyInput is method to post @mentions for users or groups
		ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
		messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

		for (String s: postArray) {
			if (s.left(1) == '@') {
				if (postMapping.containsKey(s)) { // Creating @mention items for post
					ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
					mentionSegmentInput.Id = postMapping.get(s);
					messageBodyInput.messageSegments.add(mentionSegmentInput);
					continue;
				}
			} else if (s.left(1) == '_') {
				if (postMapping.containsKey(s)) {
					ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
					textSegmentInput.text = postMapping.get(s);
					messageBodyInput.messageSegments.add(textSegmentInput);
					continue;
				}
			} else {
				ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = s;
				messageBodyInput.messageSegments.add(textSegmentInput);
			}
		}

		if (addedGroupIDs != null && addedGroupIDs.size() > 0) {
			for (ID i: addedGroupIDs) {
				//	Add the public chatter groups to the post. Can be as many as needed.
				ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
				mentionSegmentInput.Id = i;
				messageBodyInput.messageSegments.add(mentionSegmentInput);
				//	Create a space between each of the chatter groups to make it easier to read
				ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
				textSegmentInput.text = ' ';
				messageBodyInput.messageSegments.add(textSegmentInput);
			}
		}

		//	Add the message information to the item and return it to the calling class. The calling class will
		//		create the records.
		feedItemInput.body = messageBodyInput;
		feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
		feedItemInput.subjectId = subjectId;
		return feedItemInput;
	}
}