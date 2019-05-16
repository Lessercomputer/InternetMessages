//
//  ATMessagesPane.m
//  ATMail
//
//  Created by 高田 明史 on 07/12/23.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATMessagesPane.h"
#import "ATMailSpool.h"
#import "ATMailSpoolModel.h"
#import "ATMessagesModel.h"


@implementation ATMessagesPane

- (void)modelWillChange:(id)aNewModel
{
	[super modelWillChange:aNewModel];
	
	[self storeColumns];
}

- (void)modelDidChange:(id)anOldModel
{
	[super modelDidChange:anOldModel];
	
	if ([[self model] respondsToSelector:@selector(columns)])
		[self setupColumnsFromColumnsPropertyListRepresentation:[[self model] columns]];
	
	if ([[self model] respondsToSelector:@selector(sortDescriptors)])
		[[self view] setSortDescriptors:[[self model] sortDescriptors]];
}

- (void)addObserverForModel:(id)aModel
{
	[super addObserverForModel:aModel];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sortDescriptorsDidChange:)  name:ATMessagesModelSortDescriptorsDidChangeNotification object:aModel];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReadStatusDidChange:) name:ATMessageReadStatusDidChangeNotification object:[aModel mailSpool]];
}

- (void)messageReadStatusDidChange:(NSNotification *)aNotification
{
}

/*- (void)setSortDescriptors:(NSArray *)aSortDescriptors
{
	[[self view] setSortDescriptors:aSortDescriptors];
}*/

- (void)sortDescriptorsDidChange:(NSNotification *)aNotification
{
	[[self view] setSortDescriptors:[[self model] sortDescriptors]];
}

@end

@implementation ATMessagesPane (ColumnSupport)

- (void)setupColumnsFromColumnsPropertyListRepresentation:(NSArray *)aColumns
{
	[self setTableColumns:[self collectViewTableColumnsForColumnsPropertyListRepresentation:aColumns]];
}

- (NSArray *)collectViewTableColumnsForColumnsPropertyListRepresentation:(NSArray *)aColumns
{
	NSEnumerator *anEnumerator = [aColumns objectEnumerator];
	NSDictionary *aColumn = nil;
	NSMutableArray *aTableColumns = [NSMutableArray array];
	
	while (aColumn = [anEnumerator nextObject])
	{
		NSTableColumn *aTableColumn = [[self view] tableColumnWithIdentifier:[aColumn objectForKey:@"identifier"]];
		
		[aTableColumn setWidth:[[aColumn objectForKey:@"width"] floatValue]];
		
		if (aTableColumn)
			[aTableColumns addObject:aTableColumn];
	}

	return aTableColumns;
}

- (void)setTableColumns:(NSArray *)aTableColumns
{
	NSEnumerator *anEnumerator = [aTableColumns objectEnumerator];
	NSTableColumn *aTableColumn = nil;
	NSTableColumn *anOutlineColumn = nil;
	NSTableColumn *aDummyOutlineColumn = nil;
	
	if ([[self view] isKindOfClass:[NSOutlineView class]])
	{
		anOutlineColumn = [[self view] outlineTableColumn];
		aDummyOutlineColumn = [[[NSTableColumn alloc] initWithIdentifier:@"dummyOutlineColumn"] autorelease];
		[[self view] setOutlineTableColumn:aDummyOutlineColumn];
	}
	
	while (aTableColumn = [anEnumerator nextObject])
		[[self view] removeTableColumn:aTableColumn];
	
	anEnumerator = [aTableColumns objectEnumerator];
	
	while (aTableColumn = [anEnumerator nextObject])
		[[self view] addTableColumn:aTableColumn];
	
	if (anOutlineColumn)
		[[self view] setOutlineTableColumn:anOutlineColumn];
	
}

- (NSArray *)columnsPropertyListRepresentation
{
	NSMutableArray *aColumns = [NSMutableArray array];
	NSEnumerator *anEnumerator = [[[self view] tableColumns] objectEnumerator];
	NSTableColumn *aTableColumn = nil;
	
	while (aTableColumn = [anEnumerator nextObject])
	{
		NSMutableDictionary *aColumn = [NSMutableDictionary dictionary];
		
		[aColumn setObject:[aTableColumn identifier] forKey:@"identifier"];
		[aColumn setObject:[NSNumber numberWithFloat:[aTableColumn width]] forKey:@"width"];
		
		[aColumns addObject:aColumn];
	}
	
	return aColumns;
}

- (void)storeColumns
{
	[[self model] setColumns:[self columnsPropertyListRepresentation]];
}

@end

