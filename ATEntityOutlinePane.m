#import "ATEntityOutlinePane.h"
#import "ATMessageModel.h"

@implementation ATEntityOutlinePane

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[[self view] setDataSource:[self messageModel]];
	[[self view] setDelegate:self];
	
	[self addObserverForView:[self view]];
}

- (NSString *)paneNibName
{
	return @"ATEntityOutlinePane";
}

- (void)addObserverForModel:(ATMessageModel *)aModel
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(entitySelectionInModelDidChange:) name:ATMessageModelEntitySelectionDidChangeNotification object:aModel];
}

- (void)addObserverForView:(NSView *)aView
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(entitySelectionInViewDidChange:) name:NSOutlineViewSelectionDidChangeNotification object:aView];	
}

- (void)entitySelectionInModelDidChange:(NSNotification *)aNotification
{
	[[self view] reloadData];
	
	if ([[[self messageModel] selectedEntity] isTopLevelMessage])
		[[self view] deselectAll:nil];
}

- (void)entitySelectionInViewDidChange:(NSNotification *)aNotification
{
	[[self messageModel] setSelectedEntity:[[self view] itemAtRow:[[self view] selectedRow]]];
}

@end
