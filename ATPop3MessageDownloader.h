//
//  ATPop3MessageDownloader.h
//  ATMail
//
//  Created by 高田　明史 on 06/09/12.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATInternetMessage;
@class ATHeaderField;
@class ATPop3Core;
@class ATMailAccount;

extern NSString *ATPop3MessageDownloaderDidFinishDownload;

@interface ATPop3MessageDownloader : NSObject
{
	unsigned downloaderID;
	ATPop3Core *core;
	ATMailAccount *mailAccount;
	
	NSArray *messageUIDLToBeSkipped;
	NSArray *newMessageUIDL;
	unsigned newMessageUIDLIndex;
	NSArray *UIDLOnServer;
	
	id delegate;
	
	NSMutableArray *messages;
	NSOutputStream *messageOutputStream;
	NSOutputStream *messageHeaderOutputStream;
	
	unsigned countOfNewMessages;
	unsigned indexOfCurrentMessage;
	NSString *subjectOfCurrentMessage;
	unsigned sizeOfCurrentMessage;
	unsigned receivedByteCountOfCurrentMessage;
	
	BOOL inHeader;
	NSSet *headerNamesToBeSave;
	ATHeaderField *headerFieldBeingBuilt;
}

+ (unsigned)newDownloaderID;

- (id)initWithMailAccount:(ATMailAccount *)anAccount delegate:(id)aDelegate;

- (void)download;
- (void)cancel;

@end

@interface ATPop3MessageDownloader (Accessing)

- (unsigned)downloaderID;

- (ATMailAccount *)mailAccount;
- (void)setMailAccount:(ATMailAccount *)aMailAccount;

- (ATInternetMessage *)currentMessage;

- (NSArray *)messages;

- (NSArray *)newMessageUIDL;
- (NSArray *)UIDLOnServer;

- (unsigned)countOfNewMessages;
- (void)setCountOfNewMessages:(unsigned)aCount;

- (unsigned)indexOfCurrentMessage;
- (void)setIndexOfCurrentMessage:(unsigned)anIndex;

- (unsigned)sizeOfCurrentMessage;
- (void)setSizeOfCurrentMessage:(unsigned)aSize;

- (unsigned)receivedByteCountOfCurrentMessage;
- (void)setReceivedByteCountOfCurrentMessage:(unsigned)aCount;

- (double)downloadProgressOfCurrentMessage;

- (ATPop3Core *)core;

@end

@interface ATPop3MessageDownloader (MessageHandling)

- (void)downloadNextMessage;
- (void)allLinesArrivedIn:(ATHeaderField *)aHeaderField;
- (void)terminateMessageHeader;
- (void)prepareNextMessageAndStreams;
- (void)clearCurrentMessageStatus;

@end

@interface ATPop3MessageDownloader (Testing)

- (BOOL)hasNewMessages;

@end

@interface ATPop3MessageDownloader (CoreDelegate)

- (void)coreDidDownloadUIDLOnServer:(NSArray *)aUIDLOnServer;
- (void)coreWillStartToReceiveMessageOfSize:(NSNumber *)aMessageSize;
- (void)coreReceiveRetr:(NSArray *)aLines;
- (void)coreRetrFinished;

@end