//
//  ATQuotedPair.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATQuotedPair : NSObject
{
	NSString *quotedPair;
}

- (id)initWith:(NSString *)aQuotedPair;

- (NSString *)stringValue;
- (void)printOn:(NSMutableString *)aString;

@end
