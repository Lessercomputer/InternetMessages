//
//  ATComment.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/03/19.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATComment : NSObject
{
	NSMutableArray *ccontent;
}

- (void)add:(id)aToken;

- (NSMutableArray *)value;

- (NSString *)stringValue;

- (void)printOn:(NSMutableString *)aString;

@end
