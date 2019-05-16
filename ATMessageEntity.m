//
//  ATMessageEntity.m
//  ATMail
//
//  Created by 高田　明史 on 07/04/08.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATMessageEntity.h"
#import "ATHeaderField.h"
#import "ATInternetMessageLineScanner.h"
#import "ATMultipartBody.h"
#import "ATMultipartTokenScanner.h"
#import "ATBodyTextRepresentation.h"
#import "ATQuotedPrintableDecoder.h"
#import "ATBase64Decoder.h"
#import "ATOctetStreamRepresentation.h"
#import "ATMIMETokenScanner.h"

@implementation ATMessageEntity

- (id)init
{
	[super init];
	
	[self setMessageHeader:[NSMutableArray array]];

	return self;
}

+ (id)bodyPartFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner parentBoundary:(NSString *)aParentBoundary
{
	return [[[self alloc] initFromLineScanner:aLineScanner parentBoundary:aParentBoundary] autorelease];
}

- (id)initFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner parentBoundary:(NSString *)aParentBoundary
{
	[self init];
	
	parentBoundary = [aParentBoundary copy];
	
	[self readHeaderFromLineScanner:aLineScanner];
	
	if ([aLineScanner skipNextLineAndCRLF])
		[self readBodyFromLineScanner:aLineScanner];
		
	return self;
}

- (void)dealloc
{
	[self setMessageHeader:nil];
	[self setBody:nil];
	[parentBoundary release];

	[super dealloc];
}

@end

@implementation ATMessageEntity (Accessing)

- (void)setMessageHeader:(NSMutableArray *)aFields
{
	[fields release];
	fields = [aFields retain];
}

- (NSMutableArray *)messageHeader
{
	return fields;
}

- (void)setBody:(id)aBody
{
	[body release];
	body = [aBody retain];
}

- (id)body
{
	return body;
}

- (unsigned)count
{
	if ([self isMultipart])
		return [[self body] count];
	else
		return 0;
}

+ (NSSet *)supportedTypes
{
	return [NSSet setWithObjects:@"text", @"image", @"application", @"multipart", nil];
}

+ (NSSet *)supportedSubtypes
{
	NSEnumerator *aSubypeEnumerator = [[ATMIMETokenScanner ianaToken] objectEnumerator];
	NSString *aSubtypeName = nil;
	NSMutableSet *aSupportedSubtypes = [NSMutableSet set];
	
	while (aSubtypeName = [aSubypeEnumerator nextObject])
		[aSupportedSubtypes addObject:[aSubtypeName lowercaseString]];

	return aSupportedSubtypes;
}

- (id)preferredEntity
{
	if ([self isMultipartAlternative])
	{
		NSEnumerator *anEntityEnumerator = [[[self body] bodyParts] reverseObjectEnumerator];
		ATMessageEntity *anEntity = nil;
		NSSet *aSupportedTypes = [[self class] supportedTypes];
		ATMessageEntity *aProvisionalEntity = nil;
		
		while (!aProvisionalEntity && (anEntity = [anEntityEnumerator nextObject]))
		{
			if ([aSupportedTypes containsObject:[[[anEntity contentType] type] lowercaseString]] && [[[self class] supportedSubtypes] containsObject:[[[anEntity contentType] subtype] lowercaseString]])
				aProvisionalEntity = anEntity;
		}
		
		return aProvisionalEntity;
	}
	else
		return self;
}

- (id)preferredBody
{
	return [[self preferredEntity] body];
}

- (NSString *)preferredBodyStringValue
{
	id aBody = [self preferredBody];
	
	return [aBody isKindOfClass:[ATBodyTextRepresentation class]] ? aBody : [aBody stringValue];
}

- (NSMutableAttributedString *)attributedString
{
	return [self attributedStringWithRestrictionOfHeader:nil];
}

- (NSMutableAttributedString *)attributedStringWithRestrictionOfHeader:(NSSet *)aHeaderNames
{
	NSMutableAttributedString *anAttributedString = [[NSMutableAttributedString new] autorelease];
	
	[anAttributedString appendAttributedString:[self attributedStringOfHeaderRestrictedTo:aHeaderNames]];
	if ([anAttributedString length])
		[anAttributedString appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\r\n"] autorelease]];
	
	if ([self body])
		[anAttributedString appendAttributedString:[self attributedStringOfBody]];
	
	return anAttributedString;
}

- (NSMutableAttributedString *)attributedStringOfSummary
{
	NSMutableAttributedString *aSummary = [self attributedStringOfHeader];
	
	[aSummary appendAttributedString:[[[NSAttributedString alloc] initWithString:@"\r\n"] autorelease]];
	
	return aSummary;
}

- (NSMutableAttributedString *)attributedStringOfBody
{
	if ([self isMultipart])
		return [[self body] attributedStringOfSummary];
	else
		return [[self body] attributedString];
}

- (BOOL)saveBodyTo:(NSString *)aFilePath
{
	if ([[self contentType] typeIs:@"text"])
		return [[self body] saveTo:aFilePath];
	else
		return [[[self body] data] writeToFile:aFilePath atomically:YES];
}

- (NSString *)stringValue
{
	return [self isMultipart] ? [[self body] description] : [[self body] stringValue];
}

- (NSString *)description
{
	return [self stringValue] ? [self stringValue] : @"";
}

@end

@implementation ATMessageEntity (Fields)

- (void)addHeader:(ATHeaderField *)aField
{
	[[self messageHeader] addObject:aField];
}

- (unsigned)headerFieldCount
{
	return [[self messageHeader] count];
}

- (ATHeaderField *)headerFieldAt:(unsigned)anIndex
{
	ATHeaderField *aHeaderField = [fields objectAtIndex:anIndex];
	
	[aHeaderField interpret];
	
	return aHeaderField;
}

- (ATHeaderField *)lastHeaderField
{
	ATHeaderField *aHeaderField = [[self messageHeader] lastObject];
	
	[aHeaderField interpret];
	
	return aHeaderField;
}

- (ATHeaderField *)lastHeaderFieldWithoutInterpreting
{
	return [[self messageHeader] lastObject];
}

- (ATHeaderField *)headerFieldFor:(NSString *)aName
{
	return [self headerFieldFor:aName interpretIfNotInterpreted:YES];
}

- (ATHeaderField *)headerFieldFor:(NSString *)aName interpretIfNotInterpreted:(BOOL)anInterpretFlag
{
	ATHeaderField *aHeaderField;
	NSEnumerator *enumerator = [[self messageHeader] objectEnumerator];
	BOOL aHeaderFieldFound = NO;
	
	while (!aHeaderFieldFound && (aHeaderField = [enumerator nextObject]))
	{
		aHeaderFieldFound = [aHeaderField nameIs:aName];
	}
	
	if (anInterpretFlag)
		[aHeaderField interpret];
	
	return aHeaderField;
}

- (ATHeaderField *)date
{
	return [self headerFieldFor:@"date"];
}

- (NSString *)dateString
{
	return [[self date] bodyString];
}

- (ATHeaderField *)subject
{
	return [self headerFieldFor:@"subject"];
}

- (NSString *)subjectString
{	
	return [[self subject] bodyString];
}

- (ATHeaderField *)from
{
	return [self headerFieldFor:@"from"];
	
}

- (NSString *)fromString
{
	return [[self from] bodyString];
}

- (ATHeaderField *)to
{
	return [self headerFieldFor:@"to"];
}

- (NSString *)toString
{
	return [[self to] bodyString];
}

- (ATHeaderField *)sender
{
	return [self headerFieldFor:@"sender"];
}

- (ATHeaderField *)contentType
{
	return [self hasValidContentType] ? [self headerFieldFor:@"content-type"] : [self defaultContentType];
}

- (ATHeaderField *)defaultContentType
{
	return [ATHeaderField defaultContentType];
}

- (ATHeaderField *)contentTransferEncoding
{
	ATHeaderField *aContentTransferEncoding = [self headerFieldFor:@"Content-Transfer-Encoding"];
	
	if (aContentTransferEncoding && ![aContentTransferEncoding isInterpreted])
		[aContentTransferEncoding interpret];
		
	return (aContentTransferEncoding && [aContentTransferEncoding isValid]) ? aContentTransferEncoding : [self defaultContentTransferEncoding];
}

- (ATHeaderField *)defaultContentTransferEncoding
{
	return [ATHeaderField defaultContentTransferEncoding];
}

- (ATHeaderField *)contentDisposition
{
	return [self headerFieldFor:@"Content-Disposition"];
}

- (NSMutableAttributedString *)attributedStringOfHeader
{
	return [self attributedStringOfHeaderRestrictedTo:nil];
}

- (NSMutableAttributedString *)attributedStringOfHeaderRestrictedTo:(NSSet *)aHeaderNames
{
	NSEnumerator *aFieldEnumerator = [[self messageHeader] objectEnumerator];
	ATHeaderField *aField = nil;
	NSMutableAttributedString *anAttributedStringOfHeader = [[NSMutableAttributedString new] autorelease];
	
	while (aField = [aFieldEnumerator nextObject])
	{
		if (!aHeaderNames || [aField nameIsIncludedIn:aHeaderNames])
			[anAttributedStringOfHeader appendAttributedString:[aField attributedString]];
	}
	
	return anAttributedStringOfHeader;
}

@end

@implementation ATMessageEntity (Interpretting)

- (BOOL)interpret
{
	return NO;
}

- (void)readHeaderFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner
{
	[self readHeaderFromLineScanner:aLineScanner fieldNamesToBeInterpreted:nil];
}

- (void)readHeaderFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner fieldNamesToBeInterpreted:(NSSet *)aFieldNamesToBeInterpreted
{
	NSData *aLineData;
	
	while ((aLineData = [aLineScanner scanUnfoldedLine]) && [aLineData length])
	{
		ATHeaderField *aHeaderField = nil;
		
		if (aFieldNamesToBeInterpreted)
		{
			aHeaderField = [[[ATHeaderField alloc] initWithLineData:aLineData interpret:NO] autorelease];
			
			if (aHeaderField && [aFieldNamesToBeInterpreted containsObject:[[aHeaderField name] lowercaseString]])
				aHeaderField = [aHeaderField interpret] ? aHeaderField : nil;
		}
		else
			aHeaderField = [[[ATHeaderField alloc] initWithLineData:aLineData interpret:NO] autorelease];
		
		if (aHeaderField)
			[self addHeader:aHeaderField];
		
		[aLineScanner skipNextCRLF];
	}
}

- (void)readBodyFromLineScanner:(ATInternetMessageLineScanner *)aLineScanner
{
	if ([self isMultipart])
	{
		NSString *aBoundary = [[self contentType] boundary];
		ATMultipartBody *aMultipartBody = nil;

		if (aBoundary)
		{
			aMultipartBody = [ATMultipartBody multipartBodyFromLineScanner:aLineScanner boundary:aBoundary parentBoundary:parentBoundary];
		
			[self setBody:aMultipartBody];
		}
	}
	else
	{
		ATMultipartTokenScanner *aMultipartScanner = [ATMultipartTokenScanner scannerWithLineScanner:aLineScanner parentBoundary:parentBoundary];
		NSData *anOctets = [aMultipartScanner scanBodyPartOctets];
		
		if (anOctets)
		{
			//NSString *aStringOfOctets = [[[NSString alloc] initWithData:anOctets encoding:NSASCIIStringEncoding] autorelease];

			if ([[self contentType] typeIs:@"text"])
			{
				if ([self hasValidContentType] && [self bodyIsEncoded])
					anOctets = [self decode:anOctets];
					
				[self setBody:[ATBodyTextRepresentation textRepresentationWithTextData:anOctets parentEntity:self]];
			}
			else
			{
				if ([self bodyIsEncoded])
					anOctets = [self decode:anOctets];

				[self setBody:[ATOctetStreamRepresentation representationWithOctets:anOctets]];
			}
		}
	}
}

- (NSData *)decode:(NSData *)anOctets
{
	NSData *aDecodedData = nil;
	
	if ([[self contentTransferEncoding] mechanismIs:@"quoted-printable"])
	{
		aDecodedData = [ATQuotedPrintableDecoder decode:anOctets];
	}
	else if ([[self contentTransferEncoding] mechanismIs:@"base64"])
	{
		ATBase64Decoder *aDecoder = [[[ATBase64Decoder alloc] initWith:anOctets] autorelease];
		aDecodedData = [aDecoder decode];
	}
	else
		aDecodedData = anOctets;
		
	return aDecodedData;
}

@end

@implementation ATMessageEntity (Testing)

- (BOOL)isValid
{
	return NO;
}

- (BOOL)isMessage
{
	return NO;
}

- (BOOL)isTopLevelMessage
{
	return NO;
}

- (BOOL)contentTypeIsMessage
{
	return [[self contentType] typeIs:@"message"];
}

- (BOOL)isMIMEMessage
{
	[self headerFieldFor:@"MIME-Version"] ? YES : NO;
}

- (BOOL)isMultipart
{
	return [[self contentType] typeIs:@"multipart"];
}

- (BOOL)isMultipartAlternative
{
	return [self isMultipart] && [[self contentType] subtypeIs:@"alternative"];
}

- (BOOL)isCompositeType
{
	return [self isMultipart] || [self isMessage];
}

- (BOOL)contentTypeIsText
{
	return [[self contentType] typeIs:@"text"];
}

- (BOOL)contentTypeIsPlainText
{
	return [self contentTypeIsText] && [[self contentType] subtypeIs:@"plain"];
}

- (BOOL)contentTypeIsHTML
{
	return [self contentTypeIsText] && [[self contentType] subtypeIs:@"html"];
}

- (BOOL)contentTypeIsImage
{
	return [[self contentType] typeIs:@"image"];
}

- (BOOL)hasValidContentType
{
	ATHeaderField *aContentType = [self headerFieldFor:@"content-type"];
			
	return (aContentType && [aContentType isValid]) ? YES : NO;
}

- (BOOL)bodyIsPlainText
{	
	return [[self contentType] typeIs:@"text"] && [[self contentType] subtypeIs:@"plain"];
}

- (BOOL)bodyIsEncoded
{
	return [[self contentTransferEncoding] mechanismIs:@"quoted-printable"] || [[self contentTransferEncoding] mechanismIs:@"base64"];
}

- (BOOL)bodyCharsetIs:(NSString *)aCharset
{
	return [[self contentType] charsetIs:aCharset];
}


@end