#import "ATEntityHeaderPane.h"
#import "ATMessageModel.h"

@implementation ATEntityHeaderPane

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[[[[self view] tableColumnWithIdentifier:@"bodyAttributedString"] dataCell] setScrollable:YES];
	[[self view] setDataSource:[self messageModel]];
	[[self view] setDelegate:self];
}

- (NSString *)paneNibName
{
	return @"ATEntityHeaderPane";
}

- (void)addObserverForModel:(ATMessageModel *)aModel
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(entitySelectionDidChange:) name:ATMessageModelEntitySelectionDidChangeNotification object:aModel];
}

- (void)entitySelectionDidChange:(NSNotification *)aNotification
{
	[[self view] reloadData];
}

@end
