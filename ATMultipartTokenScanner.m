//
//  ATMultipartTokenScanner.m
//  ATMail
//
//  Created by 高田　明史 on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATMultipartTokenScanner.h"
#import "ATInternetMessageLineScanner.h"

@implementation ATMultipartTokenScanner

+ (id)scannerWithLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary
{
	return [[[self alloc] initWithLineScanner:aLineScanner boundary:aBoundary parentBoundary:nil] autorelease];
}

+ (id)scannerWithLineScanner:(ATInternetMessageLineScanner *)aLineScanner parentBoundary:(NSString *)aParentBoundary
{
	return [[[self alloc] initWithLineScanner:aLineScanner boundary:nil parentBoundary:aParentBoundary] autorelease];
}

+ (id)scannerWithLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary parentBoundary:(NSString *)aParentBoundary
{
	return [[[self alloc] initWithLineScanner:aLineScanner boundary:aBoundary parentBoundary:aParentBoundary] autorelease];
}

- (id)initWithLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary parentBoundary:(NSString *)aParentBoundary
{
	[super init];
	
	lineScanner = [aLineScanner retain];
	boundary = [aBoundary copy];
	parentBoundary = [aParentBoundary copy];
	dashBoundary = boundary ? [[[@"--" stringByAppendingString:boundary] dataUsingEncoding:NSASCIIStringEncoding] copy] : nil;
	parentDashBoundary = parentBoundary ? [[[@"--" stringByAppendingString:parentBoundary] dataUsingEncoding:NSASCIIStringEncoding] copy] : nil;
	
	return self;
}

- (NSString *)boundary
{
	return boundary;
}

- (void)dealloc
{
	[lineScanner release];
	[boundary release];
	[parentBoundary release];
	[dashBoundary release];
	[parentDashBoundary release];
	
	[super dealloc];
}

- (NSData *)scanDashBoundary
{
	unsigned aLocation = [lineScanner location];
	NSData *aDashBoundary = nil;
	
	if ([self skipDashBoundaryEqualTo:dashBoundary])
		aDashBoundary =  [lineScanner subdataWithRange:NSMakeRange(aLocation, [lineScanner location] - aLocation)];
		
	return aDashBoundary;
}

- (BOOL)skipDashBoundary
{
	return [self skipDashBoundaryEqualTo:dashBoundary];
}

- (BOOL)peekDashBoundary
{
	return [self peekDashBoundaryEqualTo:dashBoundary];
}

- (BOOL)peekDashBoundaryEqualTo:(NSData *)aDashBoundary
{
	BOOL aDashBoundaryFound = NO;
	
	if (aDashBoundary)
	{
		unsigned aLocation = [lineScanner location];

		if ([self skipDashBoundaryEqualTo:aDashBoundary])
		{
			[lineScanner setLocation:aLocation];
			aDashBoundaryFound = YES;
		}
	}
	
	return aDashBoundaryFound;
}

- (BOOL)skipDashBoundaryEqualTo:(NSData *)aDashBoundary
{
	BOOL aDashBoundaryFound = NO;
	unsigned aLineLength;
	const unsigned char *aRawLine = [lineScanner peekNextRawLine:&aLineLength];
	unsigned aLengthOfDashBoundaryOnRawLine;
	
	if (aRawLine && aLineLength >= [aDashBoundary length])
	{
		aLengthOfDashBoundaryOnRawLine = [self lengthOfDashBoundaryOnRawLine:aRawLine length:[aDashBoundary length]];
		
		if (aLengthOfDashBoundaryOnRawLine == [aDashBoundary length] && memcmp([aDashBoundary bytes], aRawLine, [aDashBoundary length]) == 0)
		{
			[lineScanner incrementBy:aLengthOfDashBoundaryOnRawLine];
			
			aDashBoundaryFound = YES;
		}
	}

	return aDashBoundaryFound;
}

- (BOOL)skipNoCloseDashBoundary
{
	return [self skipNoCloseDashBoundaryEqualTo:dashBoundary];
}

//dashBoundaryを現在の行から読む事が出来、なおかつ"--"が続かなければYES、そうでなければNOを返す
- (BOOL)skipNoCloseDashBoundaryEqualTo:(NSData *)aDashBoundary
{
	BOOL aNoCloseDashBoundaryFound = NO;
	unsigned aLineLength;
	const unsigned char *aRawLine = [lineScanner peekNextRawLine:&aLineLength];
	unsigned aLengthOfDashBoundaryOnRawLine;	
	NSString *aDashBoundaryString = [[[NSString alloc] initWithBytes:aRawLine length:aLineLength encoding:NSASCIIStringEncoding] autorelease];
	
	if (aRawLine && aLineLength >= [aDashBoundary length])
	{
		aLengthOfDashBoundaryOnRawLine = [self lengthOfDashBoundaryOnRawLine:aRawLine length:[aDashBoundary length]];
		
		if (aLengthOfDashBoundaryOnRawLine == [aDashBoundary length] && memcmp([aDashBoundary bytes], aRawLine, [aDashBoundary length]) == 0)
		{
			if (!((aLineLength >= aLengthOfDashBoundaryOnRawLine + 2)
						&& (memcmp(&aRawLine[aLengthOfDashBoundaryOnRawLine], "--", 2) == 0)))
				aNoCloseDashBoundaryFound = YES;
		}
	}

	if (aNoCloseDashBoundaryFound)
		[lineScanner incrementBy:aLengthOfDashBoundaryOnRawLine];
	
	return aNoCloseDashBoundaryFound;
}

- (unsigned)lengthOfDashBoundaryOnRawLine:(const unsigned char *)aRawLine length:(unsigned)aLineLength
{
	unsigned aBoundaryLength = 0;
	
	if (aLineLength > 2 && memcmp(aRawLine, "--", 2) == 0)
	{
		aBoundaryLength = [self lengthOfBoundaryOnRawLine:&aRawLine[2] length:aLineLength - 2];
		
		if (aBoundaryLength != 0)
			aBoundaryLength += 2;
	}
	
	return aBoundaryLength;
}

- (unsigned)lengthOfBoundaryOnRawLine:(const unsigned char *)aRawLine length:(unsigned)aLineLength
{
	int i = 0;
	BOOL aCharIsBchars = YES;
	
	for ( ; i < aLineLength - 1 && i < 69 && aCharIsBchars; i++)
	{
		aCharIsBchars = [self isCharacterBchars:aRawLine[i]];
	}
	
	if (aCharIsBchars && [self isCharacterBcharsnospace:aRawLine[i]])
		return i + 1;
	else
		return 0;
}


- (NSData *)scanPreamble
{
	unsigned aLocation = [lineScanner location];
	NSData *aPreamble = nil;
	
	while (![self peekDashBoundary] && [lineScanner skipNextLineAndCRLF])
		;
		
	if (![self peekDashBoundary])
		[lineScanner skipNextLine];
	else if (aLocation != [lineScanner location])
		[lineScanner decrementBy:2];
		
	if (aLocation != [lineScanner location])
		aPreamble = [lineScanner subdataWithRange:NSMakeRange(aLocation, [lineScanner location] - aLocation)];
		
	return aPreamble;
}

- (NSData *)scanUnfoldedLine
{
	return [lineScanner scanUnfoldedLine];
}

- (BOOL)skipNextCRLF
{
	return [lineScanner skipNextCRLF];
}

- (BOOL)skipTransportPadding
{
	unsigned aTransportPaddingLength;
	const unsigned char *aRawLine = [lineScanner peekNextRawLine:&aTransportPaddingLength];
	
	if (aRawLine)
	{
		unsigned i = 0;
		
		for ( ; i < aTransportPaddingLength && isblank(aRawLine[i]); i++)
			;
		
		if (i)
			[lineScanner incrementBy:i];
	}
	
	return YES;
}

- (NSData *)scanBodyPartOctets
{
	unsigned aLocation = [lineScanner location];
	BOOL aDelimiterFound = NO;
	
	while (!aDelimiterFound && ![lineScanner isAtEnd])
	{
		if ([self peekDelimiterComposedOf:parentDashBoundary])
			aDelimiterFound = YES;
		else
		{
			[lineScanner skipNextLine];
			
			if ([self peekDelimiterComposedOf:parentDashBoundary])
				aDelimiterFound = YES;
			else
				[lineScanner skipNextCRLF];
		}
	}
	
	if (aLocation != [lineScanner location])
		return [lineScanner subdataWithRange:NSMakeRange(aLocation, [lineScanner location] - aLocation)];
	else
		return nil;
}

- (BOOL)skipDelimiter
{
	BOOL aDelimiterFound = NO;
	unsigned aLocation = [lineScanner location];
	
	if ([self skipNextCRLF] && [self skipDashBoundary])
		aDelimiterFound = YES;
	else
		[lineScanner setLocation:aLocation];
		
	return aDelimiterFound;
}

- (BOOL)peekDelimiter
{
	return [self peekDelimiterComposedOf:dashBoundary];
}

- (BOOL)peekDelimiterComposedOf:(NSData *)aDashBoundary
{
	BOOL aDelimiterFound = NO;
	
	if ([self skipNextCRLF])
	{
		if ([self peekDashBoundaryEqualTo:aDashBoundary])
			aDelimiterFound = YES;
			
		[lineScanner decrementBy:2];	
	}
	
	return aDelimiterFound;
}

- (BOOL)skipNoCloseDelimiter
{
	return [self skipNoCloseDelimiterComposedOf:dashBoundary];
}

- (BOOL)skipCloseDelimiter
{
	return [self skipCloseDelimiterComposedOf:dashBoundary];
}

- (BOOL)skipNoCloseDelimiterComposedOf:(NSData *)aDashBoundary
{
	BOOL aDelimiterFound = NO;
	
	if ([self skipNextCRLF])
	{
		if ([self skipNoCloseDashBoundaryEqualTo:aDashBoundary])
			aDelimiterFound = YES;
		else
			[lineScanner decrementBy:2];
	}
	
	return aDelimiterFound;
}

- (BOOL)skipCloseDelimiterComposedOf:(NSData *)aDashBoundary
{
	BOOL aCloseDelimiterFound = NO;
	unsigned aLocation = [lineScanner location];
	
	if ([self skipNextCRLF])
	{
		if ([self skipDashBoundaryEqualTo:aDashBoundary])
		{
			unsigned aRawLineLength;
			const unsigned char *aRawLine = [lineScanner peekNextRawLine:&aRawLineLength];
			
			if (aRawLineLength >= 2 && memcmp(aRawLine, "--", 2) == 0)
			{
				[lineScanner incrementBy:2];
				
				aCloseDelimiterFound = YES;
			}
		}
		
		if (!aCloseDelimiterFound)
			[lineScanner setLocation:aLocation];
	}

	return aCloseDelimiterFound;
}

- (NSData *)scanEpilogue
{
	unsigned aLocation = [lineScanner location];
	
	while (![self peekDelimiterComposedOf:parentDashBoundary] && ![lineScanner isAtEnd])
		[lineScanner skipNextTerminatedLine];
		
	if (aLocation != [lineScanner location])
		return [lineScanner subdataWithRange:NSMakeRange(aLocation, [lineScanner location] - aLocation)];
	else
		return nil;
}

- (ATInternetMessageLineScanner *)lineScanner
{
	return lineScanner;
}

@end

@implementation ATMultipartTokenScanner (Testing)

- (BOOL)isLineDashBoundary:(NSData *)aLine
{
	return [self lengthOfDashBoundaryOnRawLine:[aLine bytes] length:[aLine length]] != 0;
}

- (BOOL)isLineBoundary:(NSData *)aLine
{
	return [self lengthOfBoundaryOnRawLine:[aLine bytes] length:[aLine length]] != 0;
}

- (BOOL)isCharacterBchars:(unsigned char)aChar
{
	return [self isCharacterBcharsnospace:aChar] || aChar == ' ';
}

- (BOOL)isCharacterBcharsnospace:(unsigned char)aChar
{
	return isalnum(aChar) || aChar == '\'' || aChar == '(' || ')' || aChar == '+' || aChar == '_' || aChar == ',' || aChar == '-' || aChar == '.' || aChar == '/' || aChar == ':' || aChar == '=' || aChar == '?';
}

@end