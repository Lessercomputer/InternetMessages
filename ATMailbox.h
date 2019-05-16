//
//  ATMailbox.h
//  ATMail
//
//  Created by 高田 明史 on 08/01/31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *ATMailboxContentsDidChangeNotification;
extern NSString *ATMailboxesDidMoveNotification;

extern NSString *ATMailboxesPropertyListPboardType;
extern NSString *ATMailboxesIDsPboardType;

@class ATMailSpool;
@class ATMsgID;

@interface ATMailbox : NSObject
{
	NSString *name;
	ATMailbox *parent;
	NSMutableArray *messages;
	/*NSArray *sortDescriptors;
	NSPredicate *predicate;
	NSArray *arrangedMessages;*/
	NSMutableArray *mailboxes;
	BOOL isWeak;
	ATMailSpool *mailSpool;
	unsigned mailboxID;
	NSMutableArray *threads;
	NSArray *unresolvedMessages;
	NSMutableDictionary *messageDictionary;
}

@end

@interface ATMailbox (Initializing)

+ (id)mailbox;
+ (id)mailboxWithName:(NSString *)aName;
+ (id)mailboxWithName:(NSString *)aName weak:(BOOL)aWeakFlag;
+ (id)mailboxWithName:(NSString *)aName weak:(BOOL)aWeakFlag mailboxID:(unsigned)aMailboxID;

+ (id)mailboxWithContentsOfFile:(NSString *)aPath mailSpool:(ATMailSpool *)aMailSpool;
+ (id)mailboxWithPropertyList:(id)aPropertyList mailSpool:(ATMailSpool *)aMailSpool;

- (id)initWithName:(NSString *)aName;
- (id)initWithName:(NSString *)aName weak:(BOOL)aWeakFlag;
- (id)initWithName:(NSString *)aName weak:(BOOL)aWeakFlag mailboxID:(unsigned)aMailboxID;

- (id)initWithPropertyList:(id)aPropertyList mailSpool:(ATMailSpool *)aMailSpool;

@end

@interface ATMailbox (Accessing)

- (unsigned)mailboxID;
- (void)setMailboxID:(unsigned)aMailboxID;

- (NSString *)name;
- (void)setName:(NSString *)aName;

- (ATMailbox *)parent;
- (void)setParent:(ATMailbox *)aParent;

- (ATMailSpool *)mailSpool;
- (void)setMailSpool:(ATMailSpool *)aMailSpool;

- (unsigned)indexOf:(id)anItem;
- (NSIndexSet *)indexSetWith:(NSArray *)aSelections;
- (NSIndexSet *)indexSetWith:(NSArray *)aSelections in:(NSArray *)aMessages;

- (NSNumber *)mailboxIDNumber;
- (NSDictionary *)itemIDPropertyList;

@end

@interface ATMailbox (AccessingToMessage)

- (NSMutableArray *)messages;
- (void)setMessages:(NSMutableArray *)aMessages;

- (NSArray *)unresolvedMessages;
- (void)setUnresolvedMessages:(NSArray *)anUnresolvedMessages;

- (unsigned)count;
- (id)at:(unsigned)anIndex;

- (NSArray *)atIndexes:(NSIndexSet *)anIndexes;

- (NSArray *)messagesForMessageID:(ATMsgID *)aMessageID;

@end

@interface ATMailbox (AccessingToDescendantMailbox)

- (NSMutableArray *)mailboxes;
- (void)setMailboxes:(NSMutableArray *)aMailboxes;

- (unsigned)countOfMailboxes;
- (ATMailbox *)mailboxAt:(unsigned)anIndex;

- (ATMailbox *)mailboxForName:(NSString *)aName;
- (ATMailbox *)mailboxFor:(unsigned)aMailboxID;

- (NSArray *)allDescendantMailboxes;
- (void)collectAllDescendantMailboxesTo:(NSMutableArray *)aMailboxes;

@end

@interface ATMailbox (CollectingMailboxes)

+ (NSArray *)toplevelMailboxesIn:(NSArray *)aMailboxes;

- (NSMutableArray *)rearrangedMessagesWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)aSortDescriptors;
- (NSMutableArray *)rearrangedThreadsWithPredicate:(NSPredicate *)aPredicate sortDescriptors:(NSArray *)aSortDescriptors;

@end

@interface ATMailbox (Inserting)

- (void)add:(id)anItem;
- (void)addItems:(NSArray *)anItems;

- (void)insert:(id)anItem at:(unsigned)anIndex;

- (void)addMessages:(NSArray *)aMessages;

@end

@interface ATMailbox (Moving)

- (void)move:(id)anItem at:(unsigned)anIndex;
- (void)moveItems:(NSArray *)anItems at:(unsigned)aStartIndex;

- (void)moveMailboxes:(NSArray *)aMailboxes at:(unsigned)aStartIndex;

- (unsigned)primitiveMove:(id)anItem at:(unsigned)anIndex;

@end

@interface ATMailbox (Removing)

- (void)remove:(id)anItem;

@end

@interface ATMailbox (Dropping)

@end

@interface ATMailbox (Threads)

- (NSMutableArray *)threads;
- (void)setThreads:(NSMutableArray *)aThreads;

- (void)updateThreads;
- (void)removeAllThreads;

- (void)contentsDidChange;

@end

@interface ATMailbox (Testing)

- (BOOL)isMailbox;
- (BOOL)isWeak;
- (BOOL)isMessage;

- (BOOL)isDescendantOf:(ATMailbox *)aMailbox;
- (BOOL)isEqualOrDescendantOf:(ATMailbox *)aMailbox;
- (BOOL)isDescendantIn:(NSArray *)aMailboxes;

- (BOOL)isRoot;

@end

@interface ATMailbox (Saving)

- (id)propertyListRepresentation;
- (BOOL)writeToFile:(NSString *)aPath;

@end