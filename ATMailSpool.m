//
//  ATMailSpool.m
//  ATMail
//
//  Created by 高田　明史 on 07/09/10.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATMailSpool.h"
#import "ATIDPool.h"
#import "ATInternetMessage.h"
#import "ATInternetMessageLineScanner.h"
#import "ATMailAccount.h"
#import "ATPop3MessageDownloader.h"
#import "ATHeaderField.h"
#import "ATMsgID.h"
#import "ATMailbox.h"
#import "ATFilterEditor.h"

NSString *ATItemIDHeaderFieldName = @"X-ATItemID";

NSString *ATMessageReadStatusDidChangeNotification = @"ATMessageReadStatusDidChangeNotification";
NSString *ATMailboxesDidChangeNotification = @"ATMailboxesDidChangeNotification";

NSString *ATMessageKey = @"ATMessageKey";

NSString *ATItemIDsPboardType = @"ATItemIDsPboardType";

@implementation ATMailSpool

- (id)init
{
	[super init];
	
	[self setIDPool:[[ATIDPool new] autorelease]];
	[self setMailboxIDPool:[[ATIDPool new] autorelease]];
	messagesDictionary = [NSMutableDictionary new];
	
	[self setRoot:[self makeMailboxWithName:@"Root" weak:NO]];
	[self setEntireMessagesMailbox:[self makeMailboxWithName:@"EntireMessages" weak:YES]];
	[[self root] add:[self entireMessagesMailbox]];
	[self setInbox:[self makeMailboxWithName:@"Inbox" weak:NO]];
	[[self root] add:[self inbox]];
	
	[self setUnsavedMessages:[NSMutableArray array]];
	[self setUnsavedHeadersFilePaths:[NSMutableArray array]];
	[self setMailAccount:[[ATMailAccount new] autorelease]];
	[self setFilterEditor:[ATFilterEditor filterEditor]];
	[self setOpenThreads:[NSMutableIndexSet indexSet]];
	
	return self;
}

- (void)dealloc
{
	if ([[self unsavedMessages] count])
		[self removeItemsInTemporaryFolder];
		
	[self setIDPool:nil];
	[self setMailboxIDPool:nil];
	[messagesDictionary release];
	messagesDictionary = nil;
	[self setRoot:nil];
	[self setEntireMessagesMailbox:nil];
	[self setUnsavedMessages:nil];
	[self setUnsavedHeadersFilePaths:nil];
	[self setTargetMissingMessages:nil];
	[self setMailAccount:nil];
	[self setFilterEditor:nil];
	[self setOpenThreads:nil];
	
	[super dealloc];
}

- (id)retain
{
	return [super retain];
}

@end

@implementation ATMailSpool (Accessing)

- (ATIDPool *)idPool
{
	return idPool;
}

- (void)setIDPool:(ATIDPool *)anIDPool
{
	[idPool release];
	idPool = [anIDPool retain];
}

- (ATIDPool *)mailboxIDPool
{
	return mailboxIDPool;
}

- (void)setMailboxIDPool:(ATIDPool *)aMailboxIDPool
{
	[mailboxIDPool release];
	mailboxIDPool = [aMailboxIDPool retain];
}

- (ATMailbox *)root
{
	return root;
}

- (void)setRoot:(ATMailbox *)aRoot
{
	[root release];
	root = [aRoot retain];
	
	[root setMailSpool:self];
}

- (ATMailbox *)entireMessagesMailbox
{
	return entireMessagesMailbox;
}

- (void)setEntireMessagesMailbox:(ATMailbox *)anEntireMessagesMailbox
{
	[entireMessagesMailbox release];
	entireMessagesMailbox = [anEntireMessagesMailbox retain];
	
	[entireMessagesMailbox setMailSpool:self];
	[[entireMessagesMailbox messages] makeObjectsPerformSelector:@selector(setMailSpool:) withObject:self];
	[self setEntireMessagesMailboxID:[anEntireMessagesMailbox mailboxID]];
	//[entireMessagesMailbox rearrangeMessages];
}

- (unsigned)entireMessagesMailboxID
{
	return entireMessagesMailboxID;
}

- (void)setEntireMessagesMailboxID:(unsigned)anID
{
	entireMessagesMailboxID = anID;
}

- (ATMailbox *)inbox
{
	return inbox;
}

- (void)setInbox:(ATMailbox *)anInbox
{
	[inbox autorelease];
	inbox = [anInbox retain];
}

- (void)setSystemMailboxDictionary:(NSDictionary *)aSystemMailboxDictionary
{
	ATMailbox *aNewEntireMessageMailbox = [aSystemMailboxDictionary objectForKey:@"entireMessagesMailbox"];
	ATMailbox *aNewInbox = [aSystemMailboxDictionary objectForKey:@"inbox"];
		
	[aNewEntireMessageMailbox setMessages:[self messages]];
	[self setEntireMessagesMailboxID:[aNewEntireMessageMailbox mailboxID]];
	[self setEntireMessagesMailbox:aNewEntireMessageMailbox];
	
	if (aNewInbox)
		[self setInbox:aNewInbox];
}
	
- (NSMutableArray *)messages
{
	return [entireMessagesMailbox messages]; 
}

- (void)setMessages:(NSMutableArray *)aMessages
{
	[[self entireMessagesMailbox] setMessages:aMessages];
	[[[self entireMessagesMailbox] messages] makeObjectsPerformSelector:@selector(setMailSpool:) withObject:self];
}

- (NSMutableArray *)unsavedMessages
{
	return unsavedMessages;
}

- (void)setUnsavedMessages:(NSMutableArray *)aMessages
{
	[unsavedMessages release];
	unsavedMessages = [aMessages retain];
}

- (NSMutableArray *)targetMissingMessages
{
	if (!targetMissingMessages)
		[self setTargetMissingMessages:[NSMutableArray array]];
	
	return targetMissingMessages;
}

- (void)setTargetMissingMessages:(NSMutableArray *)aTargetMissingMessages
{
	[targetMissingMessages release];
	targetMissingMessages = [aTargetMissingMessages retain];
}

- (NSMutableIndexSet *)indexSetWithTargetMissingMessages
{
	NSEnumerator *anEnumeratorOfTargetMissingMessages = [[self targetMissingMessages] objectEnumerator];
	ATInternetMessage *aMessage = nil;
	NSMutableIndexSet *anIndexSetOfTargetMissingMessags = [NSMutableIndexSet indexSet];
	
	while (aMessage = [anEnumeratorOfTargetMissingMessages nextObject])
	{
		[anIndexSetOfTargetMissingMessags addIndex:[aMessage itemID]];
	}
	
	return anIndexSetOfTargetMissingMessags;
}

- (NSData *)dataFromIndexSetWithTargetMissingMessages
{
	return [NSArchiver archivedDataWithRootObject:[self indexSetWithTargetMissingMessages]];
}

- (NSMutableIndexSet *)messagesToBeRead
{
	if (!messagesToBeRead)
		[self setMessagesToBeRead:[NSMutableIndexSet indexSet]];
		
	return messagesToBeRead;
}

- (void)setMessagesToBeRead:(NSMutableIndexSet *)aMessages
{
	[messagesToBeRead release];
	messagesToBeRead = [aMessages retain];
}

- (NSArray *)mailboxes
{
	return [[self root] allDescendantMailboxes];
}

- (ATMailAccount *)mailAccount
{
	return mailAccount;
}

- (void)setMailAccount:(ATMailAccount *)anAccount
{
	[mailAccount release];
	mailAccount = [anAccount retain];
}

- (ATPop3MessageDownloader *)messageDownloader
{
	if (![self isDownloading])
		[self setMessageDownloader:[[[ATPop3MessageDownloader alloc] initWithMailAccount:[self mailAccount] delegate:self] autorelease]];
		
	return messageDownloader;
}

- (void)setMessageDownloader:(ATPop3MessageDownloader *)aDownloader
{
	[messageDownloader release];
	messageDownloader = [aDownloader retain];
}

- (NSString *)mailDocumentPath
{
	return mailDocumentPath;
}

- (void)setMailDocumentPath:(NSString *)aMailDocumentPath
{
	[mailDocumentPath release];
	mailDocumentPath = [aMailDocumentPath copy];
}

+ (NSSet *)headerNamesToBeSave
{
	return [NSSet setWithObjects:@"subject", @"from", @"date", @"to", @"message-id", @"references", @"in-reply-to", nil];
}

+ (NSSet *)headerNamesToBeShow
{
	return [self headerNamesToBeSave];
}

- (NSSet *)headerNamesToBeShow
{
	return [[self class] headerNamesToBeShow];
}

- (NSMutableArray *)unsavedHeadersFilePaths
{
	return unsavedHeadersFilePaths;
}

- (void)setUnsavedHeadersFilePaths:(NSMutableArray *)anUnsavedHeadersFilePaths
{
	[unsavedHeadersFilePaths release];
	unsavedHeadersFilePaths = [anUnsavedHeadersFilePaths retain];
}

- (void)addUnsavedHeaderFilePath:(NSString *)aHeaderFilePath
{
	[[self unsavedHeadersFilePaths] addObject:aHeaderFilePath];
}

- (ATFilterEditor *)filterEditor
{	
	return filterEditor;
}

- (void)setFilterEditor:(ATFilterEditor *)aFilterEditor
{
	if (filterEditor)
		[[NSNotificationCenter defaultCenter] removeObserver:self name:ATFilterEditorDidChangeNotification object:filterEditor];
	
	[filterEditor autorelease];
	filterEditor = [aFilterEditor retain];
	
	if (filterEditor)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterEditorDidChange:) name:ATFilterEditorDidChangeNotification object:filterEditor];
}

- (NSMutableIndexSet *)openThreads
{
	return openThreads;
}

- (void)setOpenThreads:(NSMutableIndexSet *)aMessageItemIDs
{
	[openThreads release];
	openThreads = [aMessageItemIDs retain];
}

@end

@implementation ATMailSpool (QueryingPaths)

- (NSString *)messagesFolderPath
{
	return [[self mailDocumentPath] stringByAppendingPathComponent:@"messages"];
}

- (NSString *)accessibleMessageFilePathFor:(ATInternetMessage *)anInternetMessage
{
	if ([[self unsavedMessages] containsObject:anInternetMessage])
		return [self temporaryMessageFilePathFor:anInternetMessage];
	else	
		return [self messageFilePathFor:anInternetMessage];
}

- (NSString *)messageFilePathFor:(ATInternetMessage *)anInternetMessage
{
	return [[self messagesFolderPath] stringByAppendingPathComponent:[anInternetMessage filename]];
}

- (NSString *)temporaryMessageFilePathFor:(ATInternetMessage *)anInternetMessage
{
	return [[self temporaryFolderPathCreateIfAbsent] stringByAppendingPathComponent:[anInternetMessage filename]];
}

- (NSString *)temporaryHeadersFilePath
{
	return [[self temporaryFolderPathCreateIfAbsent] stringByAppendingPathComponent:@"headers.txt"];
}

- (NSString *)temporaryHeadersFilePathFor:(ATPop3MessageDownloader *)aDownloader
{
	return [[self temporaryFolderPathCreateIfAbsent] stringByAppendingPathComponent:[NSString stringWithFormat:@"downloadingHeaders%d.txt", [aDownloader downloaderID]]];
}

- (NSString *)headersFolderPath
{
	return [[self mailDocumentPath] stringByAppendingPathComponent:@"headers"];
}

- (NSString *)headersFilePath
{
	return [[self headersFolderPath] stringByAppendingPathComponent:@"0.txt"];
}

- (NSString *)temporaryFolderPath
{
	return [[self mailDocumentPath] stringByAppendingPathComponent:@"temporary"];;
}

- (NSString *)temporaryFolderPathCreateIfAbsent
{
	[self createTemporaryFolderIfAbsent];
	
	return [self temporaryFolderPath];
}

- (NSString *)headersFolderPathWithin:(NSURL *)aMailDocumentURL
{
	return [[aMailDocumentURL path] stringByAppendingPathComponent:@"headers"];
}

- (NSString *)messagesFolderPathWithin:(NSURL *)aMailDocumentURL
{
	return [[aMailDocumentURL path] stringByAppendingPathComponent:@"messages"];
}

- (NSString *)idPoolPathWithin:(NSURL *)aMailDocumentURL
{
	return [[aMailDocumentURL path] stringByAppendingPathComponent:@"idPool"];
}

- (NSString *)mailAccountPathWithin:(NSURL *)aMailDocumentURL
{
	return [[aMailDocumentURL path] stringByAppendingPathComponent:@"mailAccount"];
}

- (NSString *)systemMailboxesPath
{
	return [[self mailDocumentPath] stringByAppendingPathComponent:@"systemMailboxes"];
}

- (NSString *)filterEditorPath
{
	return [[self mailDocumentPath] stringByAppendingPathComponent:@"filterEditor"];
}

@end

@implementation ATMailSpool (QueryingStreamsAndFiles)

- (NSOutputStream *)outputStreamForTemporaryHeaders
{
	BOOL anItemIsDirectory;
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self temporaryHeadersFilePath] isDirectory:&anItemIsDirectory])
		[[NSFileManager defaultManager] createFileAtPath:[self temporaryHeadersFilePath] contents:nil attributes:nil];
	
	return [NSOutputStream outputStreamToFileAtPath:[self temporaryHeadersFilePath] append:YES];
}

- (NSOutputStream *)outputStreamForTemporaryHeadersOfDownloader:(ATPop3MessageDownloader *)aDownloader
{
	BOOL anItemIsDirectory;
	NSString *aFilePath = [self temporaryHeadersFilePathFor:aDownloader];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:aFilePath isDirectory:&anItemIsDirectory])
		[[NSFileManager defaultManager] createFileAtPath:aFilePath contents:nil attributes:nil];
	
	return [NSOutputStream outputStreamToFileAtPath:aFilePath append:YES];
}

- (NSOutputStream *)outputStreamForTemporaryMessage:(ATInternetMessage *)aMessage
{
	[self createTemporaryMessageFileFor:aMessage];

	return [NSOutputStream outputStreamToFileAtPath:[self temporaryMessageFilePathFor:aMessage] append:NO];
}

- (void)createTemporaryFolderIfAbsent
{
	BOOL anItemIsDirectory;
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[self temporaryFolderPath] isDirectory:&anItemIsDirectory])
		[[NSFileManager defaultManager] createDirectoryAtPath:[self temporaryFolderPath] attributes:nil];
}

- (void)createTemporaryMessageFileFor:(ATInternetMessage *)aMessage
{
	[[NSFileManager defaultManager] createFileAtPath:[self temporaryMessageFilePathFor:aMessage] contents:nil attributes:nil];
}

- (BOOL)createMessagesFolderAndHeadersFolderWithin:(NSURL *)aMailDocumentURL
{
	BOOL aMesseagesFolderIsCreated = [self existsMessagesFolderWithin:aMailDocumentURL] ? YES : [[NSFileManager defaultManager] createDirectoryAtPath:[self messagesFolderPathWithin:aMailDocumentURL] attributes:nil];
	BOOL aHeadersFolderIsCreated = [self existsHeadersFolderWithin:aMailDocumentURL] ? YES : [[NSFileManager defaultManager] createDirectoryAtPath:[self headersFolderPathWithin:aMailDocumentURL] attributes:nil];
	
	return aMesseagesFolderIsCreated && aHeadersFolderIsCreated;
}

- (void)removeItemsInTemporaryFolder
{
	NSArray *aDirectoryContents = [[NSFileManager defaultManager] directoryContentsAtPath:[self temporaryFolderPath]];
	NSEnumerator *aDirectoryContentsEnumerator = [aDirectoryContents objectEnumerator];
	NSString *anItemPathInTemporaryFolder = nil;
	
	while (anItemPathInTemporaryFolder = [aDirectoryContentsEnumerator nextObject])
	{
		[[NSFileManager defaultManager] removeFileAtPath:[[self temporaryFolderPath] stringByAppendingPathComponent:anItemPathInTemporaryFolder] handler:nil];
	}
}

@end

@implementation ATMailSpool (QueryingMessages)

- (unsigned)newItemID
{
	return [idPool newID];
}

- (NSArray *)itemIDsFor:(NSArray *)anItems
{
	NSMutableArray *anIDs = [NSMutableArray array];
	id anItem = nil;
	NSEnumerator *anEnumerator = [anItems objectEnumerator];
	
	while (anItem = [anEnumerator nextObject])
	{
		[anIDs addObject:[anItem itemIDPropertyList]];
	}
	
	return anIDs;
}

- (ATInternetMessage *)messageForItemID:(unsigned)anItemID
{
	BOOL aMessageFound = NO;
	NSEnumerator *anEnumeratorOfMessages = [[self messages] objectEnumerator];
	ATInternetMessage *aMessage = nil;
	
	while (!aMessageFound && (aMessage = [anEnumeratorOfMessages nextObject]))
	{
		if ([aMessage itemID] == anItemID)
			aMessageFound = YES;
	}
	
	return aMessage;
}

- (ATInternetMessage *)messageForItemIDNumber:(NSNumber *)anItemIDNumber
{
	return [messagesDictionary objectForKey:anItemIDNumber];
}

- (NSArray *)messagesForMessageID:(ATMsgID *)aMessageID
{
	return [self messagesForMessageID:aMessageID withinSearchingMessages:[self messages]];
}

- (NSArray *)messagesForMessageID:(ATMsgID *)aMessageID within:(NSArray *)anArrayOfSearchingMessages
{
	NSEnumerator *anEnumeratorOfSearchingMessages = [anArrayOfSearchingMessages objectEnumerator];
	NSArray *aSearchingMessages = nil;
	NSMutableArray *aMessages = [NSMutableArray array];
	
	while (aSearchingMessages = [anEnumeratorOfSearchingMessages nextObject])
	{
		[aMessages addObjectsFromArray:[self messagesForMessageID:aMessageID withinSearchingMessages:aSearchingMessages]];
	}
	
	return aMessages;
}

- (NSArray *)messagesForMessageID:(ATMsgID *)aMessageID withinSearchingMessages:(NSArray *)aSearchingMessages
{
	NSEnumerator *aMessagesEnumerator = [aSearchingMessages objectEnumerator];
	ATInternetMessage *aMessage = nil;
	NSMutableArray *aMessagesForMessageID = [NSMutableArray array];
	
	while (aMessage = [aMessagesEnumerator nextObject])
	{
		if ([aMessage messageIDIsEqualToMessageID:aMessageID])
			[aMessagesForMessageID addObject:aMessage];
	}
	
	return aMessagesForMessageID;
}

- (NSArray *)messagesAtIndexes:(NSIndexSet *)anIndexSet
{
	return [[self messages] objectsAtIndexes:anIndexSet];
}

- (void)filterMessages
{
	NSArray *aMessages = [[self messages] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"xMailingListNameString contains[cd] 'Ruby-List'"]];
	ATMailbox *aMailbox = [self mailboxForName:@"ruby-list"];
	//NSLog([aMessages description]);
	[aMailbox moveItems:aMessages at:0];
}

- (NSArray *)isolatedMessages
{
	NSMutableArray *aMessages = [NSMutableArray array];
	NSEnumerator *anEnumerator = [[[self entireMessagesMailbox] messages] objectEnumerator];
	ATInternetMessage *aMessage = nil;
	
	while (aMessage = [anEnumerator nextObject])
		if (![aMessage parent])
			[aMessages addObject:aMessage];

	return aMessages;
}

@end

@implementation ATMailSpool (QueryingMailboxes)

- (unsigned)newMailboxID
{
	return [[self mailboxIDPool] newID];
}

- (ATMailbox *)makeMailboxWithName:(NSString *)aName weak:(BOOL)aWeakFlag
{
	ATMailbox *aMailbox = [ATMailbox mailboxWithName:aName weak:aWeakFlag mailboxID:[self newMailboxID]];
	
	[aMailbox setMailSpool:self];
	
	return aMailbox;
}

- (ATMailbox *)mailboxFor:(unsigned)aMailboxID
{
	return [[self root] mailboxFor:aMailboxID];
}

- (ATMailbox *)mailboxForIDNumber:(NSNumber *)aNumber
{
	return [self mailboxFor:[aNumber unsignedIntValue]];
}

- (ATMailbox *)mailboxForName:(NSString *)aName
{
	return [[self root] mailboxForName:aName];
}

- (NSDictionary *)systemMailboxDictionary
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[self entireMessagesMailbox],@"entireMessagesMailbox", [self inbox],@"inbox", nil];
}

- (NSDictionary *)systemMailboxIDDictionary
{
	NSMutableDictionary *aSystemMailboxIDDictionary = [NSMutableDictionary dictionary];
	NSDictionary *aSystemMailboxDictionary = [self systemMailboxDictionary];
	NSString *aKey = nil;
	NSEnumerator *anEnumerator = [aSystemMailboxDictionary keyEnumerator];
	
	while (aKey = [anEnumerator nextObject])
		[aSystemMailboxIDDictionary setObject:[[aSystemMailboxDictionary objectForKey:aKey] mailboxIDNumber] forKey:aKey];
	
	return aSystemMailboxIDDictionary;
}

- (NSDictionary *)systemMailboxDictionaryFrom:(NSDictionary *)aSystemMailboxIDDictionary
{
	NSMutableDictionary *aSystemMaiboxDictonary = [[aSystemMailboxIDDictionary mutableCopy] autorelease];
	NSEnumerator *anEnumerator = [aSystemMaiboxDictonary keyEnumerator];
	NSString *aKey = nil;
	
	while (aKey = [anEnumerator nextObject])
	{
		ATMailbox *aMailbox = [self mailboxForIDNumber:[aSystemMaiboxDictonary objectForKey:aKey]];
		
		if (aMailbox)
			[aSystemMaiboxDictonary setObject:aMailbox forKey:aKey];
	}
	
	return aSystemMaiboxDictonary;
}

@end

@implementation ATMailSpool (Adding)

- (void)addMessages:(NSArray *)aNewMessages
{
	NSArray *aNoneFilteredMessages = nil;
	
	[self beginModifying];
	
	[[self entireMessagesMailbox] addMessages:aNewMessages];
	[aNewMessages makeObjectsPerformSelector:@selector(setMailSpool:) withObject:self];
	[aNewMessages makeObjectsPerformSelector:@selector(setToBeRead:) withObject:YES];
	//[[self inbox] moveItems:aNewMessages at:[[self inbox] count]];
	//[[self inbox] addMessages:aNewMessages];
	aNoneFilteredMessages = [[self filterEditor] filterAndMove:aNewMessages];
	[[self inbox] addMessages:aNoneFilteredMessages];
	
	[[self unsavedMessages] addObjectsFromArray:aNewMessages];
	
	[self endModifying];
}

- (void)rebuildCacheHeader
{
	NSEnumerator *enumerator = [[self messages] objectEnumerator];
	ATInternetMessage *aMessage = nil;
	NSOutputStream *aHeaderOutputStream = [NSOutputStream outputStreamToFileAtPath:[self headersFilePath] append:NO];
	
	[aHeaderOutputStream open];
	
	while (aMessage = [enumerator nextObject])
	{
		NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];

		[aMessage rebuildCacheHeaderWithin:self headerOutputStream:aHeaderOutputStream];
	
		[aPool release];
	}
	
	[aHeaderOutputStream close];
}

- (void)addMailbox:(ATMailbox *)aMailbox to:(ATMailbox *)aParentMailbox
{
	[self beginModifying];
	[aParentMailbox add:aMailbox];
	[self endModifying];
}

- (void)addIsolatedMessagesToInbox
{
	[[self inbox] moveItems:[self isolatedMessages] at:[[self inbox] count]];
}

@end

@implementation ATMailSpool (MessageStatus)

- (void)makeSelections:(NSArray *)aSelections toBeRead:(BOOL)aReadFlag
{
	[aSelections makeObjectsPerformSelector:@selector(setToBeRead:) withObject:aReadFlag];
}

- (void)addMessageToBeRead:(ATInternetMessage *)aMessage
{
	if (![self messageIsToBeRead:aMessage])
	{
		[[self messagesToBeRead] addIndex:[aMessage itemID]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ATMessageReadStatusDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:aMessage forKey:ATMessageKey]];
	}
}

- (void)removeMessageToBeRead:(ATInternetMessage *)aMessage
{
	if ([self messageIsToBeRead:aMessage])
	{
		[[self messagesToBeRead] removeIndex:[aMessage itemID]];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ATMessageReadStatusDidChangeNotification object:self userInfo:[NSDictionary dictionaryWithObject:aMessage forKey:ATMessageKey]];
	}
}

- (void)addOpenThread:(ATInternetMessage *)aMessage
{
	[[self openThreads] addIndex:[aMessage itemID]];
}

- (void)removeOpenThread:(ATInternetMessage *)aMessage
{
	[[self openThreads] removeIndex:[aMessage itemID]];
}

@end

@implementation ATMailSpool (Notifying)

- (NSMutableSet *)mailboxesInModifying
{
	return mailboxesInModifying;
}

- (void)setMailboxesInModifying:(NSMutableSet *)aMailboxes
{
	[mailboxesInModifying release];
	mailboxesInModifying = [aMailboxes retain];
}

- (void)beginModifying
{
	if (!mailboxesInModifying)
		[self setMailboxesInModifying:[NSMutableSet set]];
	
	depthOfModifying++;
}

- (void)endModifying
{
	depthOfModifying--;
	
	if (!depthOfModifying)
	{
		//[[self mailboxesInModifying] makeObjectsPerformSelector:@selector(rearrangeMessages)];
		[self postNotificationOfModifiedMailboxes];
		[self setMailboxesInModifying:nil];
	}
}

- (void)mailboxContentsDidChange:(ATMailbox *)aMailbox
{
	[[self mailboxesInModifying] addObject:aMailbox];
}

- (void)postNotificationOfModifiedMailboxes
{
	NSEnumerator *anEnumerator = [[self mailboxesInModifying] objectEnumerator];
	ATMailbox *aMailbox = nil;
	
	while (aMailbox = [anEnumerator nextObject])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:ATMailboxContentsDidChangeNotification object:aMailbox];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ATMailboxesDidChangeNotification object:self];
}

- (void)mailboxDidChangeName:(ATMailbox *)aMailbox
{
	[[NSNotificationCenter defaultCenter] postNotificationName:ATMailboxesDidChangeNotification object:self];
}

- (void)mailbox:(ATMailbox *)aMailbox didMoveMailboxes:(NSArray *)aMailboxes
{
	[[NSNotificationCenter defaultCenter] postNotificationName:ATMailboxesDidMoveNotification object:self userInfo:[NSDictionary dictionaryWithObject:aMailboxes forKey:@"mailboxes"]];
}

- (void)filterEditorDidChange:(NSNotification *)aNotification
{
	[[NSNotificationCenter defaultCenter] postNotificationName:[aNotification name] object:self];
}

@end

@implementation ATMailSpool (Testing)

- (BOOL)existsMessagesFolderAndHeadersFolderWithin:(NSURL *)aMailDocumentURL
{
	return  [self existsMessagesFolderWithin:aMailDocumentURL] && [self existsHeadersFolderWithin:aMailDocumentURL];
}

- (BOOL)existsMessagesFolderWithin:(NSURL *)aMailDocumentURL
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[self messagesFolderPathWithin:aMailDocumentURL]];
}

- (BOOL)existsHeadersFolderWithin:(NSURL *)aMailDocumentURL
{
	return [[NSFileManager defaultManager] fileExistsAtPath:[self headersFolderPathWithin:aMailDocumentURL]];
}

- (BOOL)messageIsToBeRead:(ATInternetMessage *)aMessage
{
	return [[self messagesToBeRead] containsIndex:[aMessage itemID]];
}

- (BOOL)isDownloading
{
	return messageDownloader ? YES : NO;
}

- (BOOL)messageIsIncludedIn:(NSArray *)anItems
{
	NSEnumerator *anEnumerator = [anItems objectEnumerator];
	id anItem = nil;
	BOOL aMessageIncluded = NO;
	
	while (!aMessageIncluded && (anItem = [anEnumerator nextObject]))
	{
		if ([anItem isMessage])
			aMessageIncluded = YES;
	}
	
	return aMessageIncluded;
}

- (BOOL)threadIsOpen:(ATInternetMessage *)aMessage
{
	return [[self openThreads] containsIndex:[aMessage itemID]];
}

@end

@implementation ATMailSpool (Saving)

- (BOOL)saveWithin:(NSURL *)aMailDocumentURL
{
	BOOL aMessagesFolderAndHeadersFolderExisted = YES;
	
	if (![self existsMessagesFolderAndHeadersFolderWithin:aMailDocumentURL])
		aMessagesFolderAndHeadersFolderExisted = [self createMessagesFolderAndHeadersFolderWithin:aMailDocumentURL];

	if (aMessagesFolderAndHeadersFolderExisted)
	{
		BOOL anIDPoolSaved = [self saveIDPoolWithin:aMailDocumentURL];
		BOOL aMailAccountSaved = [self saveMailAccountWithin:aMailDocumentURL];
		BOOL anUnsavedHeadersSaved = [self saveUnsavedHeaders];
		BOOL anUnsavedMessagesSaved = [self saveUnsavedMessages];
		BOOL aTargetMissingMessagesSaved = [self saveTargetMissingMessages];
		BOOL aMessagesToBeReadSaved = [self saveMessagesToBeRead];
		BOOL aMailboxIDPoolSaved = [self saveMailboxIDPool];
		BOOL aMailboxesSaved = [self saveMailboxes];
		BOOL aSystemMailboxesSaved = [self saveSystemMailboxes];
		BOOL aFilterEditorSaved = [self saveFilterEditor];
		BOOL anOpenThreadsSaved = [self saveOpenThreads];
		
		return anIDPoolSaved && aMailAccountSaved;
	}
	else
		return NO;
}

- (BOOL)saveIDPoolWithin:(NSURL *)aMailDocumentURL
{
	NSData *aSerializedIDPool = [NSPropertyListSerialization dataFromPropertyList:[idPool propertyListRepresentation] format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];

	return [aSerializedIDPool writeToFile:[self idPoolPathWithin:aMailDocumentURL] atomically:YES];
}

- (BOOL)saveUnsavedHeaders
{
	if ([[self unsavedHeadersFilePaths] count])
	{
		NSEnumerator *anEnumerator = [[self unsavedHeadersFilePaths] objectEnumerator];
		NSString *anUnsavedHeaderFilePath = nil;
		NSOutputStream *aHeadersOutputStream = nil;
		BOOL aWrittingFailed = NO;
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:[self headersFilePath]])
			[[NSFileManager defaultManager] createFileAtPath:[self headersFilePath] contents:nil attributes:nil];
			
		aHeadersOutputStream = [NSOutputStream outputStreamToFileAtPath:[self headersFilePath] append:YES];
		[aHeadersOutputStream open];
		
		while (!aWrittingFailed && (anUnsavedHeaderFilePath = [anEnumerator nextObject]))
		{
			NSData *aTemporaryHeadersData = [NSData dataWithContentsOfFile:anUnsavedHeaderFilePath];
			unsigned aWriteCount = [aHeadersOutputStream write:[aTemporaryHeadersData bytes] maxLength:[aTemporaryHeadersData length]];
			aWrittingFailed = aWriteCount != [aTemporaryHeadersData length];
			
			if (!aWrittingFailed)
				[[NSFileManager defaultManager] removeFileAtPath:anUnsavedHeaderFilePath handler:nil];
		}
		
		[aHeadersOutputStream close];
				
		return aWrittingFailed ? NO : YES;
	}
	
	return YES;
}

- (BOOL)saveUnsavedMessages
{
	NSEnumerator *anUnsavedMessagesEnumerator = [[self unsavedMessages] objectEnumerator];
	ATInternetMessage *aMessage = nil;
	BOOL aMessageMoveSucceed = YES;
	
	while (aMessageMoveSucceed && (aMessage = [anUnsavedMessagesEnumerator nextObject]))
	{
		NSString *aSourceMessageFilePath = [self temporaryMessageFilePathFor:aMessage];
		NSString *aDestinationMessageFilePath = [self messageFilePathFor:aMessage];
		
		aMessageMoveSucceed = [[NSFileManager defaultManager] movePath:aSourceMessageFilePath toPath:aDestinationMessageFilePath handler:nil];
	}
	
	if (aMessageMoveSucceed)
	{
		[[self unsavedMessages] removeAllObjects];
	}
	
	return aMessageMoveSucceed;
}

- (BOOL)saveTargetMissingMessages
{
	return [[self dataFromIndexSetWithTargetMissingMessages] writeToFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"targetMissingMessages"] atomically:YES];
}

- (BOOL)saveMessagesToBeRead
{
	return [NSArchiver archiveRootObject:[self messagesToBeRead] toFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"messagesToBeRead"]];
}

- (BOOL)saveMailAccountWithin:(NSURL *)aMailDocumentURL
{
	NSData *aSerializedMailAccount = [mailAccount serializedPropertyListRepresentation];
	
	return [aSerializedMailAccount writeToFile:[self mailAccountPathWithin:aMailDocumentURL] atomically:YES];
}


- (BOOL)saveMailboxIDPool
{
	NSData *aData = [NSPropertyListSerialization dataFromPropertyList:[[self mailboxIDPool] propertyListRepresentation] format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
	
	return [aData writeToFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"mailboxIDPool"] atomically:YES];
}

- (BOOL)saveMailboxes
{
	return [[self root] writeToFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"mailboxes"]];
}

- (BOOL)saveSystemMailboxes
{
	return [[NSPropertyListSerialization dataFromPropertyList:[self systemMailboxIDDictionary] format:NSPropertyListXMLFormat_v1_0 errorDescription:nil] writeToFile:[self systemMailboxesPath] atomically:YES];
}

- (BOOL)saveFilterEditor
{
	return [[self filterEditor] writeToFile:[self filterEditorPath]];
}

- (BOOL)saveOpenThreads
{
	return [NSArchiver archiveRootObject:[self openThreads] toFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"openThreads"]];
}

@end

@implementation ATMailSpool (Loading)

- (BOOL)loadWithin:(NSURL *)aMailDocumentURL
{
	BOOL anIDPoolLoaded;
	BOOL aMailAccountLoaded;
	BOOL aMailboxIDPoolLoaded;
	BOOL aMailboxesLoaded;
	BOOL aSystemMailboxes;
	BOOL aMessageHeadersLoaded;
	BOOL aTargetMissingMessageLoaded;
	BOOL aMessagesToBeReadLoaded;
	BOOL aFilterEditorLoaded;
	BOOL anOpenThreadsLoaded;
	
	[self removeItemsInTemporaryFolder];
	
	anIDPoolLoaded = [self loadIDPoolFromPath:[self idPoolPathWithin:aMailDocumentURL]];
	aMailAccountLoaded = [self loadMailAccountFromPath:[self mailAccountPathWithin:aMailDocumentURL]];
	aMessageHeadersLoaded = [self loadMessageHeadersFromPath:[self headersFolderPathWithin:aMailDocumentURL]];
	
	aMailboxIDPoolLoaded = [self loadMailboxIDPool];
	aMailboxesLoaded = [self loadMailboxes];
	aSystemMailboxes = [self loadSystemMailboxes];
	
	aTargetMissingMessageLoaded = [self loadTargetMissingMessage];
	aMessagesToBeReadLoaded = [self loadMessagesToBeRead];
	aFilterEditorLoaded = [self loadFilterEditor];
	anOpenThreadsLoaded = [self loadOpenThreads];
	
	return  anIDPoolLoaded && aMailAccountLoaded && aMailboxIDPoolLoaded && aMailboxesLoaded && aSystemMailboxes && aMessageHeadersLoaded && aTargetMissingMessageLoaded && aMessagesToBeReadLoaded;
}

- (BOOL)loadMessagesToBeRead
{
	NSMutableIndexSet *aMessagesToBeRead = [NSUnarchiver unarchiveObjectWithFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"messagesToBeRead"]];
	
	if (aMessagesToBeRead)
	{
		[self setMessagesToBeRead:[[aMessagesToBeRead mutableCopy] autorelease]];
		
		return YES;
	}
	else
		return YES;
}

- (BOOL)loadTargetMissingMessage
{
	NSMutableIndexSet *anIndexSetOfTargetMissingMessags = [NSUnarchiver unarchiveObjectWithFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"targetMissingMessages"]];
	
	if (anIndexSetOfTargetMissingMessags)
	{
		unsigned anItemID;
		NSMutableArray *aTargetMissingMessages = [NSMutableArray array];
		
		for (anItemID = [anIndexSetOfTargetMissingMessags firstIndex]; anItemID != NSNotFound; anItemID = [anIndexSetOfTargetMissingMessags indexGreaterThanIndex:anItemID])
		{
			ATInternetMessage *aMessage = [self messageForItemID:anItemID];
			
			if (aMessage)
				[aTargetMissingMessages addObject:aMessage];
		}
		
		[self setTargetMissingMessages:aTargetMissingMessages];
		
		return YES;
	}
	else
		return YES;
}

- (BOOL)loadIDPoolFromPath:(NSString *)aPath
{
	id aPlistOfIDPool = [NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:aPath] mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
	
	if (aPlistOfIDPool)
	{
		[self setIDPool:[ATIDPool newWith:aPlistOfIDPool]];
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)loadMailboxes
{
	return [self loadMailboxesFromPath:[[self mailDocumentPath] stringByAppendingPathComponent:@"mailboxes"]];
}

- (BOOL)loadMailboxesFromPath:(NSString *)aPath
{
	ATMailbox *aRoot = [ATMailbox mailboxWithContentsOfFile:aPath mailSpool:self];
		
	if (aRoot)
		[self setRoot:aRoot];
	
	return YES;
}

- (BOOL)loadMailboxIDPool
{
	NSData *aData = [NSData dataWithContentsOfFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"mailboxIDPool"]];
	
	if (aData)
	{
		id aPropertyList = [NSPropertyListSerialization propertyListFromData:aData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
		ATIDPool *aMailboxIDPool = [ATIDPool newWith:aPropertyList];
	
		[self setMailboxIDPool:aMailboxIDPool];
	}
	
	return YES;
}


- (BOOL)loadMailAccountFromPath:(NSString *)aPath
{
	NSData *aSerializedMailAccount = [NSData dataWithContentsOfFile:aPath];
	
	if (aSerializedMailAccount)
	{
		[self setMailAccount:[[[ATMailAccount alloc] initWithSerializedPropertyListReprensentation:aSerializedMailAccount] autorelease]];
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)loadMessageHeadersFromPath:(NSString *)aHeadersFolderPath
{
	NSMutableArray *aMessages = [NSMutableArray array];
	NSString *aHeaderFilePath = [aHeadersFolderPath stringByAppendingPathComponent:@"0.txt"];
	NSData *aHeaderData = [NSData dataWithContentsOfFile:aHeaderFilePath];
	
	if (aHeaderData)
	{
		ATInternetMessageLineScanner *aLineScanner = [[[ATInternetMessageLineScanner alloc] initWithData:aHeaderData] autorelease];
		
		while (![aLineScanner isAtEnd])
		{
			NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
			ATInternetMessage *aMessage = [ATInternetMessage messageFromLineScanner:aLineScanner onlyHeader:YES];
		
			if (aMessage)
			{
				[aMessages addObject:aMessage];
				[messagesDictionary setObject:aMessage forKey:[aMessage itemIDNumber]];
			}
			
			[aLineScanner skipNextTerminatedLine];
			[aPool release];
		}
				
		if ([aMessages count])
		{
			[self setMessages:aMessages];
			
			return YES;
		}
	}
	else
	{
		[self setMessages:aMessages];
		
		return YES;
	}
}

- (BOOL)loadSystemMailboxes
{
	NSData *aData = [NSData dataWithContentsOfFile:[self systemMailboxesPath]];
	
	if (aData)
	{
		NSDictionary *aSystemMailboxIDDictionary = [NSPropertyListSerialization propertyListFromData:aData mutabilityOption:NSPropertyListImmutable format:nil errorDescription:nil];
		NSDictionary *aSystemMailboxDictionary = [self systemMailboxDictionaryFrom:aSystemMailboxIDDictionary];
		
		[self setSystemMailboxDictionary:aSystemMailboxDictionary];
	}
	
	return YES;
}

- (BOOL)loadFilterEditor
{
	[self setFilterEditor:[ATFilterEditor filterEditorWithContentsOfFile:[self filterEditorPath] mailSpool:self]];
	
	return YES;
}

- (BOOL)loadOpenThreads
{
	NSMutableIndexSet *anOpenThreads = [NSUnarchiver unarchiveObjectWithFile:[[self mailDocumentPath] stringByAppendingPathComponent:@"openThreads"]];
	
	if (anOpenThreads)
		[self setOpenThreads:[[anOpenThreads mutableCopy] autorelease]];

	return YES;
}

@end

@implementation ATMailSpool (Importing)

- (void)importMessages:(NSArray *)aMessagePaths
{
	NSEnumerator *anEnumerator = [aMessagePaths objectEnumerator];
	NSString *aFileName;
	NSMutableArray *aMessages = [NSMutableArray array];
	NSOutputStream *aHeaderOutputStream = [self outputStreamForTemporaryHeaders];
	
	[aHeaderOutputStream open];
	
	while (aFileName = [anEnumerator nextObject])
	{
		NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
		ATInternetMessage *aMessage = [ATInternetMessage messageWithItemID:[self newItemID] afterImportingMessageFrom:aFileName to:self headerOutputStream:aHeaderOutputStream];

		if (aMessage)
			[aMessages addObject:aMessage];
			
		[aPool release];
	}
	
	[aHeaderOutputStream close];
	
	[self addMessages:aMessages];
	[self addUnsavedHeaderFilePath:[self temporaryHeadersFilePath]];
}

@end

@implementation ATMailSpool (DownloadingMessage)

- (void)download
{
	[[self messageDownloader] download];
}

- (void)downloader:(ATPop3MessageDownloader *)sender messageInto:(ATInternetMessage **)aMessage messageOutputStreamInto:(NSOutputStream **)aMessageOutputStream headerOutputStreamInto:(NSOutputStream **)aHeaderOutputStream
{
	ATInternetMessage *aNewMessage = [[[ATInternetMessage alloc] initWithItemID:[self newItemID]] autorelease];
			
	*aMessage = aNewMessage;
	*aMessageOutputStream = [self outputStreamForTemporaryMessage:aNewMessage];
	*aHeaderOutputStream = [self outputStreamForTemporaryHeadersOfDownloader:sender];
}

- (void)downloadFinished:(ATPop3MessageDownloader *)sender
{
	BOOL aMessageUIDLOfAccountIsChanged = [[self mailAccount] updateMessageUIDLToBeSkipped:sender];
	
	if (aMessageUIDLOfAccountIsChanged || [sender hasNewMessages])
	{
		[self addMessages:[sender messages]];
		[self addUnsavedHeaderFilePath:[self temporaryHeadersFilePathFor:sender]];
	}
	
	[self setMessageDownloader:nil];
}

- (void)downloadCanceled:(ATPop3MessageDownloader *)sender
{
	[self removeCanceledMessagesAndHeadersOf:sender];
	[self setMessageDownloader:nil];
}

- (void)removeCanceledMessagesAndHeadersOf:(ATPop3MessageDownloader *)aDownloader
{
	NSEnumerator *anEnumerator = [[aDownloader messages] objectEnumerator];
	ATInternetMessage *aMessage = nil;
	
	while (aMessage = [anEnumerator nextObject])
	{
		NSString *aMessageFilePath = [self temporaryMessageFilePathFor:aMessage];
		
		[[NSFileManager defaultManager] removeFileAtPath:aMessageFilePath handler:nil];
	}
	
	[[NSFileManager defaultManager] removeFileAtPath:[self temporaryHeadersFilePathFor:aDownloader] handler:nil];
}

@end