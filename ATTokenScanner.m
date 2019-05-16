//
//  ATTokenScanner.m
//  ATMail
//
//  Created by 高田　明史 on 06/03/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATTokenScanner.h"
#import "ATAddrSpec.h"
#import "ATNameAddr.h"
#import "ATGroup.h"
#import "ATCFWS.h"
#import "ATFWS.h"
#import "ATComment.h"
#import "ATCtext.h"
#import "ATQuotedPair.h"
#import "ATTimeOfDay.h"
#import "ATMsgID.h"
#import "ATBase64Decoder.h"
#import "ATQuotedPrintableDecoder.h"
#import "ATEncodedWord.h"

static NSCharacterSet *wspSet;
static NSCharacterSet *textSet;
static NSCharacterSet *utextSet;
static NSCharacterSet *obsCharSet;
static NSCharacterSet *obsCharSetExceptingWSP;
static NSCharacterSet *atextSet;
static NSCharacterSet *qtextSet;
static NSCharacterSet *lfcrSet;
static NSCharacterSet *dtextSet;
static NSCharacterSet *alphaSet;
static NSCharacterSet *ftextSet;
static NSCharacterSet *ctextSet;
static NSCharacterSet *lfSet;
static NSCharacterSet *crSet;
static NSCharacterSet *encodedTextSet;
static NSCharacterSet *encodedWordTokenSet;
static NSDictionary *zoneDic;
static NSArray *monthNames;
static NSArray *zoneNames;
static NSCharacterSet *zoneCharacterSet;
static NSArray *capitalizedMonthNames;
static NSArray *dayNames;

@implementation ATTokenScanner

+ (void)initialize
{
	NSMutableCharacterSet *aText = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(1, 9 - 1 + 1)];

	NSMutableCharacterSet *aNoWsCtl = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(1, 8 - 1 + 1)];
	NSMutableCharacterSet *aUtext = nil;	
					
	NSMutableCharacterSet *anObsChar = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(0, 9 - 0 + 1)];
	
	NSMutableCharacterSet *anObsCharExceptingWSP = nil;
	
	NSMutableCharacterSet *anAtext = [NSMutableCharacterSet decimalDigitCharacterSet];
	
	NSMutableCharacterSet *aQtext = [[aNoWsCtl mutableCopy] autorelease];
	
	NSMutableCharacterSet *aDtext = [[aNoWsCtl mutableCopy] autorelease];
	
	NSMutableCharacterSet *anAlpha = [NSMutableCharacterSet lowercaseLetterCharacterSet];
	
	NSMutableCharacterSet *aFtextSet = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(33, 57 - 33 + 1)];

	NSMutableCharacterSet *aCtextSet = [[aNoWsCtl mutableCopy] autorelease];
	
	NSMutableCharacterSet *aZoneCharacterSet;

	[aNoWsCtl addCharactersInRange:NSMakeRange(11, 12 - 11 + 1)];
	[aNoWsCtl addCharactersInRange:NSMakeRange(14, 31 - 14 + 1)];
	[aNoWsCtl addCharactersInRange:NSMakeRange(127, 1)];
			
	aUtext = [[aNoWsCtl mutableCopy] autorelease];
	[aUtext addCharactersInRange:NSMakeRange(33, 127 - 33 + 1)];
	
	utextSet = [aUtext copy];
	
	[aText addCharactersInRange:NSMakeRange(11, 12 - 11 + 1)];
	[aText addCharactersInRange:NSMakeRange(14, 127 - 14 + 1)];

	textSet	= [aText copy];

	[anObsChar addCharactersInRange:NSMakeRange(11, 12 - 11 + 1)];
	[anObsChar addCharactersInRange:NSMakeRange(14, 127 - 14 + 1)];

	obsCharSet = [anObsChar copy];
	
	anObsCharExceptingWSP = [[anObsChar mutableCopy] autorelease];
	[anObsCharExceptingWSP removeCharactersInString:@"\t "];
	
	obsCharSetExceptingWSP = [anObsCharExceptingWSP copy];
	
	[anAtext formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
	[anAtext formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
	[anAtext addCharactersInString:@"!#$%&'*+-/=?^_`{|}~"];
	
	atextSet = [anAtext copy];
	
	[aQtext addCharactersInRange:NSMakeRange(33, 1)];
	[aQtext addCharactersInRange:NSMakeRange(35, 91 - 35 + 1)];
	[aQtext addCharactersInRange:NSMakeRange(93, 126 - 93 + 1)];
	
	qtextSet = [aQtext copy];

	lfcrSet = [[NSCharacterSet characterSetWithCharactersInString:@"\r\n"] copy];
	
	[aDtext addCharactersInRange:NSMakeRange(33, 90 - 33 + 1)];
	[aDtext addCharactersInRange:NSMakeRange(94, 126 - 94 + 1)];
	
	dtextSet = [aDtext copy];
	
	[anAlpha formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
	
	alphaSet = [anAlpha copy];
	
	[aFtextSet addCharactersInRange:NSMakeRange(59, 126 - 59 + 1)];
	
	ftextSet = [aFtextSet copy];
	
	[aCtextSet addCharactersInRange:NSMakeRange(33, 39 - 33 + 1)];
	[aCtextSet addCharactersInRange:NSMakeRange(42, 91 - 42 + 1)];
	[aCtextSet addCharactersInRange:NSMakeRange(93, 126 - 93 + 1)];

	ctextSet = [aCtextSet copy];
	
	crSet = [[NSCharacterSet characterSetWithCharactersInString:@"\n"] copy];
	lfSet = [[NSCharacterSet characterSetWithCharactersInString:@"\r"] copy];

	encodedTextSet = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(33, 126 - 33 + 1)];
	[encodedTextSet removeCharactersInString:@" ?"];
	encodedTextSet = [encodedTextSet copy];
	encodedWordTokenSet = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(0, 127 - 0 + 1)];
	[encodedWordTokenSet removeCharactersInRange:NSMakeRange(0, 32)];
	[encodedWordTokenSet removeCharactersInString:@"()<>@,;:\\\"/[]?.= "];
	encodedWordTokenSet = [encodedWordTokenSet copy];

	wspSet = [[NSCharacterSet characterSetWithCharactersInString:@"\t "] copy];
	
	zoneDic = [[NSDictionary dictionaryWithObjectsAndKeys:
									@"+0000",@"ut", @"+0000",@"gmt", 
									@"-0400",@"edt", @"-0500",@"est", 
									@"-0500",@"cdt", @"-0600",@"cst", 
									@"-0600",@"mdt", @"-0700",@"mst", 
									@"-0700",@"pdt", @"-0800",@"pst", nil] copy];
	monthNames = [[NSArray arrayWithObjects:@"jan", @"feb", @"mar", @"apr", @"may", @"jun", @"jul",@"aug",@"sep", @"oct", @"nov", @"dec", nil] copy];
	zoneNames = [[NSArray arrayWithObjects:@"UT", @"GMT", @"EST",@"EDT", @"CST", @"CDT", @"MST", @"MDT", @"PST", @"PDT", nil] copy];
	aZoneCharacterSet = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(65, 73 - 65 + 1)];
	[aZoneCharacterSet addCharactersInRange:NSMakeRange(75, 90 - 75 + 1)];
	[aZoneCharacterSet addCharactersInRange:NSMakeRange(97, 105 - 97 + 1)];
	[aZoneCharacterSet addCharactersInRange:NSMakeRange(107, 122 - 107 + 1)];
	zoneCharacterSet = [aZoneCharacterSet copy];
	capitalizedMonthNames = [[NSArray arrayWithObjects:@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul",@"Aug",@"Sep", @"Oct", @"Nov", @"Dec", nil] copy];
	dayNames = [[NSArray arrayWithObjects:@"Mon", @"Tue", @"Wed", @"Thu", @"Fri", @"Sat", @"Sun", nil] copy];
}

+ (NSCharacterSet *)wspSet
{
	return wspSet;
}

+ (NSCharacterSet *)crSet
{
	return crSet;
}

+ (NSCharacterSet *)lfSet
{
	return lfSet;
}

+ (NSCharacterSet *)textSet
{
	return textSet;
}

+ (NSCharacterSet *)utextSet
{
	return utextSet;
}

+ (NSCharacterSet *)obsCharSet
{
	return obsCharSet;
}

+ (NSCharacterSet *)obsCharSetExceptingWSP
{
	return obsCharSetExceptingWSP;
}

+ (NSCharacterSet *)atextSet
{
	return atextSet;
}

+ (NSCharacterSet *)qtextSet
{
	return qtextSet;
}

+ (NSCharacterSet *)lfcrSet
{
	return lfcrSet;
}

+ (NSCharacterSet *)dtextSet
{
	return dtextSet;
}

+ (NSCharacterSet *)alphaSet
{
	return alphaSet;
}

+ (NSCharacterSet *)ftextSet
{
	return ftextSet;
}

+ (NSCharacterSet *)ctextSet
{
	return ctextSet;
}

+ (BOOL)isUnstructured:(NSString *)aString
{
	ATTokenScanner *aTokenScanner = [[[ATTokenScanner alloc] initWith:aString] autorelease];
	
	[aTokenScanner scanUnstructuredInto:nil];
	
	return [aTokenScanner isAtEnd];
}

+ (id)scannerWith:(NSString *)aString
{
	return [[[self alloc] initWith:aString] autorelease];
}

- (id)initWith:(NSString *)aString
{
	[super init];
	
	scanner = [[NSScanner scannerWithString:aString] retain];
	[scanner setCharactersToBeSkipped:nil];
	
	return self;
}

- (void)dealloc
{
	[scanner release];
	
	[super dealloc];
}

- (NSScanner *)scanner
{
	return scanner;
}

- (BOOL)isAtEnd
{
	return [scanner isAtEnd];
}

- (unsigned)scanLocation
{
	return [scanner scanLocation];
}

- (void)setScanLocation:(unsigned)aLocation
{
	[scanner setScanLocation:aLocation];
}

- (NSString *)string
{
	return [scanner string];
}

- (BOOL)scanString:(NSString *)aString intoString:(NSString **)aValue
{
	unsigned aLocation = [scanner scanLocation];
	NSString *aScannerString = [scanner string];
	NSRange aRange = NSMakeRange(aLocation, [aScannerString length] - aLocation);
	
	if (aRange.length > 0)
	{
		NSRange aStringRange = [aScannerString rangeOfString:aString options:(NSCaseInsensitiveSearch | NSLiteralSearch | NSAnchoredSearch) range:aRange];
		
		if (aStringRange.location != NSNotFound)
		{
			if (aValue)
				*aValue = [aScannerString substringWithRange:aStringRange];
			
			[scanner setScanLocation:aLocation + aStringRange.length];
			
			return YES;
		}
	}

	return NO;
}

- (BOOL)scanCharactersFromSet:(NSCharacterSet *)aCharSet intoString:(NSString **)aString
{
	NSString *aScanString = [scanner string];
	unsigned aStartingLoc = [scanner scanLocation];
	unsigned aCurrentLoc = aStartingLoc;
	unsigned aStringLength = [aScanString length];
	BOOL aCharFound = NO;
	
	for ( ; aCurrentLoc < aStringLength && [aCharSet characterIsMember:[aScanString characterAtIndex:aCurrentLoc]]; aCurrentLoc++)
		;

	if (aCurrentLoc != aStartingLoc)
	{
		[scanner setScanLocation:aCurrentLoc];
		
		if (aString)
			*aString = [aScanString substringWithRange:NSMakeRange(aStartingLoc, aCurrentLoc - aStartingLoc)];
		
		aCharFound = YES;
	}
	
	return aCharFound;
}

@end

@implementation ATTokenScanner (PrimitiveTokens)

/*
	text =	%d1-9 /         ; Characters excluding CR and LF
			%d11 /
			%d12 /
			%d14-127 /
			obs-text

*/
- (BOOL)scanTextInto:(NSString **)aText
{
	return [self scanObsTextInto:aText];
}

/*
	obs-text = *LF *CR *(obs-char *LF *CR)
*/
- (BOOL)scanObsTextInto:(NSString **)aText
{
	return [self scanObsTextInto:aText obsCharSet:[[self class] obsCharSet]];
}

- (BOOL)scanObsTextInto:(NSString **)aText obsCharSet:(NSCharacterSet *)anObsCharSet
{
	unsigned aLocation = [scanner scanLocation];
	
	do 
	{
		[self scanCharactersFromSet:[[self class] lfSet] intoString:nil];
		if (![self peekCRLF])
			[self scanCharactersFromSet:[[self class] crSet] intoString:nil];
	}
	while ([self scanCharactersFromSet:anObsCharSet intoString:nil]);

	if (aText)
	{
		if (aLocation != [scanner scanLocation])
			*aText = [[scanner string] substringWithRange:NSMakeRange(aLocation, [scanner scanLocation] - aLocation)];
		else
			*aText = @"";
	}
	
	return YES;
}

@end

@implementation ATTokenScanner (FoldingWhiteSpaceAndComments)

- (BOOL)skipFWS
{
	return [self scanCharactersFromSet:[ATTokenScanner wspSet] intoString:nil];
}

- (BOOL)scanFWSInto:(NSString **)aFWS
{
	return [self scanCharactersFromSet:[ATTokenScanner wspSet] intoString:aFWS];
}

- (BOOL)skipWSP
{
	return [scanner scanCharactersFromSet:[ATTokenScanner wspSet] intoString:nil];
}

- (BOOL)skipCRLF
{
	return [self scanString:@"\r\n" intoString:nil];
}

- (BOOL)peekCRLF
{	
	if ([self scanString:@"\r\n" intoString:nil])
	{
		[scanner setScanLocation:[scanner scanLocation] - 2];
		
		return YES;
	}
	
	return NO;
}

- (BOOL)skipCtext
{
	return [self scanCharactersFromSet:[[self class] ctextSet] intoString:nil];
}

- (BOOL)skipCcontent
{
	return [self skipCtext] || [self skipQuotedPair] || [self skipComment];
}

- (BOOL)skipComment
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	if ([self scanString:@"(" intoString:nil])
	{
		do 
		{
			[self skipFWS];
		} while ([self skipCcontent]);
		
		if ([self scanString:@")" intoString:nil])
		{
			return YES;
		}
		else
		{
			[scanner setScanLocation:aPrevLoc];
			
			return NO;
		}
	}
	
	return NO;
}

- (BOOL)skipCFWS
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	do
	{
		[self skipFWS];
	} while ([self skipComment]);
	
	return aPrevLoc < [scanner scanLocation];
}

- (BOOL)scanCFWSInto:(ATCFWS **)aCFWS
{
	if (aCFWS)
	{
		unsigned aPrevLoc = [scanner scanLocation];
		ATCFWS *aReturningCFWS = [[ATCFWS new] autorelease];
		
		do
		{
			[self scanFWSIntoToken:aReturningCFWS];
				
		} while ([self scanCommentIntoToken:aReturningCFWS]);
		
		if (aPrevLoc < [scanner scanLocation])
		{
			if (aCFWS)
				*aCFWS = aReturningCFWS;
			
			return YES;
		}
		else
			return NO;
	}
	else
		return [self skipCFWS];
}

- (BOOL)scanFWSTokenInto:(ATFWS **)aFWS
{
	if (aFWS)
	{
		NSString *aFWSString = nil;

		if ([self scanFWSInto:&aFWSString])
		{
			*aFWS = [[[ATFWS alloc] initWith:aFWSString] autorelease];
			
			return YES;
		}
		else
			return NO;
	}
	else
		return [self skipFWS];
}

- (BOOL)scanCommentInto:(ATComment **)aComment
{
	if (aComment)
	{
		unsigned aPrevLoc = [scanner scanLocation];
		ATComment *aReturningComment = [[ATComment new] autorelease];
		
		if ([self scanString:@"(" intoString:nil])
		{
			do 
			{
				[self scanFWSIntoToken:aReturningComment];
			} while ([self scanCcontentIntoToken:aReturningComment]);
			
			if ([self scanString:@")" intoString:nil])
			{
				if (aComment)
					*aComment = aReturningComment;
					
				return YES;
			}
			else
			{
				[scanner setScanLocation:aPrevLoc];
				
				return NO;
			}
		}
		else
			return NO;
	}
	else
		return [self skipComment];
}

- (BOOL)scanCtextInto:(ATCtext **)aCtext
{
	if (aCtext)
	{
		NSString *aCtextString = nil;
		
		if ([scanner scanCharactersFromSet:[[self class] ctextSet] intoString:&aCtextString])
		{
			*aCtext = [[[ATCtext alloc] initWith:aCtextString] autorelease];
			
			return aCtext;
		}
		else
			return NO;
	}
	else
		return [scanner scanCharactersFromSet:[[self class] ctextSet] intoString:nil];
}

- (BOOL)scanCtextIntoToken:(id)aToken
{
	ATCtext *aCtext = nil;
	
	if ([self scanCtextInto:&aCtext])
	{
		if (aToken)
			[aToken add:aCtext];
			
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanFWSIntoToken:(id)aToken
{
	ATFWS *aPuttingFWS = nil;
	
	if ([self scanFWSTokenInto:&aPuttingFWS])
	{
		if (aToken)
			[aToken add:aPuttingFWS];
			
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanCommentIntoToken:(id)aToken
{
	ATComment *aComment = nil;
	
	if ([self scanCommentInto:&aComment])
	{
		if (aToken)
			[aToken add:aComment];
			
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanCcontentIntoToken:(ATComment *)aComment
{
	return [self scanCtextIntoToken:aComment] || [self scanQuotedPairIntoToken:aComment] || [self scanCommentIntoToken:aComment];
}

@end

@implementation ATTokenScanner (Atom)

- (BOOL)scanAtomInto:(NSString **)aWord
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([self scanAtomExceptingCFWSInto:aWord])
	{
		[self skipCFWS];
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanAtomExceptingCFWSInto:(NSString *)anAtom
{
	return [self scanCharactersFromSet:[[self class] atextSet] intoString:anAtom];
}

- (BOOL)scanDotAtomInto:(NSString **)aDotAtom
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([self scanDotAtomTextInto:aDotAtom])
	{
		[self skipCFWS];
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanDotAtomTextInto:(NSString **)aDotAtom
{
	unsigned aPrevLoc = [scanner scanLocation];

	if ([self scanCharactersFromSet:[[self class] atextSet] intoString:nil])
	{
		BOOL aScanFailed = NO;
		
		while (!aScanFailed && [self scanString:@"." intoString:nil])
		{
			if (![self scanCharactersFromSet:[[self class] atextSet] intoString:nil])
				aScanFailed = YES;
		}
		
		if (!aScanFailed)
		{
			if (aDotAtom)
				*aDotAtom = [[scanner string] substringWithRange:NSMakeRange(aPrevLoc, [scanner scanLocation] - aPrevLoc)];
	
			return YES;
		}
	}
	
	[scanner setScanLocation:aPrevLoc];
	
	return NO;
}

@end

@implementation ATTokenScanner (QuotedStrings)

- (BOOL)scanQcontentInto:(NSString **)aQcontent
{
	return ([self scanQtextInto:aQcontent] || [self scanQuotedPairInto:aQcontent]);
}

- (BOOL)scanQtextInto:(NSString **)aQText
{
	return [self scanCharactersFromSet:[[self class] qtextSet] intoString:aQText];
}

- (BOOL)skipQuotedPair
{
	return [self scanQuotedPairInto:nil];
}

- (BOOL)scanQuotedPairInto:(NSString **)aText
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	if ([self scanString:@"\\" intoString:nil])
	{		
		if (![scanner isAtEnd] && 
				//textの規則に当てはまるか
				(([[[self class] textSet] characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]]) || 
				([[[self class] lfcrSet] characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]]) ||
				//obs-charの規則に当てはまるか
				([[[self class] obsCharSet] characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]])))
		{			
			if (aText)
				*aText = [[scanner string] substringWithRange:NSMakeRange([scanner scanLocation], 1)];
		
			[scanner setScanLocation:[scanner scanLocation] + 1];

			return YES;
		}
		else
		{
			[scanner setScanLocation:aPrevLoc];
			
			return NO;
		}
	}
	else
		return NO;
}

- (BOOL)scanQuotedStringInto:(NSString **)aQuotedString
{
	unsigned aLocation = [scanner scanLocation];
	NSString *aReturningQuotedString = nil;
	
	[self skipCFWS];
	
	if ([self scanQuotedStringExceptingCFWSInto:&aReturningQuotedString])
	{
		[self skipCFWS];
		
		if (aQuotedString)
			*aQuotedString = aReturningQuotedString;
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aLocation];
	
		return NO;
	}
}

- (BOOL)scanQuotedStringExceptingCFWSInto:(NSString **)aQuotedString
{
	unsigned aLocation = [scanner scanLocation];
	NSMutableString *aQuotedStringContent = aQuotedString ? [NSMutableString string] : nil;
	
	if ([self scanString:@"\"" intoString:nil])
	{
		BOOL aContentFinished = NO;
		NSString *aQcontent = nil;
		
		while (!aContentFinished)
		{
			if ([self scanFWSInto:&aQcontent])
				[aQuotedStringContent appendString:aQcontent];
			
			if ([self scanQcontentInto:&aQcontent])
				[aQuotedStringContent appendString:aQcontent];
			else
				aContentFinished = YES;
		}
		
		if ([self scanString:@"\"" intoString:nil])
		{
			if (aQuotedString)
				*aQuotedString = aQuotedStringContent;
			
			return YES;
		}
		else
		{
			[scanner setScanLocation:aLocation];
			
			return NO;
		}
	}

	return NO;
}

- (BOOL)scanQuotedPairIntoToken:(id)aToken
{
	NSString *aQuotedPair = nil;
	
	if ([self scanQuotedPairInto:&aQuotedPair])
	{
		if (aToken)
			[aToken add:[[[ATQuotedPair alloc] initWith:aQuotedPair] autorelease]];
			
		return YES;
	}
	else
		return NO;
}

@end

@implementation ATTokenScanner (MiscellaneousTokens)

- (BOOL)scanWordInto:(NSString **)aWord
{
	return [self scanAtomInto:aWord] || [self scanQuotedStringInto:aWord];
}

- (BOOL)scanWordExceptingCFWSInto:(NSString **)aWord
{
	return [self scanAtomExceptingCFWSInto:aWord] || [self scanQuotedStringExceptingCFWSInto:aWord];
}

- (BOOL)scanPhraseInto:(NSString **)aPhrase
{
	return [self scanObsPhraseInto:aPhrase];
}

- (BOOL)scanObsPhraseInto:(NSString **)aPhrase
{
	NSMutableString *aReturningPhrase = aPhrase ? [NSMutableString string] : nil;
	BOOL aPhraseFinished = NO;
	BOOL aWordFound = NO;
	ATEncodedWord *aPendingEncodedWord = nil;
	unsigned aLocation = [scanner scanLocation];

	while (!aPhraseFinished)
	{
		ATEncodedWord *anEncodedWord = nil;
		NSString *aWord = nil;
		
		if ([self scanEncodedWordTokenIncludingCFWSInto:&anEncodedWord])
		{
			if (aPendingEncodedWord)
				[aReturningPhrase appendString:[aPendingEncodedWord displayStringExceptRightCFWS]];
				
			aPendingEncodedWord = anEncodedWord;
		}
		else
		{
			if (aPendingEncodedWord)
			{
				[aReturningPhrase appendString:[aPendingEncodedWord displayString]];
				aPendingEncodedWord = nil;
			}

			if ([self scanWordExceptingCFWSInto:&aWord])
				[aReturningPhrase appendString:aWord];
			else if ([self scanString:@"." intoString:nil])
				[aReturningPhrase appendString:@"."];
			else if ([self skipCFWS])
				[aReturningPhrase appendString:@" "];
			else
				aPhraseFinished = YES;
		}
		
		if (aWord || anEncodedWord)
			aWordFound = YES;
	}
	
	if (aWordFound)
	{
		if (aPhrase)
			*aPhrase = aReturningPhrase;
			
		return YES;
	}
	else
	{
		[scanner setScanLocation:aLocation];
		
		return NO;
	}
}

- (BOOL)scanEncodedWordTokenInto:(id *)anEncodedWord
{
	NSString *aCharset = nil, *anEncoding = nil, *anEncodedText = nil;
	
	if ([self scanEncodedWordInto:&aCharset into:&anEncoding into:&anEncodedText])
	{
		if (anEncodedWord)
			*anEncodedWord = [ATEncodedWord encodedWordWith:aCharset encoding:anEncoding encodedText:anEncodedText];
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanEncodedWordTokenIncludingFWSInto:(ATEncodedWord **)anEncodedWord
{
	return [self scanEncodedWordTokenInto:anEncodedWord enclosingSelector:@selector(scanFWSInto:) terminatingSelector:@selector(utextContinue)];
}

- (BOOL)scanEncodedWordTokenIncludingCFWSInto:(ATEncodedWord **)anEncodedWord
{
	/*unsigned aLocation = [scanner scanLocation];
	ATCFWS *aLeftCFWS = nil, *aRightCFWS = nil;
	ATEncodedWord *aReturningEncodedWord = nil;
	BOOL aScanSucceed = NO;
	
	[self scanCFWSInto:&aLeftCFWS];
	
	if ([self scanEncodedWordTokenInto:&aReturningEncodedWord])
	{
		[aReturningEncodedWord setLeftCFWS:aLeftCFWS];
		
		if (![self scanWordExceptingCFWSInto:nil])
		{
			[self scanCFWSInto:&aRightCFWS];
			[aReturningEncodedWord setRight:aRightCFWS];
			aScanSucceed = YES;
		}
	}
	
	if (!aScanSucceed)
		[scanner setScanLocation:aLocation];
	else if (anEncodedWord)
		*anEncodedWord = aReturningEncodedWord;
	
	return aScanSucceed;*/
	return [self scanEncodedWordTokenInto:anEncodedWord enclosingSelector:@selector(scanCFWSInto:) terminatingSelector:@selector(wordContinue)];
}

- (BOOL)scanEncodedWordTokenInto:(ATEncodedWord **)anEncodedWord enclosingSelector:(SEL)anEnclosingSelector terminatingSelector:(SEL)aTerminatingSelector
{
	unsigned aLocation = [scanner scanLocation];
	id aLeft = nil, aRight = nil;
	ATEncodedWord *aReturningEncodedWord = nil;
	BOOL aScanSucceed = NO;
	
	[self performSelector:anEnclosingSelector withObject:&aLeft];
	
	if ([self scanEncodedWordTokenInto:&aReturningEncodedWord])
	{
		[aReturningEncodedWord setLeftCFWS:aLeft];
		
		if (![self performSelector:aTerminatingSelector]/*![self scanWordExceptingCFWSInto:nil]*/)
		{
			[self performSelector:anEnclosingSelector withObject:&aRight];
			[aReturningEncodedWord setRight:aRight];
			aScanSucceed = YES;
		}
	}
	
	if (!aScanSucceed)
		[scanner setScanLocation:aLocation];
	else if (anEncodedWord)
		*anEncodedWord = aReturningEncodedWord;
	
	return aScanSucceed;

}

- (BOOL)scanEncodedWordInto:(NSString **)aCharset into:(NSString **)anEncoding into:(NSString **)anEncodedText
{
	unsigned aLocation = [scanner scanLocation];
	NSString *aReturningCharset, *aReturningEncoding, *aReturningEncodedText;
	
	if ([self scanString:@"=?" intoString:nil]
		&& [self scanCharsetInto:&aReturningCharset]
		&& [self scanString:@"?" intoString:nil]
		&& [self scanEncodingInto:&aReturningEncoding]
		&& [self scanString:@"?" intoString:nil]
		&& [self scanEncodedTextInto:&aReturningEncodedText]
		&& [self scanString:@"?=" intoString:nil])
	{
		if (aCharset)
			*aCharset = aReturningCharset;
		if (anEncoding)
			*anEncoding = aReturningEncoding;
		if (anEncodedText)
			*anEncodedText = aReturningEncodedText;
		
		return YES;
	}
	
	[scanner setScanLocation:aLocation];
	
	return NO;
}

- (BOOL)scanCharsetInto:(NSString **)aCharset
{
	return [self scanTokenOfEncodedWordInto:aCharset];
}

- (BOOL)scanEncodingInto:(NSString **)anEncoding
{
	return [self scanTokenOfEncodedWordInto:anEncoding];
}

- (BOOL)scanEncodedTextInto:(NSString **)anEncodedText
{
	return [self scanCharactersFromSet:encodedTextSet intoString:anEncodedText];
}

- (BOOL)scanTokenOfEncodedWordInto:(NSString **)anEncodedWordToken
{
	return [self scanCharactersFromSet:encodedWordTokenSet intoString:anEncodedWordToken];
}

- (BOOL)scanNoEmptyUnstructuredInto:(NSString **)aNoEmptyUnstructured
{
	NSString *anUnstructured = nil;
	
	[self scanUnstructuredInto:&anUnstructured];
	
	if (anUnstructured)
	{
		if (aNoEmptyUnstructured)
			*aNoEmptyUnstructured = anUnstructured;
		
		return YES;
	}
	
	return NO;
}

/*
	unstructured    =       *([FWS] utext) [FWS]
*/
- (BOOL)scanUnstructuredInto:(NSString **)anUnstructured
{
	BOOL anUnstructuredFinished = NO;
	NSString *aFWS;
	NSString *aUtextString;
	NSMutableString *aString = anUnstructured ? [NSMutableString string] : nil;
	
	while (!anUnstructuredFinished)
	{
		if ([self scanFWSInto:&aFWS])
			[aString appendString:aFWS];
		else if ([self scanUtextInto:&aUtextString] && [aUtextString length])
			[aString appendString:aUtextString];
		else
			anUnstructuredFinished = YES;
	}
	
	if (anUnstructured)
		*anUnstructured = aString;
	
	return YES;
}

- (BOOL)scanUtextInto:(NSString **)aUtext
{
	return [self scanObsUtextInto:aUtext];
}

- (BOOL)scanObsUtextInto:(NSString **)aUtext
{
	return [self scanObsTextInto:aUtext];
}

- (BOOL)scanUTextExceptingFWSInto:(NSString **)aUTextExceptingFWS
{
	return [self scanObsUtextExceptingFWSInto:aUTextExceptingFWS];
}

- (BOOL)scanObsUtextExceptingFWSInto:(NSString **)aUTextExceptingFWS
{
	return [self scanObsTextInto:aUTextExceptingFWS obsCharSet:[[self class] obsCharSetExceptingWSP]];
}

- (BOOL)wordContinue
{
	return [self scanWordExceptingCFWSInto:nil];
}

- (BOOL)utextContinue
{
	NSString *aUtext = nil;
	
	return [self scanUTextExceptingFWSInto:&aUtext] && [aUtext length];
}

@end

@implementation ATTokenScanner (DateAndTimeSpecification)

- (BOOL)scanDateTimeInto:(NSCalendarDate **)aDateTime
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aDayOfWeek = nil;
	NSString *aDay = nil, *aMonth = nil, *aYear = nil;
	ATTimeOfDay *aTimeOfDay, *aZone = nil;
	NSCalendarDate *aReturningDateTime = nil;
	
	
	if ([self scanDayOfWeekInto:&aDayOfWeek])
	{
		if (![self scanString:@"," intoString:nil])
		{
			[scanner setScanLocation:aPrevLoc];
			
			return NO;
		}
	}
	
	if (![self scanDateInto:&aDay into:&aMonth into:&aYear])
	{
		[scanner setScanLocation:aPrevLoc];
			
		return NO;
	}
	
	if (![self skipFWS])
	{
		[scanner  setScanLocation:aPrevLoc];
			
		return NO;
	}

	if (![self scanTimeInto:&aTimeOfDay into:&aZone])
	{
		[scanner  setScanLocation:aPrevLoc];
			
		return NO;
	}
	
	[self skipCFWS];
		
	aReturningDateTime = [self dateByYear:aYear month:aMonth day:aDay timeOfDay:aTimeOfDay timeZone:aZone];
	
	if (aReturningDateTime)
		*aDateTime = aReturningDateTime;
	
	return YES;
}

- (NSCalendarDate *)dateByYear:(NSString *)aYear month:(NSString *)aMonth day:(NSString *)aDay timeOfDay:(ATTimeOfDay *)aTimeOfDay timeZone:(NSString *)aZone
{
	int aSecondsOfZone;
	BOOL aZoneIsValid;
	
	aSecondsOfZone = [self secondsOfZone:aZone isValid:&aZoneIsValid];
	
	return [NSCalendarDate dateWithYear:[aYear intValue] 
				month:[self numberOfMonth:aMonth] day:[aDay intValue] 
				hour:[aTimeOfDay hour] minute:[aTimeOfDay minute] second:[aTimeOfDay second] 
				timeZone:(aZoneIsValid ? [NSTimeZone timeZoneForSecondsFromGMT:aSecondsOfZone] : nil)];
}

- (int)secondsOfZone:(NSString *)aZone isValid:(BOOL *)aValid
{
	if (([aZone hasPrefix:@"+"] || [aZone hasPrefix:@"-"]) && (-9959 <= [aZone intValue] && [aZone intValue] <= 9959))
	{
		if ([aZone hasPrefix:@"-"] && ([aZone intValue] == 0))
			*aValid = NO;
		else
			*aValid = YES;
		
		return ([[aZone substringToIndex:3] intValue] * 60 + [[aZone substringFromIndex:3] intValue]) * 60;
	}
	else
		return [self secondsOfObsZone:aZone isValid:aValid];
}

- (int)secondsOfObsZone:(NSString *)aZone isValid:(BOOL *)aValid
{
	NSString *anObsZone = [zoneDic objectForKey:[aZone lowercaseString]];
	
	if (anObsZone)
	{	
		*aValid = YES;
		
		return [self secondsOfZone:anObsZone isValid:aValid];
	}
	else
	{
		*aValid = NO;
		
		return 0;
	}
}

- (unsigned)numberOfMonth:(NSString *)aMonth
{
	return [monthNames indexOfObject:[aMonth lowercaseString]] + 1;
}

- (BOOL)scanTimeInto:(ATTimeOfDay **)aTimeOfDay into:(NSString **)aZone
{
	unsigned aPrevLoc = [scanner scanLocation];
	ATTimeOfDay *aReturningTimeOfDay = nil;
	NSString *aReturningZone = nil;
	
	if ([self scanTimeOfDayInto:&aReturningTimeOfDay]
		/*&& [self skipFWS]*/ && [self scanZoneInto:&aReturningZone])
	{
		if (aTimeOfDay)
			*aTimeOfDay = aReturningTimeOfDay;
		if (aZone)
			*aZone = aReturningZone;
		
		return YES;
	}
	else
	{
		[scanner  setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanZoneInto:(NSString **)aZone
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	if (([self scanString:@"+" intoString:nil] || [self scanString:@"-" intoString:nil])
			&& [self scanDigitInto:nil length:4])
	{
		*aZone = [[scanner string] substringWithRange:NSMakeRange(aPrevLoc, 5)];
			
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return [self scanObsZoneInto:aZone];
	}
}

- (BOOL)scanObsZoneInto:(NSString **)aZone
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSEnumerator *enumerator = [zoneNames objectEnumerator];
	NSString *aZoneName;
	NSString *aReturningZoneName = nil;


	while ((aZoneName = [enumerator nextObject]) && ![self scanString:aZoneName intoString:&aReturningZoneName])
	{
	}
	
	if (aReturningZoneName)
	{
		*aZone = aReturningZoneName;
		
		return YES;
	}
	else if (![scanner isAtEnd] && [zoneCharacterSet characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]])
	{
		*aZone = [[scanner string] substringWithRange:NSMakeRange([scanner scanLocation], 1)];
		[scanner setScanLocation:[scanner scanLocation]];
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanTimeOfDayInto:(ATTimeOfDay **)aTimeOfDay 
{
	unsigned aPrevLoc = [scanner scanLocation];
	int aReturningHour = 0, aReturningMinute = 0;
	int aReturningSecond = 0;

	if ([self scanHourInto:&aReturningHour] && [self scanString:@":" intoString:nil] && [self scanMinuteInto:&aReturningMinute])
	{
		BOOL aScanFailed = NO;
		
		if ([self scanString:@":" intoString:nil])
		{
			if (![self scanSecondInto:&aReturningSecond])
				aScanFailed = YES;
		}
		
		if (!aScanFailed)
		{
			if (aTimeOfDay)
				*aTimeOfDay = [[[ATTimeOfDay alloc] initWith:aReturningHour with:aReturningMinute with:aReturningSecond] autorelease];
							
			return YES;
		}
	}
	
	[scanner setScanLocation:aPrevLoc];
		
	return NO;
}

- (BOOL)scanHourInto:(int *)anHour
{
	if ([self scanObsTwoDigitInto:anHour])
		return YES;
	else
		return NO;
}

- (BOOL)scanMinuteInto:(int *)aMinute
{
	return [self scanHourInto:aMinute];
}

- (BOOL)scanSecondInto:(int *)aSecond
{
	return [self scanHourInto:aSecond];
}

- (BOOL)scanTwoDigitInto:(NSString **)aTwoDigit
{
	unsigned aStartingLoc = [scanner scanLocation];
	NSCharacterSet *aDigitSet = [NSCharacterSet decimalDigitCharacterSet];
	unsigned aCount = 0;
	
	while (aCount < 2 && ![scanner isAtEnd] && [aDigitSet characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]])
	{
		[scanner setScanLocation:[scanner scanLocation] + 1];
		aCount++;
	}
	
	if (aCount == 2)
	{
		*aTwoDigit = [[scanner string] substringWithRange:NSMakeRange(aStartingLoc, aCount)];
			
		return YES;
	}
	else
	{
		[scanner setScanLocation:aStartingLoc];
		
		return NO;
	}

}

- (BOOL)scanDigitInto:(NSString **)aDigit length:(unsigned)aLength
{
	unsigned aStartingLoc = [scanner scanLocation];
	NSCharacterSet *aDigitSet = [NSCharacterSet decimalDigitCharacterSet];
	unsigned aCount = 0;
	
	while (aCount < aLength && ![scanner isAtEnd] && [aDigitSet characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]])
	{
		[scanner setScanLocation:[scanner scanLocation] + 1];
		aCount++;
	}
	
	if (aCount == aLength)
	{
		if (aDigit)
			*aDigit = [[scanner string] substringWithRange:NSMakeRange(aStartingLoc, aCount)];
			
		return YES;
	}
	else
	{
		[scanner setScanLocation:aStartingLoc];
		
		return NO;
	}
}

- (BOOL)scanObsTwoDigitInto:(int *)aTwoDigit
{
	ATCFWS *aLeftCFWS = nil;
	NSString *aTwoDigitString = nil;
	
	[self skipCFWS];
	
	if ([self scanTwoDigitInto:&aTwoDigitString])
	{
		ATCFWS *aRightCFWS = nil;
		
		[self skipCFWS];
		
		if (aTwoDigit)
			*aTwoDigit = [aTwoDigitString intValue];
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanDateInto:(NSString **)aDay into:(NSString **)aMonth into:(NSString **)aYear
{
	NSString *aReturningDay = nil, *aReturningMonth = nil, *aReturningYear = nil;
	
	if ([self scanDayInto:&aReturningDay] && [self scanMonthInto:&aReturningMonth] && [self scanYearInto:&aReturningYear])
	{
		*aDay = aReturningDay;
		*aMonth = aReturningMonth;
		*aYear = aReturningYear;
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanDayInto:(NSString **)aDay
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningDay = nil;

	[self skipFWS];

	if ([self scanOneOrTwoDIGITInto:&aReturningDay])
	{
		*aDay = aReturningDay;
		
		return YES;
	}
	
	[scanner setScanLocation:aPrevLoc];
	
	return NO;
}

- (BOOL)scanOneOrTwoDIGITInto:(NSString **)aDigit
{
	unsigned aStartingLoc = [scanner scanLocation];
	NSCharacterSet *aDigitSet = [NSCharacterSet decimalDigitCharacterSet];
	unsigned aCount = 0;
	
	while (aCount < 2 && ![scanner isAtEnd] && [aDigitSet characterIsMember:[[scanner string] characterAtIndex:[scanner scanLocation]]])
	{
		[scanner setScanLocation:[scanner scanLocation] + 1];
		aCount++;
	}
	
	if (aCount)
	{
		*aDigit = [[scanner string] substringWithRange:NSMakeRange(aStartingLoc, aCount)];
			
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanYearInto:(NSString **)aYear
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningYear = nil;
	
	if ([self scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&aReturningYear]
			&& 4 <= [aReturningYear length])
	{
		*aYear = aReturningYear;
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return [self scanObsYearInto:aYear];
	}
}

- (BOOL)scanObsYearInto:(NSString **)aYear
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningYear = nil;

	if ([self skipCFWS] 
			&& ([self scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&aReturningYear]
				&& 2 <= [aReturningYear length])
			&& [self skipCFWS])
	{
		*aYear = aReturningYear;
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}

}

- (BOOL)scanMonthInto:(NSString **)aMonth
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningMonth = nil;
	
	if ([self skipFWS] && [self scanMonthNameInto:&aReturningMonth] && [self skipFWS])
	{
		*aMonth = aReturningMonth;
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return [self scanObsMonthInto:aMonth];
	}
}

- (BOOL)scanMonthNameInto:(NSString **)aMonth
{
	NSEnumerator *enumerator = [capitalizedMonthNames objectEnumerator];
	NSString *aMonthName;
	NSString *aReturningMonthName = nil;

	while ((aMonthName = [enumerator nextObject]) && ![self scanString:aMonthName intoString:&aReturningMonthName])
	{
	}
	
	if (aReturningMonthName)
	{
		*aMonth = aReturningMonthName;
		return YES;
	}
	else
		return NO;

}

- (BOOL)scanObsMonthInto:(NSString **)aMonth
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningMonth = nil;

	if ([self skipCFWS] && [self scanMonthInto:&aReturningMonth] && [self skipCFWS])
	{
		*aMonth = aReturningMonth;
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanObsDayInto:(NSString **)aDay
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningDay = nil;
	
	[self skipCFWS];
	
	if ([self scanOneOrTwoDIGITInto:&aReturningDay])
	{
		[self skipCFWS];
		
		*aDay = aReturningDay;
		
		return YES;
	}
	
	[scanner setScanLocation:aPrevLoc];
	
	return NO;
}

- (BOOL)scanDayOfWeekInto:(NSString **)aDayOfWeek
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	[self skipFWS];
	
	if ([self scanDayNameInto:aDayOfWeek])
		return YES;
	else
	{
		[scanner setScanLocation:aPrevLoc];

		return [self scanObsDayOfWeekInto:aDayOfWeek];
	}
}

- (BOOL)scanObsDayOfWeekInto:(NSString **)aDayOfWeek
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([self scanDayNameInto:aDayOfWeek])
	{
		[self skipCFWS];
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanDayNameInto:(NSString **)aDayOfWeek
{
	NSEnumerator *enumerator = [dayNames objectEnumerator];
	NSString *aDayName;
	NSString *aReturningDayName = nil;

	while ((aDayName = [enumerator nextObject]) && ![self scanString:aDayName intoString:&aReturningDayName])
	{
	}
	
	if (aReturningDayName)
	{
		*aDayOfWeek = aReturningDayName;
		return YES;
	}
	else
		return NO;
}

@end

@implementation ATTokenScanner (AddressSpecification)

- (BOOL)scanAddressInto:(id *)anAddress
{
	id aReturningAddress = nil;
	
	if ([self scanMailboxInto:&aReturningAddress] || [self scanGroupInto:&aReturningAddress])
	{
		if (anAddress)
			*anAddress = aReturningAddress;
			
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanAddressListInto:(NSArray **)anAddressList
{
	return [self scanObsAddrListInto:anAddressList];
}

- (BOOL)scanObsAddrListInto:(NSArray **)anAddressList
{
	id anAddress = nil;
	NSMutableArray *aReturningAddressList = [NSMutableArray array];
	BOOL aFinished = NO;

	while (!aFinished)
	{
		if ([self scanAddressInto:&anAddress])
			[aReturningAddressList addObject:anAddress];
	
		[self skipCFWS];
	
		if (![self scanString:@"," intoString:nil])
			aFinished = YES;
		else
			[self skipCFWS];
	}
	
	if (anAddressList)
		*anAddressList = aReturningAddressList;
		
	return YES;
}

- (BOOL)scanGroupInto:(ATGroup **)aGroup
{
	NSString *aDisplayName = nil;
	NSArray *aMailboxList = nil;

	if ([self scanGroupInto:&aDisplayName into:&aMailboxList])
	{
		if (aGroup)
			*aGroup = [[[ATGroup alloc] initWith:aDisplayName with:aMailboxList] autorelease];
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanGroupInto:(NSString **)aDisplayName into:(NSArray **)aMailboxList
{
	unsigned aPrevLoc = [scanner scanLocation];	
	NSString *aReturningDisplayName = nil;

	if ([self scanDisplayNameInto:&aReturningDisplayName] && [self scanString:@":" intoString:nil])
	{
		NSArray *aReturningMailboxList = nil;

		if (![self scanMailboxListInto:&aReturningMailboxList])
			[self skipCFWS];
		
		if ([self scanString:@";" intoString:nil])
		{
			[self skipCFWS];
			
			if (aDisplayName)
				*aDisplayName = aReturningDisplayName;
			if (aMailboxList)
				*aMailboxList = aReturningMailboxList;
			
			return YES;
		}
	}

	[scanner setScanLocation:aPrevLoc];
	
	return NO;
}

- (BOOL)scanMailboxListInto:(NSArray **)aMailboxList
{
	return [self scanObsMboxListInto:aMailboxList];
}

- (BOOL)scanObsMboxListInto:(NSArray **)aMailboxList
{
	id aMailbox = nil;
	NSMutableArray *aReturningMailboxList = [NSMutableArray array];
	BOOL aFinished = NO;

	while (!aFinished)
	{
		if ([self scanMailboxInto:&aMailbox])
			[aReturningMailboxList addObject:aMailbox];
	
		[self skipCFWS];
	
		if (![self scanString:@"," intoString:nil])
			aFinished = YES;
		else
			[self skipCFWS];
	}
	
	if (aMailboxList)
		*aMailboxList = aReturningMailboxList;
		
	return YES;
}

- (BOOL)scanMailboxInto:(id *)aMailbox
{		
	return ([self scanNameAddrInto:aMailbox] || [self scanAddrSpecInto:aMailbox]);
}

- (BOOL)scanAddrSpecInto:(ATAddrSpec **)anAddrSpec
{
	NSString *aLocalPart = nil, *aDomain = nil;
	
	if ([self scanAddrSpecInto:&aLocalPart into:&aDomain])
	{
		if (anAddrSpec)
			*anAddrSpec = [[[ATAddrSpec alloc] initWith:aLocalPart with:aDomain] autorelease];
			
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanAddrSpecInto:(NSString **)aLocalPart into:(NSString **)aDomain
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningLocalPart = nil, *aReturningDomain = nil;
		
	if ([self scanLocalPartInto:&aReturningLocalPart] 
		&& [self scanString:@"@" intoString:nil] 
		&& [self scanDomainInto:&aReturningDomain])
	{
		if (aLocalPart)
			*aLocalPart = aReturningLocalPart;
		if (aDomain)
			*aDomain = aReturningDomain;
			
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanNameAddrInto:(ATNameAddr **)aNameAddr
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningDisplayName = nil;
	ATAngleAddr *aReturningAngleAddr = nil;
	
	[self scanDisplayNameInto:&aReturningDisplayName];
	
	if ([self scanAngleAddrInto:&aReturningAngleAddr])
	{
		if (aNameAddr)
			*aNameAddr = [[[ATNameAddr alloc] initWith:aReturningDisplayName with:aReturningAngleAddr] autorelease];
		
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanDisplayNameInto:(NSString **)aDisplayName 
{
	return [self scanPhraseInto:aDisplayName];
}

- (BOOL)scanAngleAddrInto:(ATAngleAddr **)anAngleAddr
{
	return [self scanObsAngleAddrInto:anAngleAddr];
}

- (BOOL)scanObsAngleAddrInto:(ATAngleAddr **)anAngleAddr
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([self scanString:@"<" intoString:nil])
	{	
		ATAddrSpec *anAddrSpec = nil;
		
		[self skipObsRoute];
		
		if ([self scanAddrSpecInto:&anAddrSpec] && [scanner  scanString:@">" intoString:nil])
		{	
			if (anAngleAddr)
				*anAngleAddr = [[[ATAngleAddr alloc] initWith:anAddrSpec] autorelease];
		
			[self skipCFWS];
		
			return YES;
		}
	}
	
	[scanner setScanLocation:aPrevLoc];
	
	return NO;
}

- (BOOL)skipObsRoute
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([self skipObsDomainList] && [self scanString:@":" intoString:nil])
	{
		[self skipCFWS];
		
		return YES;
	}
	
	[scanner setScanLocation:aPrevLoc];
	
	return NO;
}

- (BOOL)skipObsDomainList
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	if ([self scanString:@"@" intoString:nil] && [self scanDomainInto:nil])
	{
		do
		{
			while ([self skipCFWS] || [self scanString:@"," intoString:nil])
				;
		} while ([self scanString:@"@" intoString:nil] && [self scanDomainInto:nil]);
			
		return YES;
	}

	[scanner setScanLocation:aPrevLoc];
		
	return NO;
}

- (BOOL)scanDomainInto:(NSString **)aDomain
{
	return [self scanDomainLiteralInto:aDomain] || [self scanObsDomainInto:aDomain];
}

- (BOOL)scanDomainLiteralInto:(NSString **)aDomainLiteral
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([self scanString:@"[" intoString:nil])
	{
		BOOL aFinished = NO;
		NSMutableString *aReturningDomainLiteral = aDomainLiteral ? [NSMutableString string] : nil;

		[aReturningDomainLiteral appendString:@"["];
	
		while (!aFinished)
		{
			NSString *aDcontent = nil;
			
			if ([self skipFWS])
				[aReturningDomainLiteral appendString:@" "];
		
			if ([self scanDcontentInto:&aDcontent])
				[aReturningDomainLiteral appendString:aDcontent];
			else
				aFinished = YES;
		}
	
		if ([self scanString:@"]" intoString:nil])
		{
			[aReturningDomainLiteral appendString:@"]"];
		
			if (aDomainLiteral)
				*aDomainLiteral = aReturningDomainLiteral;
		
			[self skipCFWS];
			
			return YES;
		}
	}
	
	[scanner setScanLocation:aPrevLoc];
	
	return NO;
}

- (BOOL)scanDcontentInto:(NSString **)aDcontent
{
	return ([self scanDtextInto:aDcontent] || [self scanQuotedPairInto:aDcontent]);
}

- (BOOL)scanDtextInto:(NSString **)aDtext
{
	return [self scanCharactersFromSet:[[self class] dtextSet] intoString:aDtext];
}

- (BOOL)scanLocalPartInto:(NSString **)aLocalPart
{
	return [self scanObsLocalPartInto:aLocalPart];
}

- (BOOL)scanObsLocalPartInto:(NSString **)aLocalPart
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSMutableString *aReturningLocalPart = [NSMutableString string];
	NSString *aWord = nil;
		
	if ([self scanWordInto:&aWord])
	{
		BOOL aScanFailed = NO;
		
		[aReturningLocalPart appendString:aWord];
		
		while (!aScanFailed && [self scanString:@"." intoString:nil])
		{
			[aReturningLocalPart appendString:@"."];
			
			if ([self scanWordInto:&aWord])
				[aReturningLocalPart appendString:aWord];
			else
				aScanFailed = YES;
		}
		
		if (!aScanFailed)
		{
			if (aLocalPart)
				*aLocalPart = aReturningLocalPart;
			
			return YES;
		}
	}
	
	[scanner setScanLocation:aPrevLoc];
	
	return NO;	
}

- (BOOL)scanObsDomainInto:(NSString **)aDomain
{
	unsigned aLocation = [scanner scanLocation];
	NSMutableString *aReturningDomain = aDomain ? [NSMutableString string] : nil;
	NSString *anAtom = nil;
	BOOL anErrorOccurred = NO;
	
	if ([self scanAtomInto:&anAtom])
	{
		[aReturningDomain appendString:anAtom];
		
		while (!anErrorOccurred && [self scanString:@"." intoString:nil])
		{
			[aReturningDomain appendString:@"."];
			
			if ([self scanAtomInto:&anAtom])
				[aReturningDomain appendString:anAtom];
			else
			{
				anErrorOccurred = YES;
				[scanner setScanLocation:aLocation];
			}
		}
	}
	
	if (!anErrorOccurred)
	{
		if (aDomain)
			*aDomain = aReturningDomain;
		
		return YES;
	}
	else
		return NO;
}

@end

@implementation ATTokenScanner (IdentificationFields)

- (BOOL)scanMsgIDInto:(ATMsgID **)aMsgID
{
	NSString *anIDLeft = nil, *anIDRight = nil;
	
	if ([self scanMsgIDInto:&anIDLeft into:&anIDRight])
	{
		if (aMsgID)
			*aMsgID = [[[ATMsgID alloc] initWith:anIDLeft with:anIDRight] autorelease];
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanMsgIDInto:(NSString **)anIDLeft into:(NSString **)anIDRight
{
	unsigned aPrevLoc = [scanner scanLocation];
	NSString *aReturningIDLeft = nil, *aReturningIDRight = nil;
	
	[self skipCFWS];
	
	if ([self scanString:@"<" intoString:nil] 
		&& [self scanIDLeftInto:&aReturningIDLeft] && [self scanString:@"@" intoString:nil] && [self scanIDRightInto:&aReturningIDRight]
		&& [self scanString:@">" intoString:nil])
	{
		[self skipCFWS];
		
		if (anIDLeft)
			*anIDLeft = aReturningIDLeft;
		if (anIDRight)
			*anIDRight = aReturningIDRight;
			
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
	
		return NO;
	}
}

- (BOOL)scanIDLeftInto:(NSString **)anIDLeft
{
	return [self scanObsIDLeftInto:anIDLeft];
}

- (BOOL)scanNoFoldQuoteInto:(NSString **)aNoFoldQuote
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	if ([self scanString:@"\"" intoString:nil])
	{
		NSMutableString *aReturningNoFoldQuote = [NSMutableString string];
		NSString *aString = nil;
		
		[aReturningNoFoldQuote appendString:@"\""];
		
		while ([self scanQtextInto:&aString] || [self scanQuotedPairInto:&aString])
		{
			[aReturningNoFoldQuote appendString:aString];
		}
		
		if ([scanner  scanString:@"\"" intoString:nil])
		{
			if (aNoFoldQuote)
				*aNoFoldQuote = aReturningNoFoldQuote;
	
			[aReturningNoFoldQuote appendString:@"\""];
			
			return YES;
		}
		else
		{
			[scanner setScanLocation:aPrevLoc];
	
			return NO;
		}		
	}
	else
		return NO;
}

- (BOOL)scanObsIDLeftInto:(NSString **)anIDLeft
{
	return [self scanLocalPartInto:anIDLeft];
}

- (BOOL)scanIDRightInto:(NSString **)anIDRight
{
	[self scanObsIDRightInto:anIDRight];
}

- (BOOL)scanNoFoldLiteralInto:(NSString **)aNoFoldLiteral
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	if ([self scanString:@"[" intoString:nil])
	{
		NSMutableString *aReturningNoFoldLiteral = [NSMutableString string];
		NSString *aString = nil;
		
		[aReturningNoFoldLiteral appendString:@"["];
		
		while ([self scanDtextInto:&aString] || [self scanQuotedPairInto:&aString])
		{
			[aReturningNoFoldLiteral appendString:aString];
		}
		
		if ([scanner  scanString:@"]" intoString:nil])
		{
			if (aNoFoldLiteral)
				*aNoFoldLiteral = aReturningNoFoldLiteral;
				
			[aReturningNoFoldLiteral appendString:@"]"];
	
			return YES;
		}
		else
		{
			[scanner setScanLocation:aPrevLoc];
	
			return NO;
		}		
	}
	else
		return NO;
}

- (BOOL)scanObsIDRightInto:(NSString **)anIDRight
{
	return [self scanDomainInto:anIDRight];
}

@end

@implementation ATTokenScanner (ResentFields)

//path = ([CFWS] "<" ([CFWS] / addr-spec) ">" [CFWS]) / obs-path
- (BOOL)scanPathInto:(id *)aPath
{
	return [self scanObsPathInto:aPath];
}

- (BOOL)scanObsPathInto:(id *)aPath
{
	return [self scanObsAngleAddrInto:aPath];
}

- (BOOL)scanNameValListInto:(NSDictionary **)aNameValList
{
	NSMutableDictionary *aReturningNameValList = [NSMutableDictionary dictionary];
	NSString *anItemName = nil;
	id anItemValue = nil;

	[self skipCFWS];
	
	if ([self scanNameValPairInto:&anItemName into:&anItemValue])
	{
		BOOL aNameValPairFound = YES;
		
		[aReturningNameValList setObject:anItemValue forKey:anItemName];
		
		do
		{
			unsigned aPrevLoc = [scanner scanLocation];
			
			aNameValPairFound = [self scanNameValPairInto:&anItemName into:&anItemValue];
			
			if (aNameValPairFound)
			{
				[aReturningNameValList setObject:anItemValue forKey:anItemName];
			}
			else
			{
				[scanner setScanLocation:aPrevLoc];
			}
							
		} while (aNameValPairFound);
	}
	
	if (aNameValList)
		*aNameValList = aReturningNameValList;
		
	return YES;
}

- (BOOL)scanNameValPairInto:(NSString **)anItemName into:(id *)anItemValue
{
	unsigned aPrevLoc = [scanner scanLocation];
	
	NSString *aReturningItemName = nil;
	id aReturningItemValue = nil;
	
	if ([self scanItemNameInto:&aReturningItemName] && [self skipCFWS] && [self scanItemValueInto:&aReturningItemValue])
	{
		if (anItemName)
			*anItemName = aReturningItemName;
		if (anItemValue)
			*anItemValue = aReturningItemValue;
			
		return YES;
	}
	else
	{
		[scanner setScanLocation:aPrevLoc];
		
		return NO;
	}
}

- (BOOL)scanItemNameInto:(NSString **)anItemName
{
	unsigned aStartingLoc = [scanner scanLocation];
	
	if ([self scanCharactersFromSet:[[self class] alphaSet] intoString:nil])
	{		
		do
		{
			[self scanString:@"-" intoString:nil];
		} while ([self scanCharactersFromSet:[[self class] alphaSet] intoString:nil] || [self scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet]  intoString:nil]);
		
		if (anItemName)
			*anItemName = [[scanner string] substringWithRange:NSMakeRange(aStartingLoc, [scanner scanLocation] - aStartingLoc)];
			
		return YES;
	}
	else
	{
		[scanner setScanLocation:aStartingLoc];
		
		return NO;
	}
}

- (BOOL)scanItemValueInto:(id *)anItemValue
{
	id aReturningItemValue = nil;

	if ([self scanAngleAddrInto:&aReturningItemValue])
	{
		NSMutableArray *anAngleAddrArray = [NSMutableArray array];

		[anAngleAddrArray addObject:aReturningItemValue];
		
		while ([self scanAngleAddrInto:&aReturningItemValue])
		{
			[anAngleAddrArray addObject:aReturningItemValue];
		}
		
		aReturningItemValue = anAngleAddrArray;
	}
	else 
	{
		[self scanAddrSpecInto:&aReturningItemValue] || [self scanDomainInto:&aReturningItemValue] || [self scanMsgIDInto:&aReturningItemValue];
	}
	
	if (anItemValue)
		*anItemValue = aReturningItemValue;
	
	return aReturningItemValue ? YES : NO;
}

@end
