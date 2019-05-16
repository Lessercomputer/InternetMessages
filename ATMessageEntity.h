//
//  ATMessageEntity.h
//  ATMail
//
//  Created by 高田　明史 on 07/04/08.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATHeaderField;
@class ATInternetMessageLineScanner;

@interface ATMessageEntity : NSObject
{
	NSMutableArray *fields;
	id body;
	NSString *parentBoundary;
}

+ (id)bodyPartFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner parentBoundary:(NSString *)aParentBoundary;

- (id)initFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner parentBoundary:(NSString *)aParentBoundary;

@end

@interface ATMessageEntity (Accessing)

- (void)setMessageHeader:(NSMutableArray *)aFields;
- (NSMutableArray *)messageHeader;

- (void)setBody:(id)aBody;
- (id)body;

- (unsigned)count;

+ (NSSet *)supportedTypes;
+ (NSSet *)supportedSubtypes;

- (id)preferredEntity;
- (id)preferredBody;
- (NSString *)preferredStringValue;

- (NSMutableAttributedString *)attributedString;
- (NSMutableAttributedString *)attributedStringWithRestrictionOfHeader:(NSSet *)aHeaderNames;
- (NSMutableAttributedString *)attributedStringOfSummary;
- (NSMutableAttributedString *)attributedStringOfBody;

- (BOOL)saveBodyTo:(NSString *)aFilePath;

- (NSString *)stringValue;

@end

@interface ATMessageEntity (Fields)

- (void)addHeader:(ATHeaderField *)aField;

- (ATHeaderField *)headerFieldAt:(unsigned)anIndex;

- (unsigned)headerFieldCount;

- (ATHeaderField *)lastHeaderField;
- (ATHeaderField *)lastHeaderFieldWithoutInterpreting;

- (ATHeaderField *)headerFieldFor:(NSString *)aName;
- (ATHeaderField *)headerFieldFor:(NSString *)aName interpretIfNotInterpreted:(BOOL)anInterpretFlag;

- (ATHeaderField *)date;
- (NSString *)dateString;

- (ATHeaderField *)subject;
- (NSString *)subjectString;

- (ATHeaderField *)from;
- (NSString *)fromString;

- (ATHeaderField *)to;
- (NSString *)toString;

- (ATHeaderField *)sender;

- (ATHeaderField *)contentType;
- (ATHeaderField *)defaultContentType;

- (ATHeaderField *)contentTransferEncoding;
- (ATHeaderField *)defaultContentTransferEncoding;

- (ATHeaderField *)contentDisposition;

- (NSMutableAttributedString *)attributedStringOfHeader;
- (NSMutableAttributedString *)attributedStringOfHeaderRestrictedTo:(NSSet *)aHeaderNames;

@end

@interface ATMessageEntity (Interpretting)

- (BOOL)interpret;

- (void)readHeaderFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner;
- (void)readHeaderFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner fieldNamesToBeInterpreted:(NSSet *)aFieldNamesToBeInterpreted;
- (void)readBodyFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner;

@end

@interface ATMessageEntity (Testing)

- (BOOL)isMessage;

- (BOOL)isValid;

- (BOOL)isTopLevelMessage;

- (BOOL)contentTypeIsMessage;
- (BOOL)isMIMEMessage;
- (BOOL)isMultipart;
- (BOOL)isMultipartAlternative;
- (BOOL)isCompositeType;

- (BOOL)contentTypeIsText;
- (BOOL)contentTypeIsPlainText;
- (BOOL)contentTypeIsHTML;
- (BOOL)contentTypeIsImage;

- (BOOL)hasValidContentType;

- (BOOL)bodyIsPlainText;
- (BOOL)bodyCharsetIs:(NSString *)aCharset;

@end
