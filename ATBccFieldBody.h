//
//  ATBccFieldBody.h
//  ATMail
//
//  Created by ���c�@���j on 06/04/17.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATBccFieldBody : NSObject
{
	NSMutableArray *addressList;
}

- (void)setValue:(NSMutableArray *)anAddressList;

- (NSString *)stringValue;
@end
