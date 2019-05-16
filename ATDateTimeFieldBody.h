//
//  ATDateTimeFieldBody.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/08.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATDateTimeFieldBody : NSObject
{
	NSCalendarDate *value;
}

- (id)initWith:(NSString *)aValue;

- (void)setValue:(NSCalendarDate *)aValue;
- (NSCalendarDate *)value;

- (NSString *)stringValue;

@end
