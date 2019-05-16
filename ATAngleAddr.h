//
//  ATAngleAddr.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATAddrSpec;

@interface ATAngleAddr : NSObject
{
	ATAddrSpec *addrSpec;
}

- (id)initWith:(ATAddrSpec *)anAddrSpec;

- (void)setAddrSpec:(ATAddrSpec *)anAddrSpec;
- (ATAddrSpec *)addrSpec;

- (NSString *)value;
- (NSString *)stringValue;

@end
