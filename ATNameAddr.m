//
//  ATNameAddr.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATNameAddr.h"
#import "ATAngleAddr.h"


@implementation ATNameAddr

- (id)initWith:(NSString *)aDisplayName with:(ATAngleAddr *)anAngleAddr
{
	[super init];
	
	[self setDisplayName:aDisplayName];
	[self setAngleAddr:anAngleAddr];
	
	return self;
}

- (void)dealloc
{
	[self setDisplayName:nil];
	[self setAngleAddr:nil];

	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:displayName forKey:@"displayName"];
	[coder encodeObject:angleAddr forKey:@"angleAddr"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    [self setDisplayName:[decoder decodeObjectForKey:@"displayName"]];
	[self setAngleAddr:[decoder decodeObjectForKey:@"angleAddr"]];

    return self;
}

- (void)setDisplayName:(NSString *)aDisplayName
{
	[displayName release];
	displayName = [aDisplayName copy];
}

- (NSString *)displayName
{
	return displayName;
}

- (void)setAngleAddr:(ATAngleAddr *)anAngleAddr
{
	[angleAddr release];
	angleAddr = [anAngleAddr retain];
}

- (ATAngleAddr *)angleAddr
{
	return angleAddr;
}

- (NSString *)value
{
	return [NSString stringWithFormat:@"%@%@", [self displayName] ? [self displayName] : @"", [[self angleAddr] stringValue]];
}

- (NSString *)stringValue
{
	return [self value];
}

@end
