//
//  ATMIMETokenScanner.m
//  ATMail
//
//  Created by 高田　明史 on 06/09/21.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATMIMETokenScanner.h"
#import "ATBase64Decoder.h"
#import "ATHeaderField.h"
#import "ATContentTypeFieldBody.h"

static NSCharacterSet *tspecials;
static NSCharacterSet *tokenCharacterSet;
static NSCharacterSet *bcharsnospaceSet;
static NSCharacterSet *especials;
static NSArray *ianaToken;

@implementation ATMIMETokenScanner

+ (void)initialize
{
	NSMutableCharacterSet *aUsAscii = [NSMutableCharacterSet characterSetWithRange:NSMakeRange(0, 127 - 0 + 1)];
	[aUsAscii removeCharactersInRange:NSMakeRange(0, 31)];
	[aUsAscii removeCharactersInString:@"	 ()<>@,;:\\\"/[]?="];
	tokenCharacterSet = [aUsAscii copy];
	tspecials = [[NSCharacterSet characterSetWithCharactersInString:@"()<>@,;:\\\"/[]?="] copy];
	bcharsnospaceSet = [NSMutableCharacterSet letterCharacterSet];//letterCharacterSetはアルファベットのAからZ、aからzまでの文字集合を返す。
	[bcharsnospaceSet addCharactersInString:@"0123456789"];
	[bcharsnospaceSet addCharactersInString:@"'()+_,-./:=?"];
	bcharsnospaceSet = [bcharsnospaceSet copy];
	especials = [[NSCharacterSet characterSetWithCharactersInString:@"()<>@,;:\\\"/[]?.="] copy];
}

+ (NSArray *)ianaToken
{
	if (!ianaToken)
	{
		NSMutableArray *anArray = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"iana-token" ofType:@"plist"]];
		NSArray *anAdditionalSubtype = [NSArray arrayWithObjects:@"Plain", @"Octet-Stream", @"PostScript", @"Mixed", @"Alternative", @"Digest", @"Parallel", @"RFC822", @"Partial", @"External-Body", @"html", @"rfc822", @"enriched", @"basic", @"related", nil];

		[anArray addObjectsFromArray:anAdditionalSubtype];
		
		ianaToken = [anArray copy];
	}
	
	return ianaToken;
}

@end

@implementation ATMIMETokenScanner (ScaningTokens)

- (BOOL)scanParametersInto:(NSDictionary **)aParameters
{
	unsigned aLocation = [scanner scanLocation];
	BOOL anErrorOccurred = NO, aFinished = NO;
	*aParameters = [NSMutableDictionary dictionary];
	
	do
	{
		[self skipCFWS];
		
		if ([scanner scanString:@";" intoString:nil])
		{
			NSString *anAttribute, *aValue;
		
			[self skipCFWS];
			
			if ([self scanParameterInto:&anAttribute into:&aValue])
				[*aParameters setObject:aValue forKey:anAttribute];
			else
				anErrorOccurred = YES;
		}
		else
			aFinished = YES;
	} while (!anErrorOccurred && !aFinished);
	
	if (aFinished)
	{
		return YES;
	}
	else
	{
		[scanner setScanLocation:aLocation];
		return NO;
	}
}

- (BOOL)scanParameterInto:(NSString **)anAttribute into:(NSString **)aValue
{
	unsigned aLocation = [scanner scanLocation];
		
	if ([self scanAttributeInto:anAttribute])
	{
		[self skipCFWS];
		[scanner scanString:@"=" intoString:nil];
		[self skipCFWS];
		
		if ([self scanValueInto:aValue])
			return YES;
	}
	
	[scanner setScanLocation:aLocation];
		
	return NO;
}

- (BOOL)scanAttributeInto:(NSString **)anAttribute
{
	return [self scanTokenInto:anAttribute];
}

- (BOOL)scanValueInto:(NSString **)aValue
{
	return [self scanQuotedStringInto:aValue] || [self scanTokenInto:aValue];
}

- (BOOL)scanTokenInto:(NSString **)aToken
{
	return [scanner scanCharactersFromSet:tokenCharacterSet intoString:aToken];
}

- (BOOL)scanTypeInto:(NSString **)aType
{	
	return [self scanDiscreteTypeInto:aType] || [self scanCompositeTypeInto:aType];
}

- (BOOL)scanSubtypeInto:(NSString **)aType
{
	return [self scanExtensionTokenInto:aType] || [self scanIANATokenInto:aType];
}

- (BOOL)scanIetfTokenInto:(NSString **)anIetfToken
{
	return [self scanIANATokenInto:anIetfToken];
}

- (BOOL)scanIANATokenInto:(NSString **)aType
{	
	return [self scanStringListedIn:[[self class] ianaToken] into:aType];
}

- (BOOL)scanStringListedIn:(NSArray *)aStringList into:(NSString **)aString
{
	NSEnumerator *enumerator = [aStringList objectEnumerator];
	NSString *aStringInList = nil, *aReturningString = nil;
					  	
	while ((aStringInList = [enumerator nextObject]) && ![scanner scanString:aStringInList intoString:&aReturningString])
	{
	}

	if (aStringInList)
	{
		*aString = aReturningString;
		
		return YES;
	}
	else
		return NO;
}

- (BOOL)scanDiscreteTypeInto:(NSString **)aType
{
	NSArray *aDiscreateTypes = [NSArray arrayWithObjects:@"text", @"image", @"audio", @"video", @"application", nil];
	
	return [self scanStringListedIn:aDiscreateTypes into:aType];
}

- (BOOL)scanCompositeTypeInto:(NSString **)aType
{
	if ([scanner scanString:@"message" intoString:aType] || [scanner scanString:@"multipart" intoString:aType])
		return YES;
	else
		return [self scanExtensionTokenInto:aType];
}

- (BOOL)scanExtensionTokenInto:(NSString **)aType
{
	return [self scanIetfTokenInto:aType] || [self scanXTokenInto:aType];
}

- (BOOL)scanXTokenInto:(NSString **)aType
{
	unsigned aLocation = [scanner scanLocation];
	NSString *aPrefix, *aString;
		
	if ([scanner scanString:@"X-" intoString:&aPrefix] && [self scanTextInto:&aString])
	{
		*aType = [aPrefix stringByAppendingString:aString];
		
		return YES;
	}

	[scanner setScanLocation:aLocation];
		
	return NO;
}

@end

@implementation ATMIMETokenScanner (ScaningFields)

- (BOOL)scanMIMEVersionFieldValueInto:(NSString **)aVersion1 into:(NSString **)aVersion2
{
	unsigned aLocation = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:aVersion1])
	{
		[self skipCFWS];
		
		if ([scanner scanString:@"." intoString:nil])
		{
			[self skipCFWS];
			
			if ([scanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:aVersion2])
			{
				[self skipCFWS];
				
				return YES;
			}
		}
	}

	[scanner setScanLocation:aLocation];
		
	return NO;
}



- (BOOL)scanContentTypeFieldValueInto:(NSString **)aType into:(NSString **)aSubtype into:(NSDictionary **)aParameters
{
	unsigned aLocation = [scanner scanLocation];
	id aReturningType, aReturningSubtype, aReturningParameters;
		
	[self skipCFWS];
	
	if ([self scanTypeInto:&aReturningType])
	{
		[self skipCFWS];
		
		if ([scanner scanString:@"/" intoString:nil])
		{
			[self skipCFWS];
			
			if ([self scanSubtypeInto:&aReturningSubtype])
			{
				[self skipCFWS];
				
				if ([self scanParametersInto:&aReturningParameters])
				{
					[self skipCFWS];
					
					if (aType)
						*aType = aReturningType;
					
					if (aSubtype)
						*aSubtype = aReturningSubtype;
					
					if (aParameters)
						*aParameters = aReturningParameters;
						
					return YES;
				}
			}
		}
	}
	
	[scanner setScanLocation:aLocation];
				
	return NO;
}

- (BOOL)scanContentTransferEncodingFieldValueInto:(NSString *)aMechanism
{
	NSArray *aMechanisms = [NSArray arrayWithObjects:@"7bit", @"8bit", @"binary", @"quoted-printable", @"base64", nil];
	unsigned aLocation = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([self scanStringListedIn:aMechanisms into:aMechanism] || [self scanIetfTokenInto:aMechanism] || [self scanXTokenInto:aMechanism])
	{
		[self skipCFWS];
				
		return YES;
	}

	[scanner setScanLocation:aLocation];
	
	return NO;
}

- (BOOL)scanContentIDFieldValueInto:(ATMsgID **)aContentID
{
	unsigned aLocation = [scanner scanLocation];
	
	[self skipCFWS];
	
	if ([self scanMsgIDInto:aContentID])
	{
		[self skipCFWS];
		
		return YES;
	}

	[scanner setScanLocation:aLocation];
	
	return NO;
}

- (BOOL)scanContentDescriptionFieldValueInto:(NSString **)aContentDescription
{
	return [self scanTextInto:aContentDescription];
}

@end