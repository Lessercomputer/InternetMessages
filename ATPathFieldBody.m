//
//  ATPathFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATPathFieldBody.h"
#import "ATMIMETokenScanner.h"
#import "ATTokenScanner.h"

@implementation ATPathFieldBody

- (id)initWith:(NSString *)aString
{
	ATMIMETokenScanner *aTokenScanner = [[[ATMIMETokenScanner alloc] initWith:aString] autorelease];
	id aPath = nil;
	
	[super init];

	if ([aTokenScanner scanPathInto:&aPath] && [aTokenScanner isAtEnd])
	{
		[self setValue:aPath];
		
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
	[value release];
	value = [aValue retain];
}

- (id)value
{
	return value;
}

- (NSString *)stringValue
{
	return [[self value] stringValue];
}

@end
