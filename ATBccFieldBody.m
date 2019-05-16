//
//  ATBccFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/17.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATBccFieldBody.h"
#import "ATTokenScanner.h"


@implementation ATBccFieldBody

- (id)initWith:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [ATTokenScanner scannerWith:aString];
	NSArray *anAddressList = nil;
	
	[super init];
	
	if ([aTokenScanner scanAddressListInto:&anAddressList] && [aTokenScanner isAtEnd])
	{
		[self setValue:[anAddressList isKindOfClass:[NSMutableArray class]] ? anAddressList : [[anAddressList mutableCopy] autorelease]];
		
		return self;
	}
	else if ([aTokenScanner skipCFWS] && [aTokenScanner isAtEnd])
	{
		[self setValue:[NSMutableArray array]];
		
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

- (void)setValue:(NSMutableArray *)anAddressList
{
	[addressList release];
	addressList = [anAddressList retain];
}

- (NSMutableArray *)value
{
	return addressList;
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
