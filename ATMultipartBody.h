//
//  ATMultipartBody.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/10/03.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATInternetMessageLineScanner;
@class ATMultipartTokenScanner;

@interface ATMultipartBody : NSObject
{
	NSString *parentBoundary;
	NSString *boundary;
	NSMutableArray *bodyParts;
}

+ (id)multipartBodyFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary;
+ (id)multipartBodyFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary parentBoundary:(NSString *)aParentBoundary;

- (id)initFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary parentBoundary:(NSString *)aParentBoundary;

- (NSString *)stringValue;

- (NSMutableAttributedString *)attributedString;
- (NSMutableAttributedString *)attributedStringOfSummary;

- (NSMutableArray *)bodyParts;

- (id)at:(unsigned)anIndex;

- (unsigned)count;

- (BOOL)isMultipart;

@end
