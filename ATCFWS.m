//
//  ATCFWS.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATCFWS.h"
#import "ATFWS.h"


@implementation ATCFWS

- (id)init
{
	[super init];
	
	cfws = [NSMutableArray new];
	
	return self;
}

- (void)dealloc
{
	[cfws release];
	
	[super dealloc];
}

- (void)add:(id)aToken
{
	[cfws addObject:aToken];
}

- (BOOL)endWithFWS
{
	return [[[self value] lastObject] isKindOfClass:[ATFWS class]];
}

- (NSArray *)value
{
	return cfws;
}

- (NSString *)stringValue
{
	NSMutableString *aString = [NSMutableString string];

	[[self value] makeObjectsPerformSelector:@selector(printOn:) withObject:aString];	
	
	return aString;
}

- (NSString *)description
{
	return [[self stringValue] autorelease];
}

@end
