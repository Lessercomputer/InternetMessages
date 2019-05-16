//
//  ATPop3Core.m
//  ATMail
//
//  Created by 高田　明史 on 06/09/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATPop3Core.h"
#import "ATMailAccount.h"


@implementation ATPop3Core

- (id)initWith:(ATMailAccount *)anAccount with:(id)aDelegate
{
	[super init];
	
	account = [anAccount retain];
	delegate = aDelegate;
	//[self setLogging:YES];
	cancelLock = [NSLock new];
	runLock = [NSLock new];
	
	return self;
}

- (void)dealloc
{
	[account release];
	delegate = nil;
	[self setLineFragment:nil];
	[self setCommand:nil];
	[uidDic release];
	[cancelLock release];
	cancelLock = nil;
	[runLock release];
	runLock = nil;
	
	[super dealloc];
}

- (BOOL)logging
{
	return logging;
}

- (void)setLogging:(BOOL)aFlag
{
	logging = aFlag;
}

- (void)startWithThread:(id)anObject
{
	NSAutoreleasePool *aPool = [[NSAutoreleasePool alloc] init];
	
	[self authorize];
	
	while ([self isRunning] && ![self isCanceled] && [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
		;
	
	if ([self isCanceled])
		[self closeStreams];
	
	[aPool release];
	NSLog(@"end of #startWithThread:");
}

- (BOOL)isCanceled
{
	BOOL aCancelFlag;
	
	[cancelLock lock];
	aCancelFlag = isCanceled;
	[cancelLock unlock];
	
	return aCancelFlag;
}

- (BOOL)isRunning
{
	BOOL aRunFlag;
	
	[runLock lock];
	aRunFlag = isRunning;
	[runLock unlock];
	
	return aRunFlag;
}

@end

@implementation ATPop3Core (Controlling)

- (void)start
{
	if ([self isRunning])
		return;
	
	isRunning = YES;
	[NSThread detachNewThreadSelector:@selector(startWithThread:) toTarget:self withObject:nil];
}

- (void)cancel
{
	[cancelLock lock];
	isCanceled = YES;
	[cancelLock unlock];
}

- (void)prepareRetrFor:(NSString *)aUID
{
	selectorToInterpret = @selector(interpretRetrStatusIndicator:);
	[self prepareCommand:[@"retr " stringByAppendingString:[uidDic objectForKey:aUID]]];
}

- (void)prepareQuit
{
	selectorToInterpret = @selector(interpretQuit:);
	[self prepareCommand:@"quit"];
}

@end

@implementation ATPop3Core (StreamHandling)

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
	//NSLog(@"#stream:handleEvent: aStream is %@ eventCode is %d", aStream, eventCode);
    if (aStream == inputStream)
        [self handleInputStreamEvent:eventCode];
	else if (aStream == outputStream)
        [self handleOutputStreamEvent:eventCode];
}

- (void)handleInputStreamEvent:(NSStreamEvent)eventCode
{
    switch (eventCode)
	{
        case NSStreamEventHasBytesAvailable:
		{
			NSString *aString = [self readResponse];
			
			if (aString)
				[self receive:aString];
			
            break;
		}
    }
}

- (void)handleOutputStreamEvent:(NSStreamEvent)eventCode
{
	switch (eventCode)
	{
        case NSStreamEventHasSpaceAvailable:
		{
			[self writeCommandIfPossible];
			
            break;
		}
    }
}

- (void)openStreams
{
	[NSStream getStreamsToHost:[NSHost hostWithName:[account hostName]] port:110 inputStream:&inputStream outputStream:&outputStream];
	
	[inputStream retain];
	[outputStream retain];
	[inputStream setDelegate:self];
	[outputStream setDelegate:self];
	[inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[inputStream open];
	[outputStream open];
}

- (void)closeStreams
{
	NSLog(@"#closeStreams");
	[inputStream close];
	[outputStream close];
	[inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[outputStream removeFromRunLoop:[NSRunLoop currentRunLoop]  forMode:NSDefaultRunLoopMode];
	[inputStream setDelegate:nil];
	[outputStream setDelegate:nil];
	[inputStream release];
	[outputStream release];
	inputStream = nil;
	outputStream = nil;
}

- (NSString *)readResponse
{
	NSMutableData *aData = [NSMutableData dataWithLength:1024];
	int aReadCount = [inputStream read:(uint8_t *)[aData mutableBytes] maxLength:[aData length]];
	
	if (aReadCount > 0)
	{		
		[aData setLength:aReadCount];
				
		return [[[NSString alloc] initWithData:aData encoding:NSASCIIStringEncoding] autorelease];
	}
	else
	{
		NSLog(@"no read bytes");
		
		return nil;
	}
}

- (void)receive:(NSString *)aResponse
{
	NSArray *aLines = [self divideLines:aResponse];
	
	[self logResponse:aLines];
	
	if (selectorToInterpret)
		[self performSelector:selectorToInterpret withObject:aLines];
}

- (void)logResponse:(NSArray *)aLines
{
	if ([self logging])
	{
		NSEnumerator *enumerator = [aLines objectEnumerator];
		NSString *aLine = nil;

		while (aLine = [enumerator nextObject])
		{
			CFShow(aLine);
		}
	}
}

@end

@implementation ATPop3Core (CommandSending)

- (void)authorize
{
	selectorToInterpret = @selector(interpretGreeting:);
	
	[self setLineFragment:@""];
	
	[self openStreams];
}

- (void)uidl
{
	[uidDic release];
	uidDic = [NSMutableDictionary new];
	selectorToInterpret = @selector(interpretUIDLStatusIndicator:);
	
	[self send:@"UIDL"];
}

- (void)retrFor:(NSString *)aUID
{
	[self prepareRetrFor:aUID];
	[self writeCommandIfPossible];
}

- (void)quit
{
	[self prepareQuit];
	[self writeCommandIfPossible];
}

- (void)prepareCommand:(NSString *)aCommand
{
	[self setCommand:[aCommand stringByAppendingString:@"\r\n"]];
}

- (void)send:(NSString *)aCommand
{
	[self prepareCommand:aCommand];
	[self writeCommandIfPossible];
}

- (void)writeCommandIfPossible
{
	if ([self command] && [outputStream hasSpaceAvailable])
	{
		NSData *aData = [[self command] dataUsingEncoding:NSASCIIStringEncoding];
		int aWriteCount = [outputStream write:[aData bytes] maxLength:[aData length]];
		
		if (aWriteCount != [aData length])
			NSLog(@"has remaining data");
		
		if ([self logging])
			CFShow([self command]);
			
		[self setCommand:nil];
	}
}

- (void)setCommand:(NSString *)aString
{
	[command release];
	command = [aString copy];
}

- (NSString *)command
{
	return command;
}

- (NSString *)lineFragment
{
	return lineFragment;
}

- (void)setLineFragment:(NSString *)aString
{
	[lineFragment autorelease];
	lineFragment = [aString copy];
}

- (NSString *)decodeByteStuff:(NSString *)aString
{
	if ([aString hasPrefix:@"."])
	{
		if ([aString length] > 1)
			return [aString substringFromIndex:1];
		else
			return nil;
	}
	else
		return aString;
}

- (NSArray *)divideLines:(NSString *)aString
{
	NSMutableArray *aLines = [NSMutableArray array];
	NSScanner *aScanner = [NSScanner scannerWithString:[[self lineFragment] stringByAppendingString:aString]];
	NSCharacterSet *aNewlineSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
	
	[aScanner setCharactersToBeSkipped:nil];
	[self setLineFragment:@""];
	
	while (![aScanner isAtEnd])
	{
		NSString *aLine = @"";
		
		[aScanner scanUpToCharactersFromSet:aNewlineSet intoString:&aLine];
		
		if ([aScanner scanString:@"\r\n" intoString:nil])
			[aLines addObject:aLine];
		else if ([aScanner isAtEnd])
			[self setLineFragment:aLine];
		else if ([aScanner scanString:@"\r" intoString:nil] && [aScanner isAtEnd])
			[self setLineFragment:[aLine stringByAppendingString:@"\r"]];
		else
			NSLog(@"error");
	}
	
	return aLines;
}

@end

@implementation ATPop3Core (Interpreting)

- (void)interpretGreeting:(NSArray *)aLines
{
	if ([[aLines lastObject] hasPrefix:@"+OK"])
	{		
		[self send:[NSString stringWithFormat:@"user %@", [account userName]]];
		
		selectorToInterpret = @selector(interpretUser:);
	}
}

- (void)interpretUser:(NSArray *)aLines
{
	if ([[aLines lastObject] hasPrefix:@"+OK"])
	{
		[self send:[NSString stringWithFormat:@"pass %@", [account password]]];
		
		selectorToInterpret = @selector(interpretPass:);
	}
	else
		[self quit];
}

- (void)interpretPass:(NSArray *)aLines
{
	if ([[aLines lastObject] hasPrefix:@"+OK"])
	{
		selectorToInterpret = NULL;
		
		[self uidl];
	}
	else
		[self quit];
}

- (void)interpretUIDLStatusIndicator:(NSArray *)aLines
{
	selectorToInterpret = @selector(interpretUIDL:);
	
	if ([aLines count] > 1)
	{
		NSMutableArray *aResponse = [[aLines mutableCopy] autorelease];
		[aResponse removeObjectAtIndex:0];
		
		[self interpretUIDL:aResponse];
	}
}

- (void)interpretUIDL:(NSArray *)aLines
{
	NSEnumerator *enumerator = [aLines objectEnumerator];
	NSString *aLine = nil;
	NSString *aDecodedLine = nil;
	
	while (aLine = [enumerator nextObject])
	{
		aDecodedLine = [self decodeByteStuff:aLine];
		
		if (aDecodedLine)
		{
			NSArray *aNumberAndUID = [aDecodedLine componentsSeparatedByString:@" "];
			
			[uidDic setObject:[aNumberAndUID objectAtIndex:0] forKey:[aNumberAndUID objectAtIndex:1]];
		}
	}
	
	if (!aDecodedLine)
	{
		selectorToInterpret = NULL;
		[delegate performSelectorOnMainThread:@selector(coreDidDownloadUIDLOnServer:) withObject:[uidDic allKeys] waitUntilDone:YES];
		[self writeCommandIfPossible];
	}
}

- (void)interpretRetrStatusIndicator:(NSArray *)aLines
{
	NSMutableArray *aResponse = [[aLines mutableCopy] autorelease];
	unsigned aMessageSize = [[[[aResponse objectAtIndex:0] componentsSeparatedByString:@" "] objectAtIndex:1] intValue];
	
	[aResponse removeObjectAtIndex:0];
	
	[delegate performSelectorOnMainThread:@selector(coreWillStartToReceiveMessageOfSize:) withObject:[NSNumber numberWithUnsignedInt:aMessageSize] waitUntilDone:YES];
	
	selectorToInterpret = @selector(interpretRetr:);
	[self interpretRetr:aResponse];
}

- (void)interpretRetr:(NSArray *)aLines
{
	NSEnumerator *enumerator = [aLines objectEnumerator];
	
	NSMutableArray *aDecodedLines =  [NSMutableArray array];
	BOOL responseFinished = NO;
	NSString *aString = nil;
	
	while (aString = [enumerator nextObject])
	{
		aString = [self decodeByteStuff:aString];
		
		if (aString)
			[aDecodedLines addObject:aString];
		else 
		{
			selectorToInterpret = NULL;
			responseFinished = YES;
		}
	}
	
	if ([aDecodedLines count])
		[delegate performSelectorOnMainThread:@selector(coreReceiveRetr:) withObject:aDecodedLines waitUntilDone:YES];
	
	if (responseFinished)
	{
		[delegate performSelectorOnMainThread:@selector(coreRetrFinished) withObject:nil waitUntilDone:YES];
		[self writeCommandIfPossible];
	}
}

- (void)interpretQuit:(NSArray *)aLines
{	
	selectorToInterpret = NULL;
	[self closeStreams];
	[runLock lock];
	isRunning = NO;
	[runLock unlock];
}

@end
