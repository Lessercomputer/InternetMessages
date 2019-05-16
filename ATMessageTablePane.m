#import "ATMessageTablePane.h"
#import "ATMailSpool.h"
#import "ATMailSpoolModel.h"
#import "ATMailbox.h"
#import "ATMessagesModel.h"

@implementation ATMessageTablePane

- (NSString *)paneNibName
{
	return @"ATMessageTablePane";
}

- (void)addObserverForModel:(id)aModel
{
	[super addObserverForModel:aModel];
	
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortDescriptorsDidChange:)  name:ATMessagesModelSortDescriptorsDidChangeNotification object:aModel];
}

- (void)addObserverForView:(NSView *)aView
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionsInViewDidChange:) name:NSTableViewSelectionDidChangeNotification object:aView];
}

- (void)selectionsInViewDidChange:(NSNotification *)aNotification
{
	[[self model] selectMessagesAtIndexes:[[self view] selectedRowIndexes]];
}

- (void)updateSelectionInView
{
	[[self view] selectRowIndexes:[[self model] selectionIndexSet] byExtendingSelection:NO];
}

- (void)messageReadStatusDidChange:(NSNotification *)aNotification
{
	[[self view] reloadData];
}

/*- (void)tableViewColumnDidMove:(NSNotification *)aNotification
{
	[self storeColumns];
}

- (void)tableViewColumnDidResize:(NSNotification *)aNotification
{
	[self storeColumns];
}*/

@end
