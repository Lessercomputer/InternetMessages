//
//  ATFieldBody.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/03/11.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface ATFieldBody : NSObject
{
	NSMutableString *value;
}

+ (void)setFieldBody:(Class)aFieldBodyClass forName:(NSString *)aName;
+ (Class)fieldBodyForName:(NSString *)aName;

@end

@interface ATFieldBody (Initializing)

- (id)initWithFoldedLine:(NSString *)aString;

@end

@interface ATFieldBody (Accessing)

- (NSMutableString *)value;
- (void)setValue:(NSMutableString *)aString;

- (NSString *)stringValue;

- (void)addLine:(NSString *)aLine;

@end
