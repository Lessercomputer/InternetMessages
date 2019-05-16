//
//  ATContentDescriptionFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/09/24.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATContentDescriptionFieldBody.h"
#import "ATMIMETokenScanner.h"


@implementation ATContentDescriptionFieldBody

- (id)initWith:(NSString *)aString
{
	ATMIMETokenScanner *aTokenScanner = [[[ATMIMETokenScanner alloc] initWith:aString] autorelease];
	
	[super init];
	
	if ([aTokenScanner scanContentDescriptionFieldValueInto:&contentDescription])
	{
		[contentDescription retain];
		
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
	[contentDescription release];
	
	[super dealloc];
}


- (NSString *)stringValue
{
	return contentDescription;
}

@end
