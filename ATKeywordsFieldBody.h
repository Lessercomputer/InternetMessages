//
//  ATKeywordsFieldBody.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/17.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATKeywordsFieldBody : NSObject
{
	NSMutableArray *keywords;
}

- (void)setValue:(NSMutableArray *)aValue;
- (NSMutableArray *)value;

- (NSString *)stringValue;

@end
