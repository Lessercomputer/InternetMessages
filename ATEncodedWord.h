//
//  ATEncodedWord.h
//  ATMail
//
//  Created by 高田　明史 on 06/10/24.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ATCFWS;

@interface ATEncodedWord : NSObject
{
	NSString *charset;
	NSString *encoding;
	NSString *encodedText;
	ATCFWS *leftCFWS;
	ATCFWS *rightCFWS;
}

+ (id)encodedWordWith:(NSString *)aCharset encoding:(NSString *)anEncoding encodedText:(NSString *)anEncodedText;

- (id)initWith:(NSString *)aCharset encoding:(NSString *)anEncoding encodedText:(NSString *)anEncodedText;

- (void)setLeftCFWS:(ATCFWS *)aLeftCFWS;
- (void)setRight:(ATCFWS *)aRightCFWS;

- (NSString *)displayString;
- (NSString *)displayStringExceptRightCFWS;

+ (NSString *)decodeEncodedWord:(NSString *)aCharset encoding:(NSString *)anEncoding encodedText:(NSString *)anEncodedText leftCFWS:(ATCFWS *)aLeftCFWS rightCFWS:(ATCFWS *)aRightCFWS includingRightCFWS:(BOOL)anIncludingFlag;
+ (NSString *)encodedWord:(NSString *)aCharset encoding:(NSString *)anEncoding encodedText:(NSString *)anEncodedText;

@end
