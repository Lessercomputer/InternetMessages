/* ATMessageOutlineView */

#import <Cocoa/Cocoa.h>

@interface ATMessageOutlineView : NSOutlineView
{
	BOOL isInUpdating;
}

- (void)updateExpandingStatusOfChildrenOf:(id)anItem;
- (void)updateExpandingStatusOf:(id)anItem;

@end
