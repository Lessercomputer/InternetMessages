//
//  ATAddrSpec.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATAddrSpec.h"


@implementation ATAddrSpec

- (id)initWith:(NSString *)aLocalPart with:(NSString *)aDomain
{
	[super init];
	
	[self setLocalPart:aLocalPart];
	[self setDomain:aDomain];
	
	return self;
}

- (void)dealloc
{
	[self setLocalPart:nil];
	[self setDomain:nil];

	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:localPart forKey:@"localPart"];
	[coder encodeObject:domain forKey:@"domain"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
	[self setLocalPart:[decoder decodeObjectForKey:@"localPart"]];
	[self setDomain:[decoder decodeObjectForKey:@"domain"]];

    return self;
}

- (void)setLocalPart:(NSString *)aLocalPart
{
	[localPart release];
	localPart = [aLocalPart copy];
}

- (NSString *)localPart
{
	return localPart;
}

- (void)setDomain:(NSString *)aDomain
{
	[domain release];
	domain = [aDomain copy];
}

- (NSString *)domain
{
	return domain;
}

- (NSString *)value
{
	return [NSString stringWithFormat:@"%@@%@", [self localPart], [self domain]];
}

- (NSString *)stringValue
{
	return [self value];
}

@end
