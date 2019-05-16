//
//  ATMailboxFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/17.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMailboxFieldBody.h"
#import "ATTokenScanner.h"


@implementation ATMailboxFieldBody

- (id)initWith:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [ATTokenScanner scannerWith:aString];
	id aMailbox = nil;
	
	[super init];

	if ([aTokenScanner scanMailboxInto:&aMailbox] && [aTokenScanner isAtEnd])
	{
		[self setValue:aMailbox];
		
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

- (void)setValue:(id)aValue
{
	[mailbox release];
	mailbox = [aValue retain];
}

- (id)value
{
	return mailbox;
}

- (NSString *)stringValue
{
	return [[self value] stringValue];
}

@end
