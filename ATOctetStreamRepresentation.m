//
//  ATOctetStreamRepresentation.m
//  ATMail
//
//  Created by 高田　明史 on 07/11/04.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATOctetStreamRepresentation.h"


@implementation ATOctetStreamRepresentation

+ (id)representationWithOctets:(NSData *)anOctets
{
	return [[[self alloc] initWithData:anOctets] autorelease];
}

- (id)initWithData:(NSData *)aData
{
	[super init];
	
	data = [aData retain];
	
	return self;
}

- (void)dealloc
{
	[data release];
	
	[super dealloc];
}

- (NSData *)data
{
	return data;
}

- (NSString *)stringValue
{
	return [[self data] description];
}

- (NSMutableAttributedString *)attributedString
{
	NSFileWrapper *aFileWrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:[self data]] autorelease];
	NSTextAttachment *aTextAttachment = [[[NSTextAttachment alloc] initWithFileWrapper:aFileWrapper] autorelease];
	NSAttributedString *anImageAttributedString = [NSAttributedString attributedStringWithAttachment:aTextAttachment];
	NSImage *anImage = [[[NSImage alloc] initWithData:[self data]] autorelease];
	
	if (anImage)
		[[aTextAttachment attachmentCell] setImage:anImage];
	
	return anImageAttributedString;
}

@end
