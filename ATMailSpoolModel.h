/* ATMailSpoolModel */

#import <Cocoa/Cocoa.h>

@class ATMailSpool;
@class ATInternetMessage;
@class ATMailbox;
@class ATMessagesModel;
@class ATThreadsModel;
@class ATMessageModel;

extern NSString *ATCurrentMailboxDidChangeNotification;
extern NSString *ATMailSpoolModelSelectedMailboxesDidChangeNotification;
extern NSString *ATMailSpoolMessagesModelDidChangeNotification;

@interface ATMailSpoolModel : NSObject
{
	ATMailSpool *mailSpool;
	
	ATMailbox *currentMailbox;
	NSArray *selectedMailboxes;
	
	NSMutableDictionary *messagesModelsDictionary;
	
	ATMessagesModel *messagesModel;
	ATThreadsModel *threadsModel;
	
	ATMessageModel *messageModel;
	
	int pboardChangeCount;
	NSArray *draggingItems;
}

+ (id)modelWithMailSpool:(ATMailSpool *)aMailSpool;

- (id)initWithMailSpool:(ATMailSpool *)aMailSpool;

- (ATMailSpool *)mailSpool;
- (void)setMailSpool:(ATMailSpool *)aMailSpool;

@end

@interface ATMailSpoolModel (Messages)

- (void)makeSelectionsToBeRead:(BOOL)aReadFlag;

- (BOOL)showCurrentMessageInFinder;

- (void)applyFilterToSelections;

@end

@interface ATMailSpoolModel (Mailboxes)

- (NSArray *)selectedMailboxes;
- (void)setSelectedMailboxes:(NSArray *)aSelectedMailboxes;

- (ATMailbox *)currentMailbox;
- (void)setCurrentMailbox:(ATMailbox *)aMailbox;

- (void)makeNewMailbox;

- (void)currentMailboxContentsDidChange:(NSNotification *)aNotification;
- (void)mailboxesDidMove:(NSNotification *)aNotification;

@end

@interface ATMailSpoolModel (MessagesModel)

- (ATMessagesModel *)messagesModel;
- (void)setMessagesModel:(ATMessagesModel *)aModel;

- (void)setMessagesModelsForMailbox:(ATMailbox *)aMailbox;
- (ATMessagesModel *)messagesModelsFor:(ATMailbox *)aMailbox;

- (NSMutableDictionary *)messagesModelsDictionary;
- (void)setMessagesModelsDictionary:(NSMutableDictionary *)aDictionary;

- (void)messagesModelCurrentMessageDidChange:(NSNotification *)aNotification;

@end

@interface ATMailSpoolModel (ThreadsModel)

- (ATThreadsModel *)threadsModel;
- (void)setThreadsModel:(ATThreadsModel *)aModel;

@end

@interface ATMailSpoolModel (MessageModel)

- (ATMessageModel *)messageModel;
- (void)setMessageModel:(ATMessageModel *)aModel;

@end

@interface ATMailSpoolModel (DraggingAndDropping)

- (void)writeItems:(NSArray *)anItems toPasteBoard:(NSPasteboard *)aPboard;
- (NSArray *)draggingItems;
- (void)setDraggingItems:(NSArray *)anItems;
- (NSArray *)pboardTypes;

- (NSDragOperation)validateDrop:(id <NSDraggingInfo>)anInfo proposedItem:(id)anItem proposedChildIndex:(int)anIndex;
- (BOOL)acceptDrop:(id <NSDraggingInfo>)anInfo item:(id)anItem childIndex:(int)anIndex;

@end

@interface ATMailSpoolModel (SavingAndLoading)

- (id)propertyListRepresentation;
- (void)setPropertyListRepresentation:(id)aPlist;

@end