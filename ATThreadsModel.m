//
//  ATThreadsModel.m
//  ATMail
//
//  Created by 高田 明史 on 09/01/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ATThreadsModel.h"


@implementation ATThreadsModel

- (NSArray *)nonArrangedMessages
{
	return [[self mailbox] threads];
}

@end

@implementation ATThreadsModel (Arranging)

- (void)rearrangeMessages
{
	[self setArrangedMessages:[[self mailbox] rearrangedThreadsWithPredicate:[self predicate] sortDescriptors:[self sortDescriptors]]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ATMessagesModelContentsDidChangeNotification object:self];
}

@end

@implementation ATThreadsModel (OutlineDataSouce)

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	if (item)
		return [item countOfReturnMessages];
	else
		return [[self arrangedMessages] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
{
	if (item)
		return [[item returnMessages] objectAtIndex:index];
	else
		return [[self arrangedMessages] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return [item hasReturnMessage];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)aTableColumn byItem:(id)item
{
	if ([item isMailbox])
	{
		if ([[aTableColumn identifier] isEqualToString:@"subjectString"])
			return [item name];
		else
			return @"";
	}
	else
		return [item valueForKey:[aTableColumn identifier]];
}

- (BOOL)outlineView:(NSOutlineView *)anOutlineView itemIsExpanded:(id)anItem
{
	return [anItem isOpen];
}

- (void)expandItem:(id)item expandChildren:(BOOL)expandChildren
{
	[item openThreadsRecursive:expandChildren];
}

- (void)collapseItem:(id)item collapseChildren:(BOOL)collapseChildren
{
	[item closeThreadsRecursive:collapseChildren];
}

/*- (BOOL)outlineView:(NSOutlineView *)anOutlineView writeItems:(NSArray *)aMailboxes toPasteboard:(NSPasteboard *)aPboard
{
	NSArray *aToplevelMailboxes = [ATMailbox toplevelMailboxesIn:aMailboxes];
	
	pboardChangeCount = [aPboard declareTypes:[NSArray arrayWithObject:ATMailboxesIDsPboardType] owner:self];
	[aPboard setPropertyList:[[self mailSpool] itemIDsFor:aToplevelMailboxes] forType:ATMailboxesIDsPboardType];
	[self setDraggingItems:aToplevelMailboxes];
	
	return YES;
}*/

- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	[self setSortDescriptors:[outlineView sortDescriptors]];
}

@end
