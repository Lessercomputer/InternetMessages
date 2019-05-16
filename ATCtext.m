//
//  ATCtext.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATCtext.h"


@implementation ATCtext

- (id)initWith:(NSString *)aCtext
{
	[super init];
	
	ctext = [aCtext copy];
	
	return self;
}

- (void)dealloc
{
	[ctext release];
	
	[super dealloc];
}

- (NSString *)stringValue
{
	return ctext;
}

- (void)printOn:(NSMutableString *)aString
{
	[aString appendString:ctext];
}

@end
