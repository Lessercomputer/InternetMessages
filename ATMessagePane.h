//
//  ATMessagePane.h
//  ATMail
//
//  Created by 高田 明史 on 07/12/23.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATMailPane.h"
@class ATMessageModel;
@class ATMessageEntity;

@interface ATMessagePane : ATMailPane
{
	ATMessageModel *messageModel;
}

- (id)initWith:(ATMessageModel *)aModel;

- (ATMessageModel *)messageModel;
- (void)setMessageModel:(ATMessageModel *)aModel;

- (void)addObserverForModel:(ATMessageModel *)aModel;
- (void)addObserverForView:(NSView *)aView;

- (BOOL)isPreferredPaneFor:(ATMessageEntity *)anEntity;

- (void)setEntity:(ATMessageEntity *)anEntity;

@end
