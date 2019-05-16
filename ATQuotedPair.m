//
//  ATQuotedPair.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATQuotedPair.h"


@implementation ATQuotedPair

- (id)initWith:(NSString *)aQuotedPair
{
	[super init];
	
	quotedPair = [aQuotedPair copy];
	
	return self;
}

- (void)dealloc
{
	[quotedPair release];
	
	[super dealloc];
}

- (NSString *)stringValue
{
	return quotedPair;
}

- (void)printOn:(NSMutableString *)aString
{
	[aString appendString:quotedPair];
}

@end
