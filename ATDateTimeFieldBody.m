//
//  ATDateTimeFieldBody.m
//  ATMail
//
//  Created by 高田　明史 on 06/04/08.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATDateTimeFieldBody.h"
#import "ATTokenScanner.h"


@implementation ATDateTimeFieldBody

- (id)initWith:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [ATTokenScanner scannerWith:aString];
	NSCalendarDate *aDateTime = nil;
	
	[super init];
	
	if ([aTokenScanner scanDateTimeInto:&aDateTime] && [aTokenScanner isAtEnd])
	{
		[self setValue:aDateTime];
		
		return self;
	}
	else
	{
		[self release];
		
		return nil;
	}
}

- (void)dealloc
{
	[self setValue:nil];
	
	[super dealloc];
}

- (void)setValue:(NSCalendarDate *)aValue
{
	[value release];
	value = [aValue copy];
}

- (NSCalendarDate *)value
{
	return value;
}

- (NSString *)stringValue
{
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	
	[dateFormatter setDateStyle:NSDateFormatterFullStyle];
	[dateFormatter setTimeStyle:NSDateFormatterLongStyle ];

	NSString *formattedDateString = [dateFormatter stringFromDate:[self value]];

	return formattedDateString;
}

@end
