//
//  ATAddrSpec.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATAddrSpec : NSObject
{
	NSString *localPart;
	NSString *domain;
}

- (id)initWith:(NSString *)aLocalPart with:(NSString *)aDomain;

- (void)setLocalPart:(NSString *)aLocalPart;
- (NSString *)localPart;

- (void)setDomain:(NSString *)aDomain;
- (NSString *)domain;

- (NSString *)value;
- (NSString *)stringValue;

@end
