//
//  ATMailPane.m
//  ATMail
//
//  Created by 高田 明史 on 07/12/23.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATMailPane.h"


@implementation ATMailPane

- (void)awakeFromNib
{
	NSView *aSuperView = [contentView superview];
	
	[contentView retain];
	[contentView removeFromSuperview];
	[aSuperView release];
}

- (void)dealloc
{
	[contentView release];
	contentView = nil;
		
	[super dealloc];
}

- (NSString *)paneNibName
{
	return nil;
}

- (BOOL)loadContentView
{
	return [NSBundle loadNibNamed:[self paneNibName] owner:self];
}

- (NSView *)contentView
{
	if (!contentView)
		[self loadContentView];
	
	return contentView;
}

- (NSView *)view
{
	return view;
}

- (void)setupResponderChain
{
	[self setNextResponder:[[self contentView] nextResponder]];
	[[self contentView] setNextResponder:self];
}

- (void)restoreResponderChain
{
	[[self contentView] setNextResponder:[self nextResponder]];
	[self setNextResponder:nil];
}

- (id)propertyListRepresentation
{
	NSMutableDictionary *aPlist = [NSMutableDictionary dictionary];
	
	[aPlist setObject:NSStringFromRect([[self contentView] frame]) forKey:@"viewFrame"];
	
	return aPlist;
}

- (void)setPropertyListRepresentation:(id)aPlist
{
	[[self contentView] setFrame:NSRectFromString([aPlist objectForKey:@"viewFrame"])];
}

@end
