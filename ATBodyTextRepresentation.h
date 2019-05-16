//
//  ATBodyTextRepresentation.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 07/07/15.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATHeaderField;
@class ATMessageEntity;

@interface ATBodyTextRepresentation : NSObject
{
	ATHeaderField *contentType;
	ATHeaderField *contentTransferEncoding;
	NSData *textData;
	NSString *text;
	NSMutableAttributedString *attributedString;
}

+ (id)textRepresentationWithTextData:(NSData *)aTextData parentEntity:(ATMessageEntity *)anEntity;

+ (id)textRepresentationWithTextData:(NSData *)aTextData contentType:(ATHeaderField *)aContentType contentTransferEncoding:(ATHeaderField *)aContentTransferEncoding;
- (id)initWithTextData:(NSData *)aTextData contentType:(ATHeaderField *)aContentType contentTransferEncoding:(ATHeaderField *)aContentTransferEncoding;

- (void)interpret;

- (NSString *)text;

- (NSString *)stringValue;
- (NSMutableAttributedString *)attributedString;

- (BOOL)saveTo:(NSString *)aFilePath;

@end
