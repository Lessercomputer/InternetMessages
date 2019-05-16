//
//  ATInternetMessageLineScanner.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 07/09/03.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATInternetMessageLineScanner : NSObject
{
	NSData *rawAsciiData;
	unsigned location;
}

+ (id)scannerWithData:(NSData *)aRawAsciiData;
+ (id)scannerWithFileContentsOfFile:(NSString *)aPath;

- (id)initWithData:(NSData *)aRawAsciiData;
- (id)initWithFileContentsOfFile:(NSString *)aPath;

- (NSData *)scanNextLine;
- (NSData *)peekNextLine;
- (const unsigned char *)peekNextRawLine:(unsigned *)aRawLineLength;
- (BOOL)skipNextLine;

- (NSData *)scanUnfoldedLine;

- (NSRange)scanNextLineRange;
- (NSData *)scanNextCRLF;

- (NSRange)scanNextCRLFRange;
- (BOOL)skipNextCRLF;
- (NSRange)scanNextCRLFRange;

- (BOOL)skipNextLineAndCRLF;
- (BOOL)skipNextTerminatedLine;

- (NSData *)subdataWithRange:(NSRange)aRange;
- (NSData *)remainingData;

- (NSArray *)allLines;

- (BOOL)isAtEnd;

- (unsigned)location;
- (void)setLocation:(unsigned)aLocation;

- (void)incrementBy:(unsigned)aCount;
- (void)decrementBy:(unsigned)aCount;

@end
