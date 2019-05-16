//
//  ATMsgID.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATMsgID : NSObject <NSCopying>
{
	NSString *idLeft;
	NSString *idRight;
}

- (id)initWith:(NSString *)anIDLeft with:(NSString *)anIDRight;

- (void)setIDLeft:(NSString *)anIDLeft;
- (NSString *)idLeft;

- (void)setIDRight:(NSString *)anIDRight;
- (NSString *)idRight;

- (NSString *)stringValue;

- (BOOL)isEqualToMessageID:(ATMsgID *)aMessageID;

@end
