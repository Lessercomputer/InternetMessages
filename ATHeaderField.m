//
//  ATHeaderField.m
//  ATMail
//
//  Created by 高田　明史 on 06/02/22.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATHeaderField.h"
#import "ATFieldBody.h"
#import "ATContentTypeFieldBody.h"
#import "ATContentTransferEncodingFieldBody.h"
#import "ATTokenScanner.h"

static int callCountOfIsValid = 0;

@implementation ATHeaderField

+ (void)logCallCountOfIsValid
{
	NSLog(@"callCountOfIsValid: %d", callCountOfIsValid);
}

+ (id)defaultContentType
{
	ATHeaderField *aDefaultContentType = [[[self alloc] initWithName:@"Content-Type" fieldBody:[ATContentTypeFieldBody defaultContentType]] autorelease];
	[aDefaultContentType interpret];
	
	return aDefaultContentType;
}

+ (id)defaultContentTransferEncoding
{
	ATHeaderField *aDefaultContentTransferEncoding = [[[self alloc] initWithName:@"Content-Transfer-Encoding" fieldBody:[ATContentTransferEncodingFieldBody defaultContentTransferEncoding]] autorelease];
	[aDefaultContentTransferEncoding interpret];
	
	return aDefaultContentTransferEncoding;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    if([super respondsToSelector:aSelector])
        return  [super methodSignatureForSelector:aSelector];
	else
		return  [[self body] methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([[self body] respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:[self body]];
    else
        [super forwardInvocation:anInvocation];
}

@end

@implementation ATHeaderField (Initializing)

+ (id)headerFieldWithLineData:(NSData *)aLineData
{
	return [[[self alloc] initWithLineData:aLineData interpret:YES] autorelease];
}

- (id)initWithLineData:(NSData *)aLineData interpret:(BOOL)anInterpretFlag
{
	return [self initWithLine:[[[NSString alloc] initWithData:aLineData encoding:NSASCIIStringEncoding] autorelease] interpret:anInterpretFlag];
}

- (id)initWithLine:(NSString *)aLine interpret:(BOOL)anInterpretFlag
{
	if (anInterpretFlag)
	{
		NSString *aName = nil, *aBody = @"";
		BOOL anInitializationSucceed = NO;

		if ([self scanHeaderField:aLine intoFieldName:&aName intoBody:&aBody])
		{
			[self initWithName:aName fieldBody:aBody];
		
			if ([self interpret])
				anInitializationSucceed = YES;
		}
		
		if (!anInitializationSucceed)
		{
			[self release];
			self = nil;
		}
	}
	else
		[self initWithName:nil fieldBody:aLine];
		
	return self;
}

- (id)initWithName:(NSString *)aFieldName fieldBody:(id)aFieldBody
{
	[super init];
	
	[self setName:aFieldName];
	[self setBody:aFieldBody];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:body forKey:@"body"];
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    [self setName:[decoder decodeObjectForKey:@"name"]];
    [self setBody:[decoder decodeObjectForKey:@"body"]];

    return self;
}

- (void)dealloc
{
	[self setName:nil];
	[self setBody:nil];
	
	[super dealloc];
}

@end

@implementation ATHeaderField (Accessing)

- (NSString *)name
{
	[self interpretName];
	
	return name;
}

- (void)setName:(NSString *)aString
{
	[name release];
	name = [aString copy];
}

- (id)body
{
	[self interpretBody];
		
	return body;
}

- (void)setBody:(id)aBody
{
	[body release];
	body = [aBody retain];
}

- (NSString *)bodyString
{
	return [[self body] stringValue];
}

- (id)value
{
	return [[self body] value];
}

- (void)addLine:(NSString *)aLine
{
	if (![self isInterpreted])
	{
		[self interpretName];
		[body appendString:aLine];
	}
}

- (NSMutableAttributedString *)attributedString
{
	NSMutableAttributedString *anAttributedString = [[NSMutableAttributedString new] autorelease];
	
	[anAttributedString appendAttributedString:[[[NSAttributedString alloc] initWithString:[[self name] stringByAppendingString:@":"]] autorelease]];
	[anAttributedString setAttributes:[NSDictionary dictionaryWithObject:[NSColor colorWithCalibratedRed:(double)73/(double)255 green:(double)129/(double)255 blue:(double)122/(double)255 alpha:1] forKey:NSForegroundColorAttributeName] range:NSMakeRange(0, [anAttributedString length])];
	
	[anAttributedString appendAttributedString:[self bodyAttributedString]];
	[anAttributedString appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\r\n"] autorelease]];
	
	return anAttributedString;
}

- (NSAttributedString *)bodyAttributedString
{
	id aBody = [self body];
	
	if (aBody)
		return [aBody isKindOfClass:[ATFieldBody class]] ? [aBody attributedString] : [[[NSAttributedString alloc] initWithString:[body stringValue] attributes:[NSDictionary dictionaryWithObject:[NSColor darkGrayColor] forKey:NSForegroundColorAttributeName]] autorelease];
	else
		return [[NSAttributedString new] autorelease];
}

- (NSData *)rawData
{
	NSData *aNameData = [[self name] dataUsingEncoding:NSASCIIStringEncoding];
	NSData *aBodyData = [body dataUsingEncoding:NSASCIIStringEncoding];
	NSMutableData *aHeaderData = [[aNameData mutableCopy] autorelease];
	
	[aHeaderData appendBytes:":" length:1];
	
	if (aBodyData)
		[aHeaderData appendData:aBodyData];
	else
		NSLog(@"bodyData absent");
	
	[aHeaderData appendBytes:"\r\n" length:2];
	
	return aHeaderData;
}

@end

@implementation ATHeaderField (Interpretting)

+ (NSArray *)groupFolded:(NSArray *)aLines
{
	NSMutableArray *aGroupedFields = [NSMutableArray array];
	NSEnumerator *enumerator = [aLines objectEnumerator];
	NSString *aLine = nil;
	
	while (aLine = [enumerator nextObject])
	{
		if ([self isFolding:aLine])
			[[aGroupedFields lastObject] addObject:aLine];
		else
			[aGroupedFields addObject:[NSMutableArray arrayWithObject:aLine]];
	}
	
	return aGroupedFields;
}

- (BOOL)scanHeaderField:(NSString *)aFirstLine intoFieldName:(NSString **)aFieldName intoBody:(NSString **)aBody
{
	ATTokenScanner *aScanner = [ATTokenScanner scannerWith:aFirstLine];	
	
	if ([aScanner scanCharactersFromSet:[ATTokenScanner ftextSet] intoString:aFieldName])
	{
		[aScanner scanCharactersFromSet:[ATTokenScanner wspSet] intoString:nil];
		
		if ([aScanner scanString:@":" intoString:nil])
		{
			if (![aScanner isAtEnd])
				*aBody = [[aScanner string] substringFromIndex:[aScanner scanLocation]];
				
			return YES;
		}
	}

	return NO;
}

- (BOOL)interpretName
{	
	if (![self nameIsInterpreted])
	{
		BOOL anInterpretationSucceed = YES;
		NSString *aName = nil, *aBody = @"";
		
		if ([self scanHeaderField:body intoFieldName:&aName intoBody:&aBody])
		{
			[self setName:aName];
			[self setBody:[[aBody mutableCopy] autorelease]];
		}
		else
		{
			anInterpretationSucceed = NO;
			[self setName:@""];
		}
		
		return anInterpretationSucceed;
	}
	else
		return ![name isEqualToString:@""];

}

- (BOOL)interpretBody
{
	if (![self isInterpreted])
	{
		BOOL anInterpretationSucceed = YES;
		Class aFieldBodyClass = [ATFieldBody fieldBodyForName:[self name]];
				
		id aFieldBody = [[[aFieldBodyClass alloc] initWith:body] autorelease];
		
		if (!aFieldBody)
		{
			anInterpretationSucceed = NO;
			aFieldBody = [[[ATFieldBody alloc] initWith:body] autorelease];
		}
		
		[self setBody:aFieldBody];
		
		return anInterpretationSucceed;
	}
	else
		return [self isValid];	
}

- (BOOL)interpret
{
	return [self interpretName] && [self interpretBody];
}

@end

@implementation ATHeaderField (Testing)

- (BOOL)nameIs:(NSString *)aName
{
	NSString *aFieldName = [self name];
	
	return aFieldName ? [aFieldName caseInsensitiveCompare:aName] == NSOrderedSame : NO;
}

- (BOOL)nameIsIncludedIn:(NSSet *)aHeaderNames
{
	NSEnumerator *aNameEnumerator = [aHeaderNames objectEnumerator];
	NSString *aName = nil;
	BOOL aNameFound = NO;
	
	while (!aNameFound && (aName = [aNameEnumerator nextObject]))
	{
		if ([self nameIs:aName])
			aNameFound = YES;
	}
	
	return aNameFound;
}

+ (BOOL)isFolding:(NSString *)aLine
{
	NSRange aRange = [aLine rangeOfCharacterFromSet:[ATTokenScanner wspSet]];
	
	return aRange.location == 0;
}

- (BOOL)isFolding:(NSString *)aLine
{
	return [[self class] isFolding:aLine];
}

- (BOOL)isInterpreted
{
	return name && ![body isKindOfClass:[NSString class]];
}

- (BOOL)nameIsInterpreted
{
	return name ? YES : NO;
}

- (BOOL)isValid
{
	if (![self isInterpreted])
		[self interpret];
	
	//return ![name isEqualToString:@""] && ![body isKindOfClass:[ATFieldBody class]];
	callCountOfIsValid++;
	return [name length] && ![body isKindOfClass:[ATFieldBody class]];
}

@end