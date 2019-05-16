#import "ATMessageOutlinePane.h"
#import "ATInternetMessage.h"
#import "ATMailSpool.h"
#import "ATMailSpoolModel.h"

@implementation ATMessageOutlinePane

- (void)awakeFromNib
{	
	[super awakeFromNib];
	
	[[self view] setOutlineTableColumn:[[self view] tableColumnWithIdentifier:@"subjectString"]];
	[[self view] setAutoresizesOutlineColumn:NO];
}

- (NSString *)paneNibName
{
	return @"ATMessageOutlinePane";
}

- (void)addObserverForView:(NSView *)aView
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionsInViewDidChange:) name:NSOutlineViewSelectionDidChangeNotification object:aView];
}

- (void)selectionsInViewDidChange:(NSNotification *)aNotification
{
	[[self model] setSelections:[self messagesWith:[[self view] selectedRowIndexes]]];
}

- (void)updateSelectionInView
{
	[[self view] selectRowIndexes:[self indexSetWith:[[self model] selections]] byExtendingSelection:NO];
}

- (NSIndexSet *)indexSetWith:(NSArray *)aMessages
{
	NSEnumerator *anEnumeratorOfMessages = [aMessages objectEnumerator];
	ATInternetMessage *aMessage = nil;
	NSMutableIndexSet *anIndexSet = [NSMutableIndexSet indexSet];
	
	while (aMessage = [anEnumeratorOfMessages nextObject])
	{
		[anIndexSet addIndex:[[self view] rowForItem:aMessage]];
	}
	
	return anIndexSet;
}

- (NSArray *)messagesWith:(NSIndexSet *)anIndexSet
{
	NSMutableArray *aMessages = [NSMutableArray array];
	int i;
	
	for (i = [anIndexSet firstIndex] ; i != NSNotFound; i = [anIndexSet indexGreaterThanIndex:i])
	{
		ATInternetMessage *aMessage = [[self view] itemAtRow:i];
		
		if (aMessage)
			[aMessages addObject:aMessage];
	}
	
	return aMessages;
}

- (void)messageReadStatusDidChange:(NSNotification *)aNotification
{
	[[self view] reloadItem:[[aNotification userInfo] objectForKey:ATMessageKey]];
}

@end
