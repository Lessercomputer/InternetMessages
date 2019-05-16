//
//  ATContentTypeFieldBody.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/09/23.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATContentTypeFieldBody : NSObject
{
	NSString *type;
	NSString *subtype;
	NSDictionary *parameters;
}

+ (id)defaultContentType;

- (id)initWithUnfoldedLine:(NSString *)aString;
- (id)initWithType:(NSString *)aType subtype:(NSString *)aSubtype parameters:(NSDictionary *)aParameters;

- (NSString *)type;
- (NSString *)subtype;

- (NSString *)charset;
- (NSString *)boundary;

- (NSString *)stringValue;

- (BOOL)typeIs:(NSString *)aType;
- (BOOL)subtypeIs:(NSString *)aSubtype;
- (BOOL)charsetIs:(NSString *)aCharset;

@end
