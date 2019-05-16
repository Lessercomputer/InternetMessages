//
//  ATEncodedWord.m
//  ATMail
//
//  Created by 高田　明史 on 06/10/24.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATEncodedWord.h"
#import "ATCFWS.h"
#import "ATBase64Decoder.h"
#import "ATQuotedPrintableDecoder.h"

@implementation ATEncodedWord

+ (id)encodedWordWith:(NSString *)aCharset encoding:(NSString *)anEncoding encodedText:(NSString *)anEncodedText
{
	return [[[self alloc] initWith:aCharset encoding:anEncoding encodedText:anEncodedText] autorelease];
}

- (id)initWith:(NSString *)aCharset encoding:(NSString *)anEncoding encodedText:(NSString *)anEncodedText
{
	[super init];
	
	[self setCharset:aCharset];
	[self setEncoding:anEncoding];
	encodedText = [anEncodedText retain];
	
	return self;
}

- (void)dealloc
{
	[self setCharset:nil];
	[self setEncoding:nil];
	[encodedText release];
	[self setLeftCFWS:nil];
	[self setRight:nil];
	
	[super dealloc];
}

- (BOOL)isEncoded
{
	return YES;
}

- (void)setCharset:(NSString *)aCharset
{
	[charset release];
	charset = [aCharset copy];
}

- (void)setEncoding:(NSString *)anEncoding
{
	[encoding release];
	encoding = [anEncoding copy];
}

- (void)setLeftCFWS:(ATCFWS *)aLeftCFWS
{
	[leftCFWS release];
	leftCFWS = [aLeftCFWS retain];
}

- (void)setRight:(ATCFWS *)aRightCFWS
{
	[rightCFWS release];
	rightCFWS = [aRightCFWS retain];
}

- (NSString *)displayString
{
	return [[self class] decodeEncodedWord:charset encoding:encoding encodedText:encodedText leftCFWS:leftCFWS rightCFWS:rightCFWS includingRightCFWS:YES];
}

- (NSString *)displayStringExceptRightCFWS
{
	return [[self class] decodeEncodedWord:charset encoding:encoding encodedText:encodedText leftCFWS:leftCFWS rightCFWS:rightCFWS includingRightCFWS:NO];
}

+ (NSString *)decodeEncodedWord:(NSString *)aCharset encoding:(NSString *)anEncoding encodedText:(NSString *)anEncodedText leftCFWS:(ATCFWS *)aLeftCFWS rightCFWS:(ATCFWS *)aRightCFWS includingRightCFWS:(BOOL)anIncludingFlag
{
	NSData *aStringData = nil;
	CFStringEncoding aCFEncoding;
	NSString *anEncodedWord = nil;
	//NSString *aReturningWord = nil;
	NSString *aLeftString = @"";
	NSString *aRightString = @"";
	
	if ([[anEncoding lowercaseString] isEqualToString:@"b"])
	{
		ATBase64Decoder *aDecoder = [[[ATBase64Decoder alloc] initWith:[anEncodedText dataUsingEncoding:NSASCIIStringEncoding]] autorelease];
		aStringData = [aDecoder decode];
	} else if ([[anEncoding lowercaseString] isEqualToString:@"q"])
	{
		aStringData = [ATQuotedPrintableDecoder decodeWithQ:[anEncodedText dataUsingEncoding:NSASCIIStringEncoding]];
	}
	
	aCFEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)aCharset);
	
	if (aStringData && aCFEncoding != kCFStringEncodingInvalidId)
	{
		NSStringEncoding aNSEncoding = CFStringConvertEncodingToNSStringEncoding(aCFEncoding);
			
		anEncodedWord = [[[NSString alloc] initWithData:aStringData encoding:aNSEncoding] autorelease];
	}
	
	if (!anEncodedWord)
		anEncodedWord = [self encodedWord:aCharset encoding:anEncoding encodedText:anEncodedText];
	
	//return [NSString stringWithFormat:@"%@%@%@", (aLeftCFWS ? @" " : @""), anEncodedWord, ((aRightCFWS && anIncludingFlag) ? @" " : @"")];
	
	if (aLeftCFWS)
	{
		if ([aLeftCFWS isKindOfClass:[NSString class]])
			aLeftString = aLeftCFWS;
		else
			aLeftString = @" ";
	}
	
	if (anIncludingFlag && aRightCFWS)
	{
		if ([aRightCFWS isKindOfClass:[NSString class]])
			aRightString = aRightCFWS;
		else
			aRightString = @" ";
	}
	
	return [NSString stringWithFormat:@"%@%@%@", aLeftString, anEncodedWord, aRightString];
}

+ (NSString *)encodedWord:(NSString *)aCharset encoding:(NSString *)anEncoding encodedText:(NSString *)anEncodedText
{
	return [NSString stringWithFormat:@"=?%@?%@?%@?=", aCharset, anEncoding, anEncodedText];
}

@end
