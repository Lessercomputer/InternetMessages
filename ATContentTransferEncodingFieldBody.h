//
//  ATContentTransferEncodingFieldBody.h
//  ATMail
//
//  Created by ���c�@���j on 06/09/24.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATContentTransferEncodingFieldBody : NSObject
{
	NSString *encoding;
}

+ (id)defaultContentTransferEncoding;

- (BOOL)mechanismIs:(NSString *)aMechanism;

@end
