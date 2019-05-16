//
//  ATMIMEVersionFieldBody".m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/09/22.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMIMEVersionFieldBody.h"
#import "ATMIMETokenScanner.h"


@implementation ATMIMEVersionFieldBody

- (id)initWith:(NSString *)aString
{
	ATMIMETokenScanner *aTokenScanner = [[[ATMIMETokenScanner alloc] initWith:aString] autorelease];
	
	[super init];
	
	if ([aTokenScanner scanMIMEVersionFieldValueInto:&version1 into:&version2])
	{
		[version1 retain];
		[version2 retain];
		
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
	[version1 release];
	[version2 release];
	
	[super dealloc];
}


- (NSString *)stringValue
{
	return [NSString stringWithFormat:@"%@.%@", version1, version2];
}

@end
