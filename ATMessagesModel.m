//
//  ATMessagesModel.m
//  ATMail
//
//  Created by 高田 明史 on 08/11/29.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATMessagesModel.h"
#import "ATMailbox.h"
#import "ATInternetMessage.h"
#import "ATMailSpool.h"

NSString *ATMessagesModelContentsDidChangeNotification = @"ATMessagesModelContentsDidChangeNotification";
NSString *ATMessagesModelCurrentMessageDidChangeNotification = @"ATMessagesModelCurrentMessageDidChangeNotification";
NSString *ATMessagesModelSelectionsDidChangeNotification = @"ATMessagesModelSelectionsDidChangeNotification";
NSString *ATMessagesModelSortDescriptorsDidChangeNotification = @"ATMessagesModelSortDescriptorsDidChangeNotification";

NSString *ATSelectedMessageKey = @"ATSelectedMessageKey";

@implementation ATMessagesModel

+ (id)messagesModelWithMailbox:(ATMailbox *)aMailbox mailSpool:(ATMailSpool *)aMailSpool
{
	return [[[self alloc] initWithMailbox:aMailbox mailSpool:aMailSpool] autorelease];
}

+ (id)messagesModelWithPropertyList:(id)aPlist mailbox:(ATMailbox *)aMailbox mailSpool:(ATMailSpool *)aMailSpool
{
	return [[[self alloc] initWithPropertyList:aPlist mailbox:aMailbox mailSpool:aMailSpool] autorelease];
}

- (id)initWithMailbox:(ATMailbox *)aMailbox mailSpool:(ATMailSpool *)aMailSpool
{
	[super init];
	
	[self setMailbox:aMailbox];
	[self setMailSpool:aMailSpool];
	
	[self setSortDescriptors:[[self class] defaultSortDescriptros]];
	[self setColumns:[[self class] defaultColumns]];
	
	return self;
}

- (id)initWithPropertyList:(id)aPlist mailbox:(ATMailbox *)aMailbox mailSpool:(ATMailSpool *)aMailSpool
{
	[self initWithMailbox:aMailbox mailSpool:aMailSpool];
	
	[self setColumns:[aPlist objectForKey:@"columns"]];
	[self setSortDescriptors:[self sortDescriptorsFromPlist:[aPlist objectForKey:@"sortDescriptors"]]];
	
	return self;
}

- (void)dealloc
{
	[self setCurrentMessage:nil];
	[self setSelections:nil];
	[self setMailbox:nil];
	[self setMailSpool:nil];
	
	[super dealloc];
}

- (ATMailbox *)mailbox
{
	return mailbox;
}

- (void)setMailbox:(ATMailbox *)aMailbox
{
	if (mailbox)
		[[NSNotificationCenter defaultCenter]  removeObserver:self name:nil object:mailbox];

	[mailbox release];
	mailbox = [aMailbox retain];
	
	if (mailbox)
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentMailboxContentsDidChange:) name:ATMailboxContentsDidChangeNotification object:mailbox];
	
	[self setSelections:nil];
}

- (ATMailSpool *)mailSpool
{
	return mailSpool;
}

- (void)setMailSpool:(ATMailSpool *)aMailSpool
{
	[mailSpool release];
	mailSpool = [aMailSpool retain];
}

- (NSArray *)nonArrangedMessages
{
	return [[self mailbox] messages];
}

- (void)currentMailboxContentsDidChange:(NSNotification *)aNotification
{
	[self rearrangeMessages];
	[self updateSelections];
}

@end

@implementation ATMessagesModel (Arranging)

- (NSArray *)arrangedMessages
{
	return arrangedMessages ? arrangedMessages : [self nonArrangedMessages];
}

- (void)setArrangedMessages:(NSArray *)anArrangedMessages
{
	[arrangedMessages release];
	arrangedMessages = [anArrangedMessages retain];
}

- (NSArray *)sortDescriptors
{
	return sortDescriptors;// ? sortDescriptors : [NSArray array];//WithObject:[[[NSSortDescriptor alloc] initWithKey:@"date.body.value" ascending:NO] autorelease]];
}

- (void)setSortDescriptors:(NSArray *)aSortDescriptors
{	
	if (![aSortDescriptors count])
		aSortDescriptors = nil;
		
	if (sortDescriptors != aSortDescriptors && ![sortDescriptors isEqualToArray:aSortDescriptors])
	{
		[sortDescriptors release];
		sortDescriptors = [aSortDescriptors copy];
		[self rearrangeMessages];
	}
}

- (NSPredicate *)predicate
{
	return predicate;
}

- (void)setPredicate:(NSPredicate *)aPredicate
{
	[predicate release];
	predicate = [aPredicate copy];
	[self rearrangeMessages];
}

- (NSString *)predicateString
{
	return [[self predicate] predicateFormat];
}

- (void)setPredicateString:(NSString *)aString
{
	NSPredicate *aPredicate = [aString length] ? [NSPredicate predicateWithFormat:@"subjectString contains[cd] %@", aString] : nil;

	 if ([self predicate] != aPredicate && ![[self predicate] isEqual:aPredicate])
		[self setPredicate:aPredicate];
}

- (void)rearrangeMessages
{
	[self setArrangedMessages:[[self mailbox] rearrangedMessagesWithPredicate:[self predicate] sortDescriptors:[self sortDescriptors]]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ATMessagesModelContentsDidChangeNotification object:self];
}

+ (NSArray *)defaultSortDescriptros
{
	return [NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"date.body.value" ascending:NO] autorelease]];
}

@end

@implementation ATMessagesModel (Selecting)

- (ATInternetMessage *)currentMessage
{
	return currentMessage;
}

- (void)setCurrentMessage:(ATInternetMessage *)aMessage
{
	[currentMessage release];
	currentMessage = [aMessage retain];
		
	[[NSNotificationCenter defaultCenter] postNotificationName:ATMessagesModelCurrentMessageDidChangeNotification object:self userInfo:(currentMessage ? [NSDictionary dictionaryWithObject:currentMessage forKey:ATSelectedMessageKey] : nil)];
}

- (NSArray *)selections
{
	return selections;
}

- (void)setSelections:(NSArray *)aSelections
{
	if ((selections != aSelections) && ![selections isEqualToArray:aSelections])
	{
		NSArray *anOldSelections = [selections autorelease];

		selections = [aSelections copy];
		
		if (!([self currentMessage] && selections && [selections containsObject:[self currentMessage]]))
		{
			if (selections && [selections count])
				[self setCurrentMessage:[selections lastObject]];
			else
				[self setCurrentMessage:nil];
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ATMessagesModelSelectionsDidChangeNotification object:self];
	}
}

- (void)updateSelections
{
	NSEnumerator *anEnumerator = [[self selections] objectEnumerator];
	ATInternetMessage *aMessage = nil;
	NSMutableArray *aNewSelections = [NSMutableArray array];
	
	while (aMessage = [anEnumerator nextObject])
	{
		if ([[self mailbox] indexOf:aMessage] != NSNotFound)
			[aNewSelections addObject:aMessage];
	}
	
	[self setSelections:aNewSelections];
}

- (NSIndexSet *)selectionIndexSet
{
	//return [[self mailbox] indexSetWith:[self selections]];
	return [[self mailbox] indexSetWith:[self selections] in:[self arrangedMessages]];
}

- (void)selectMessagesAtIndexes:(NSIndexSet *)anIndexSet
{
	//[self setSelections:[[self mailbox] atIndexes:anIndexSet]];
	[self setSelections:[[self arrangedMessages] objectsAtIndexes:anIndexSet]];
}

@end

@implementation ATMessagesModel (ColumnSupport)

- (NSMutableArray *)columns
{
	return columns;
}

- (void)setColumns:(NSMutableArray *)aColumns
{
	[columns release];
	columns = [aColumns retain];
}

+ (NSArray *)defaultColumns
{
	//NSMutableArray *aColumns = [NSMutableArray array];
	NSArray *aDefaultColumnsPlist = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultMessagesColumns" ofType:@"plist"]];
	/*NSEnumerator *anEnumerator = [aDefaultColumnsPlist objectEnumerator];
	NSDictionary *aColumnSettings = nil;
	
	while (aColumnSettings = [anEnumerator nextObject])
	{
		NSSortDescriptor *aSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:[aColumnSettings objectForKey:@"sortKey"] ascending:[aColumnSettings objectForKey:@"ascending"]] autorelease];
	}*/
	
	return aDefaultColumnsPlist;
}

@end

@implementation ATMessagesModel (TableDataSouce)

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [[self arrangedMessages] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	return [[[self arrangedMessages] objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];
}

- (BOOL)tableView:(NSTableView *)aTableView writeRowsWithIndexes:(NSIndexSet *)aRowIndexes toPasteboard:(NSPasteboard *)aPboard
{
	[self writeItems:[[self mailbox] atIndexes:aRowIndexes] toPasteBoard:aPboard];
	
	return YES;
}

/*- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id < NSDraggingInfo >)anInfo row:(NSInteger)aRow dropOperation:(NSTableViewDropOperation)anOperation
{
	
}*/

- (void)tableView:(NSTableView *)tableView sortDescriptorsDidChange:(NSArray *)oldDescriptors
{
	[self setSortDescriptors:[tableView sortDescriptors]];
}

@end

@implementation ATMessagesModel (Persistence)

- (id)propertyListRepresentation
{
	return [NSDictionary dictionaryWithObjectsAndKeys:[self columns],@"columns", [self sortDescriptorsPropertyListRepresentation],@"sortDescriptors", nil];
}

- (id)sortDescriptorsPropertyListRepresentation
{
	NSMutableArray *aSortDescriptorsPlist = [NSMutableArray array];
	NSEnumerator *anEnumerator = [[self sortDescriptors] objectEnumerator];
	NSSortDescriptor *aSortDescriptor = nil;
	
	while (aSortDescriptor = [anEnumerator nextObject])
	{
		NSMutableDictionary *aSortDescriptorPlist = [NSMutableDictionary dictionary];
		
		[aSortDescriptorPlist setObject:[NSNumber numberWithBool:[aSortDescriptor ascending]] forKey:@"ascending"];
		[aSortDescriptorPlist setObject:[aSortDescriptor key] forKey:@"key"];
		[aSortDescriptorPlist setObject:NSStringFromSelector([aSortDescriptor selector]) forKey:@"selector"];
		
		[aSortDescriptorsPlist addObject:aSortDescriptorPlist];
	}
	
	return aSortDescriptorsPlist;
}

- (NSArray *)sortDescriptorsFromPlist:(id)aPlist
{
	NSMutableArray *aSortDescriptors = [NSMutableArray array];
	NSEnumerator *anEnumerator = [aPlist objectEnumerator];
	NSDictionary *aSortDescriptorPlist = nil;
	
	while (aSortDescriptorPlist = [anEnumerator nextObject])
	{
		NSSortDescriptor *aSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:[aSortDescriptorPlist objectForKey:@"key"] ascending:[[aSortDescriptorPlist objectForKey:@"ascending"] boolValue] selector:NSSelectorFromString([aSortDescriptorPlist objectForKey:@"selector"])] autorelease];
		
		[aSortDescriptors addObject:aSortDescriptor];
	}
	
	return aSortDescriptors;
}

@end

