/* ATMailDocumentWindowController */

#import <Cocoa/Cocoa.h>

@class ATMessageEntity;
@class ATInternetMessage;
@class ATMailSpool;
@class ATMailSpoolModel;
@class ATMessageTablePane;
@class ATMessageOutlinePane;
@class ATMessageTextPane;
@class ATMessageImagePane;
@class ATEntityHeaderPane;
@class ATEntityOutlinePane;
@class ATHTMLPane;
@class ATMailboxesOutlinePane;

typedef enum { ATNilPaneType = -1, ATMessageTablePaneType, ATMessageOutlinePaneType } ATMessagesPaneType;

@interface ATMailDocumentWindowController : NSWindowController
{	
	IBOutlet id splitView;
	IBOutlet id dummyMessagesView;
	IBOutlet id dummyMessageView;
	
	IBOutlet id entityHeaderDrawer;
	IBOutlet id entityHeaderDrawerContentView;
	IBOutlet id entitySplitView;
	IBOutlet id dummyEntityHeaderView;
	IBOutlet id dummyEntityOutlineView;

	IBOutlet id mailboxesDrawer;
	
	IBOutlet NSObjectController *messagesModelController;
	
	id mailSpoolModel;
	
	id currentMessagesPane;
	ATMessageTablePane *messageTablePane;
	ATMessageOutlinePane *messageOutlinePane;
	
	id currentMessagePane;
	ATMessageTextPane *messageTextPane;
	ATMessageImagePane *messageImagePane;
	ATHTMLPane *messageHTMLPane;
	
	ATEntityHeaderPane *entityHeaderPane;
	ATEntityOutlinePane *entityOutlinePane;
	
	ATMailboxesOutlinePane *mailSpoolOutlinePane;
	
	BOOL inUpdatingOfMessageViews;
	//BOOL inSynchronizationOfViewAndModel;
}

+ (id)windowControllerWithMailSpoolModel:(ATMailSpoolModel *)aModel;

- (id)initWithMailSpoolModel:(ATMailSpoolModel *)aModel;

@end

@interface ATMailDocumentWindowController (Accessing)

- (ATMailSpool *)mailSpool;
- (ATMailSpoolModel *)mailSpoolModel;

- (ATMessagesPaneType)currentMessagesPaneType;
- (void)setCurrentMessagesPaneType:(ATMessagesPaneType)aTag;


- (NSDrawer *)drawerOpenedOnEdge:(NSRectEdge)anEdge;

@end

@interface ATMailDocumentWindowController (Actions)

- (IBAction)turnMessagesViewTo:(id)sender;

- (IBAction)saveBodyOfSelectedEntity:(id)sender;
- (IBAction)showCurrentMessageInFinder:(id)sender;
- (IBAction)makeSelectionsToBeRead:(id)sender;
- (IBAction)makeSelectionsRead:(id)sender;

- (IBAction)toggleMailboxesDrawer:(id)sender;
- (IBAction)toggleEntityDrawer:(id)sender;

- (void)toggleDrawer:(NSDrawer *)aDrawer;

- (IBAction)applyFiltersToSelectedMessages:(id)sender;

@end

@interface ATMailDocumentWindowController (UpdatingView)

- (void)changeMessagesPaneTo:(id)aMessagesPane;
- (void)changeMessagePaneTo:(id)aMessagePane;

- (void)updateSelectionsInViewWith:(NSArray *)aSelections;

- (void)updateMessageViewWithSelectedEntity:(ATMessageEntity *)aSelectedEntity;

@end

@interface ATMailDocumentWindowController (SavingAndLoading)

- (id)propertyListRepresentation;
- (id)propertyListRepresentationForDrawer:(NSDrawer *)aDrawer;

- (void)setPropertyListRepresentation:(id)aPlist;
- (void)setDrawerSettings:(id)aDrawerPlist toDrawer:(NSDrawer *)aDrawer;

@end