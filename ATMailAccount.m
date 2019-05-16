//
//  ATMailAccount.m
//  ATMail
//
//  Created by 高田　明史 on 06/08/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMailAccount.h"
#import "ATPop3MessageDownloader.h"

@implementation ATMailAccount

- (id)init
{
	return [self initWithHostName:nil userName:nil password:nil messageUIDLToBeSkipped:nil];
}

- (id)initWithHostName:(NSString *)aHostName userName:(NSString *)aUserName password:(NSString *)aPassword messageUIDLToBeSkipped:(NSArray *)aMessageUIDLToBeSkipped
{
	[super init];
		
	[self setHostName:aHostName];
	[self setUserName:aUserName];
	[self setPassword:aPassword];
	
	[self setMessageUIDLToBeSkipped:(aMessageUIDLToBeSkipped ? aMessageUIDLToBeSkipped : [NSArray array])];

	return self;
}

- (id)initWithPropertyListReprensentation:(NSDictionary *)aPlistRep
{
	return [self initWithHostName:[aPlistRep objectForKey:@"hostName"] userName:[aPlistRep objectForKey:@"userName"] password:[aPlistRep objectForKey:@"password"] messageUIDLToBeSkipped:[aPlistRep objectForKey:@"messageUIDLToBeSkipped"]];
}

- (id)initWithSerializedPropertyListReprensentation:(NSData *)aSerializedPlistRep
{
	return [self initWithPropertyListReprensentation:[NSPropertyListSerialization propertyListFromData:aSerializedPlistRep mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:nil]];
}

- (void)dealloc
{
	[self setHostName:nil];
	[self setUserName:nil];
	[self setPassword:nil];
	
	[self setMessageUIDLToBeSkipped:nil];
	
	[super dealloc];
}

- (void)setHostName:(NSString *)aName
{
	[hostName release];
	hostName = [aName copy];
}

- (NSString *)hostName
{
	return hostName;
}

- (void)setUserName:(NSString *)aName
{
	[userName release];
	userName = [aName copy];
}

- (NSString *)userName
{
	return userName;
}

- (void)setPassword:(NSString *)aPassword
{
	[password release];
	password = [aPassword copy];
}

- (NSString *)password
{
	return password;
}

- (NSArray *)messageUIDLToBeSkipped
{
	return messageUIDLToBeSkipped;
}

- (void)setMessageUIDLToBeSkipped:(NSArray *)aUIDL
{
	[messageUIDLToBeSkipped autorelease];
	messageUIDLToBeSkipped = [aUIDL copy];
}

- (BOOL)updateMessageUIDLToBeSkipped:(ATPop3MessageDownloader *)aDownloader
{
	NSArray *aDownloadedMessageUIDL = [[self messageUIDLToBeSkipped] arrayByAddingObjectsFromArray:[aDownloader newMessageUIDL]];
	NSMutableArray *aMessageUIDLToBeSkipped = [NSMutableArray array];
	NSEnumerator *enumerator = [[aDownloader UIDLOnServer] objectEnumerator];
	NSString *aMessageUIDOnServer = nil;
	BOOL aDownloadedMessageUIDLIsChanged = NO;
	
	while (aMessageUIDOnServer = [enumerator nextObject])
	{
		if ([aDownloadedMessageUIDL containsObject:aMessageUIDOnServer])
			[aMessageUIDLToBeSkipped addObject:aMessageUIDOnServer];
	}

	if (![[self messageUIDLToBeSkipped] isEqualToArray:aMessageUIDLToBeSkipped])
	{
		aDownloadedMessageUIDLIsChanged = YES;
		[self setMessageUIDLToBeSkipped:aMessageUIDLToBeSkipped];
	}
	
	return aDownloadedMessageUIDLIsChanged;
}

- (NSDictionary *)propertyListRepresentation
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[self hostName],@"hostName", [self userName],@"userName", [self password],@"password", [self messageUIDLToBeSkipped],@"messageUIDLToBeSkipped", nil];
}

- (NSData *)serializedPropertyListRepresentation
{	
	return [NSPropertyListSerialization dataFromPropertyList:[self propertyListRepresentation] format:NSPropertyListXMLFormat_v1_0 errorDescription:nil];
}

@end
