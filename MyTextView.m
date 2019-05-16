#import "MyTextView.h"

@implementation MyTextView

- (void)resetCursorRects
{
	NSLog(@"#resetCursorRects");
	[super resetCursorRects];
}

- (void)addCursorRect:(NSRect)aRect cursor:(NSCursor *)anObj
{
	NSLog(@"#addCursorRect:cursor:");
	[super addCursorRect:aRect cursor:anObj];
}

- (NSDictionary *)linkTextAttributes
{
	NSMutableDictionary *aDic = [[[super linkTextAttributes] mutableCopy] autorelease];
	
	[aDic setObject:[NSCursor pointingHandCursor] forKey:NSCursorAttributeName];
	
	return aDic;
}

@end
