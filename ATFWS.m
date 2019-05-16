//
//  ATFWS.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATFWS.h"


@implementation ATFWS

- (id)initWith:(NSString *)aFWSString
{
	[super init];
	
	fws = [aFWSString copy];

	return self;
}

- (void)dealloc
{
	[fws release];
	
	[super dealloc];
}

- (NSString *)stringValue
{
	return fws;
}

- (void)printOn:(NSMutableString *)aString
{
	[aString appendString:fws];
}

@end
