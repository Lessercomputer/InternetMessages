//
//  ATKeywordsFieldBody.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/17.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATKeywordsFieldBody.h"
#import "ATTokenScanner.h"


@implementation ATKeywordsFieldBody

- (id)initWith:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [ATTokenScanner scannerWith:aString];
	NSMutableArray *aKeywords = [NSMutableArray array];
	NSString *aPhrase = nil;
	
	[super init];
	
	do
	{
		if ([aTokenScanner scanPhraseInto:&aPhrase])
			[aKeywords addObject:aPhrase];
			
	} while ([aTokenScanner scanString:@"," intoString:nil]);
	
	if ([aTokenScanner isAtEnd])
	{
		[self setValue:aKeywords];
		
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

- (void)setValue:(NSMutableArray *)aValue
{
	[keywords release];
	keywords = [aValue retain];
}

- (NSMutableArray *)value
{
	return keywords;
}

- (NSString *)stringValue
{
	NSMutableString *aString = [NSMutableString string];
	NSEnumerator *enumerator = [[self value] objectEnumerator];
	id akeyword = [enumerator nextObject];
	
	if (akeyword)
		[aString appendString:akeyword];
	
	while (akeyword = [enumerator nextObject])
	{
		[aString appendFormat:@", %@", akeyword, nil];
	}
	
	return aString;
}

@end
