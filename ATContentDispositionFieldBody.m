//
//  ATContentDispositionFieldBody.m
//  ATMail
//
//  Created by 高田　明史 on 07/11/10.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATContentDispositionFieldBody.h"
#import "ATMIMETokenScanner.h"


@implementation ATContentDispositionFieldBody

- (id)initWith:(NSString *)aString
{
	ATMIMETokenScanner *aScanner = [ATMIMETokenScanner scannerWith:aString];
	BOOL anInitializationSucceed = NO;
	
	[super init];
	
	dispositionType = [[self scanDispositionTypeFrom:aScanner] retain];
	
	if (dispositionType)
	{
		parameters = [[self scanDispositionParametersFrom:aScanner] retain];
		
		[aScanner skipCFWS];
		
		if ([aScanner isAtEnd])
			anInitializationSucceed = YES;
	}
	
	if (!anInitializationSucceed)
	{
		[self release];
		self = nil;
	}
	
	return self;
}

- (void)dealloc
{
	[dispositionType release];
	[parameters release];
	
	[super dealloc];
}

- (NSString *)dispositionType
{
	return dispositionType;
}

- (NSMutableDictionary *)parameters
{
	return parameters;
}

- (NSString *)filename
{
	return [[self parameters] objectForKey:@"filename"];
}

- (NSString *)stringValue
{
	return [NSString stringWithFormat:@"%@; %@", [self dispositionType], [self parameters]];
}

- (NSString *)scanDispositionTypeFrom:(ATMIMETokenScanner *)aScanner
{
	NSString *aDispositionType = nil;
	
	[aScanner skipCFWS];
	
	[aScanner scanString:@"inline" intoString:&aDispositionType] || [aScanner scanString:@"attachment" intoString:&aDispositionType] 
		|| [aScanner scanExtensionTokenInto:&aDispositionType];
	
	return aDispositionType;	
}

- (NSMutableDictionary *)scanDispositionParametersFrom:(ATMIMETokenScanner *)aScanner
{
	NSMutableDictionary *aContentDispositionParameterDictionary = [NSMutableDictionary dictionary];
	NSString *aName = nil, *aValue = nil;
	
	while ([self scanDispositionParmNameInto:&aName valueInto:&aValue from:aScanner])
	{
		[aContentDispositionParameterDictionary setObject:aValue forKey:[aName lowercaseString]];
	}
	
	return aContentDispositionParameterDictionary;
}

- (BOOL)scanDispositionParmNameInto:(NSString **)aName valueInto:(NSString **)aValue from:(ATMIMETokenScanner *)aScanner
{	
	NSString *aReturningName = nil, *aReturningValue = nil;
	BOOL aParameterFound = NO;
	
	[aScanner skipCFWS];
	
	if ([aScanner scanString:@";" intoString:nil])
	{
		[aScanner skipCFWS];
		
		aParameterFound = [self scanFilenameParmNameInto:&aReturningName valueInto:&aReturningValue from:aScanner] || [aScanner scanParameterInto:&aReturningName into:&aReturningValue];
	}
	
	if (aParameterFound)
	{
		*aName = aReturningName;
		*aValue = aReturningValue;
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanFilenameParmNameInto:(NSString **)aName valueInto:(NSString **)aValue from:(ATMIMETokenScanner *)aScanner
{
	NSString *aReturningName = nil, *aReturningValue = nil;
	
	if ([aScanner scanString:@"filename" intoString:&aReturningName])
	{
		[aScanner skipCFWS];
		
		if ([aScanner scanString:@"=" intoString:nil])
		{
			[aScanner skipCFWS];
			
			if ([aScanner scanValueInto:&aReturningValue])
			{
				*aName = aReturningName;
				*aValue = aReturningValue;
				
				return YES;
			}
		}
	}
	
	return NO;
}

@end
