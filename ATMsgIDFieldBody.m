//
//  ATMsgIDFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/17.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMsgIDFieldBody.h"
#import "ATTokenScanner.h"
#import "ATMsgID.h"


@implementation ATMsgIDFieldBody

- (id)initWith:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [ATTokenScanner scannerWith:aString];
	NSMutableArray *aMsgIDs = [NSMutableArray array];
	ATMsgID *aMsgID;
	
	[super init];
	
	while ([aTokenScanner scanMsgIDInto:&aMsgID])
	{
		[aMsgIDs addObject:aMsgID];
	}
	
	if ([aMsgIDs count] && [aTokenScanner isAtEnd])
	{
		[self setValue:aMsgIDs];
		
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

- (void)setValue:(NSMutableArray *)aValue
{
	[msgIDs release];
	msgIDs = [aValue retain];
}

- (NSMutableArray *)value
{
	return msgIDs;
}

- (NSString *)stringValue
{
	NSMutableString *aString = [NSMutableString string];
	NSEnumerator *enumerator = [[self value] objectEnumerator];
	id aMsgID = [enumerator nextObject];
	
	if (aMsgID)
		[aString appendString:[aMsgID stringValue]];
	
	while (aMsgID = [enumerator nextObject])
	{
		[aString appendFormat:@", %@", [aMsgID stringValue], nil];
	}
	
	return aString;
}

@end
