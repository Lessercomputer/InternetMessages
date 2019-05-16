//
//  ATMultipartTokenScanner.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 07/09/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATInternetMessageLineScanner;

@interface ATMultipartTokenScanner : NSObject
{
	ATInternetMessageLineScanner *lineScanner;
	NSString *boundary;
	NSString *parentBoundary;
	NSData *dashBoundary;
	NSData *parentDashBoundary;
}

+ (id)scannerWithLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary;
+ (id)scannerWithLineScanner:(ATInternetMessageLineScanner *)aLineScanner parentBoundary:(NSString *)aParentBoundary;
+ (id)scannerWithLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary parentBoundary:(NSString *)aParentBoundary;

- (id)initWithLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary parentBoundary:(NSString *)aParentBoundary;

- (NSString *)boundary;

- (NSData *)scanDashBoundary;
- (BOOL)skipDashBoundary;
- (BOOL)peekDashBoundary;
- (BOOL)peekDashBoundaryEqualTo:(NSData *)aDashBoundary;

- (BOOL)skipDashBoundaryEqualTo:(NSData *)aDashBoundary;
- (BOOL)skipNoCloseDashBoundary;
- (BOOL)skipNoCloseDashBoundaryEqualTo:(NSData *)aDashBoundary;

- (unsigned)lengthOfDashBoundaryOnRawLine:(const unsigned char *)aRawLine length:(unsigned)aLineLength;
- (unsigned)lengthOfBoundaryOnRawLine:(const unsigned char *)aRawLine length:(unsigned)aLineLength;

- (NSData *)scanPreamble;

- (NSData *)scanUnfoldedLine;

- (BOOL)skipNextCRLF;

- (BOOL)skipTransportPadding;

- (NSData *)scanBodyPartOctets;

- (BOOL)skipDelimiter;
- (BOOL)peekDelimiter;

- (BOOL)skipNoCloseDelimiter;
- (BOOL)skipCloseDelimiter;
- (BOOL)skipNoCloseDelimiterComposedOf:(NSData *)aDashBoundary;
- (BOOL)skipCloseDelimiterComposedOf:(NSData *)aDashBoundary;

- (NSData *)scanEpilogue;

- (ATInternetMessageLineScanner *)lineScanner;

@end

@interface ATMultipartTokenScanner (Testing)

- (BOOL)isLineDashBoundary:(NSData *)aLine;
- (BOOL)isLineBoundary:(NSData *)aLine;

- (BOOL)isCharacterBchars:(unsigned char)aChar;
- (BOOL)isCharacterBcharsnospace:(unsigned char)aChar;

@end