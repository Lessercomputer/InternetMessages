//
//  ATAddressListFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATAddressListFieldBody.h"
#import "ATTokenScanner.h"


@implementation ATAddressListFieldBody

- (id)initWith:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [ATTokenScanner scannerWith:aString];
	NSArray *anAddressList = nil;
	
	[super init];
	
	if ([aTokenScanner scanAddressListInto:&anAddressList] && [aTokenScanner isAtEnd])
	{
		[self setValue:anAddressList];
		
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

- (void)setValue:(NSArray *)anAddressList
{
	[value release];
	value = [anAddressList copy];
}

- (NSArray *)value
{
	return value;
}

- (NSString *)stringValue
{
	NSMutableString *aString = [NSMutableString string];
	NSEnumerator *enumerator = [[self value] objectEnumerator];
	id anAddress = [enumerator nextObject];
	
	if (anAddress)
		[aString appendString:[anAddress stringValue]];
	
	while (anAddress = [enumerator nextObject])
	{
		[aString appendFormat:@", %@", [anAddress stringValue], nil];
	}
	
	return aString;
}

@end
