//
//  ATReceivedFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATReceivedFieldBody.h"
#import "ATTokenScanner.h"


@implementation ATReceivedFieldBody

- (id)initWith:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [ATTokenScanner scannerWith:aString];
	NSDictionary *aNameValList = nil;
	NSCalendarDate *aDateTime = nil;
	
	[super init];
	
	if ([aTokenScanner scanNameValListInto:&aNameValList])
		[self setValue:aNameValList];
	else
	{
		[self release];
		
		return nil;
	}
	
	if ([aTokenScanner scanString:@";" intoString:nil])
	{
		if ([aTokenScanner scanDateTimeInto:&aDateTime])
			[self setDateTime:aDateTime];
		else
		{
			[self release];
			
			return nil;
		}
	}
	
	if ([aTokenScanner isAtEnd])
		return self;
	else
	{
		[self release];
		
		return nil;
	}
}

- (void)dealloc
{
	[self setValue:nil];
	[self setDateTime:nil];
	
	[super dealloc];
}

- (void)setValue:(NSDictionary *)aValue
{
	[nameValList release];
	nameValList = [aValue retain];
}

- (NSDictionary *)value
{
	return nameValList;
}

- (void)setDateTime:(NSCalendarDate *)aDateTime
{
	[dateTime release];
	dateTime = [aDateTime retain];
}

- (NSCalendarDate *)dateTime
{
	return dateTime;
}

- (NSString *)stringValue
{
	NSMutableString *aString = [NSMutableString string];
	NSEnumerator *anEnumerator = [[self value] keyEnumerator];
	id anItemName = nil;
	
	while (anItemName = [anEnumerator nextObject])
	{
		id anItem = [nameValList objectForKey:anItemName];
		NSMutableString *aStringValueOfanItem = [anItem isKindOfClass:[NSString class]] ? anItem : nil;
		
		if ([anItem isKindOfClass:[NSString class]])
			aStringValueOfanItem = anItem;
		else if ([anItem isKindOfClass:[NSArray class]])
		{
			NSEnumerator *anEnumeratorOfanItem = [anItem objectEnumerator];
			id anAddr = nil;
			
			aStringValueOfanItem = [NSMutableString string];
			
			while (anAddr = [anEnumeratorOfanItem nextObject])
				[aStringValueOfanItem appendString:[anAddr stringValue]];
		}
		else
			aStringValueOfanItem = [anItem stringValue];
			
		[aString appendFormat:([aString length] ? @" %@=%@" : @"%@=%@"), anItemName, aStringValueOfanItem];
	}
	
	if ([self dateTime])
		[aString appendFormat:@";%@", [self dateTime]];
		
	return aString;
}

@end
