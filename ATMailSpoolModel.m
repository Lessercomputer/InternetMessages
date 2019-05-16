#import "ATMailSpoolModel.h"
#import "ATMailSpool.h"
#import "ATInternetMessage.h"
#import "ATMailbox.h"
#import "ATMessagesModel.h"
#import "ATMessageModel.h"

NSString *ATCurrentMailboxDidChangeNotification = @"ATCurrentMailboxDidChangeNotification";
NSString *ATMailSpoolModelSelectedMailboxesDidChangeNotification = @"ATMailSpoolModelSelectedMailboxesDidChangeNotification";
NSString *ATMailSpoolMessagesModelDidChangeNotification = @"ATMailSpoolMessagesModelDidChangeNotification";

@implementation ATMailSpoolModel

+ (id)modelWithMailSpool:(ATMailSpool *)aMailSpool
{
	return [[[self alloc] initWithMailSpool:aMailSpool] autorelease];
}

- (id)initWithMailSpool:(ATMailSpool *)aMailSpool
{
	[super init];
	
	[self setMessagesModelsDictionary:[NSMutableDictionary dictionary]];
	[self setMailSpool:aMailSpool];
	[self setMessageModel:[[[ATMessageModel alloc] init] autorelease]];
	
	return self;
}

- (void)dealloc
{
	[self setDraggingItems:nil];
	[self setCurrentMailbox:nil];
	[self setSelectedMailboxes:nil];
	[self setMessagesModelsDictionary:nil];
	[self setMailSpool:nil];

	[super dealloc];
}

- (ATMailSpool *)mailSpool
{
	return mailSpool;
}

- (void)setMailSpool:(ATMailSpool *)aMailSpool
{
	if (mailSpool != aMailSpool)
	{
		if (mailSpool)
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			
		[mailSpool release];
		mailSpool = [aMailSpool retain];
	
		if (mailSpool)
		{
			[self setCurrentMailbox:[mailSpool entireMessagesMailbox]];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailboxesDidMove:) name:ATMailboxesDidMoveNotification object:mailSpool];
		}
	}
}

@end

@implementation ATMailSpoolModel (Messages)

- (BOOL)showCurrentMessageInFinder
{
	return [[NSWorkspace sharedWorkspace] selectFile:[mailSpool accessibleMessageFilePathFor:[self currentMessage]] inFileViewerRootedAtPath:@""];
}

- (void)makeSelectionsToBeRead:(BOOL)aReadFlag
{
	[[self selections] makeObjectsPerformSelector:@selector(setToBeRead:) withObject:aReadFlag];
}

- (void)applyFilterToSelections
{
	[[[self mailSpool] filterEditor] filterAndMove:[self selections]];
}

@end

@implementation ATMailSpoolModel (Mailboxes)

- (NSArray *)selectedMailboxes
{
	return selectedMailboxes;
}

- (void)setSelectedMailboxes:(NSArray *)aSelectedMailboxes
{
	if ((selectedMailboxes != aSelectedMailboxes) && ![selectedMailboxes isEqualToArray:aSelectedMailboxes])
	{
		[selectedMailboxes release];
		selectedMailboxes = [aSelectedMailboxes copy];
		
		if ([selectedMailboxes count])
			[self setCurrentMailbox:[selectedMailboxes objectAtIndex:0]];
		else
			[self setCurrentMailbox:nil];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ATMailSpoolModelSelectedMailboxesDidChangeNotification object:self];
	}
}

- (ATMailbox *)currentMailbox
{
	return currentMailbox;
}

- (void)setCurrentMailbox:(ATMailbox *)aMailbox
{
	if (currentMailbox != aMailbox)
	{
		/*if (currentMailbox)
			[self setMessagesModel:nil];*/
	
		[currentMailbox release];
		currentMailbox = [aMailbox retain];
	
		if (currentMailbox)
			[self setMessagesModelsForMailbox:currentMailbox];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ATCurrentMailboxDidChangeNotification object:self];
	}
}

- (void)makeNewMailbox
{
	ATMailbox *aMailbox = [[self mailSpool] makeMailboxWithName:@"Untitled Mailbox" weak:NO];
	
	if ([self currentMailbox])
		[[self mailSpool] addMailbox:aMailbox to:[self currentMailbox]];
	else
		[[self mailSpool] addMailbox:aMailbox to:[[self mailSpool] root]];
}


- (void)mailboxesDidMove:(NSNotification *)aNotification
{
	//[self setSelectedMailboxes:[[aNotification userInfo] objectForKey:@"mailboxes"]];
	[[NSNotificationCenter defaultCenter] postNotificationName:[aNotification name] object:self userInfo:[aNotification userInfo]];
}

@end

@implementation ATMailSpoolModel (MessagesModel)

- (ATMessagesModel *)messagesModel
{
	return [[self messagesModelsFor:[self currentMailbox]] objectForKey:@"messages"];
}

/*- (void)setMessagesModel:(ATMessagesModel *)aModel
{
	if (messagesModel != aModel)
	{
		if (messagesModel)
			[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:messagesModel];//removeObserver:self name:ATMessagesModelContentsDidChangeNotification object:messagesModel];
			
			
		[messagesModel release];
		messagesModel = [aModel retain];
		
		if (messagesModel)
		{
			//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesModelContentsDidChange:) name:ATMessagesModelContentsDidChangeNotification object:messagesModel];
			//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesModelCurrentMessageDidChange:) name:ATMessagesModelCurrentMessageDidChangeNotification object:messagesModel];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ATMailSpoolMessagesModelDidChangeNotification object:self];
	}
}*/

- (void)setMessagesModelsForMailbox:(ATMailbox *)aMailbox
{
	if (aMailbox)
	{
		NSMutableDictionary *aMessagesModels = [self messagesModelsFor:aMailbox];
		NSEnumerator *anEnumerator = nil;
		ATMessagesModel *aMessagesModel = nil;
		
		if (!aMessagesModels)
		{
			ATMessagesModel *aMessagesModel = [ATMessagesModel messagesModelWithMailbox:aMailbox mailSpool:[self mailSpool]];
			ATThreadsModel *aThreadsModel = [ATThreadsModel messagesModelWithMailbox:aMailbox mailSpool:[self mailSpool]];
			
			aMessagesModels = [NSMutableDictionary dictionary];
			
			[aMessagesModels setObject:aMessagesModel forKey:@"messages"];
			[aMessagesModels setObject:aThreadsModel forKey:@"threads"];

			[[self messagesModelsDictionary] setObject:aMessagesModels forKey:[aMailbox mailboxIDNumber]];
		}
		
		anEnumerator = [aMessagesModels objectEnumerator];
		
		while (aMessagesModel = [anEnumerator nextObject])
		{
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messagesModelCurrentMessageDidChange:) name:ATMessagesModelCurrentMessageDidChangeNotification object:aMessagesModel];
		}
	}
}

- (NSMutableDictionary *)messagesModelsFor:(ATMailbox *)aMailbox
{
	return [[self messagesModelsDictionary] objectForKey:[aMailbox mailboxIDNumber]];
}

- (NSMutableDictionary *)messagesModelsDictionary
{
	return messagesModelsDictionary;
}

- (void)setMessagesModelsDictionary:(NSMutableDictionary *)aDictionary
{
	[messagesModelsDictionary release];
	messagesModelsDictionary = [aDictionary retain];
}

- (void)messagesModelCurrentMessageDidChange:(NSNotification *)aNotification
{
	[messageModel setMessage:[[aNotification userInfo] objectForKey:ATSelectedMessageKey]];
}

@end

@implementation ATMailSpoolModel (ThreadsModel)

- (ATThreadsModel *)threadsModel
{
	return [[self messagesModelsFor:[self currentMailbox]] objectForKey:@"threads"];
}

/*- (void)setThreadsModel:(ATThreadsModel *)aModel
{
	if (threadsModel != aModel)
	{
	}
}*/

@end

@implementation ATMailSpoolModel (MessageModel)

- (ATMessageModel *)messageModel
{
	return messageModel;
}

- (void)setMessageModel:(ATMessageModel *)aModel
{
	[messageModel release];
	messageModel = [aModel retain];
}

@end

@implementation ATMailSpoolModel (DraggingAndDropping)

- (void)writeItems:(NSArray *)anItems toPasteBoard:(NSPasteboard *)aPboard
{
	pboardChangeCount = [aPboard declareTypes:[NSArray arrayWithObject:ATItemIDsPboardType] owner:self];
	[aPboard setPropertyList:[[self mailSpool] itemIDsFor:anItems] forType:ATItemIDsPboardType];
	[self setDraggingItems:anItems];
}

- (void)pasteboardChangedOwner:(NSPasteboard *)sender
{
	[self setDraggingItems:nil];
}

- (NSArray *)draggingItems
{
	return draggingItems;
}

- (void)setDraggingItems:(NSArray *)anItems
{
	[draggingItems release];
	draggingItems = [anItems copy];
}

- (NSArray *)pboardTypes
{
	return [NSArray arrayWithObjects:ATMailboxesIDsPboardType, ATItemIDsPboardType, nil];
}

/*- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)aType
{
	
}*/

- (NSDragOperation)validateDrop:(id <NSDraggingInfo>)anInfo proposedItem:(id)anItem proposedChildIndex:(int)anIndex
{
	ATMailbox *aDroppingMailbox = [[self draggingItems] lastObject];

	if ((pboardChangeCount != [[anInfo draggingPasteboard] changeCount])
		|| [anItem isEqualOrDescendantOf:aDroppingMailbox]
		|| [anItem isEqual:[[self mailSpool] entireMessagesMailbox]]
		|| ([aDroppingMailbox isEqual:[[self mailSpool] entireMessagesMailbox]] && anItem)
		|| (!anItem && [[self mailSpool] messageIsIncludedIn:[self draggingItems]]))
	{
			return NSDragOperationNone;
	}
	
	return NSDragOperationMove;
}

- (BOOL)acceptDrop:(id <NSDraggingInfo>)anInfo item:(id)anItem childIndex:(int)anIndex
{
	ATMailbox *aTargetMailbox = anItem ? anItem : [[self mailSpool] root];
	unsigned aStartIndex = anIndex == -1 ? [aTargetMailbox count] : anIndex;
	
	[aTargetMailbox moveMailboxes:[self draggingItems] at:aStartIndex];
	
	return YES;
}

@end

@implementation ATMailSpoolModel (SavingAndLoading)

- (id)propertyListRepresentation
{
	NSEnumerator *anEnumerator = [[self messagesModelsDictionary] keyEnumerator];
	NSNumber *aMailboxIDNumber = nil;
	NSMutableDictionary *aMessagesModelsPlist = [NSMutableDictionary dictionary];
	
	while (aMailboxIDNumber = [anEnumerator nextObject])
	{
		NSDictionary *aMessagesModels = [[self messagesModelsDictionary] objectForKey:aMailboxIDNumber];
		NSDictionary *aMessagesModelPlist = [[aMessagesModels objectForKey:@"messages"] propertyListRepresentation];
		NSDictionary *aThreadsModelPlist = [[aMessagesModels objectForKey:@"threads"] propertyListRepresentation];
		NSDictionary *aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:aMessagesModelPlist,@"messages", aThreadsModelPlist,@"threads", nil];
		
		[aMessagesModelsPlist setObject:aDictionary forKey:[aMailboxIDNumber stringValue]];
	}
	
	return [NSDictionary dictionaryWithObjectsAndKeys:[[self currentMailbox] mailboxIDNumber],@"currentMailboxID", aMessagesModelsPlist,@"messagesModels", nil];
}

- (void)setPropertyListRepresentation:(id)aPlist
{
	//[self setCurrentMailbox:[[self mailSpool] mailboxForIDNumber:[aPlist objectForKey:@"currentMailboxID"]]];
	NSMutableDictionary *aMessagesModels = [NSMutableDictionary dictionary];
	NSDictionary *aMessagesModelsPlist = [aPlist objectForKey:@"messagesModels"];
	NSEnumerator *anEnumerator = [aMessagesModelsPlist keyEnumerator];
	NSString *aMailboxIDString = nil;
	
	while (aMailboxIDString = [anEnumerator nextObject])
	{
		NSNumber *aMailboxIDNumber = [NSNumber numberWithInt:[aMailboxIDString intValue]];
		ATMailbox *aMailbox = [[self mailSpool] mailboxForIDNumber:aMailboxIDNumber];
		ATMessagesModel *aMessagesModel = [ATMessagesModel messagesModelWithPropertyList:[[aMessagesModelsPlist objectForKey:aMailboxIDString] objectForKey:@"messages"] mailbox:aMailbox mailSpool:[self mailSpool]];
		ATThreadsModel *aThreadsModel = [ATThreadsModel messagesModelWithPropertyList:[[aMessagesModelsPlist objectForKey:aMailboxIDString] objectForKey:@"threads"] mailbox:aMailbox mailSpool:[self mailSpool]];
		NSDictionary *aMessagesModelsEntry = [NSDictionary dictionaryWithObjectsAndKeys:aMessagesModel,@"messages", aThreadsModel,@"threads", nil];
		
		[aMessagesModels setObject:aMessagesModelsEntry forKey:aMailboxIDNumber];
	}
	
	[self setMessagesModelsDictionary:aMessagesModels];
	
	[self setSelectedMailboxes:[NSArray arrayWithObject:[[self mailSpool] mailboxForIDNumber:[aPlist objectForKey:@"currentMailboxID"]]]];
}

@end