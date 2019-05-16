//
//  ATQuotedPrintableDecoder.m
//  ATQuotedPrintable
//
//  Created by 高田　明史 on 07/11/18.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATQuotedPrintableDecoder.h"


@implementation ATQuotedPrintableDecoder

+ (NSData *)decode:(NSData *)anInputData
{
	id aDecoder = [[[self alloc] initWithData:anInputData] autorelease];
	
	return [aDecoder decode];
}

+ (NSData *)decodeWithQ:(NSData *)anInputData
{
	id aDecoder = [[[self alloc] initWithData:anInputData withQ:YES] autorelease];
	
	return [aDecoder decode];
}

- (id)initWithData:(NSData *)anInputData
{
	return [self initWithData:anInputData withQ:NO];
}

- (id)initWithData:(NSData *)anInputData withQ:(BOOL)aQDecoderFlag
{
	[super init];
	
	inputData = [anInputData retain];
	outputData = [NSMutableData new];
	isQDecoder = aQDecoderFlag;
	
	return self;
}
	
- (void)dealloc
{
	[inputData release];
	[outputData release];
	
	[super dealloc];
}

- (NSData *)decode
{
	[self decodeQpLine];
	
	while ([self decodeCRLF])
		[self decodeQpLine];
		
	return [self isAtEnd] ? outputData : nil;
}

- (BOOL)isAtEnd
{
	return location >= [inputData length];
}

- (unsigned char)currentCharacter
{
	return ((unsigned char *)[inputData bytes])[location];
}

- (void)decodeQpLine
{
	BOOL aSectionComposedOfSegment = NO;
	BOOL anErrorOccurred = NO;
	
	do
	{
		[self decodeQpSection];
		
		if ([self skipEqualSign])
		{
			aSectionComposedOfSegment = YES;
			
			[self skipTransportPadding];
			
			if (![self skipCRLF])
				anErrorOccurred = YES;
		}
		else
		{
			aSectionComposedOfSegment = NO;
			[self removeTransportPadding];
		}

	}
	while (aSectionComposedOfSegment && !anErrorOccurred);
}

- (BOOL)decodeCRLF
{
	if ([self skipCRLF])
	{
		[outputData appendBytes:"\r\n" length:2];
		
		return YES;
	}
	
	return NO;
}

- (void)decodeQpPart
{
	[self decodeQpSection];
}

- (BOOL)decodeQpSegment
{
	unsigned aLocation = location;
	
	[self decodeQpSection];
		
	if ([self skipEqualSign])
		return YES;
	else
	{
		location = aLocation;
		
		return NO;
	}
}

- (void)decodeQpSection
{
	while (![self isAtEnd] && ([self decodePtext] || [self decodeSpace] || [self decodeTab]))
		;
}

- (BOOL)decodePtext
{
	return [self decodeHexOctet] || [self decodeSafeChar];
}

- (BOOL)decodeHexOctet
{
	unsigned aLocation = location;
	BOOL aDecodeOfHexOctetSucceed = NO;
	
	if ([self skipEqualSign])
	{
		unsigned char aHexChars[2];
		
		if (![self isAtEnd] && [self currentCharacterIsHexChar])
		{
			aHexChars[0] = [self currentCharacter];
			location++;
			
			if (![self isAtEnd] && [self currentCharacterIsHexChar])
			{
				unsigned char aHexOctet;
				
				aHexChars[1] = [self currentCharacter];
				aHexOctet = (unsigned char)strtol((const char *)aHexChars, NULL, 16);
				[outputData appendBytes:&aHexOctet length:1];
				location++;

				aDecodeOfHexOctetSucceed = YES;
			}
		}
	}
	
	if (aDecodeOfHexOctetSucceed)
		return YES;
	else
	{
		location = aLocation;
		
		return NO;
	}
}

- (BOOL)currentCharacterIsHexChar
{
	unsigned char aCharacter = ((unsigned char *)[inputData bytes])[location];
	
	if ((aCharacter >= '0' && aCharacter <= '9')
		|| (aCharacter >= 'A' && aCharacter <= 'F') || (aCharacter >= 'a' && aCharacter <= 'f'))
		return YES;
	else
		return NO;
}
	
- (BOOL)decodeSafeChar
{
	unsigned char aCharacter = ((unsigned char *)[inputData bytes])[location];
	
	if ((aCharacter >= 33 && aCharacter <= 60) || (aCharacter >= 62 && aCharacter <= 126))
	{
		if (isQDecoder && aCharacter == '_')
			aCharacter = ' ';
			
		[outputData appendBytes:&aCharacter length:1];
		location++;
		
		return YES;
	}
	
	return NO;
}

- (BOOL)decodeSpace
{
	return [self decodeCharacterEqualTo:' '];
}

- (BOOL)decodeTab
{
	return [self decodeCharacterEqualTo:'\t'];
}

- (BOOL)decodeCharacterEqualTo:(unsigned char)aCharacter
{
	unsigned char aCurrentCharacter = ((unsigned char *)[inputData bytes])[location];
	
	if (aCurrentCharacter == aCharacter)
	{
		[outputData appendBytes:&aCurrentCharacter length:1];
		location++;
		
		return YES;
	}
	
	return NO;
}

- (BOOL)skipTransportPadding
{
	unsigned aLocation = location;
	
	while (![self isAtEnd] && ((((unsigned char *)[inputData bytes])[location] == ' ') || (((unsigned char *)[inputData bytes])[location] == '\t')))
		location++;
		
	return aLocation != location;
}

- (BOOL)skipCRLF
{
	if (location + 1 < [inputData length])
	{
		if ((((unsigned char *)[inputData bytes])[location] == '\r') && (((unsigned char *)[inputData bytes])[location + 1] == '\n'))
		{
			location += 2;
			
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)skipEqualSign
{
	if (![self isAtEnd] && (((unsigned char *)[inputData bytes])[location] == '='))
	{
		location++;
		
		return YES;
	}
	
	return NO;
}

- (void)removeTransportPadding
{
	int i = [outputData length] - 1;
	unsigned aTransportPaddingCount = 0;
	
	for ( ; i > 0 && [self transportPaddingIsAt:i] ; i--)
	{
		aTransportPaddingCount++;
	}
	
	if (aTransportPaddingCount > 0)
		[outputData setLength:[outputData length] - aTransportPaddingCount];
}

- (BOOL)transportPaddingIsAt:(NSUInteger)anIndex
{
	unsigned char aCharacter = ((unsigned char *)[outputData bytes])[anIndex];
	
	return aCharacter == ' ' || aCharacter == '\t';
}

@end
