//
//  ATBase64Processor.m
//  ATBase64
//
//  Created by çÇìc ñæéj on Sun Apr 10 2005.
//  Copyright (c) 2005 __MyCompanyName__. All rights reserved.
//

#import "ATBase64Processor.h"

NSString *ATBase64ProcessWillStartNotification = @"ATBase64ProcessWillStartNotification";
NSString *ATBase64InProcessNotification = @"ATBase64InProcessNotification";
NSString *ATBase64ProcessDidEndNotification = @"ATBase64ProcessDidEndNotification";
NSString *ATBase64ProcessCanceldNotification = @"ATBase64ProcessCanceldNotification";
NSString *ATBase64ProcessFaildNotification = @"ATBase64ProcessFaildNotification";

@implementation ATBase64Processor

+ (id)processor
{
	return [[self new] autorelease];
}

- (id)init
{
	[self initWith:nil];

	return self;
}

- (id)initWith:(NSData *)aData
{
	[super init];
	
	[self setInputData:aData];
	outputData = [[NSMutableData data] retain];
	
	return self;
}

- (NSData *)inputData
{
	return inputData;
}

- (void)setInputData:(NSData *)aData
{
	[inputData release];
	inputData = [aData retain];
}

- (void)dealloc
{
	[self setInputData:nil];
	[outputData release];
	
	[super dealloc];
}

- (void)process
{
	[[NSNotificationCenter defaultCenter] postNotificationName:ATBase64ProcessWillStartNotification object:self];
	[self processWithScheduled:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0.2],@"interval", [NSNumber numberWithDouble:0.8],@"limit", nil]];
}

- (void)processWithScheduled:(NSDictionary *)aSchedule
{
	@try
	{
		[self processWithLimit:[[aSchedule objectForKey:@"limit"] doubleValue]];
		
		if ([self isAtEnd])
			[[NSNotificationCenter defaultCenter] postNotificationName:ATBase64ProcessDidEndNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:location],@"location", [NSNumber numberWithUnsignedInt:[inputData length]],@"length", outputData,@"data", nil]];
		else
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:ATBase64InProcessNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInt:location],@"location", [NSNumber numberWithUnsignedInt:[inputData length]],@"length", nil]];
			[self performSelector:@selector(processWithScheduled:) withObject:aSchedule afterDelay:[[aSchedule objectForKey:@"interval"] doubleValue]];
		}
	}
	@catch (NSException *anException)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:ATBase64ProcessFaildNotification object:self];
	}
}	
			
- (void)processWithLimit:(NSTimeInterval)aLimit
{
	NSDate *aDate = [NSDate dateWithTimeIntervalSinceNow:aLimit];
	
	while (!([self isAtEnd] || [aDate timeIntervalSinceNow] <  0))
	{
		[self processNext];
	}
}

- (void)cancel
{
	[[self class] cancelPreviousPerformRequestsWithTarget:self];
	[[NSNotificationCenter defaultCenter] postNotificationName:ATBase64ProcessCanceldNotification object:self];
}

- (void)processNext
{
}

- (BOOL)isAtEnd
{
	return location >= [inputData length];
}

@end
