//
//  ATMailboxesOutlinePane.m
//  ATMail
//
//  Created by 高田 明史 on 08/02/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATMailboxesOutlinePane.h"
#import "ATMailSpool.h"
#import "ATMailSpoolModel.h"
#import "ATMailboxesOutlineDataSource.h"
#import "ATMailbox.h"

@implementation ATMailboxesOutlinePane

/*- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[[self dataSource] setMailSpoolModel:[self model]];
	[[self view] reloadData];
	[self updateSelectionInView];
	[[self view] registerForDraggedTypes:[[self model] pboardTypes]];
}*/

- (void)dealloc
{
	[[self view] registerForDraggedTypes:nil];
	[dataSource release];
	dataSource = nil;
	
	[super dealloc];
}

- (NSString *)paneNibName
{
	return @"ATMailboxesOutlinePane";
}

- (id)dataSource
{
	return dataSource;
}

- (void)modelDidChange:(id)anOldModel
{
	[super modelDidChange:anOldModel];
	
	[[self dataSource] setMailSpoolModel:[self model]];
	[[self view] reloadData];
	[self updateSelectionInView];
	[[self view] registerForDraggedTypes:[[self model] pboardTypes]];
}

- (void)addObserverForModel:(ATMailSpoolModel *)aModel
{
	//[super addObserverForModel:aModel];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentMailboxInModelDidChange:) name:ATCurrentMailboxDidChangeNotification object:aModel];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailboxesDidChange:) name:ATMailboxesDidChangeNotification object:[aModel mailSpool]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedMailboxesDidChange:) name:ATMailSpoolModelSelectedMailboxesDidChangeNotification object:aModel];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailboxesDidMove:) name:ATMailboxesDidMoveNotification object:aModel];
}

- (void)addObserverForView:(NSView *)aView
{
	//[super addObserverForView:aView];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionsInViewDidChange:) name:NSOutlineViewSelectionDidChangeNotification object:aView];
}

- (void)selectionsInViewDidChange:(NSNotification *)aNotification
{
	//[[self mailSpoolModel] setCurrentMailbox:[[self view] itemAtRow:[[self view] selectedRow]]];
	NSIndexSet *aSelectionIndexSet = [[self view] selectedRowIndexes];
	NSMutableArray *aMailboxesSelection = [NSMutableArray array];
	unsigned i =  [aSelectionIndexSet firstIndex];
	
	for ( ; i != NSNotFound; i = [aSelectionIndexSet indexGreaterThanIndex:i])
	{
		[aMailboxesSelection addObject:[[self view] itemAtRow:i]];
	}
	
	[[self model] setSelectedMailboxes:aMailboxesSelection];
}

- (void)currentMailboxInModelDidChange:(NSNotification *)aNotification
{
	[self updateSelectionInView];
}

- (void)updateSelectionInView
{
	//[[self view] selectRow:[[self view] rowForItem:[[self mailSpoolModel] currentMailbox]] byExtendingSelection:NO];
	NSMutableIndexSet *aSelectionIndexSet = [NSMutableIndexSet indexSet];
	NSArray *aSelectedMailboxes = [[self model] selectedMailboxes];
	NSEnumerator *anEnumerator = [aSelectedMailboxes objectEnumerator];
	ATMailbox *aSelectedMailbox = nil;
	
	while (aSelectedMailbox = [anEnumerator nextObject])
	{
		[aSelectionIndexSet addIndex:[[self view] rowForItem:aSelectedMailbox]];
	}
	
	[[self view] selectRowIndexes:aSelectionIndexSet byExtendingSelection:NO];
}

- (void)mailboxesDidChange:(NSNotification *)aNotification
{
	[[self view] reloadData];
}

- (void)selectedMailboxesDidChange:(NSNotification *)aNotification
{
	[self updateSelectionInView];
}

- (void)mailboxesDidMove:(NSNotification *)aNotification
{
	[self updateSelectionInView];
}

- (IBAction)makeNewMailbox:(id)sender
{
	[[self mailSpoolModel] makeNewMailbox];
}

@end
