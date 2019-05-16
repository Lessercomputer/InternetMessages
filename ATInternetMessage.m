//
//  ATInternetMessage.m
//  ATMail
//
//  Created by 高田　明史 on 06/02/22.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATInternetMessage.h"
#import "ATMultipartBody.h"
#import "ATBodyTextRepresentation.h"
#import "ATInternetMessageLineScanner.h"
#import "ATHeaderField.h"
#import "ATFieldBody.h"
#import "ATMailSpool.h"
#import "ATMsgID.h"

@implementation ATInternetMessage

@end

@implementation ATInternetMessage (Initializing)

+ (id)messageWithItemID:(unsigned)anItemID afterImportingMessageFrom:(NSString *)aSourcePath to:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderStream
{
	return [[[self alloc] initWithItemID:anItemID afterImportingMessageFrom:aSourcePath to:aMailSpool headerOutputStream:aHeaderStream] autorelease];
}

+ (id)messageFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner onlyHeader:(BOOL)anOnlyHeaderFlag
{
	return [[[self alloc] initFromLineScanner:aLineScanner onlyHeader:anOnlyHeaderFlag] autorelease];
}

+ (id)messageFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner onlyHeader:(BOOL)anOnlyHeaderFlag fieldNamesToBeInterpreted:(NSSet *)aFieldNamesToBeInterpreted;
{
	return [[[self alloc] initFromLineScanner:aLineScanner onlyHeader:anOnlyHeaderFlag fieldNamesToBeInterpreted:aFieldNamesToBeInterpreted] autorelease];
}

- (id)init
{
	return [self initWithItemID:NSNotFound];
}

- (id)initWithItemID:(unsigned)anItemID
{
	[super init];
	
	[self setItemID:anItemID];
		
	return self;
}

- (id)initWithItemID:(unsigned)anItemID afterImportingMessageFrom:(NSString *)aSourcePath to:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream
{	
	[self initWithItemID:anItemID];

	if ([self importMessageFromFile:aSourcePath to:aMailSpool headerOutputStream:aHeaderOutputStream])
		return self;
	else
	{
		[self release];
		
		return nil;
	}
}

- (id)initFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner onlyHeader:(BOOL)anOnlyHeaderFlag
{
	return [self initFromLineScanner:aLineScanner onlyHeader:anOnlyHeaderFlag fieldNamesToBeInterpreted:nil];
}

- (id)initFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner onlyHeader:(BOOL)anOnlyHeaderFlag fieldNamesToBeInterpreted:(NSSet *)aFieldNamesToBeInterpreted
{
	[self init];
	
	[self readHeaderFromLineScanner:aLineScanner fieldNamesToBeInterpreted:aFieldNamesToBeInterpreted];
	
	return self;
}

- (void)dealloc
{
	[self setMailSpool:nil];
	[self setParent:nil];
	[self setParentMessage:nil];
	[self setReturnMessages:nil];
	
	[super dealloc];
}

@end

@implementation ATInternetMessage (Importing)

- (BOOL)importMessageFromFile:(NSString *)aSourcePath to:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream
{
	NSString *aMessageDestinationPath = [aMailSpool temporaryMessageFilePathFor:self];
	
	if ([[NSFileManager defaultManager] copyPath:aSourcePath toPath:aMessageDestinationPath handler:nil])
	{
		ATInternetMessageLineScanner *aLineScanner = [ATInternetMessageLineScanner scannerWithFileContentsOfFile:aMessageDestinationPath];

		[self importMessageHeaderFromLineScanner:aLineScanner to:aMailSpool headerOutputStream:aHeaderOutputStream];
				
		return YES;
	}

	return NO;
}

- (void)importMessageHeaderFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner to:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream
{
	NSSet *aHeaderNamesToBeSave = [[aMailSpool class] headerNamesToBeSave];
	NSData *aLineData = nil;
	NSMutableData *anItemIDFieldData = [[[self dataWithItemIDField] mutableCopy] autorelease];
	
	while ((aLineData = [aLineScanner scanUnfoldedLine]) && [aLineData length])
	{
		ATHeaderField *aHeaderField = [[[ATHeaderField alloc] initWithLineData:aLineData interpret:NO] autorelease];
		
		if ([aHeaderField nameIsIncludedIn:aHeaderNamesToBeSave])
		{
			NSData *aRawData = [aHeaderField rawData];
			
			[aHeaderOutputStream write:[aRawData bytes] maxLength:[aRawData length]];
			[self addHeader:aHeaderField];
		}
		
		[aLineScanner skipNextCRLF];
	}
		
	[anItemIDFieldData appendBytes:"\r\n" length:2];
	[aHeaderOutputStream write:[anItemIDFieldData bytes] maxLength:[anItemIDFieldData length]];
}

@end

@implementation ATInternetMessage (Loading)

- (void)readAllContentsFrom:(ATMailSpool *)aMailSpool
{
	[self readAllContentsFromPath:[aMailSpool accessibleMessageFilePathFor:self]];
}

- (void)readAllContentsFromPath:(NSString *)aMsgFilePath
{		
	if ([[NSFileManager defaultManager] fileExistsAtPath:aMsgFilePath])
	{
		NSData *aMessageData = [NSData dataWithContentsOfFile:aMsgFilePath];
		ATInternetMessageLineScanner *aLineScanner = [[[ATInternetMessageLineScanner alloc] initWithData:aMessageData] autorelease];
		
		[self removeAllEntities];
		
		[self readHeaderFromLineScanner:aLineScanner];
		
		if ([aLineScanner skipNextLineAndCRLF])
			[self readBodyFromLineScanner:aLineScanner];
	}
}

- (void)rebuildCacheHeaderWithin:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream
{
	NSString *aMessageFilePath = [aMailSpool messageFilePathFor:self];
	ATInternetMessageLineScanner *aLineScanner = [ATInternetMessageLineScanner scannerWithFileContentsOfFile:aMessageFilePath];
	NSData *aHeaderLine = nil;
	NSMutableData *aNewHeaderCache = [NSMutableData data];
	NSSet *aNamesToBeCached = [ATMailSpool headerNamesToBeSave];
	NSData *anItemIDField = [[NSString stringWithFormat:@"%@:%u\r\n\r\n", ATItemIDHeaderFieldName, [self itemID]] dataUsingEncoding:NSASCIIStringEncoding];
	
	while ((aHeaderLine = [aLineScanner scanUnfoldedLine]) && [aHeaderLine length])
	{
		ATHeaderField *aHeaderField = [[[ATHeaderField alloc] initWithLineData:aHeaderLine interpret:NO] autorelease];
		
		if ([aHeaderField nameIsIncludedIn:aNamesToBeCached])
			[aNewHeaderCache appendData:[aHeaderField rawData]];
		
		[aLineScanner skipNextCRLF];
	}
	
	[aNewHeaderCache appendBytes:[anItemIDField bytes] length:[anItemIDField length]];
	[aHeaderOutputStream write:[aNewHeaderCache bytes] maxLength:[aNewHeaderCache length]];
}

@end

@implementation ATInternetMessage (Accessing)

- (void)setItemID:(unsigned)anItemID
{
	itemID = anItemID;
}

- (unsigned)itemID
{
	return itemID;
}

- (NSString *)itemIDString
{
	return [NSString stringWithFormat:@"%u", [self itemID]];
}

- (NSNumber *)itemIDNumber
{
	return [NSNumber numberWithUnsignedInt:[self itemID]];
}

- (ATHeaderField *)messageID
{
	if (!messageIDField)
		messageIDField = [self headerFieldFor:@"message-id"];
	
	return messageIDField;
}

- (ATMsgID *)messageIDValue
{	
	ATHeaderField *aHeader = [self messageID];
	
	return [aHeader isValid] ? [[aHeader value] lastObject] : nil;
}

- (void)setMailSpool:(ATMailSpool *)aMailSpool
{
	mailSpool = aMailSpool;
}

- (ATMailSpool *)mailSpool
{
	return mailSpool;
}

- (ATMailbox *)parent
{
	return parent;
}

- (void)setParent:(ATMailbox *)aMailbox
{
	parent = aMailbox;
}

- (void)setToBeRead:(BOOL)aToBeReadFlag
{
	if (aToBeReadFlag)
		[[self mailSpool] addMessageToBeRead:self];
	else
		[[self mailSpool] removeMessageToBeRead:self];
}

- (BOOL)isToBeRead
{
	return [[self mailSpool] messageIsToBeRead:self];
}

- (void)removeAllEntities
{
	[self setMessageHeader:[NSMutableArray array]];
	[self setBody:nil];
	isInterpreted = NO;
	isValid = NO;
	messageIDField = nil;
}

- (NSString *)bodyString
{
	if ([self isMIMEMessage] && [self isMultipart])
		return [[self body] stringValue];
	else
		return [self body];
}

- (NSString *)stringValue
{
	return [self bodyString];
}

- (unsigned)bodyPartCount
{
	return [self count];
}

- (NSString *)filename
{
	return [[self itemIDString] stringByAppendingPathExtension:@"txt"];
}

- (NSString *)stringWithItemIDField
{
	return [NSString stringWithFormat:@"%@:%u\r\n", ATItemIDHeaderFieldName, [self itemID]];
}

- (NSData *)dataWithItemIDField
{
	return [[self stringWithItemIDField] dataUsingEncoding:NSASCIIStringEncoding];
}

- (NSDictionary *)itemIDPropertyList
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[self itemIDNumber],@"itemID", @"message",@"type", nil];
}

+ (NSArray *)messagesForMessageID:(ATMsgID *)aParentMessageID in:(NSArray *)aMessages
{
	NSEnumerator *anEnumeator = [aMessages objectEnumerator];
	id anItem = nil;
	NSMutableArray *aFoundMessages = [NSMutableArray array];
	
	while (anItem = [anEnumeator nextObject])
	{
		if ([anItem messageIDIsEqualToMessageID:aParentMessageID])
			[aFoundMessages addObject:anItem];
	}
				
	return aFoundMessages;
}

@end

@implementation ATInternetMessage (Fields)

- (ATHeaderField *)inReplyTo
{
	return [self headerFieldFor:@"in-reply-to"];
}

- (NSArray *)messageIDsOfInReplyTo
{
	return [[self inReplyTo] value];
}

- (ATMsgID *)lastMessageIDOfInReplyTo
{
	return [[self messageIDsOfInReplyTo] lastObject];
}

- (ATHeaderField *)references
{
	return [self  headerFieldFor:@"references"];
}

- (NSArray *)messageIDsOfReferences
{
	return [[self references] value];
}

- (ATMsgID *)lastMessageIDOfReferences
{
	return [[self messageIDsOfReferences] lastObject];
}

- (ATMsgID *)lastMessageIDOfReferencesOrInReplyTo
{
	ATMsgID *aTargetMessageID = [self lastMessageIDOfReferences];
	
	if (!aTargetMessageID)
		aTargetMessageID = [self lastMessageIDOfInReplyTo];

	return aTargetMessageID;
}

- (ATHeaderField *)xMailingListName
{
	return [self headerFieldFor:@"X-ML-Name"];
}

- (NSString *)xMailingListNameString
{
	return [[self xMailingListName] value];
}

@end

@implementation ATInternetMessage (Threads)

- (void)setReturnMessages:(NSMutableArray *)aReturnMessages
{
	[returnMessages release];
	returnMessages = [aReturnMessages retain];
}

- (NSMutableArray *)returnMessages
{
	if (!returnMessages)
		[self setReturnMessages:[NSMutableArray array]];
		
	return returnMessages;
}

- (BOOL)addReturnMessage:(ATInternetMessage *)aMessage
{
	if (![self isEqual:aMessage])
	{
		[[self returnMessages] addObject:aMessage];
		[aMessage setParentMessage:self];
		
		return YES;
	}
	
	return NO;
}

- (ATInternetMessage *)parentMessage
{
	return parentMessage;
}

- (void)setParentMessage:(ATInternetMessage *)aMessage
{
	parentMessage = aMessage;
}

- (unsigned)countOfReturnMessages
{
	return [[self returnMessages] count];
}

- (BOOL)resolveParentMessageWithin:(NSArray *)aParentCandidatesArray
{
	ATMsgID *aParentMessageID = [self lastMessageIDOfReferencesOrInReplyTo];
	BOOL aParentResolved = NO;
	NSArray *aParentCandidates = nil;
	NSEnumerator *aParentCandidatesEnumerator = [aParentCandidatesArray objectEnumerator];
	
	while (!aParentResolved && (aParentCandidates = [aParentCandidatesEnumerator nextObject]))
	{
		NSArray *aParentMessages = [ATInternetMessage messagesForMessageID:aParentMessageID in:aParentCandidates];
	
		if ([aParentMessages count])
		{
			NSEnumerator *aParentMessagesEnumerator = [aParentMessages objectEnumerator];
			ATInternetMessage *aParentMessage = nil;
			
			if (aParentMessage = [aParentMessagesEnumerator nextObject])
			{
				if ([aParentMessage addReturnMessage:self])
					aParentResolved = YES;
			}
		}
	}
	
	return aParentResolved;
}

- (BOOL)resolveParentMessageWithinDictionary:(NSDictionary *)aParentCandidatesDictionary
{
	ATMsgID *aParentMessageID = [self lastMessageIDOfReferencesOrInReplyTo];	
	ATInternetMessage *aParentMessage = [aParentCandidatesDictionary objectForKey:aParentMessageID];
	
	if (aParentMessage)
	{
		[aParentMessage addReturnMessage:self];
		return YES;
	}
	
	return NO;	
}

- (BOOL)resolveReferencesOrInReplyTo
{
	return [self resolveParentMessageWithin:[[self parent] messages]];
}

- (void)removeAllReturnMessages
{
	if ([[self returnMessages] count])
	{
		[[self returnMessages] makeObjectsPerformSelector:@selector(setParentMessage:) withObject:nil];
		[[self returnMessages] makeObjectsPerformSelector:@selector(removeAllReturnMessages) withObject:nil];
		[[self returnMessages] removeAllObjects];
	}
}

- (void)sortReturnMessagesByDate
{
	NSSortDescriptor *aDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date.body.value" ascending:YES] autorelease];
	
	[self sortReturnMessagesUsingDescriptors:[NSArray arrayWithObject:aDescriptor] recursive:YES];
}

- (void)sortReturnMessagesUsingDescriptors:(NSArray *)aDescriptors recursive:(BOOL)aRecursiveFlag
{
	if (returnMessages)
	{
		[[self returnMessages] sortUsingDescriptors:aDescriptors];
	}
	
	if (aRecursiveFlag)
	{
		NSEnumerator *aReturnMessagesEnumerator = [[self returnMessages] objectEnumerator];
		ATInternetMessage *aReturnMessage = nil;
		
		while (aReturnMessage = [aReturnMessagesEnumerator nextObject])
		{
			[aReturnMessage sortReturnMessagesUsingDescriptors:aDescriptors recursive:aRecursiveFlag];
		}
	}
}

- (void)openThread
{
	[self openThreadsRecursive:NO firstPass:YES];
}

- (void)openThreadsRecursive:(BOOL)aRecursiveFlag
{
	[self openThreadsRecursive:aRecursiveFlag firstPass:YES];
}

- (void)openThreadsRecursive:(BOOL)aRecursiveFlag firstPass:(BOOL)aFirstPassFlag
{
	if ([[self returnMessages] count])
		[[self mailSpool] addOpenThread:self];
	
	if (aRecursiveFlag)
	{
		NSEnumerator *anEnumerator = [[self returnMessages] objectEnumerator];
		ATInternetMessage *aReplyMessage = nil;
		
		while (aReplyMessage = [anEnumerator nextObject])
			[aReplyMessage openThreadsRecursive:aRecursiveFlag firstPass:NO];
	}
	
	if (aFirstPassFlag)
		[[self parent] threadsDidOpen:self];
}

- (void)closeThread
{
	[self closeThreadsRecursive:NO firstPass:YES];
}

- (void)closeThreadsRecursive:(BOOL)aRecursiveFlag
{
	[self closeThreadsRecursive:aRecursiveFlag firstPass:YES];
}

- (void)closeThreadsRecursive:(BOOL)aRecursiveFlag firstPass:(BOOL)aFirstPassFlag
{	
	if (aRecursiveFlag)
	{
		NSEnumerator *anEnumerator = [[self returnMessages] objectEnumerator];
		ATInternetMessage *aReplyMessage = nil;
		
		while (aReplyMessage = [anEnumerator nextObject])
			[aReplyMessage closeThreadsRecursive:aRecursiveFlag firstPass:NO];
	}
	
	if ([[self returnMessages] count])
		[[self mailSpool] removeOpenThread:self];
	
	if (aFirstPassFlag)
		[[self parent] threadsDidClose:self];
}

+ (NSMutableArray *)resolveParentMessageOf:(NSArray *)aReplies within:(NSArray *)aParentCandidatesArray putNoneRepliesInto:(NSArray **)aNoneReplies resolvedRepliesInto:(NSArray **)aResolvedReplies
{
	NSMutableArray *anUnresolvedReplies = [NSMutableArray array];
	NSMutableArray *aNoneReplyArray = [NSMutableArray array];
	NSMutableArray *aResolvedReplyArray = [NSMutableArray array];
	NSEnumerator *anEnumerator = [aReplies objectEnumerator];
	ATInternetMessage *aMessage = nil;
	
	while (aMessage = [anEnumerator nextObject])
	{
		if (![aMessage isReturnMessage])
			[aNoneReplyArray addObject:aMessage];
		else 
		{
			if ([aMessage resolveParentMessageWithin:aParentCandidatesArray])
				[aResolvedReplyArray addObject:aMessage];
			else
				[anUnresolvedReplies addObject:aMessage];
		}
	}
	
	if (aNoneReplies)
		*aNoneReplies = aNoneReplyArray;
	
	if (aResolvedReplies)
		*aResolvedReplies = aResolvedReplyArray;
		
	return anUnresolvedReplies;
}

+ (NSMutableArray *)resolveParentMessageOf:(NSArray *)aReplies withinDictionary:(NSDictionary *)aParentCandidatesDictionary putNoneRepliesInto:(NSArray **)aNoneReplies resolvedRepliesInto:(NSArray **)aResolvedReplies
{
	NSMutableArray *anUnresolvedReplies = [NSMutableArray array];
	NSMutableArray *aNoneReplyArray = [NSMutableArray array];
	NSMutableArray *aResolvedReplyArray = [NSMutableArray array];
	NSEnumerator *anEnumerator = [aReplies objectEnumerator];
	ATInternetMessage *aMessage = nil;
	
	while (aMessage = [anEnumerator nextObject])
	{
		if (![aMessage isReturnMessage])
			[aNoneReplyArray addObject:aMessage];
		else 
		{
			if ([aMessage resolveParentMessageWithinDictionary:aParentCandidatesDictionary])
				[aResolvedReplyArray addObject:aMessage];
			else
				[anUnresolvedReplies addObject:aMessage];
		}
	}
	
	if (aNoneReplies)
		*aNoneReplies = aNoneReplyArray;
	
	if (aResolvedReplies)
		*aResolvedReplies = aResolvedReplyArray;
		
	return anUnresolvedReplies;
}

@end

@implementation ATInternetMessage (Interpretting)

- (void)readHeaderFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner fieldNamesToBeInterpreted:(NSSet *)aFieldNamesToBeInterpreted
{
	ATHeaderField *aHeaderField = nil;
	
	[super readHeaderFromLineScanner:aLineScanner fieldNamesToBeInterpreted:aFieldNamesToBeInterpreted];
	
	aHeaderField = [self lastHeaderFieldWithoutInterpreting];
	
	if (![aHeaderField nameIs:ATItemIDHeaderFieldName])
		aHeaderField = [self headerFieldFor:ATItemIDHeaderFieldName];
		
	if (aHeaderField)
		[self setItemID:[[aHeaderField bodyString] intValue]];
}

- (void)addHeaderLine:(NSString *)aLine interpretWhenUnfolded:(BOOL)anInterpretFlag
{
	if ([self lastHeaderFieldWithoutInterpreting] && [[self lastHeaderFieldWithoutInterpreting] isFolding:aLine])
	{
		[[self lastHeaderFieldWithoutInterpreting] addLine:aLine];
	}
	else
	{
		ATHeaderField *aHeaderField = [[[ATHeaderField alloc] initWithLine:aLine interpret:NO] autorelease];
		
		if (anInterpretFlag)
			[[self lastHeaderFieldWithoutInterpreting] name];
		
		if (aHeaderField)
			[self addHeader:aHeaderField];
	}
}

- (BOOL)interpret
{	
	if (!isInterpreted)
	{
		isValid = [self interpretMessageHeader] && [self hasRequiredHeader];
		isInterpreted = YES;
	}
	
	return isValid;
}

- (BOOL)interpretMessageHeader
{
	BOOL aHeaderIsValid = YES;
	ATHeaderField *aHeaderField = nil;
	NSEnumerator *enumerator = [[self messageHeader] objectEnumerator];
	
	while (aHeaderField = [enumerator nextObject])
	{
		if (![aHeaderField isInterpreted])
			[aHeaderField interpret];
		
		if (![aHeaderField isValid])
			aHeaderIsValid = NO;
	}
		
	return aHeaderIsValid;
}

@end

@implementation ATInternetMessage (Testing)

- (BOOL)isValid
{
	return isValid;
}

- (BOOL)isMessage
{
	return YES;
}

- (BOOL)isTopLevelMessage
{
	return YES;
}

- (BOOL)hasRequiredHeader
{
	if ([self date])
	{		
		if ([self from] && [[self from] isValid] && ([[[[self from] body] value] count] == 1))
			return YES;
		else if ([self sender])
			return YES;
		else
			return NO;
	}
	else
		return NO;
}

- (BOOL)isReturnMessage
{
	return ([[[self references] value] count] || [[[self inReplyTo] value] count]) ? YES : NO;
}

- (BOOL)hasReturnMessage
{
	return returnMessages && [returnMessages count];
}

- (BOOL)hasValidMessageID
{
	return [[self messageID] isValid];
}

- (BOOL)messageIDIsEqualToMessageID:(ATMsgID *)aMessageID
{
	ATHeaderField *aField = [self messageID];
	
	return [aField isValid] && [[[aField value] lastObject] isEqualToMessageID:aMessageID];
}

- (BOOL)isMailbox
{
	return NO;
}

- (BOOL)isOpen
{
	return [[self mailSpool] threadIsOpen:self];
}

@end