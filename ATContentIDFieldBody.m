//
//  ATContentIDFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/09/24.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATContentIDFieldBody.h"
#import "ATMIMETokenScanner.h"


@implementation ATContentIDFieldBody

- (id)initWith:(NSString *)aString
{
	ATMIMETokenScanner *aTokenScanner = [[[ATMIMETokenScanner alloc] initWith:aString] autorelease];
	
	[super init];
	
	if ([aTokenScanner scanContentIDFieldValueInto:&contentID])
	{
		[contentID retain];
		
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
	[contentID release];
	
	[super dealloc];
}


- (NSString *)stringValue
{
	return [contentID stringValue];
}

@end
