//
//  ATMailSpool.h
//  ATMail
//
//  Created by 高田　明史 on 07/09/10.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *ATItemIDHeaderFieldName;

extern NSString *ATMessageReadStatusDidChangeNotification;
extern NSString *ATMailboxesDidChangeNotification;

extern NSString *ATMessageKey;

extern NSString *ATItemIDsPboardType;

@class ATIDPool;
@class ATInternetMessage;
@class ATMailAccount;
@class ATPop3MessageDownloader;
@class ATMsgID;
@class ATMailbox;
@class ATFilterEditor;

@interface ATMailSpool : NSObject
{
	ATIDPool *idPool;
	NSMutableDictionary *messagesDictionary;
	ATMailbox *entireMessagesMailbox;
	ATMailbox *inbox;
	ATMailAccount *mailAccount;
	ATPop3MessageDownloader *messageDownloader;
	NSString *mailDocumentPath;
	NSMutableArray *unsavedMessages;
	NSMutableArray *threads;
	NSMutableArray *targetMissingMessages;
	NSMutableIndexSet *messagesToBeRead;
	NSMutableIndexSet *openThreads;
	ATMailbox *root;
	ATIDPool *mailboxIDPool;
	unsigned entireMessagesMailboxID;
	NSMutableSet *mailboxesInModifying;
	NSMutableArray *unsavedHeadersFilePaths;
	ATFilterEditor *filterEditor;
	unsigned depthOfModifying;
}

@end

@interface ATMailSpool (Accessing)

- (ATIDPool *)idPool;
- (void)setIDPool:(ATIDPool *)anIDPool;

- (ATIDPool *)mailboxIDPool;
- (void)setMailboxIDPool:(ATIDPool *)aMailboxIDPool;

- (ATMailbox *)root;
- (void)setRoot:(ATMailbox *)aRoot;

- (ATMailbox *)entireMessagesMailbox;
- (void)setEntireMessagesMailbox:(ATMailbox *)anEntireMessagesMailbox;
- (unsigned)entireMessagesMailboxID;
- (void)setEntireMessagesMailboxID:(unsigned)anID;

- (ATMailbox *)inbox;
- (void)setInbox:(ATMailbox *)anInbox;

- (NSMutableArray *)messages;
- (void)setMessages:(NSMutableArray *)aMessages;

- (NSMutableArray *)unsavedMessages;
- (void)setUnsavedMessages:(NSMutableArray *)aMessages;

- (NSMutableArray *)targetMissingMessages;
- (void)setTargetMissingMessages:(NSMutableArray *)aTargetMissingMessages;

- (NSMutableIndexSet *)indexSetWithTargetMissingMessages;
- (NSData *)dataFromIndexSetWithTargetMissingMessages;

- (NSMutableIndexSet *)messagesToBeRead;
- (void)setMessagesToBeRead:(NSMutableIndexSet *)aMessages;

- (NSArray *)mailboxes;

- (ATMailAccount *)mailAccount;
- (void)setMailAccount:(ATMailAccount *)anAccount;

- (NSString *)mailDocumentPath;
- (void)setMailDocumentPath:(NSString *)aMailDocumentPath;

- (ATPop3MessageDownloader *)messageDownloader;
- (void)setMessageDownloader:(ATPop3MessageDownloader *)aDownloader;

+ (NSSet *)headerNamesToBeSave;
+ (NSSet *)headerNamesToBeShow;
- (NSSet *)headerNamesToBeShow;

- (NSMutableArray *)unsavedHeadersFilePaths;
- (void)setUnsavedHeadersFilePaths:(NSMutableArray *)anUnsavedHeadersFilePaths;

- (void)addUnsavedHeaderFilePath:(NSString *)aHeaderFilePath;

- (ATFilterEditor *)filterEditor;
- (void)setFilterEditor:(ATFilterEditor *)aFilterEditor;

- (NSMutableIndexSet *)openThreads;
- (void)setOpenThreads:(NSMutableIndexSet *)aMessageItemIDs;

@end

@interface ATMailSpool (QueryingPaths)

- (NSString *)messagesFolderPath;
- (NSString *)accessibleMessageFilePathFor:(ATInternetMessage *)anInternetMessage;
- (NSString *)messageFilePathFor:(ATInternetMessage *)anInternetMessage;
- (NSString *)headersFolderPath;
- (NSString *)headersFilePath;
- (NSString *)headersFolderPathWithin:(NSURL *)aMailDocumentURL;
- (NSString *)messagesFolderPathWithin:(NSURL *)aMailDocumentURL;
- (NSString *)idPoolPathWithin:(NSURL *)aMailDocumentURL;
- (NSString *)mailAccountPathWithin:(NSURL *)aMailDocumentURL;
- (NSString *)systemMailboxesPath;

- (NSString *)temporaryMessageFilePathFor:(ATInternetMessage *)anInternetMessage;
- (NSString *)temporaryHeadersFilePath;
- (NSString *)temporaryFolderPath;
- (NSString *)temporaryFolderPathCreateIfAbsent;

- (NSString *)filterEditorPath;

@end

@interface ATMailSpool (QueryingStreamsAndFiles)

- (NSOutputStream *)outputStreamForTemporaryHeaders;
- (NSOutputStream *)outputStreamForTemporaryMessage:(ATInternetMessage *)aMessage;

- (BOOL)createMessagesFolderAndHeadersFolderWithin:(NSURL *)aMailDocumentURL;
- (void)createTemporaryFolderIfAbsent;
- (void)createTemporaryMessageFileFor:(ATInternetMessage *)aMessage;
- (void)removeItemsInTemporaryFolder;

@end

@interface ATMailSpool (QueryingMessages)

- (unsigned)newItemID;
- (NSArray *)itemIDsFor:(NSArray *)anItems;
- (ATInternetMessage *)messageForItemID:(unsigned)anItemID;
- (ATInternetMessage *)messageForItemIDNumber:(NSNumber *)anItemIDNumber;

- (NSArray *)messagesForMessageID:(ATMsgID *)aMessageID;
- (NSArray *)messagesForMessageID:(ATMsgID *)aMessageID within:(NSArray *)anArrayOfSearchingMessages;
- (NSArray *)messagesForMessageID:(ATMsgID *)aMessageID withinSearchingMessages:(NSArray *)aSearchingMessages;

- (NSArray *)messagesAtIndexes:(NSIndexSet *)anIndexSet;

- (NSArray *)isolatedMessages;

@end

@interface ATMailSpool (QueryingMailboxes)

- (unsigned)newMailboxID;
- (ATMailbox *)makeMailboxWithName:(NSString *)aName weak:(BOOL)aWeakFlag;
- (ATMailbox *)mailboxFor:(unsigned)aMailboxID;
- (ATMailbox *)mailboxForIDNumber:(NSNumber *)aNumber;
- (ATMailbox *)mailboxForName:(NSString *)aName;

- (NSDictionary *)systemMailboxDictionary;
- (NSDictionary *)systemMailboxIDDictionary;
- (NSDictionary *)systemMailboxDictionaryFrom:(NSDictionary *)aSystemMailboxIDDictionary;

@end

@interface ATMailSpool (Adding)

- (void)addMessages:(NSArray *)aMessages;
- (void)addMailbox:(ATMailbox *)aMailbox to:(ATMailbox *)aParentMailbox;

- (void)rebuildCacheHeader;

- (void)addIsolatedMessagesToInbox;

@end

@interface ATMailSpool (MessageStatus)

- (void)makeSelections:(NSArray *)aSelections toBeRead:(BOOL)aReadFlag;
- (void)addMessageToBeRead:(ATInternetMessage *)aMessage;
- (void)removeMessageToBeRead:(ATInternetMessage *)aMessage;

- (void)addOpenThread:(ATInternetMessage *)aMessage;
- (void)removeOpenThread:(ATInternetMessage *)aMessage;

@end

@interface ATMailSpool (Notifying)

- (NSMutableSet *)mailboxesInModifying;
- (void)setMailboxesInModifying:(NSMutableSet *)aMailboxes;

- (void)beginModifying;
- (void)endModifying;
- (void)mailboxContentsDidChange:(ATMailbox *)aMailbox;
- (void)postNotificationOfModifiedMailboxes;

- (void)mailboxDidChangeName:(ATMailbox *)aMailbox;
- (void)mailbox:(ATMailbox *)aMailbox didMoveMailboxes:(NSArray *)aMailboxes;

- (void)filterEditorDidChange:(NSNotification *)aNotification;

@end

@interface ATMailSpool (Testing)

- (BOOL)existsMessagesFolderAndHeadersFolderWithin:(NSURL *)aMailDocumentURL;
- (BOOL)existsMessagesFolderWithin:(NSURL *)aMailDocumentURL;
- (BOOL)existsHeadersFolderWithin:(NSURL *)aMailDocumentURL;

- (BOOL)messageIsToBeRead:(ATInternetMessage *)aMessage;

- (BOOL)isDownloading;

- (BOOL)messageIsIncludedIn:(NSArray *)anItems;

- (BOOL)threadIsOpen:(ATInternetMessage *)aMessage;

@end

@interface ATMailSpool (Saving)

- (BOOL)saveWithin:(NSURL *)aMailDocumentURL;

- (BOOL)saveUnsavedHeaders;
- (BOOL)saveUnsavedMessages;

- (BOOL)saveMessagesToBeRead;
- (BOOL)saveTargetMissingMessages;
- (BOOL)saveIDPoolWithin:(NSURL *)aMailDocumentURL;
- (BOOL)saveMailboxIDPool;
- (BOOL)saveMailboxes;
- (BOOL)saveMailAccountWithin:(NSURL *)aMailDocumentURL;
- (BOOL)saveSystemMailboxes;
- (BOOL)saveFilterEditor;
- (BOOL)saveOpenThreads;

@end

@interface ATMailSpool (Loading)

- (BOOL)loadWithin:(NSURL *)aMailDocumentURL;

- (BOOL)loadMessagesToBeRead;
- (BOOL)loadTargetMissingMessage;
- (BOOL)loadIDPoolFromPath:(NSString *)aPath;
- (BOOL)loadMailboxes;
- (BOOL)loadMailboxesFromPath:(NSString *)aPath;

- (BOOL)loadMailAccountFromPath:(NSString *)aPath;
- (BOOL)loadMessageHeadersFromPath:(NSString *)aMessageHeadersFolderPath;
- (BOOL)loadMailboxIDPool;
- (BOOL)loadSystemMailboxes;
- (BOOL)loadFilterEditor;
- (BOOL)loadOpenThreads;

@end

@interface ATMailSpool (Importing)

- (void)importMessages:(NSArray *)aMessagePaths;

@end

@interface ATMailSpool (DownloadingMessage)

- (void)download;

- (void)downloader:(ATPop3MessageDownloader *)sender messageInto:(ATInternetMessage **)aMessage messageOutputStreamInto:(NSOutputStream **)aMessageOutputStream headerOutputStreamInto:(NSOutputStream **)aHeaderOutputStream;

- (void)downloadFinished:(ATPop3MessageDownloader *)sender;
- (void)downloadCanceled:(ATPop3MessageDownloader *)sender;

- (void)removeCanceledMessagesAndHeadersOf:(ATPop3MessageDownloader *)aDownloader;

@end