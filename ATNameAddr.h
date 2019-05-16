//
//  ATNameAddr.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATAngleAddr;

@interface ATNameAddr : NSObject
{
	NSString *displayName;
	ATAngleAddr *angleAddr;
}

- (id)initWith:(NSString *)aDisplayName with:(ATAngleAddr *)anAngleAddr;

- (void)setDisplayName:(NSString *)aDisplayName;
- (NSString *)displayName;

- (void)setAngleAddr:(ATAngleAddr *)anAngleAddr;
- (ATAngleAddr *)angleAddr;

- (NSString *)value;
- (NSString *)stringValue;
 
@end
