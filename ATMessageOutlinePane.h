/* ATMessageOutlinePane */

#import "ATMessagesPane.h"

@interface ATMessageOutlinePane : ATMessagesPane
{
}

- (NSIndexSet *)indexSetWith:(NSArray *)aMessages;
- (NSArray *)messagesWith:(NSIndexSet *)anIndexSet;

@end
