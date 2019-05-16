//
//  ATInternetMessage.h
//  ATMail
//
//  Created by 高田　明史 on 06/02/22.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//


#import "ATMessageEntity.h"

@class ATMailSpool;
@class ATInternetMessageLineScanner;
@class ATMsgID;
@class ATMailbox;

@interface ATInternetMessage : ATMessageEntity
{
	unsigned itemID;
	BOOL isInterpreted;
	BOOL isValid;
	NSMutableArray *returnMessages;
	ATMailSpool *mailSpool;
	ATMailbox *parent;
	ATInternetMessage *parentMessage;
	ATHeaderField *messageIDField;
}
@end

@interface ATInternetMessage (Initializing)

+ (id)messageFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner onlyHeader:(BOOL)anOnlyHeaderFlag;
+ (id)messageFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner onlyHeader:(BOOL)anOnlyHeaderFlag fieldNamesToBeInterpreted:(NSSet *)aFieldNamesToBeInterpreted;
+ (id)messageWithItemID:(unsigned)anItemID afterImportingMessageFrom:(NSString *)aSourcePath to:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream;

- (id)initWithItemID:(unsigned)anItemID;
- (id)initFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner onlyHeader:(BOOL)anOnlyHeaderFlag;
- (id)initFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner onlyHeader:(BOOL)anOnlyHeaderFlag fieldNamesToBeInterpreted:(NSSet *)aFieldNamesToBeInterpreted;
- (id)initWithItemID:(unsigned)anItemID afterImportingMessageFrom:(NSString *)aSourcePath to:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream;

@end

@interface ATInternetMessage (Importing)

- (BOOL)importMessageFromFile:(NSString *)aSourcePath to:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream;
- (void)importMessageHeaderFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner to:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream;

@end

@interface ATInternetMessage (Loading)

- (void)readAllContentsFrom:(ATMailSpool *)aMailSpool;
- (void)readAllContentsFromPath:(NSString *)aMsgFilePath;

- (void)rebuildCacheHeaderWithin:(ATMailSpool *)aMailSpool headerOutputStream:(NSOutputStream *)aHeaderOutputStream;

@end

@interface ATInternetMessage (Accessing)

- (void)setItemID:(unsigned)anItemID;
- (unsigned)itemID;
- (NSString *)itemIDString;
- (NSNumber *)itemIDNumber;

- (ATHeaderField *)messageID;
- (ATMsgID *)messageIDValue;

- (void)setMailSpool:(ATMailSpool *)aMailSpool;
- (ATMailSpool *)mailSpool;

- (ATMailbox *)parent;
- (void)setParent:(ATMailbox *)aMailbox;

- (void)setToBeRead:(BOOL)aToBeReadFlag;
- (BOOL)isToBeRead;

- (void)removeAllEntities;

- (unsigned)bodyPartCount;

- (NSString *)filename;
- (NSString *)stringWithItemIDField;
- (NSData *)dataWithItemIDField;

- (NSDictionary *)itemIDPropertyList;

+ (NSArray *)messagesForMessageID:(ATMsgID *)aParentMessageID in:(NSArray *)aMessages;

@end

@interface ATInternetMessage (Fields)

- (ATHeaderField *)inReplyTo;
- (NSArray *)messageIDsOfInReplyTo;
- (ATMsgID *)lastMessageIDOfInReplyTo;

- (ATHeaderField *)references;
- (NSArray *)messageIDsOfReferences;
- (ATMsgID *)lastMessageIDOfReferences;

- (ATMsgID *)lastMessageIDOfReferencesOrInReplyTo;

- (ATHeaderField *)xMailingListName;
- (NSString *)xMailingListNameString;

@end

@interface ATInternetMessage (Threads)

- (void)setReturnMessages:(NSMutableArray *)aReturnMessages;
- (NSMutableArray *)returnMessages;

- (unsigned)countOfReturnMessages;

- (BOOL)addReturnMessage:(ATInternetMessage *)aMessage;

- (ATInternetMessage *)parentMessage;
- (void)setParentMessage:(ATInternetMessage *)aMessage;

- (BOOL)resolveParentMessageWithin:(NSArray *)aParentCandidatesArray;
- (BOOL)resolveReferencesOrInReplyTo;

- (void)removeAllReturnMessages;

- (void)sortReturnMessagesByDate;
- (void)sortReturnMessagesUsingDescriptors:(NSArray *)aDescriptors recursive:(BOOL)aRecursiveFlag;

- (void)openThread;
- (void)openThreadsRecursive:(BOOL)aRecursiveFlag;
- (void)openThreadsRecursive:(BOOL)aRecursiveFlag firstPass:(BOOL)aFirstPassFlag;
- (void)closeThread;
- (void)closeThreadsRecursive:(BOOL)aRecursiveFlag;
- (void)closeThreadsRecursive:(BOOL)aRecursiveFlag firstPass:(BOOL)aFirstPassFlag;

+ (NSMutableArray *)resolveParentMessageOf:(NSArray *)aReplies within:(NSArray *)aParentCandidatesArray putNoneRepliesInto:(NSArray **)aNoneReplies resolvedRepliesInto:(NSArray **)aResolvedReplies;

@end

@interface ATInternetMessage (Interpretting)

- (void)addHeaderLine:(NSString *)aLine interpretWhenUnfolded:(BOOL)anInterpretFlag;

- (BOOL)interpretMessageHeader;

@end

@interface ATInternetMessage (Testing)

- (BOOL)hasRequiredHeader;

- (BOOL)isReturnMessage;

- (BOOL)hasReturnMessage;

- (BOOL)hasValidMessageID;

- (BOOL)messageIDIsEqualToMessageID:(ATMsgID *)aMessageID;

- (BOOL)isMailbox;

- (BOOL)isOpen;

@end