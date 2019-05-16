//
//  ATMsgID.m
//  ATMail
//
//  Created by 高田　明史 on 06/04/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMsgID.h"


@implementation ATMsgID

- (id)initWith:(NSString *)anIDLeft with:(NSString *)anIDRight
{
	[super init];
	
	[self setIDLeft:anIDLeft];
	[self setIDRight:anIDRight];
	
	return self;
}

- (void)dealloc
{
	[self setIDLeft:nil];
	[self setIDRight:nil];
	
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[[self class] allocWithZone:zone] initWith:[self idLeft] with:[self idRight]];
}

- (void)setIDLeft:(NSString *)anIDLeft
{
	[idLeft release];
	idLeft = [anIDLeft retain];
}

- (NSString *)idLeft
{
	return idLeft;
}

- (void)setIDRight:(NSString *)anIDRight
{
	[idRight release];
	idRight = [anIDRight retain];
}
	
- (NSString *)idRight
{
	return idRight;
}

- (NSString *)stringValue
{
	return [NSString stringWithFormat:@"%@@%@", [self idLeft], [self idRight]];
}

- (NSString *)description
{
	return [self stringValue];
}

- (unsigned int)hash
{
	return [[self idLeft] hash] + [[self idRight] hash];
}

- (BOOL)isEqual:(id)anObject
{
	return self == anObject || [self isEqualToMessageID:anObject];
}

- (BOOL)isEqualToMessageID:(ATMsgID *)aMessageID
{
	return (self == aMessageID) || ([[self idLeft] isEqualToString:[aMessageID idLeft]] && [[self idRight] isEqualToString:[aMessageID idRight]]);
}

@end
