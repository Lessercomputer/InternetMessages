//
//  ATMailboxListFieldBody.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/08.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATMailboxListFieldBody : NSObject
{
	NSArray *value;
}

- (void)setValue:(NSArray *)aMailboxList;
- (NSArray *)value;

- (NSString *)stringValue;

@end
