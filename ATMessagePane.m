//
//  ATMessagePane.m
//  ATMail
//
//  Created by 高田 明史 on 07/12/23.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATMessagePane.h"


@implementation ATMessagePane

- (id)initWith:(ATMessageModel *)aModel
{
	[super init];
	
	[self setMessageModel:aModel];
	
	return self;
}

- (void)dealloc
{
	[self setMessageModel:nil];
	
	[super dealloc];
}

- (ATMessageModel *)messageModel
{
	return messageModel;
}

- (void)setMessageModel:(ATMessageModel *)aModel
{
	if (messageModel != aModel)
	{
		if (messageModel)
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			
		[messageModel release];
		messageModel = [aModel retain];
		
		if (messageModel)
			[self addObserverForModel:messageModel];
	}
}

- (void)addObserverForModel:(ATMessageModel *)aModel
{
}

- (void)addObserverForView:(NSView *)aView
{
}

- (BOOL)isPreferredPaneFor:(ATMessageEntity *)anEntity
{
	return NO;
}

- (void)setEntity:(ATMessageEntity *)anEntity
{
	
}

@end
