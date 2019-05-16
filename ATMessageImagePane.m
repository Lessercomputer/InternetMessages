#import "ATMessageImagePane.h"

@implementation ATMessageImagePane

- (BOOL)isPreferredPaneFor:(ATMessageEntity *)anEntity
{
	return [anEntity contentTypeIsImage];
}

- (NSString *)paneNibName
{
	return @"ATMessageImagePane";
}

- (void)setEntity:(ATMessageEntity *)anEntity
{
	[[self view] setImage:[[[NSImage alloc] initWithData:[[anEntity body] data]] autorelease]];
	[[self view] setFrameSize:[[[self view] image] size]];
}

@end
