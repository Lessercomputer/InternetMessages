//
//  ATCFWS.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATCFWS : NSObject
{
	NSMutableArray *cfws;
}

- (void)add:(id)aToken;

- (BOOL)endWithFWS;

- (NSArray *)value;
- (NSString *)stringValue;

@end
