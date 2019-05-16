//
//  ATFilter.m
//  ATMail
//
//  Created by 高田 明史 on 08/03/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATFilter.h"


@implementation ATFilter

@end

@implementation ATFilter (Initializing)

+ (id)filterWithPropertyListRepresentation:(NSDictionary *)aPlist mailSpool:(ATMailSpool *)aMailSpool
{
	return [[[self alloc] initWithPropertyListRepresentation:aPlist mailSpool:aMailSpool] autorelease];
}

- (id)initWithName:(NSString *)aName predicateString:(NSString *)aPredicateString targetMailbox:(ATMailbox *)aMailbox
{
	[super init];
	
	[self setName:aName];
	[self setPredicateString:aPredicateString];
	[self setTargetMailbox:aMailbox];
	
	return self;
}

- (id)initWithPropertyListRepresentation:(NSDictionary *)aPlist mailSpool:(ATMailSpool *)aMailSpool
{
	[self initWithName:[aPlist objectForKey:@"name"] predicateString:[aPlist objectForKey:@"predicateString"] targetMailbox:[aMailSpool mailboxForIDNumber:[aPlist objectForKey:@"mailboxIDNumber"]]];
	
	return self;
}

- (void)dealloc
{
	[self setName:nil];
	[self setPredicateString:nil];
	[self setTargetMailbox:nil];
	
	[super dealloc];
}

@end

@implementation ATFilter (Accessing)

- (NSString *)name
{
	return name;
}

- (void)setName:(NSString *)aName
{
	[name autorelease];
	name = [aName copy];
}

- (NSString *)predicateString
{
	return predicateString;
}

- (void)setPredicateString:(NSString *)aString
{
	[predicateString autorelease];
	predicateString = [aString copy];
}

- (NSPredicate *)predicate
{
	return [NSPredicate predicateWithFormat:[self predicateString]];
}

- (ATMailbox *)targetMailbox
{
	return targetMailbox;
}

- (void)setTargetMailbox:(ATMailbox *)aMailbox
{
	[targetMailbox autorelease];
	targetMailbox = [aMailbox retain];
}

- (NSArray *)editableKeys
{
	return [NSArray arrayWithObjects:@"name", @"predicateString", @"targetMailbox", nil];
}

@end

@implementation ATFilter (Converting)

- (NSDictionary *)propertyListRepresentation
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[self name],@"name", [self predicateString],@"predicateString", [[self targetMailbox] mailboxIDNumber],@"mailboxIDNumber", nil];
}

@end

@implementation ATFilter (Filtering)

- (NSArray *)filter:(NSArray *)aMessages
{
	NSPredicate *aPredicate = [self predicate];
	NSArray *aFilteredMessages = [aMessages filteredArrayUsingPredicate:aPredicate];
	
	return aFilteredMessages;
}

- (void)filterAndMove:(NSMutableArray *)aMessages
{
	NSArray *aFilteredMessages = [self filter:aMessages];
	
	//[[self targetMailbox] moveItems:aFilteredMessages at:[[self targetMailbox] count]];
	[aMessages removeObjectsInArray:aFilteredMessages];
	[[self targetMailbox] addMessages:aFilteredMessages];
}

@end