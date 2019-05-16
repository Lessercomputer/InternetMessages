#import "ATMessageTextPane.h"

@implementation ATMessageTextPane

- (BOOL)isPreferredPaneFor:(ATMessageEntity *)anEntity
{
	return [anEntity contentTypeIsText];
}

- (NSString *)paneNibName
{
	return @"ATMessageTextPane";
}

- (void)setEntity:(ATMessageEntity *)anEntity
{
	NSTextStorage *aTextStorage = [[self view] textStorage];
		
	[aTextStorage beginEditing];
	
	if (anEntity)
	{
		[aTextStorage setAttributedString:[anEntity attributedStringWithRestrictionOfHeader:[[self messageModel] headerNamesToBeShow]]];
	}
	else
	{
		[[aTextStorage mutableString] setString:@"No Selection"];
	}
	
	[aTextStorage endEditing];

	[[self view] scrollRangeToVisible:NSMakeRange(0,0)];
}

@end
