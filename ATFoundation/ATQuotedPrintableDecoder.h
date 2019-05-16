//
//  ATQuotedPrintableDecoder.h
//  ATQuotedPrintable
//
//  Created by 高田　明史 on 07/11/18.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATQuotedPrintableDecoder : NSObject
{
	NSData *inputData;
	NSMutableData *outputData;
	unsigned location;
	BOOL isQDecoder;
}

+ (NSData *)decode:(NSData *)anInputData;
+ (NSData *)decodeWithQ:(NSData *)anInputData;

- (id)initWithData:(NSData *)anInputData;
- (id)initWithData:(NSData *)anInputData withQ:(BOOL)aQDecoderFlag;

- (NSData *)decode;
- (BOOL)isAtEnd;

- (void)decodeQpLine;
- (BOOL)decodeCRLF;
- (void)decodeQpPart;
- (BOOL)decodeQpSegment;
- (void)decodeQpSection;
- (BOOL)decodePtext;
- (BOOL)decodeHexOctet;
- (BOOL)currentCharacterIsHexChar;
- (BOOL)decodeSafeChar;
- (BOOL)decodeSpace;
- (BOOL)decodeTab;
- (BOOL)decodeCharacterEqualTo:(unsigned char)aCharacter;
- (BOOL)skipTransportPadding;
- (BOOL)skipCRLF;
- (BOOL)skipEqualSign;
- (void)removeTransportPadding;
- (BOOL)transportPaddingIsAt:(NSUInteger)anIndex;

@end
