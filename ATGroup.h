//
//  ATGroup.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATGroup : NSObject
{
	NSString *displayName;
	NSArray *mailboxList;
}

- (id)initWith:(NSString *)aDisplayName with:(NSArray *)aMailboxList;

- (void)setDisplayName:(NSString *)aDisplayName;
- (NSString *)displayName;

- (void)setMailboxList:(NSArray *)aMailboxList;
- (NSArray *)mailboxList;

- (NSString *)value;
- (NSString *)stringValue;

@end
