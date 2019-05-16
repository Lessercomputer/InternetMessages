//
//  ATFilterEditor.m
//  ATMail
//
//  Created by 高田 明史 on 08/03/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATFilterEditor.h"

NSString *ATFilterEditorDidChangeNotification = @"ATFilterEditorDidChangeNotification";

@implementation ATFilterEditor

@end

@implementation ATFilterEditor (Initializing)

+ (id)filterEditor
{
	return [[[self alloc] init] autorelease];
}

+ (id)filterEditorWithContentsOfFile:(NSString *)aPath mailSpool:(ATMailSpool *)aMailSpool
{
	return [[[self alloc] initWithContentsOfFile:aPath mailSpool:aMailSpool] autorelease];
}

- (id)init
{
	return [self initWithFilters:[NSMutableArray array]];
}

- (id)initWithFilters:(NSMutableArray *)aFilters
{
	[super init];
	
	[self setFilters:aFilters];
	
	return self;
}

- (id)initWithContentsOfFile:(NSString *)aPath mailSpool:(ATMailSpool *)aMailSpool
{
	NSArray *aPlistOfFilters = [NSArray arrayWithContentsOfFile:aPath];
	NSEnumerator *anEnumerator = [aPlistOfFilters objectEnumerator];
	NSDictionary *aFilterPlist = nil;
	NSMutableArray *aFilters = [NSMutableArray array];
	
	while (aFilterPlist = [anEnumerator nextObject])
		[aFilters addObject:[ATFilter filterWithPropertyListRepresentation:aFilterPlist mailSpool:aMailSpool]];
	
	return [self initWithFilters:aFilters];
}

- (void)dealloc
{
	[self setFilters:nil];
	
	[super dealloc];
}

@end

@implementation ATFilterEditor (Accessing)

- (NSMutableArray *)filters
{
	return filters;
}

- (void)setFilters:(NSMutableArray *)aFilters
{
	[self removeObservingOf:filters];
	
	[filters autorelease];
	filters = [aFilters retain];
	
	[self addObservingOf:filters];
}

- (void)insertObject:(ATFilter *)aFilter inFiltersAtIndex:(unsigned)anIndex
{
	[[self filters] insertObject:aFilter atIndex:anIndex];
	[self addObservingOfFilter:aFilter];
	[[NSNotificationCenter defaultCenter] postNotificationName:ATFilterEditorDidChangeNotification object:self];
}

- (void)removeObjectFromFiltersAtIndex:(unsigned)anIndex
{
	[self removeObservingOfFilter:[[self filters] objectAtIndex:anIndex]];
	[[self filters] removeObjectAtIndex:anIndex];
	[[NSNotificationCenter defaultCenter] postNotificationName:ATFilterEditorDidChangeNotification object:self];
}

@end

@implementation ATFilterEditor (Saving)

- (BOOL)writeToFile:(NSString *)aPath
{
	NSMutableArray *aPlistOfFilters = [NSMutableArray array];
	NSEnumerator *anEnumerator = [[self filters] objectEnumerator];
	ATFilter *aFilter = nil;
	
	while (aFilter = [anEnumerator nextObject])
		[aPlistOfFilters addObject:[aFilter propertyListRepresentation]];
	
	return [aPlistOfFilters writeToFile:aPath atomically:YES];
}

@end

@implementation ATFilterEditor (Filtering)

- (NSArray *)filterAndMove:(NSArray *)aMessages
{
	NSArray *aFilters = [self filters];
	NSEnumerator *anEnumerator = [aFilters objectEnumerator];
	ATFilter *aFilter = nil;
	NSMutableArray *aMessagesToFilter = [[aMessages mutableCopy] autorelease];
	
	while (aFilter = [anEnumerator nextObject])
	{
		[aFilter filterAndMove:aMessagesToFilter];
	}
	
	return aMessagesToFilter;
}

@end

@implementation ATFilterEditor (Observing)

- (void)addObservingOf:(NSArray *)aFilters
{
	NSEnumerator *anEnumerator = [aFilters objectEnumerator];
	ATFilter *aFilter = nil;
	
	while (aFilter = [anEnumerator nextObject])
		[self addObservingOfFilter:aFilter];
}

- (void)removeObservingOf:(NSArray *)aFilters
{
	NSEnumerator *anEnumerator = [aFilters objectEnumerator];
	ATFilter *aFilter = nil;
	
	while (aFilter = [anEnumerator nextObject])
		[self removeObservingOfFilter:aFilter];
}

- (void)addObservingOfFilter:(ATFilter *)aFilter
{
	NSArray *anEditableKeys = [aFilter editableKeys];
	NSEnumerator *anEnumerator = [anEditableKeys objectEnumerator];
	NSString *aKey = nil;
	
	while (aKey = [anEnumerator nextObject])
		[aFilter addObserver:self forKeyPath:aKey options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)removeObservingOfFilter:(ATFilter *)aFilter
{
	NSArray *anEditableKeys = [aFilter editableKeys];
	NSEnumerator *anEnumerator = [anEditableKeys objectEnumerator];
	NSString *aKey = nil;
	
	while (aKey = [anEnumerator nextObject])
		[aFilter removeObserver:self forKeyPath:aKey];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	[[NSNotificationCenter defaultCenter] postNotificationName:ATFilterEditorDidChangeNotification object:self];
}

@end