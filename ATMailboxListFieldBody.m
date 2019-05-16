//
//  ATMailboxListFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/08.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMailboxListFieldBody.h"
#import "ATTokenScanner.h"


@implementation ATMailboxListFieldBody

- (id)initWith:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [ATTokenScanner scannerWith:aString];
	NSArray *aMailboxList = nil;
	
	[super init];
	
	if ([aTokenScanner scanMailboxListInto:&aMailboxList] && [aTokenScanner isAtEnd])
	{
		[self setValue:aMailboxList];
		
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

- (void)setValue:(NSArray *)aMailboxList
{
	[value release];
	value = [aMailboxList copy];
}

- (NSArray *)value
{
	return value;
}

- (NSString *)stringValue
{
	NSMutableString *aString = [NSMutableString string];
	NSEnumerator *enumerator = [[self value] objectEnumerator];
	id aMailbox = [enumerator nextObject];
	
	if (aMailbox)
		[aString appendString:[aMailbox stringValue]];
	
	while (aMailbox = [enumerator nextObject])
	{
		[aString appendFormat:@", %@", [aMailbox stringValue], nil];
	}
	
	return aString;
}

@end
