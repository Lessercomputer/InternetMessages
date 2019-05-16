#import "ATFilterEditorWindowController.h"

@implementation ATFilterEditorWindowController

+ (id)filterEditorWindowControllerWith:(ATFilterEditor *)anEditor
{
	return [[[self alloc] initWithFilterEditor:anEditor] autorelease];
}

- (id)initWithFilterEditor:(ATFilterEditor *)anEditor
{
	[super initWithWindowNibName:@"ATFilterEditorWindow"];
	
	filterEditor = [anEditor retain];
	
	return self;
}

- (void)dealloc
{
	[filterEditor release];
	filterEditor = nil;
	
	[super dealloc];
}

@end
