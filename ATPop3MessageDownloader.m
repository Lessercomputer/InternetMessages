//
//  ATPop3MessageDownloader.m
//  ATMail
//
//  Created by 高田　明史 on 06/09/12.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATPop3MessageDownloader.h"
#import "ATPop3Core.h"
#import "ATInternetMessage.h"
#import "ATMailSpool.h"
#import "ATHeaderField.h"

NSString *ATPop3MessageDownloaderDidFinishDownload = @"ATPop3MessageDownloaderDidFinishDownload";

static unsigned downloaderIDIndex;

@implementation ATPop3MessageDownloader

+ (void)initialize
{
    [self setKeys:[NSArray arrayWithObjects:@"sizeOfCurrentMessage",@"receivedByteCountOfCurrentMessage",nil] triggerChangeNotificationsForDependentKey:@"downloadProgressOfCurrentMessage"];
}

+ (unsigned)newDownloaderID
{
	downloaderIDIndex++;
	return downloaderIDIndex;
}

- (id)initWithMailAccount:(ATMailAccount *)anAccount delegate:(id)aDelegate
{
	[super init];
	
	downloaderID = [[self class] newDownloaderID];
	delegate = aDelegate;
	messageUIDLToBeSkipped = [[anAccount messageUIDLToBeSkipped] copy];
	[self setMailAccount:anAccount];
	core = [[ATPop3Core alloc] initWith:anAccount with:self];
	messages = [NSMutableArray new];
	headerNamesToBeSave = [[ATMailSpool headerNamesToBeSave] copy];
	
	return self;
}

- (void)dealloc
{
	[messageUIDLToBeSkipped release];
	[self setMailAccount:nil];
	[core release];
	[messages release];
	[newMessageUIDL release];
	[UIDLOnServer release];
	[headerNamesToBeSave release];
	
	[super dealloc];
}


- (void)download
{
	[[self core] start];
}

- (void)cancel
{
	NSLog(@"ATPop3MessageDownloader #cancel");
	[[self core] cancel];
	
	[self closeStreams];
	[delegate downloadCanceled:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:ATPop3MessageDownloaderDidFinishDownload object:self];
}

@end

@implementation ATPop3MessageDownloader (Accessing)

- (unsigned)downloaderID
{
	return downloaderID;
}

- (ATMailAccount *)mailAccount
{
	return mailAccount;
}

- (void)setMailAccount:(ATMailAccount *)aMailAccount
{
	[mailAccount release];
	mailAccount = [aMailAccount retain];
}

- (ATInternetMessage *)currentMessage
{
	return [[self messages] lastObject];
}

- (NSArray *)messages
{
	return messages;
}

- (NSArray *)newMessageUIDL
{
	return newMessageUIDL;
}

- (NSArray *)UIDLOnServer
{
	return UIDLOnServer;
}

- (unsigned)countOfNewMessages
{
	return countOfNewMessages;
}

- (void)setCountOfNewMessages:(unsigned)aCount
{
	countOfNewMessages = aCount;
}

- (unsigned)indexOfCurrentMessage
{
	return indexOfCurrentMessage;
}

- (void)setIndexOfCurrentMessage:(unsigned)anIndex
{
	indexOfCurrentMessage = anIndex;
}

- (void)setSubjectOfCurrentMessage:(NSString *)aSubject
{
	[subjectOfCurrentMessage release];
	subjectOfCurrentMessage = [aSubject copy];
}

- (NSString *)subjectOfCurrentMessage
{
	return subjectOfCurrentMessage;
}

- (unsigned)sizeOfCurrentMessage
{
	return sizeOfCurrentMessage;
}

- (void)setSizeOfCurrentMessage:(unsigned)aSize;
{
	sizeOfCurrentMessage = aSize;
}

- (unsigned)receivedByteCountOfCurrentMessage
{
	return receivedByteCountOfCurrentMessage;
}

- (void)setReceivedByteCountOfCurrentMessage:(unsigned)aCount
{
	receivedByteCountOfCurrentMessage = aCount;
}

- (double)downloadProgressOfCurrentMessage
{
	double aProgress = 0;
	
	if ([self sizeOfCurrentMessage] != 0)
		aProgress = (double)[self receivedByteCountOfCurrentMessage] / (double)[self sizeOfCurrentMessage]; 
	
	return aProgress;
}

- (ATPop3Core *)core
{
	return core;
}

@end

@implementation ATPop3MessageDownloader (MessageHandling)

- (void)downloadNextMessage
{
	if (newMessageUIDLIndex < [newMessageUIDL count])
	{
		[self prepareNextMessageAndStreams];
				
		[[self core] prepareRetrFor:[newMessageUIDL objectAtIndex:newMessageUIDLIndex]];
		newMessageUIDLIndex++;
		[self setIndexOfCurrentMessage:newMessageUIDLIndex];
	}
	else
	{
		[[self core] prepareQuit];
		[delegate downloadFinished:self];
		[[NSNotificationCenter defaultCenter] postNotificationName:ATPop3MessageDownloaderDidFinishDownload object:self];
	}
}

- (void)allLinesArrivedIn:(ATHeaderField *)aHeaderField
{
	NSData *aRawData = nil;
	int aReturnValue = 0;
	NSString *aString = nil;
	
	headerFieldBeingBuilt = nil;

	if ([aHeaderField nameIsIncludedIn:headerNamesToBeSave])
	{
		aRawData = [aHeaderField rawData];
		
		aReturnValue = [messageHeaderOutputStream write:[aRawData bytes] maxLength:[aRawData length]];
		
		if (aReturnValue == -1)
		{
			NSString *aString = [[[NSString alloc] initWithData:aRawData encoding:NSASCIIStringEncoding] autorelease];
			NSLog(aString);
		}
	}
	
	if ([aHeaderField nameIs:@"subject"])
		[self setSubjectOfCurrentMessage:[aHeaderField bodyString]];
}

- (void)terminateMessageHeader
{
	NSMutableData *anItemIDFieldData = [[[[messages lastObject] dataWithItemIDField] mutableCopy] autorelease];
	int aReturnValue = 0;
	
	if (headerFieldBeingBuilt)
		[self allLinesArrivedIn:headerFieldBeingBuilt];

	[anItemIDFieldData appendBytes:"\r\n" length:2];
	aReturnValue = [messageHeaderOutputStream write:[anItemIDFieldData bytes] maxLength:[anItemIDFieldData length]];
	
	if (aReturnValue == -1)
	{
		NSLog(@"#terminateFailed");
	}
	
	inHeader = NO;
}

- (void)prepareNextMessageAndStreams
{
	NSOutputStream *aMessageOutputStream, *aHeaderOutputStream;
	ATInternetMessage *aNewMessage;
	
	[delegate downloader:self messageInto:&aNewMessage messageOutputStreamInto:&aMessageOutputStream headerOutputStreamInto:&aHeaderOutputStream];
	
	[messages addObject:aNewMessage];
	[self clearCurrentMessageStatus];
	
	messageOutputStream = [aMessageOutputStream retain];
	[messageOutputStream open];
	messageHeaderOutputStream = [aHeaderOutputStream retain];
	[messageHeaderOutputStream open];
}

- (void)clearCurrentMessageStatus
{
	[self setSizeOfCurrentMessage:0];
	[self setReceivedByteCountOfCurrentMessage:0];
	inHeader = YES;
}

- (void)closeStreams
{
	[messageOutputStream close];
	[messageOutputStream release];
	messageOutputStream = nil;
	[messageHeaderOutputStream close];
	[messageHeaderOutputStream release];
	messageHeaderOutputStream = nil;
}

@end

@implementation ATPop3MessageDownloader (Testing)

- (BOOL)hasNewMessages
{
	return [self countOfNewMessages] ? YES : NO;
}

@end

@implementation ATPop3MessageDownloader (CoreDelegate)

- (void)coreDidDownloadUIDLOnServer:(NSArray *)aUIDLOnServer
{
	newMessageUIDL = [aUIDLOnServer mutableCopy];
	UIDLOnServer = [aUIDLOnServer retain];
	
	if (messageUIDLToBeSkipped)
		[newMessageUIDL removeObjectsInArray:messageUIDLToBeSkipped];
		
	[self setCountOfNewMessages:[newMessageUIDL count]];
	
	[self downloadNextMessage];
}

- (void)coreWillStartToReceiveMessageOfSize:(NSNumber *)aMessageSize
{
	[self setSizeOfCurrentMessage:[aMessageSize unsignedIntValue]];
}

- (void)coreReceiveRetr:(NSArray *)aLines
{
	NSEnumerator *enumerator = [aLines objectEnumerator];
	NSString *aLine = nil;
	
	while (aLine = [enumerator nextObject])
	{
		NSData *aLineData = [aLine length] ? [aLine dataUsingEncoding:NSASCIIStringEncoding] : nil;

		if (aLineData)
			[messageOutputStream write:[aLineData bytes] maxLength:[aLineData length]];
		
		[messageOutputStream write:"\r\n" maxLength:2];

		if (inHeader)
		{	
			if (aLineData)
			{
				headerFieldBeingBuilt = [[self currentMessage] lastHeaderFieldWithoutInterpreting];
				
				[[self currentMessage] addHeaderLine:aLine interpretWhenUnfolded:NO];
				
				if (![ATHeaderField isFolding:aLine] && headerFieldBeingBuilt)
					[self allLinesArrivedIn:headerFieldBeingBuilt];
			}
			else
			{
				[self terminateMessageHeader];
			}
		}
		
		[self setReceivedByteCountOfCurrentMessage:[self receivedByteCountOfCurrentMessage] + [aLine length] + 2];
	}
}

- (void)coreRetrFinished
{
	if (inHeader)
		[self terminateMessageHeader];
	
	[self closeStreams];
	[self downloadNextMessage];
}

@end