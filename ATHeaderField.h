//
//  ATHeaderField.h
//  ATMail
//
//  Created by 高田　明史 on 06/02/22.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATFieldBody;

@interface ATHeaderField : NSObject
{
	NSString *name;
	id body;
}

+ (id)defaultContentType;
+ (id)defaultContentTransferEncoding;

@end

@interface ATHeaderField (Initializing)

+ (id)headerFieldWithLineData:(NSData *)aLineData;

- (id)initWithLineData:(NSData *)aLineData interpret:(BOOL)anInterpretFlag;
- (id)initWithLine:(NSString *)aLine interpret:(BOOL)anInterpretFlag;
- (id)initWithName:(NSString *)aFieldName fieldBody:(id)aFieldBody;

@end

@interface ATHeaderField (Accessing)

- (NSString *)name;
- (void)setName:(NSString *)aString;

- (id)body;
- (void)setBody:(id)aBody;

- (NSString *)bodyString;
- (NSAttributedString *)bodyAttributedString;
- (NSMutableAttributedString *)attributedString;
- (id)value;

- (void)addLine:(NSString *)aLine;

- (NSData *)rawData;

@end

@interface ATHeaderField (Interpretting)


+ (NSArray *)groupFolded:(NSArray *)aLines;

- (BOOL)scanHeaderField:(NSString *)aFirstLine intoFieldName:(NSString **)aFieldName intoBody:(NSString **)aBody;

- (BOOL)interpretName;
- (BOOL)interpretBody;
- (BOOL)interpret;

@end

@interface ATHeaderField (Testing)

+ (BOOL)isFolding:(NSString *)aLine;
- (BOOL)isFolding:(NSString *)aLine;

- (BOOL)nameIs:(NSString *)aName;
- (BOOL)nameIsIncludedIn:(NSSet *)aHeaderNames;

- (BOOL)nameIsInterpreted;
- (BOOL)isInterpreted;
- (BOOL)isValid;

@end