//
//  ATMessagesModel.h
//  ATMail
//
//  Created by 高田 明史 on 08/11/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString *ATMessagesModelContentsDidChangeNotification;
extern NSString *ATMessagesModelCurrentMessageDidChangeNotification;
extern NSString *ATMessagesModelSelectionsDidChangeNotification;
extern NSString *ATMessagesModelSortDescriptorsDidChangeNotification;

extern NSString *ATSelectedMessageKey;

@class ATMailbox;
@class ATInternetMessage;
@class ATMailSpool;

@interface ATMessagesModel : NSObject
{
	ATMailSpool *mailSpool;
	ATMailbox *mailbox;
	
	ATInternetMessage *currentMessage;
	NSArray *selections;

	NSArray *sortDescriptors;
	NSPredicate *predicate;
	NSArray *arrangedMessages;
	
	NSMutableArray *columns;
}

+ (id)messagesModelWithMailbox:(ATMailbox *)aMailbox mailSpool:(ATMailSpool *)aMailSpool;
+ (id)messagesModelWithPropertyList:(id)aPlist mailbox:(ATMailbox *)aMailbox mailSpool:(ATMailSpool *)aMailSpool;

- (id)initWithMailbox:(ATMailbox *)aMailbox mailSpool:(ATMailSpool *)aMailSpool;
- (id)initWithPropertyList:(id)aPlist mailbox:(ATMailbox *)aMailbox mailSpool:(ATMailSpool *)aMailSpool;

- (ATMailbox *)mailbox;
- (void)setMailbox:(ATMailbox *)aMailbox;

- (ATMailSpool *)mailSpool;
- (void)setMailSpool:(ATMailSpool *)aMailSpool;

- (NSArray *)nonArrangedMessages;

@end


@interface ATMessagesModel (ColumnSupport)

- (NSMutableArray *)columns;
- (void)setColumns:(NSMutableArray *)aColumns;

+ (NSArray *)defaultColumns;

@end

@interface ATMessagesModel (TableDataSouce)
@end

@interface ATMessagesModel (Persistence)

- (id)propertyListRepresentation;
- (NSArray *)sortDescriptorsFromPlist:(id)aPlist;

@end
