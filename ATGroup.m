//
//  ATGroup.m
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/04/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATGroup.h"


@implementation ATGroup

- (id)initWith:(NSString *)aDisplayName with:(NSArray *)aMailboxList
{
	[super init];
	
	[self setDisplayName:aDisplayName];
	[self setMailboxList:aMailboxList];
	
	return self;
}

- (void) dealloc
{
	[self setDisplayName:nil];
	[self setMailboxList:nil];
	
	[super dealloc];
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:displayName forKey:@"displayName"];
	[coder encodeObject:mailboxList forKey:@"mailboxList"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    [self setDisplayName:[decoder decodeObjectForKey:@"displayName"]];
	[self setMailboxList:[decoder decodeObjectForKey:@"mailboxList"]];
	  
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

- (void)setMailboxList:(NSArray *)aMailboxList
{
	[mailboxList release];
	mailboxList = [aMailboxList copy];
}

- (NSArray *)mailboxList
{
	return mailboxList;
}

- (NSString *)value
{
	return [self stringValue];
}

- (NSString *)stringValue
{
	NSMutableString *aString = [NSMutableString stringWithFormat:@"%@:", [self displayName]];
	
	if ([self mailboxList])
	{
		NSEnumerator *enumerator = [[self mailboxList] objectEnumerator];
		id aMailbox = [enumerator nextObject];
		
		if (aMailbox)
			[aString appendString:[aMailbox stringValue]];
		
		while (aMailbox = [enumerator nextObject])
		{
			[aString appendFormat:@", %@", [aMailbox stringValue]];
		}
	}
	
	[aString appendString:@";"];
	
	return aString;

}


@end
