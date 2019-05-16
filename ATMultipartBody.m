//
//  ATMultipartBody.m
//  ATMail
//
//  Created by 高田　明史 on 06/10/03.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMultipartBody.h"
#import "ATMIMETokenScanner.h"
#import "ATMessageEntity.h"

@implementation ATMultipartBody

+ (id)multipartBodyFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary
{
	return [[[self alloc] initFromLineScanner:aLineScanner boundary:aBoundary parentBoundary:nil] autorelease];
}

+ (id)multipartBodyFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary parentBoundary:(NSString *)aParentBoundary
{
	return [[[self alloc] initFromLineScanner:aLineScanner boundary:aBoundary parentBoundary:aParentBoundary] autorelease];
}

- (id)initFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner boundary:(NSString *)aBoundary parentBoundary:(NSString *)aParentBoundary
{
	ATMultipartTokenScanner *aMultipartScanner = [ATMultipartTokenScanner scannerWithLineScanner:aLineScanner boundary:aBoundary parentBoundary:aParentBoundary];
	ATMessageEntity *aBodyPart = nil;
	NSData *aPreamble = nil;
	NSString *aPreambleString = nil;
	BOOL aMultipartBodyInitializingSucceed = NO;

	[super init];

	boundary = [aBoundary copy];
	parentBoundary = [aParentBoundary copy];
	bodyParts = [NSMutableArray new];
	
	aPreamble = [aMultipartScanner scanPreamble];
	if (aPreamble)
		aPreambleString = [[[NSString alloc] initWithData:aPreamble encoding:NSASCIIStringEncoding] autorelease];
	[aMultipartScanner skipNextCRLF];
	
	if ([aMultipartScanner skipNoCloseDashBoundary] && [aMultipartScanner skipTransportPadding] && [aMultipartScanner skipNextCRLF])
	{
		aBodyPart = [ATMessageEntity bodyPartFromLineScanner:[aMultipartScanner lineScanner] parentBoundary:[aMultipartScanner boundary]];
		
		if (aBodyPart)
			[bodyParts addObject:aBodyPart];
		
		while (aBodyPart = [self scanEncapsulationFrom:aMultipartScanner])
			[bodyParts addObject:aBodyPart];
		
		if ([aMultipartScanner skipCloseDelimiter] && [aMultipartScanner skipTransportPadding])
		{
			NSData *anEpilogue = nil;
			NSString *anEpilogueString = nil;
			
			[aMultipartScanner skipNextCRLF];
			
			anEpilogue = [aMultipartScanner scanEpilogue];
			if (anEpilogue)
				anEpilogueString = [[[NSString alloc] initWithData:anEpilogue encoding:NSASCIIStringEncoding] autorelease];
			
			aMultipartBodyInitializingSucceed = YES;
		}
	}
	
	if (!aMultipartBodyInitializingSucceed)
	{
		[self release];
		self = nil;
	}
	
	return self;
}

- (ATMessageEntity *)scanEncapsulationFrom:(ATMultipartTokenScanner *)aMultipartScanner
{
	ATMessageEntity *aBodyPart = nil;
	
	//delimiterとclose-delimiterの区別が必要
	if ([aMultipartScanner skipNoCloseDelimiter] && [aMultipartScanner skipTransportPadding] && [aMultipartScanner skipNextCRLF])
		aBodyPart = [ATMessageEntity bodyPartFromLineScanner:[aMultipartScanner lineScanner] parentBoundary:[aMultipartScanner boundary]];
	
	return aBodyPart;
}

- (void)dealloc
{
	[parentBoundary release];
	[boundary release];
	[bodyParts release];
	
	[super dealloc];
}

- (NSString *)stringValue
{
	return [bodyParts description];
}

- (NSString *)description
{
	return [self stringValue];
}

- (NSMutableAttributedString *)attributedString
{
	NSMutableAttributedString *anAttributedString = [[[NSMutableAttributedString alloc] initWithString:@""] autorelease];
	NSEnumerator *anEnumerator = [[self bodyParts] objectEnumerator];
	ATMessageEntity *anEntity = nil;
	
	while (anEntity = [anEnumerator nextObject])
	{
		if ([anAttributedString length])
			[anAttributedString appendAttributedString:[[[NSMutableAttributedString alloc] initWithString:@"\r\n"] autorelease]];
			
		[anAttributedString appendAttributedString:[anEntity attributedString]];
	}
	
	return anAttributedString;	
}

- (NSMutableAttributedString *)attributedStringOfSummary
{
	NSMutableAttributedString *anAttributedString = [[NSMutableAttributedString new] autorelease];
	NSEnumerator *anEnumerator = [[self bodyParts] objectEnumerator];
	ATMessageEntity *anEntity = nil;
	
	while (anEntity = [anEnumerator nextObject])
	{
		if ([anEntity isMultipart])
			[anAttributedString appendAttributedString:[anEntity attributedStringOfSummary]];
		else
			[anAttributedString appendAttributedString:[anEntity attributedString]];
	}
		
	return anAttributedString;
}

- (NSMutableArray *)bodyParts
{
	return bodyParts;
}

- (id)at:(unsigned)anIndex
{
	return [[self bodyParts] objectAtIndex:anIndex];
}

- (unsigned)count
{
	return [[self bodyParts] count];
}

- (BOOL)isMultipart
{
	return YES;
}

@end
