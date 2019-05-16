//
//  ATAngleAddr.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATAngleAddr.h"
#import "ATAddrSpec.h"


@implementation ATAngleAddr

- (id)initWith:(ATAddrSpec *)anAddrSpec
{
	[super init];
	
	[self setAddrSpec:anAddrSpec];
	
	return self;
}

- (void)dealloc
{
	[self setAddrSpec:nil];

	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:addrSpec forKey:@"addrSpec"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
	[self setAddrSpec:[decoder decodeObjectForKey:@"addrSpec"]];

    return self;
}

- (void)setAddrSpec:(ATAddrSpec *)anAddrSpec
{
	[addrSpec release];
	addrSpec = [anAddrSpec retain];
}

- (ATAddrSpec *)addrSpec
{
	return addrSpec;
}

- (NSString *)value
{
	return [NSString stringWithFormat:@"<%@>", [[self addrSpec] stringValue]];
}

- (NSString *)stringValue
{
	return [self value];
}

@end
