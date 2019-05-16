//
//  ATCtext.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATCtext : NSObject
{
	NSString *ctext;
}

- (id)initWith:(NSString *)aCtext;

- (NSString *)stringValue;
- (void)printOn:(NSMutableString *)aString;

@end
