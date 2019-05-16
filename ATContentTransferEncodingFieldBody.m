//
//  ATContentTransferEncodingFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/09/24.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATContentTransferEncodingFieldBody.h"
#import "ATMIMETokenScanner.h"


@implementation ATContentTransferEncodingFieldBody

+ (id)defaultContentTransferEncoding
{
	id aDefault = [[[self alloc] init] autorelease];
	
	[aDefault setEncoding:@"7BIT"];
	
	return aDefault;
}

- (id)initWith:(NSString *)aString
{
	ATMIMETokenScanner *aTokenScanner = [[[ATMIMETokenScanner alloc] initWith:aString] autorelease];
	
	[super init];
	
	if ([aTokenScanner scanContentTransferEncodingFieldValueInto:&encoding])
	{
		[encoding retain];
		
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
	[encoding release];
	
	[super dealloc];
}


- (NSString *)stringValue
{
	return encoding;
}

- (void)setEncoding:(NSString *)anEncoding
{
	[encoding autorelease];
	encoding = [anEncoding copy];
}

- (BOOL)mechanismIs:(NSString *)aMechanism
{
	return [[encoding lowercaseString] isEqualToString:[aMechanism lowercaseString]];
}

@end
