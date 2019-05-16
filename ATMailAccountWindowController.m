#import "ATMailAccountWindowController.h"


@implementation ATMailAccountWindowController

- (id)init
{
	[super initWithWindowNibName:@"ATMailAccountWindow"];
	
	return self;
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	[controller setContent:[[[self document] mailSpool] mailAccount]];
}

- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName
{
	return [NSString stringWithFormat:@"%@ - Mail Account", displayName];
}

@end
