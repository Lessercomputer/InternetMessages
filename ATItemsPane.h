//
//  ATItemsPane.h
//  ATMail
//
//  Created by 高田 明史 on 08/12/31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATMailPane.h"


@interface ATItemsPane : ATMailPane
{
	id model;
	IBOutlet NSObjectController *modelController;
}

+ (id)paneWith:(id)aModel;
- (id)initWith:(id)aModel;

- (id)model;
- (void)setModel:(id)aModel;

- (void)modelWillChange:(id)aNewModel;
- (void)modelDidChange:(id)anOldModel;

- (id)dataSource;

- (void)addObserverForModel:(id)aModel;
- (void)addObserverForView:(NSView *)aView;

- (void)selectionInModelDidChange:(NSNotification *)aNotification;
- (void)updateSelectionInView;

- (void)currentMailboxInModelDidChange:(NSNotification *)aNotification;

@end
