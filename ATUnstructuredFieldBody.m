//
//  ATUnstructuredFieldBody.m
//  ATMail
//
//  Created by 高田　明史 on 06/04/08.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATUnstructuredFieldBody.h"
#import "ATTokenScanner.h"
#import "ATMIMETokenScanner.h"
#import "ATEncodedWord.h"

@implementation ATUnstructuredFieldBody

- (id)initWith:(NSString *)aString
{
	[super init];
	
	if ([ATTokenScanner isUnstructured:aString])
	{
		[self setValue:[self decodeEncodedWordIn:aString]];
		
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

- (void)setValue:(NSString *)aString
{
	[value release];
	value = [aString copy];
}

- (NSString *)value
{
	return value;
}

- (NSString *)stringValue
{
	return [self value];
}

- (NSString *)decodeEncodedWordIn:(NSString *)anUnstructuredText
{
	ATTokenScanner *aScanner = [ATTokenScanner scannerWith:anUnstructuredText];
	BOOL aDecodingFinished = NO;
	ATEncodedWord *aPendingEncodedWord = nil;
	NSMutableString *aDecodedUnstructured = [NSMutableString string];
	
	while (!aDecodingFinished)
	{
		ATEncodedWord *anEncodedWord = nil;
		NSString *aText = nil;
		NSString *aFWS = nil;
		
		if ([aScanner scanEncodedWordTokenIncludingFWSInto:&anEncodedWord])
		{
			if (aPendingEncodedWord)
				[aDecodedUnstructured appendString:[aPendingEncodedWord displayStringExceptRightCFWS]];
			
			aPendingEncodedWord = anEncodedWord;
		}
		else
		{
			if (aPendingEncodedWord)
				[aDecodedUnstructured appendString:[aPendingEncodedWord displayString]];
			
			aPendingEncodedWord = nil;
			
			if ([aScanner scanUTextExceptingFWSInto:&aText] && [aText length])
				[aDecodedUnstructured appendString:aText];
			else if ([aScanner scanFWSInto:&aFWS])
				[aDecodedUnstructured appendString:aFWS];
			else
				aDecodingFinished = YES;
		}
	}
	
	return aDecodedUnstructured;
}

@end
