//
//  ATMailbox.m
//  ATMail
//
//  Created by 高田 明史 on 08/01/31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATMailbox.h"
#import "ATMailSpool.h"

NSString *ATMailboxContentsDidChangeNotification = @"ATMailboxContentsDidChangeNotification";
NSString *ATMailboxesDidMoveNotification = @"ATMailboxesDidMoveNotification";

NSString *ATMailboxesPropertyListPboardType = @"ATMailboxesPropertyListPboardType";
NSString *ATMailboxesIDsPboardType = @"NSString *ATMailboxesIDsPboardType";

@implementation ATMailbox

- (id)retain
{
	return [super retain];
}

@end

@implementation ATMailbox (Initializing)

+ (id)mailbox
{
	return [[[self alloc] initWithName:@""] autorelease];
}

+ (id)mailboxWithName:(NSString *)aName
{
	return [[[self alloc] initWithName:aName] autorelease];
}

+ (id)mailboxWithName:(NSString *)aName weak:(BOOL)aWeakFlag
{
	return [[[self alloc] initWithName:aName weak:aWeakFlag] autorelease];
}

+ (id)mailboxWithName:(NSString *)aName weak:(BOOL)aWeakFlag mailboxID:(unsigned)aMailboxID
{
	return [[[self alloc] initWithName:aName weak:aWeakFlag mailboxID:aMailboxID] autorelease];
}

+ (id)mailboxWithContentsOfFile:(NSString *)aPath mailSpool:(ATMailSpool *)aMailSpool
{
	NSData *aData = [NSData dataWithContentsOfFile:aPath];
	
	if (aData)
	{
		NSPropertyListFormat aPropertyListFormat;
		id aPropertyList = [NSPropertyListSerialization propertyListFromData:aData mutabilityOption:NSPropertyListImmutable format:&aPropertyListFormat errorDescription:nil];
	
		return [self mailboxWithPropertyList:aPropertyList mailSpool:aMailSpool];
	}
	else
		return nil;
}

+ (id)mailboxWithPropertyList:(id)aPropertyList mailSpool:(ATMailSpool *)aMailSpool
{
	return [[[self alloc] initWithPropertyList:aPropertyList mailSpool:aMailSpool] autorelease];
}

- (id)initWithName:(NSString *)aName
{
	return [self initWithName:aName weak:NO];
}

- (id)initWithName:(NSString *)aName weak:(BOOL)aWeakFlag
{
	return [self initWithName:aName weak:aWeakFlag mailboxID:NSNotFound];
}

- (id)initWithName:(NSString *)aName weak:(BOOL)aWeakFlag mailboxID:(unsigned)aMailboxID
{
	[super init];
	
	[self setName:aName];
	[self setMessages:[NSMutableArray array]];
	[self setUnresolvedMessages:[NSArray array]];
	[self setMailboxes:[NSMutableArray array]];
	isWeak = aWeakFlag;
	[self setMailboxID:aMailboxID];
	messageDictionary = [NSMutableDictionary new];
	
	return self;
}

- (id)initWithPropertyList:(id)aPropertyList mailSpool:(ATMailSpool *)aMailSpool
{
	NSEnumerator *anEnumerator = [[aPropertyList objectForKey:@"messages"] objectEnumerator];
	id anItem = nil;
	
	[self initWithName:[aPropertyList objectForKey:@"name"] weak:[[aPropertyList objectForKey:@"isWeak"] boolValue] mailboxID:[[aPropertyList objectForKey:@"mailboxID"] unsignedIntValue]];
	[self setMailSpool:aMailSpool];
	
	while (anItem = [anEnumerator nextObject])
	{
		ATInternetMessage *aMessage = [aMailSpool messageForItemIDNumber:anItem];
		ATMsgID *aMessageID = [aMessage messageIDValue];
		
		[self add:aMessage];
		
		if (aMessageID)
		{
			[messageDictionary setObject:aMessage forKey:aMessageID];
		}
	}
	
	anEnumerator = [[aPropertyList objectForKey:@"mailboxes"] objectEnumerator];
	
	while (anItem = [anEnumerator nextObject])
		[self add:[ATMailbox mailboxWithPropertyList:anItem mailSpool:aMailSpool]];
	
	[self updateThreads];
	//[self setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date.body.value" ascending:NO] autorelease]]];
	
	return self;
}

- (void)dealloc
{
	NSLog([self name]);
	[self setMailSpool:nil];
	[self setName:nil];
	[self setMessages:nil];
	[self setMailboxes:nil];
	[self setThreads:nil];
	[messageDictionary release];
	messageDictionary = nil;
	[self setUnresolvedMessages:nil];
	
	[super dealloc];
}

@end

@implementation ATMailbox (Accessing)

- (unsigned)mailboxID
{
	return mailboxID;
}

- (void)setMailboxID:(unsigned)aMailboxID
{
	mailboxID = aMailboxID;
}

- (NSNumber *)mailboxIDNumber
{
	return [NSNumber numberWithUnsignedInt:[self mailboxID]];
}

- (NSString *)name
{
	return name;
}

- (void)setName:(NSString *)aName
{
	if (name != aName)
	{
		[name release];
		name = [aName copy];
		
		[[self mailSpool] mailboxDidChangeName:self];
	}
}

- (ATMailbox *)parent
{
	return parent;
}

- (void)setParent:(ATMailbox *)aParent
{
	parent = aParent;
}

- (unsigned)indexOf:(id)anItem
{
	return [anItem isMessage] ? [[self messages] indexOfObject:anItem] : [[self mailboxes] indexOfObject:anItem];
}

- (ATMailSpool *)mailSpool
{
	return mailSpool;
}

- (void)setMailSpool:(ATMailSpool *)aMailSpool
{
	mailSpool = aMailSpool;
	
	if (![self isWeak])
	{
		[[self messages] makeObjectsPerformSelector:@selector(setMailSpool:) withObject:mailSpool];
		[[self mailboxes] makeObjectsPerformSelector:@selector(setMailSpool:) withObject:mailSpool];
	}
}

- (NSIndexSet *)indexSetWith:(NSArray *)aSelections
{
	return [self indexSetWith:aSelections in:[self messages]];
}

- (NSIndexSet *)indexSetWith:(NSArray *)aSelections in:(NSArray *)aMessages
{
	NSEnumerator *anEnumeratorOfSelections = [aSelections objectEnumerator];
	ATInternetMessage *aMessage = nil;
	NSMutableIndexSet *anIndexSet = [NSMutableIndexSet indexSet];
	
	while (aMessage = [anEnumeratorOfSelections nextObject])
	{
		unsigned anIndex = [aMessages indexOfObject:aMessage];
		
		if (anIndex != NSNotFound)
			[anIndexSet addIndex:anIndex];
	}
	
	return anIndexSet;
}

- (NSDictionary *)itemIDPropertyList
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:[self mailboxID]],@"itemID", @"mailbox",@"type", nil];
}

@end

@implementation ATMailbox (AccessingToMessage)

- (NSMutableArray *)messages
{
	return messages;
}

- (void)setMessages:(NSMutableArray *)aMessages
{
	NSEnumerator *anEnumerator = [aMessages objectEnumerator];
	id aMessage = nil;
	
	if (![self isWeak])
		[messages makeObjectsPerformSelector:@selector(setParent:) withObject:nil];
		
	[messages release];
	messages = [aMessages retain];
	
	if (![self isWeak])
		[messages makeObjectsPerformSelector:@selector(setParent:) withObject:self];
}

- (NSArray *)unresolvedMessages
{
	return unresolvedMessages;
}

- (void)setUnresolvedMessages:(NSArray *)anUnresolvedMessages
{
	[unresolvedMessages release];
	unresolvedMessages = [anUnresolvedMessages copy];
}

- (unsigned)count
{
	return [[self messages] count];
}

- (id)at:(unsigned)anIndex
{
	return [[self messages] objectAtIndex:anIndex];
}

- (NSArray *)atIndexes:(NSIndexSet *)anIndexes
{
	NSMutableArray *anItems = [NSMutableArray array];
	id anItem = nil;
	unsigned i = 0;
	
	for ( ; (i = [anIndexes indexGreaterThanOrEqualToIndex:i]) != NSNotFound ; i++)
	{
		[anItems addObject:[self at:i]];
	}
	
	return anItems;
}

- (NSArray *)messagesForMessageID:(ATMsgID *)aMessageID
{
	return [ATInternetMessage messagesForMessageID:aMessageID in:[self messages]];
}

@end

@implementation ATMailbox (AccessingToDescendantMailbox)

- (NSMutableArray *)mailboxes
{
	return mailboxes;
}

- (void)setMailboxes:(NSMutableArray *)aMailboxes
{
	[mailboxes release];
	mailboxes = [aMailboxes retain];
}

- (unsigned)countOfMailboxes
{
	return [[self mailboxes] count];
}

- (ATMailbox *)mailboxAt:(unsigned)anIndex
{
	return [[self mailboxes] objectAtIndex:anIndex];
}

- (ATMailbox *)mailboxForName:(NSString *)aName
{
	if ([[self name] isEqualToString:aName])
		return self;
	else
	{
		NSEnumerator *anEnumerator = [[self mailboxes] objectEnumerator];
		ATMailbox *aMailbox = nil, *aTargetMailbox = nil;
		
		while (!aTargetMailbox && (aMailbox = [anEnumerator nextObject]))
		{
			aTargetMailbox = [aMailbox mailboxForName:aName];
		}
		
		return aTargetMailbox;
	}
}

- (ATMailbox *)mailboxFor:(unsigned)aMailboxID
{
	ATMailbox *aTargetMailbox = nil;
	
	if ([self mailboxID] == aMailboxID)
		aTargetMailbox = self;
	else
	{
		NSEnumerator *anEnumerator = [[self mailboxes] objectEnumerator];
		ATMailbox *aMailbox = nil;
		
		while (!aTargetMailbox && (aMailbox = [anEnumerator nextObject]))
		{
			aTargetMailbox = [aMailbox mailboxFor:aMailboxID];
		}
	}
	
	return aTargetMailbox;
}

- (NSArray *)allDescendantMailboxes
{
	NSMutableArray *aMailboxes = [NSMutableArray array];
	
	[self collectAllDescendantMailboxesTo:aMailboxes];
	
	return aMailboxes;
}

- (void)collectAllDescendantMailboxesTo:(NSMutableArray *)aMailboxes
{
	NSEnumerator *anEnumerator = [[self mailboxes] objectEnumerator];
	ATMailbox *aMailbox = nil;
	
	while (aMailbox = [anEnumerator nextObject])
	{
		[aMailboxes addObject:aMailbox];
		[aMailbox collectAllDescendantMailboxesTo:aMailboxes];
	}
}

@end

@implementation ATMailbox (CollectingMailboxes)

+ (NSArray *)toplevelMailboxesIn:(NSArray *)aMailboxes
{
	NSMutableArray *aToplevelMailboxes = [NSMutableArray array];
	NSEnumerator *anEnumerator = [aMailboxes objectEnumerator];
	ATMailbox *aMailbox = nil;
	
	while (aMailbox = [anEnumerator nextObject])
		if (![aMailbox isDescendantIn:aMailboxes])
			[aToplevelMailboxes addObject:aMailbox];
	
	return aToplevelMailboxes;
}

- (NSMutableArray *)rearrangedMessagesWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)aSortDescriptors
{
	NSMutableArray *aRearrangedMessages = [[[self messages] mutableCopy] autorelease];
	
	if (aPredicate)
		[aRearrangedMessages filterUsingPredicate:aPredicate];
		
	if (aSortDescriptors)
		[aRearrangedMessages sortUsingDescriptors:aSortDescriptors];
		
	return aRearrangedMessages;
}

- (NSMutableArray *)rearrangedThreadsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)aSortDescriptors
{
	NSMutableArray *aRearrangedMessages = [[[self threads] mutableCopy] autorelease];
	
	if (aPredicate)
		[aRearrangedMessages filterUsingPredicate:aPredicate];
		
	if (aSortDescriptors)
	{
		NSEnumerator *anEnumerator = [aRearrangedMessages objectEnumerator];
		ATInternetMessage *aMessage = nil;
		
		[aRearrangedMessages sortUsingDescriptors:aSortDescriptors];
		
		while (aMessage = [anEnumerator nextObject])
			[aMessage sortReturnMessagesUsingDescriptors:aSortDescriptors recursive:YES];
	}
			
	return aRearrangedMessages;
}

@end

@implementation ATMailbox (Inserting)

- (void)add:(id)anItem
{
	unsigned anIndex = [anItem isMessage] ? [self count] : [self countOfMailboxes];
	
	[self insert:anItem at:anIndex];
}

- (void)addItems:(NSArray *)anItems
{
	NSEnumerator *anItemsEnumerator = [anItems objectEnumerator];
	id anItem = nil;
	
	while (anItem = [anItemsEnumerator nextObject])
		[self add:anItem];
}

- (void)insert:(id)anItem at:(unsigned)anIndex
{
	if (![self isWeak])
		[anItem setParent:self];
	
	[anItem setMailSpool:[self mailSpool]];
	
	if ([anItem isMessage])
	{
		[[self messages] insertObject:anItem atIndex:anIndex];
	}	
	else
		[[self mailboxes] insertObject:anItem atIndex:anIndex];
		
	[[self mailSpool] mailboxContentsDidChange:self];
}

- (void)addMessages:(NSArray *)aMessages
{	
	if (![self isWeak])
	{
		NSArray *aResolvedReplies = nil;
		NSMutableArray *aStillUnresolvedReplies = [ATInternetMessage resolveParentMessageOf:[self unresolvedMessages] within:[NSArray arrayWithObject:aMessages] putNoneRepliesInto:nil resolvedRepliesInto:&aResolvedReplies];
		NSArray *aNoneReplies = nil;
		NSMutableArray *aNewUnresolvedReplies =  [ATInternetMessage resolveParentMessageOf:aMessages within:[NSArray arrayWithObjects:[self messages], aMessages, nil] putNoneRepliesInto:&aNoneReplies resolvedRepliesInto:nil];
		
		[self setUnresolvedMessages:aStillUnresolvedReplies];
		
		[[self threads] removeObjectsInArray:aResolvedReplies];
		[[self threads] addObjectsFromArray:aNewUnresolvedReplies];
		[[self threads] addObjectsFromArray:aNoneReplies];
	}
	
	[self addItems:aMessages];
	
	if (![self isWeak])
		[aMessages makeObjectsPerformSelector:@selector(openThreadsRecursive:) withObject:YES];
}
	
@end

@implementation ATMailbox (Moving)

- (void)move:(id)anItem at:(unsigned)anIndex
{
	[self moveItems:[NSArray arrayWithObject:anItem] at:anIndex];
}

- (void)moveItems:(NSArray *)anItems at:(unsigned)aStartIndex
{
	NSEnumerator *anEnumerator = [anItems objectEnumerator];
	id anItem = nil;
	unsigned anIndex = aStartIndex;
		
	[[self mailSpool] beginModifying];

	for (; anItem = [anEnumerator nextObject]; anIndex++)
	{
		if ([anItem parent])
			anIndex = [self primitiveMove:anItem at:anIndex];
		else
			[self insert:anItem at:anIndex];
	}
	
	[[self mailSpool] endModifying];
}

- (void)moveMailboxes:(NSArray *)aMailboxes at:(unsigned)aStartIndex
{
	unsigned anIndex = aStartIndex < [self countOfMailboxes] ? [self indexOf:[self mailboxAt:aStartIndex]] : [self countOfMailboxes];

	[self moveItems:aMailboxes at:anIndex];
	
	[[self mailSpool] mailbox:self didMoveMailboxes:aMailboxes];
}

- (unsigned)primitiveMove:(id)anItem at:(unsigned)anIndex
{
	if ([self indexOf:anItem] < anIndex)
		anIndex--;
	
	[[anItem parent] remove:anItem];
	[self insert:anItem at:anIndex];

	return anIndex;
}

@end

@implementation ATMailbox (Removing)

- (void)remove:(id)anItem
{
	if (![self isWeak])
		[anItem setParent:nil];
	
	if ([anItem isMailbox])
		[[self mailboxes] removeObject:anItem];
	else
		[[self messages] removeObject:anItem];
	
	[[self mailSpool] mailboxContentsDidChange:self];
}

@end

@implementation ATMailbox (Dropping)

@end

@implementation ATMailbox (Threads)

- (NSMutableArray *)threads
{
	return threads;
}

- (void)setThreads:(NSMutableArray *)aThreads
{
	[threads release];
	threads = [aThreads retain];
}

- (void)updateThreads
{
	NSLog(@"#updateThreads start");
	[self removeAllThreads];

	NSArray *aNoneReplies = nil;
	//NSMutableArray *aStillUnresolvedReplies = [ATInternetMessage resolveParentMessageOf:[self messages] within:[NSArray arrayWithObject:[self messages]] putNoneRepliesInto:&aNoneReplies resolvedRepliesInto:nil];
	NSMutableArray *aStillUnresolvedReplies = [ATInternetMessage resolveParentMessageOf:[self messages] withinDictionary:messageDictionary putNoneRepliesInto:&aNoneReplies resolvedRepliesInto:nil];
	NSMutableArray *aToplevelThreads = [[aStillUnresolvedReplies mutableCopy] autorelease];
	
	[aToplevelThreads addObjectsFromArray:aNoneReplies];
	[aToplevelThreads sortUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date.body.value" ascending:YES] autorelease]]];
	[aToplevelThreads makeObjectsPerformSelector:@selector(sortReturnMessagesByDate)];
	[self setThreads:aToplevelThreads];
	[self setUnresolvedMessages:aStillUnresolvedReplies];

	NSLog(@"#updateThreads end");
}

- (void)removeAllThreads
{
	NSEnumerator *anEnumerator = [[self messages] objectEnumerator];
	id anItem = nil;
	
	while (anItem = [anEnumerator nextObject])
	{
		if ([anItem isMessage])
			[anItem removeAllReturnMessages];
	}
}

- (void)threadsDidOpen:(ATInternetMessage *)aMessage
{
	[self contentsDidChange];
}

- (void)threadsDidClose:(ATInternetMessage *)aMessage
{
	[self contentsDidChange];
}

- (void)contentsDidChange
{
	[[self mailSpool] beginModifying];
	[[self mailSpool] mailboxContentsDidChange:self];
	[[self mailSpool] endModifying];
}

@end

@implementation ATMailbox (Testing)

- (BOOL)isMailbox
{
	return YES;
}

- (BOOL)isWeak
{
	return isWeak;
}

- (BOOL)isMessage
{
	return NO;
}

- (BOOL)isDescendantOf:(ATMailbox *)aMailbox
{
	if ([self isRoot])
		return NO;
	else
	{
		ATMailbox *anAncestor = [self parent];
		
		while (![anAncestor isEqual:aMailbox] && ![anAncestor isRoot])
		{
			anAncestor = [anAncestor parent];
		}
		
		return [anAncestor isRoot] ? NO : YES;
	}
}

- (BOOL)isEqualOrDescendantOf:(ATMailbox *)aMailbox
{
	return [self isEqual:aMailbox] || [self isDescendantOf:aMailbox];
}

- (BOOL)isDescendantIn:(NSArray *)aMailboxes
{
	NSEnumerator *anEnumerator = [aMailboxes objectEnumerator];
	ATMailbox *aMailbox = nil;
	BOOL aMailboxIsAncestor = NO;
	
	while (!aMailboxIsAncestor && (aMailbox = [anEnumerator nextObject]))
		aMailboxIsAncestor = [self isDescendantOf:aMailbox];
		
	return aMailboxIsAncestor;
}

- (BOOL)isRoot
{
	return [self parent] ? NO : YES;
}

@end

@implementation ATMailbox (Saving)

- (id)propertyListRepresentation
{
	NSMutableArray *aMessages = [NSMutableArray array];
	NSMutableArray *aMailboxes = [NSMutableArray array];
	NSEnumerator *anEnumerator = [[self messages] objectEnumerator];
	id anItem = nil;
	
	while (anItem = [anEnumerator nextObject])
		if (![self isWeak])
			[aMessages addObject:[anItem itemIDNumber]];
	
	anEnumerator = [[self mailboxes] objectEnumerator];
	
	while (anItem = [anEnumerator nextObject])
		[aMailboxes addObject:[anItem propertyListRepresentation]];
		
	return [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:[self mailboxID]],@"mailboxID", [self name],@"name", [NSNumber numberWithBool:[self isWeak]],@"isWeak", aMessages,@"messages", aMailboxes,@"mailboxes", nil];
}

- (BOOL)writeToFile:(NSString *)aPath
{
	NSData *aData = [NSPropertyListSerialization dataFromPropertyList:[self propertyListRepresentation] format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
	
	return [aData writeToFile:aPath atomically:YES];
}

@end
