#import "ATMailDocumentWindowController.h"
#import "ATInternetMessage.h"
#import "ATMailSpool.h"
#import "ATMailSpoolModel.h"
#import "ATMessageModel.h"
#import "ATBodyTextRepresentation.h"
#import "ATMailboxesOutlinePane.h"

@implementation ATMailDocumentWindowController

+ (id)windowControllerWithMailSpoolModel:(ATMailSpoolModel *)aModel
{
	return [[[self alloc] initWithMailSpoolModel:aModel] autorelease];
}

- (id)initWithMailSpoolModel:(ATMailSpoolModel *)aModel
{
	[super initWithWindowNibName:@"ATMailDocumentWindow"];
	
	[self setMailSpoolModel:aModel];
	
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[messageTablePane release];
	[messageOutlinePane release];
	[messageTextPane release];
	[messageHTMLPane release];
	[messageImagePane release];
	[entityHeaderPane release];
	[entityOutlinePane release];
	[mailSpoolOutlinePane release];
	
	[[self mailSpoolModel] setMailSpool:nil];
	
	[super dealloc];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
		
	messageTablePane = [[ATMessageTablePane alloc] initWith:[[self mailSpoolModel] messagesModel]];
	messageOutlinePane = [[ATMessageOutlinePane alloc] initWith:[[self mailSpoolModel] threadsModel]];

	messageTextPane = [[ATMessageTextPane alloc] initWith:[[self mailSpoolModel] messageModel]];
	messageHTMLPane = [[ATHTMLPane alloc] initWith:[[self mailSpoolModel] messageModel]];
	messageImagePane = [[ATMessageImagePane alloc] initWith:[[self mailSpoolModel] messageModel]];
	[self updateMessageViewWithSelectedEntity:[[[self mailSpoolModel] messageModel] selectedEntity]];
	
	entityHeaderPane = [[ATEntityHeaderPane alloc] initWith:[[self mailSpoolModel] messageModel]];
	entityOutlinePane = [[ATEntityOutlinePane alloc] initWith:[[self mailSpoolModel] messageModel]];
	[[entityHeaderPane contentView] setFrameSize:[dummyEntityHeaderView frame].size];
	[entitySplitView replaceSubview:dummyEntityHeaderView with:[entityHeaderPane contentView]];
	[entitySplitView replaceSubview:dummyEntityOutlineView with:[entityOutlinePane contentView]];
	
	mailSpoolOutlinePane = [[ATMailboxesOutlinePane alloc] initWith:mailSpoolModel];
	[mailboxesDrawer setContentView:[mailSpoolOutlinePane contentView]];
	[mailSpoolOutlinePane setupResponderChain];

	[self changeMessagesPaneTo:messageTablePane];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageEntitySelectionDidChange:) name:ATMessageModelEntitySelectionDidChangeNotification object:[[self mailSpoolModel] messageModel]]; 
}

- (void)mailSpoolCurrentMailboxDidChange:(NSNotification *)aNotification
{
	[messageTablePane setModel:[[self mailSpoolModel] messagesModel]];
	[messageOutlinePane setModel:[[self mailSpoolModel] threadsModel]];
	
	[messagesModelController setContent:[currentMessagesPane model]];
}

@end

@implementation ATMailDocumentWindowController (Accessing)

- (ATMailSpool *)mailSpool
{
	return [[self document] mailSpool];
}

- (ATMailSpoolModel *)mailSpoolModel
{
	return mailSpoolModel;
}

- (void)setMailSpoolModel:(ATMailSpoolModel *)aModel
{
	if (mailSpoolModel != aModel)
	{
		if (mailSpoolModel)
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:mailSpoolModel];
		}
		
		[mailSpoolModel release];
		mailSpoolModel = [aModel retain];
		
		if (mailSpoolModel)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSpoolCurrentMailboxDidChange:) name:ATCurrentMailboxDidChangeNotification object:mailSpoolModel];
		
			if ([self isWindowLoaded])
				[messagesModelController setContent:[currentMessagesPane model]];
		}
	}
}

- (ATMessagesPaneType)currentMessagesPaneType
{
	if (!currentMessagesPane)
		return ATNilPaneType;
	else if (currentMessagesPane == messageTablePane)
		return ATMessageTablePaneType;
	else if (currentMessagesPane == messageOutlinePane)
		return ATMessageOutlinePaneType;
}

- (void)setCurrentMessagesPaneType:(ATMessagesPaneType)aTag
{
	if (aTag == ATMessageTablePaneType)
		[self changeMessagesPaneTo:messageTablePane];
	else if (aTag == ATMessageOutlinePaneType)
		[self changeMessagesPaneTo:messageOutlinePane];
}

- (NSDrawer *)drawerOpenedOnEdge:(NSRectEdge)anEdge
{
	NSEnumerator *anEnumerator = [[[self window] drawers] objectEnumerator];
	NSDrawer *aDrawer = nil;
	
	while (aDrawer = [anEnumerator nextObject])
	{
		if ([aDrawer state] == NSDrawerOpenState && [aDrawer edge] == anEdge)
			break;
	}
	
	return aDrawer;
}

@end

@implementation ATMailDocumentWindowController (Actions)

- (IBAction)saveBodyOfSelectedEntity:(id)sender
{
	[[NSSavePanel savePanel] beginSheetForDirectory:nil file:[[[self mailSpoolModel] messageModel] filename] modalForWindow:[self window] modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton)
		[[[self mailSpoolModel] messageModel] saveBodyOfSelectedEntityTo:[sheet filename]];
}

- (IBAction)showCurrentMessageInFinder:(id)sender
{
	[[self mailSpoolModel] showCurrentMessageInFinder];
}

- (IBAction)turnMessagesViewTo:(id)sender
{	
	[self setCurrentMessagesPaneType:[sender selectedSegment]];
}

- (IBAction)makeSelectionsToBeRead:(id)sender
{
	[[self mailSpoolModel] makeSelectionsToBeRead:YES];
}

- (IBAction)makeSelectionsRead:(id)sender
{
	[[self mailSpoolModel] makeSelectionsToBeRead:NO];
}

- (IBAction)toggleMailboxesDrawer:(id)sender
{
	[self toggleDrawer:mailboxesDrawer];
}

- (IBAction)toggleEntityDrawer:(id)sender
{
	[self toggleDrawer:entityHeaderDrawer];
}

- (void)toggleDrawer:(NSDrawer *)aDrawer
{
	if ([aDrawer state] == NSDrawerClosedState || [aDrawer state] == NSDrawerClosingState)
	{
		if ([self drawerOpenedOnEdge:[aDrawer preferredEdge]])
		{
			NSRectEdge anEdgeToOpen;
			
			if ([aDrawer preferredEdge] == NSMinXEdge)
				anEdgeToOpen = NSMaxXEdge;
			else if ([aDrawer preferredEdge] == NSMaxXEdge)
				anEdgeToOpen = NSMinXEdge;
				
			[aDrawer openOnEdge:anEdgeToOpen];
		}
		else
			[aDrawer open];
	}
	else
		[aDrawer close];
}

- (IBAction)filterMessagesOfCurrentMailbox:(id)sender
{
	[[self mailSpoolModel] filterMessagesOfCurrentMailbox:sender];
}

- (IBAction)applyFiltersToSelectedMessages:(id)sender
{
	[[self mailSpoolModel] applyFilterToSelections];
}

@end

@implementation ATMailDocumentWindowController (UpdatingView)

- (void)changeMessagesPaneTo:(id)aMessagesPane
{
	NSView *anOldView = currentMessagesPane ? [currentMessagesPane contentView] : dummyMessagesView;
	
	if (anOldView != [aMessagesPane contentView])
	{
		[self willChangeValueForKey:@"currentMessagesPaneType"];
		
		if (currentMessagesPane)
			[currentMessagesPane restoreResponderChain];
			
		[[aMessagesPane contentView] setFrameSize:[anOldView frame].size];
		[splitView replaceSubview:anOldView with:[aMessagesPane contentView]];
		[aMessagesPane setupResponderChain];
		currentMessagesPane = aMessagesPane;
		[messagesModelController setContent:[currentMessagesPane model]];
		
		[self didChangeValueForKey:@"currentMessagesPaneType"];
		
		[[self window] makeFirstResponder:[currentMessagesPane view]];
	}
}

- (void)changeMessagePaneTo:(id)aMessagePane
{
	NSView *anOldView = currentMessagePane ? [currentMessagePane contentView] : dummyMessageView;
	
	[[aMessagePane contentView] setFrameSize:[anOldView frame].size];
	[splitView replaceSubview:anOldView with:[aMessagePane contentView]];
	currentMessagePane = aMessagePane;
}

- (id)preferredMessagePaneFor:(ATMessageEntity *)anEntity
{
	if ([anEntity contentTypeIsText])
	{
		if ([anEntity contentTypeIsHTML])
			return messageHTMLPane;
		else
			return messageTextPane;
	}
	else if ([anEntity contentTypeIsImage])
		return messageImagePane;
	
	return messageTextPane;
}

- (void)messageEntitySelectionDidChange:(NSNotification *)aNotification
{
	ATMessageEntity *aSelectedEntity = [[aNotification userInfo] objectForKey:ATSelectedEntityKey];
	
	[self updateMessageViewWithSelectedEntity:aSelectedEntity];
}

- (void)updateMessageViewWithSelectedEntity:(ATMessageEntity *)aSelectedEntity
{
	id aPreferredEntity = [aSelectedEntity preferredEntity];
	id aPreferredPane = [self preferredMessagePaneFor:aPreferredEntity];
		
	[self changeMessagePaneTo:aPreferredPane];
	[aPreferredPane setEntity:aPreferredEntity];
	
	//[[self window] makeFirstResponder:[currentMessagePane view]];
}

@end

@implementation ATMailDocumentWindowController (SavingAndLoading)

- (id)propertyListRepresentation
{
	NSMutableDictionary *aPlist = [NSMutableDictionary dictionary];
	NSMutableDictionary *aWindowSettings = [NSMutableDictionary dictionary];
	
	[messageTablePane storeColumns];
	[messageOutlinePane storeColumns];
	
	[aWindowSettings setObject:[[self window] stringWithSavedFrame] forKey:@"windowFrame"];
	[aWindowSettings setObject:[NSNumber numberWithInt:[self currentMessagesPaneType]] forKey:@"currentMessagesPaneType"];
	[aWindowSettings setObject:[currentMessagesPane propertyListRepresentation] forKey:@"messagesPaneSettings"];
	[aWindowSettings setObject:[currentMessagePane propertyListRepresentation] forKey:@"messagePaneSettings"];
	[aWindowSettings setObject:[self propertyListRepresentationForDrawer:mailboxesDrawer] forKey:@"mailboxesDrawer"];
	[aWindowSettings setObject:[self propertyListRepresentationForDrawer:entityHeaderDrawer] forKey:@"entityDrawer"];
	
	[aPlist setObject:[[self mailSpoolModel] propertyListRepresentation] forKey:@"mailSpoolModelSettings"];
	[aPlist setObject:aWindowSettings forKey:@"windowSettings"];
	
	return aPlist;
}

- (id)propertyListRepresentationForDrawer:(NSDrawer *)aDrawer
{
	NSMutableDictionary *aDrawerPlist = [NSMutableDictionary dictionary];
	
	[aDrawerPlist setObject:[NSNumber numberWithBool:([aDrawer state] == NSDrawerOpenState)] forKey:@"isOpen"];
	[aDrawerPlist setObject:[NSNumber numberWithInt:[aDrawer edge]] forKey:@"edge"];
	
	return aDrawerPlist;
}

- (void)setPropertyListRepresentation:(id)aPlist
{
	NSDictionary *aWindowSettings = [aPlist objectForKey:@"windowSettings"];
	
	[self window];
	
	[[self mailSpoolModel] setPropertyListRepresentation:[aPlist objectForKey:@"mailSpoolModelSettings"]];
	
	[currentMessagesPane setPropertyListRepresentation:[aWindowSettings objectForKey:@"messagesPaneSettings"]];
	[currentMessagePane setPropertyListRepresentation:[aWindowSettings objectForKey:@"messagePaneSettings"]];
	[[self window] setFrameFromString:[[aPlist objectForKey:@"windowSettings"] objectForKey:@"windowFrame"]];
	[self setCurrentMessagesPaneType:[[aWindowSettings objectForKey:@"currentMessagesPaneType"] intValue]];
	[self setDrawerSettings:[aWindowSettings objectForKey:@"mailboxesDrawer"] toDrawer:mailboxesDrawer];
	[self setDrawerSettings:[aWindowSettings objectForKey:@"entityDrawer"] toDrawer:entityHeaderDrawer];
}

- (void)setDrawerSettings:(id)aDrawerPlist toDrawer:(NSDrawer *)aDrawer
{
	if ([[aDrawerPlist objectForKey:@"isOpen"] boolValue])
		[aDrawer openOnEdge:[[aDrawerPlist objectForKey:@"edge"] intValue]];
}
	
@end