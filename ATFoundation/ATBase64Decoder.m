//
//  ATBase64Decoder.m
//  ATBase64Decoder
//
//  Created by çÇìc ñæéj on Mon Jan 24 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import "ATBase64Decoder.h"

NSString *ATBase64DecoderNoCharacterException = @"ATBase64DecoderNoCharacterException";
NSString *ATBase64DecoderInvalidDataException = @"ATBase64DecoderInvalidDataException";

@implementation ATBase64Decoder

- (NSData *)decode
{
	while (![self isAtEnd])
	{
		[self processNext];
	}
	
	return outputData;
}

- (void)processNext
{
	unsigned char aBase64String[4], aValues[3];
	unsigned aLengthOfString = [self nextString:aBase64String];
	unsigned aPadCount = 0;
	
	if (aLengthOfString == 4)
	{
		if ([self isValid:aBase64String pad:&aPadCount])
		{
			[self decode:aBase64String to:aValues];
			[outputData appendBytes:aValues length:(3 - aPadCount)];
			
			if (aPadCount)
				readPad = YES;
		}
	}
}

- (NSUInteger)nextString:(unsigned char *)aString
{
	int i;
	
	for (i = 0; ![self isAtEnd] && i < 4; i++)
	{
		aString[i] = [self nextCharacter];
	}
	
	return i;
}

- (unsigned char)nextCharacter
{
	BOOL aReadChar = NO;
	unsigned char *aTop = (unsigned char *)[inputData bytes];
	
	for ( ; !aReadChar && location < [inputData length]; location++)
	{
		aReadChar = [self isBase64Character:aTop[location]];
	}
	
	return aReadChar ? aTop[location - 1] : 0;
}

- (BOOL)isBase64Character:(unsigned char )aCharacter
{
	return ((aCharacter >= 'A' && aCharacter <= 'Z')  ||
			(aCharacter >= 'a' && aCharacter <= 'z')  ||
			(aCharacter >= '0' && aCharacter <= '9')  ||
			(aCharacter == '+') || (aCharacter == '/') ||
			(aCharacter == '='));
}
	
- (BOOL)isValid:(unsigned char *)aString pad:(int *)aPadCount
{
	if (aString[0] != '=' && aString[1] != '=' && aString[2] != '=' && aString[3] != '=')
	{
		*aPadCount = 0;
		return YES;
	}
	else if (aString[0] != '=' && aString[1] != '=' && aString[2] != '=' && aString[3] == '=')
	{
		*aPadCount = 1;
		return YES;
	}
	else if (aString[0] != '=' && aString[1] != '=' && aString[2] == '=' && aString[3] == '=')
	{
		*aPadCount = 2;
		return YES;
	}
	
	return NO;
}

- (BOOL)isAtEnd
{
	return [super isAtEnd] || readPad;
}

- (void)decode:(unsigned char *)aBase64String to:(unsigned char *)aValues
{
	unsigned char aBase64Values[4];
	
	[self decodeBase64String:aBase64String  to:aBase64Values];
	[self convert:aBase64Values to:aValues];
}

- (void)decodeBase64String:(unsigned char *)aBase64String  to:(unsigned char *)aBase64Values
{
	int i;
	
	for (i = 0; i < 4; i++)
	{
		aBase64Values[i] = [self decode:aBase64String[i]];
	}
}

- (unsigned char)decode:(unsigned char)aCharacter
{
	if (aCharacter >= 'A' && aCharacter <= 'Z')
		return aCharacter - 'A';
	else if (aCharacter >= 'a' && aCharacter <= 'z')
		return aCharacter - 'a' + 26;
	else if (aCharacter >= '0' && aCharacter <= '9')
		return aCharacter - '0' + 52;
	else if (aCharacter == '+')
		return 62;
	else if (aCharacter == '/')
		return 63;
	else if (aCharacter == '=')
		return 0;
}

- (void)convert:(unsigned char *)aBase64Values to:(unsigned char *)aValues
{
	aValues[0] = aBase64Values[0] << 2 | aBase64Values[1] >> 4;
	aValues[1] = aBase64Values[1] << 4 | aBase64Values[2] >> 2;
	aValues[2] = aBase64Values[2] << 6 | aBase64Values[3];
}

@end
