//
//  ATComment.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/03/19.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATComment.h"


@implementation ATComment

- (id)init
{
	[super init];
	
	ccontent = [NSMutableArray new];
	
	return self;
}

- (void)dealloc
{
	[ccontent release];
	
	[super dealloc];
}

- (void)add:(id)aToken
{
	[[self value] addObject:aToken];
}

- (NSMutableArray *)value
{
	return ccontent;
}

- (NSString *)stringValue
{
	NSMutableString *aString = [NSMutableString string];
	
	[self printOn:aString];
	
	return aString;
}

- (void)printOn:(NSMutableString *)aString
{
	[aString appendString:@"("];
	
	[[self value] makeObjectsPerformSelector:@selector(printOn:) withObject:aString];	
	
	[aString appendString:@")"];
}

@end
