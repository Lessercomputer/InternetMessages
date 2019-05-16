//
//  ATInternetMessageLineScanner.m
//  ATMail
//
//  Created by 高田　明史 on 07/09/03.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATInternetMessageLineScanner.h"

/*
	フォルディングを解除した行を一つ返す。
*/


@implementation ATInternetMessageLineScanner

+ (id)scannerWithData:(NSData *)aRawAsciiData
{
	return [[[self alloc] initWithData:aRawAsciiData] autorelease];
}

+ (id)scannerWithFileContentsOfFile:(NSString *)aPath
{
	return [[[self alloc] initWithFileContentsOfFile:aPath] autorelease];
}

- (id)initWithData:(NSData *)aRawAsciiData
{
	[super init];
	
	rawAsciiData = [aRawAsciiData retain];
		
	return self;
}

- (id)initWithFileContentsOfFile:(NSString *)aPath
{
	return [self initWithData:[NSData dataWithContentsOfFile:aPath]];
}

- (void)dealloc
{
	[rawAsciiData release];
	
	[super dealloc];
}

//CRLFを含まない行を一つ返す
- (NSData *)scanNextLine
{
	NSRange aNextLineRange = [self scanNextLineRange];
	
	return aNextLineRange.location != NSNotFound ? [rawAsciiData subdataWithRange:aNextLineRange] : nil;
}

- (NSData *)peekNextLine
{
	unsigned aLocation = location;
	NSRange aNextLineRange = [self scanNextLineRange];
	
	location = aLocation;
	
	return aNextLineRange.location != NSNotFound ? [rawAsciiData subdataWithRange:aNextLineRange] : nil;
}

- (const unsigned char *)peekNextRawLine:(unsigned *)aRawLineLength
{
	unsigned aLocation = location;
	NSRange aNextLineRange = [self scanNextLineRange];
	
	location = aLocation;

	if (aNextLineRange.location != NSNotFound)
	{
		*aRawLineLength = aNextLineRange.length;
		
		return &[rawAsciiData bytes][aNextLineRange.location];
	}
	else
		return NULL;
}

- (BOOL)skipNextLine
{
	NSRange aNextLineRange = [self scanNextLineRange];
	
	return aNextLineRange.location != NSNotFound;
}

- (NSData *)scanUnfoldedLine
{
	NSRange aNextLineRange = [self scanNextLineRange];
	NSMutableData *aNextLineData = nil;
	
	if (aNextLineRange.location != NSNotFound)
	{
		NSMutableData *aNextLineMutableData = [NSMutableData data];
		unsigned char *aRawAsciiBytes = &[rawAsciiData bytes][aNextLineRange.location];
		BOOL aLineUnfolded = NO;
		
		[aNextLineMutableData appendBytes:aRawAsciiBytes length:aNextLineRange.length];
				
		while (!aLineUnfolded && [self skipNextCRLF])
		{
			aNextLineRange = [self scanNextLineRange];
			
			if (aNextLineRange.location != NSNotFound)
			{
				unsigned char *aRawLine = &[rawAsciiData bytes][aNextLineRange.location];
				
				if (isblank(aRawLine[0]))
				{
					[aNextLineMutableData appendBytes:aRawLine length:aNextLineRange.length];
				}
				else
				{
					[self setLocation:[self location] - aNextLineRange.length - 2];//CRLFとaNextLineRangeを読む前の位置に戻す
					aLineUnfolded = YES;
				}
			}
			else
			{
				[self setLocation:[self location] - 2];//CRLFを読む前の位置に戻す
				aLineUnfolded = YES;
			}
		}
		
		aNextLineData = aNextLineMutableData;
	}
	
	return aNextLineData;
}

- (NSRange)scanNextLineRange
{
	BOOL aCRLFFound = NO;
	unsigned aStartOfLine = location;
	NSRange aLineRange = NSMakeRange(0, 0);
	
	for ( ; !aCRLFFound && location < [rawAsciiData length] ; location++)
	{
		char aChar = ((char *)[rawAsciiData bytes])[location];
		
		if (aChar == '\r')
		{
			if ((location + 1 < [rawAsciiData length]) && (((char *)[rawAsciiData bytes])[location + 1] == '\n'))
			{
				--location;//位置をCRに戻す
				aCRLFFound = YES;
			}
			else
				[[NSException exceptionWithName:@"ATInternetMessageLineScannerException" reason:nil userInfo:nil] raise];
		}
		else if (aChar == '\n')
			[[NSException exceptionWithName:@"ATInternetMessageLineScannerException" reason:nil userInfo:nil] raise];
	}
	
	if (aCRLFFound)
		aLineRange = NSMakeRange(aStartOfLine, location - aStartOfLine);//行の範囲はCRLFを含まない
	else if (aStartOfLine != location)
		aLineRange = NSMakeRange(aStartOfLine, location - aStartOfLine);//CRLFが無い行
	else
		aLineRange = NSMakeRange(NSNotFound, 0);
		
	return aLineRange;
}

- (NSData *)scanNextCRLF
{
	NSRange aCRLFRange = [self scanNextCRLFRange];
	
	if (aCRLFRange.location != NSNotFound)
		return [rawAsciiData subdataWithRange:aCRLFRange];
	else
		return nil;
}

- (BOOL)skipNextCRLF
{
	return [self scanNextCRLFRange].location != NSNotFound;
}

- (NSRange)scanNextCRLFRange
{
	NSRange aCRLFRange;
	
	if ((([rawAsciiData length] - location) >= 2)
		&& (((char *)[rawAsciiData bytes])[location] == '\r')
		&& (((char *)[rawAsciiData bytes])[location + 1] == '\n'))
	{
		aCRLFRange = NSMakeRange(location, 2);
		location += 2;
	}
	else
		aCRLFRange = NSMakeRange(NSNotFound, 0);
		
	return aCRLFRange;
}

- (BOOL)skipNextLineAndCRLF
{
	unsigned aLocation = location;
	
	if ([self skipNextLine] && [self skipNextCRLF])
		return YES;
	else
	{
		location = aLocation;
		
		return NO;
	}
}

- (BOOL)skipNextTerminatedLine
{
	if ([self skipNextLine])
	{
		[self skipNextCRLF];
		
		return YES;
	}
	else
		return NO;
}

- (NSData *)subdataWithRange:(NSRange)aRange
{
	return [rawAsciiData subdataWithRange:aRange];
}

- (NSData *)remainingData
{
	return [self subdataWithRange:NSMakeRange(location, [rawAsciiData length] - location)];
}

- (NSArray *)allLines
{
	NSMutableArray *aLines = [NSMutableArray array];
	
	while (location < [rawAsciiData length])
	{
		[aLines addObject:[self scanNextLine]];
		[self scanNextCRLF];
	}
		
	return aLines;
}

- (BOOL)isAtEnd
{
	return location >= [rawAsciiData length];
}

- (unsigned)location
{
	return location;
}

- (void)setLocation:(unsigned)aLocation
{
	location = aLocation;
}

- (void)incrementBy:(unsigned)aCount
{
	location += aCount;
}

- (void)decrementBy:(unsigned)aCount
{
	location -= aCount;
}

@end
