//
//  ATItemsPane.m
//  ATMail
//
//  Created by 高田 明史 on 08/12/31.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATItemsPane.h"
#import "ATMailSpoolModel.h"
#import "ATMessagesModel.h"

@implementation ATItemsPane

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	//[[self view] setDataSource:[self dataSource]];
	[[self view] setDelegate:self];
	//[modelController setContent:[self model]];
	//[[self view] reloadData];
	
	//[self updateSelectionInView];

	[self addObserverForView:[self view]];
}

+ (id)paneWith:(id)aModel
{
	return [[[self alloc] initWith:aModel] autorelease];
}

- (id)initWith:(id)aModel
{
	[super init];
	
	[self setModel:aModel];
	
	return self;
}

- (void)dealloc
{
	[[self view] setDataSource:nil];
	[[self view] setDelegate:nil];
	
	[self setModel:nil];
	
	[super dealloc];
}


- (id)model
{
	return model;
}

- (void)setModel:(id)aModel
{
	if (model != aModel)
	{
		[self contentView];
		
		if (model)
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:model];

			[self modelWillChange:aModel];
			
			[[self view] setDataSource:nil];
		}
			
		[model release];
		model = [aModel retain];
	
		if (model)
		{
			[self addObserverForModel:model];

			//[[self view] setDataSource:[self dataSource]];
			
			[self modelDidChange:nil];
			
			[[self view] setDataSource:[self dataSource]];
		}
	}
}

- (void)modelWillChange:(id)aNewModel
{
}

- (void)modelDidChange:(id)anOldModel
{
}

- (id)dataSource
{
	return [self model];
}

- (void)addObserverForModel:(id)aModel
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectionInModelDidChange:) name:ATMessagesModelSelectionsDidChangeNotification object:aModel];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentMailboxInModelDidChange:) name:ATMessagesModelContentsDidChangeNotification object:aModel];
}

- (void)addObserverForView:(NSView *)aView
{
}

- (void)selectionInModelDidChange:(NSNotification *)aNotification
{
	[self updateSelectionInView];
}

- (void)updateSelectionInView
{
}

- (void)currentMailboxInModelDidChange:(NSNotification *)aNotification
{
	[[self view] reloadData];
	[self updateSelectionInView];
}

@end
