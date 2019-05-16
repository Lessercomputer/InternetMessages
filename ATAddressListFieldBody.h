//
//  ATAddressListFieldBody.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATAddressListFieldBody : NSObject
{
	NSArray *value;
}

- (void)setValue:(NSArray *)anAddressList;

- (NSString *)stringValue;
@end
