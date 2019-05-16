//
//  ATBase64Decoder.h
//  ATBase64Decoder
//
//  Created by çÇìc ñæéj on Mon Jan 24 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import "ATBase64Processor.h"

extern NSString *ATBase64DecoderNoCharacterException;
extern NSString *ATBase64DecoderInvalidDataException;

@interface ATBase64Decoder : ATBase64Processor
{
	BOOL readPad;
}

- (NSData *)decode;

- (NSUInteger)nextString:(unsigned char *)aString;
- (unsigned char )nextCharacter;
- (BOOL)isBase64Character:(unsigned char )aCharacter;
- (BOOL)isValid:(unsigned char *)aString pad:(int *)aPadCount;
- (void)decode:(unsigned char *)aBase64String to:(unsigned char *)aValues;
- (void)decodeBase64String:(unsigned char *)aBase64String  to:(unsigned char *)aBase64Values;
- (unsigned char)decode:(unsigned char)aCharacter;
- (void)convert:(unsigned char *)aBase64Values to:(unsigned char *)aValues;

@end
