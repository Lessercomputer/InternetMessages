//
//  ATReceivedFieldBody.h
//  ATMail
//
//  Created by ���c�@���j on 06/04/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATReceivedFieldBody : NSObject
{
	NSDictionary *nameValList;
	NSCalendarDate *dateTime;
}

- (void)setDateTime:(NSCalendarDate *)aDateTime;
- (void)setValue:(NSDictionary *)aValue;
- (void)setDateTime:(NSCalendarDate *)aDateTime;

@end
