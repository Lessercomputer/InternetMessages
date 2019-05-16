#import "ATMessageOutlineView.h"

@implementation ATMessageOutlineView

- (void)reloadData
{
	[super reloadData];
	
	[self prepareUpdating];
	[self updateExpandingStatusOfChildrenOf:nil];
	isInUpdating = NO;
}

- (void)expandItem:(id)item expandChildren:(BOOL)expandChildren
{
	if (isInUpdating)
		[super expandItem:item expandChildren:expandChildren];
	else
		[[self dataSource] expandItem:item expandChildren:expandChildren];
}

- (void)collapseItem:(id)item collapseChildren:(BOOL)collapseChildren
{
	if (isInUpdating)
		[super collapseItem:item collapseChildren:collapseChildren];
	else
		[[self dataSource] collapseItem:item collapseChildren:collapseChildren];
}

- (void)updateExpandingStatusOfChildrenOf:(id)anItem
{
	int aChildrenCount = [[self dataSource] outlineView:self numberOfChildrenOfItem:anItem];
	int aChildIndex = 0;
	
	for ( ; aChildIndex < aChildrenCount; aChildIndex++)
	{
		id aChild = [[self dataSource] outlineView:self child:aChildIndex ofItem:anItem];
		
		[self updateExpandingStatusOf:aChild];
	}
}

- (void)updateExpandingStatusOf:(id)anItem
{
	if ([[self dataSource] outlineView:self isItemExpandable:anItem])
	{
		if ([[self dataSource] outlineView:self itemIsExpanded:anItem] && ![self isItemExpanded:anItem])
			[self expandItem:anItem];
		else if (![[self dataSource] outlineView:self itemIsExpanded:anItem] && [self isItemExpanded:anItem])
			[self collapseItem:anItem];
			
		[self updateExpandingStatusOfChildrenOf:anItem];
	}
}

- (void)prepareUpdating
{
	isInUpdating = YES;
}

@end
