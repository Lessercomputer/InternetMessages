//
//  ATMailboxesOutlineDataSource.m
//  ATMail
//
//  Created by 高田 明史 on 08/02/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATMailboxesOutlineDataSource.h"
#import "ATMailSpool.h"
#import "ATMailbox.h"
#import "ATMailSpoolModel.h"

@implementation ATMailboxesOutlineDataSource

- (void)dealloc
{
	[self setMailSpoolModel:nil];
	
	[super dealloc];
}

- (ATMailSpool *)mailSpool
{
	return [[self mailSpoolModel] mailSpool];
}

- (ATMailSpoolModel *)mailSpoolModel
{
	return mailSpoolModel;
}

- (void)setMailSpoolModel:(ATMailSpoolModel *)aMailSpoolModel
{
	[mailSpoolModel release];
	mailSpoolModel = [aMailSpoolModel retain];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)anIndex ofItem:(id)anItem
{
	return anItem ? [anItem mailboxAt:anIndex] : [[[self mailSpool] root] mailboxAt:anIndex];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)anItem
{
	return ![anItem isWeak];
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)anItem
{	
	if (![self mailSpoolModel])
		return 0;
	
	return anItem ? [anItem countOfMailboxes] : [[[self mailSpool] root] countOfMailboxes];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)aTableColumn byItem:(id)item
{
	return [item name];
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
	[item setName:object];
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView writeItems:(NSArray *)anItems toPasteboard:(NSPasteboard *)aPboard
{
	[[self mailSpoolModel] writeItems:anItems toPasteBoard:aPboard];
		
	return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)anOutlineView validateDrop:(id < NSDraggingInfo >)anInfo proposedItem:(id)anItem proposedChildIndex:(int)anIndex
{
	//NSLog(@"item: %@ childIndex: %d", anItem, anIndex);
	return [[self mailSpoolModel] validateDrop:anInfo proposedItem:anItem proposedChildIndex:anIndex];
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView acceptDrop:(id < NSDraggingInfo >)anInfo item:(id)anItem childIndex:(int)anIndex
{
	return [[self mailSpoolModel] acceptDrop:anInfo item:anItem childIndex:anIndex];
}

@end
