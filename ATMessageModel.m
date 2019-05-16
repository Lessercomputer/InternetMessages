//
//  ATMessageModel.m
//  ATMail
//
//  Created by 高田　明史 on 06/11/19.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMessageModel.h"
#import "ATInternetMessage.h"
#import "ATHeaderField.h"

NSString *ATMessageModelEntitySelectionDidChangeNotification = @"ATMessageModelEntitySelectionDidChangeNotification";
NSString *ATSelectedEntityKey = @"ATSelectedEntityKey";

@implementation ATMessageModel

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[message release];
	[selectedEntity release];
	
	[super dealloc];
}

- (ATInternetMessage *)message
{
	return message;
}

- (void)setMessage:(ATInternetMessage *)aMessage
{
	[message release];
	message = [aMessage retain];
	
	if (![message body])
	{
		[message readAllContentsFrom:[message mailSpool]];
		[message setToBeRead:NO];
	}

	[self setSelectedEntity:message];
}

- (ATMessageEntity *)selectedEntity
{
	return selectedEntity;
}

- (void)setSelectedEntity:(ATMessageEntity *)anEntity
{
	id anEntityToBeSelected = anEntity ? anEntity : [self message];
	NSDictionary *aUserInfo = anEntityToBeSelected ? [NSDictionary dictionaryWithObject:anEntityToBeSelected forKey:ATSelectedEntityKey] : nil;
	
	[selectedEntity autorelease];
	selectedEntity = [anEntityToBeSelected retain];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ATMessageModelEntitySelectionDidChangeNotification object:self userInfo:aUserInfo];
}

- (NSString *)filename
{
	return [[[self selectedEntity] contentDisposition] filename];
}

- (BOOL)saveBodyOfSelectedEntityTo:(NSString *)aFilePath
{
	return [[self selectedEntity] saveBodyTo:aFilePath];
}

- (NSSet *)headerNamesToBeShow
{
	return [[[self message] mailSpool] headerNamesToBeShow];
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	id aPart = (item ? item : [self message]);
	
	return [aPart isMultipart] ? [[aPart body] count] : 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	id aPart = (item ? item : [self message]);
	
	return [[aPart body] at:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return [item isMultipart];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	return [[item contentType] bodyString];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[self selectedEntity] headerFieldCount];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return [[[self selectedEntity] headerFieldAt:rowIndex] valueForKey:[aTableColumn identifier]];
}

/*- (void)selectedMessageInMailSpoolModelDidChange:(NSNotification *)aNotification
{
	[self setMessage:[[aNotification userInfo] objectForKey:ATSelectedMessageKey]];
}*/

@end
