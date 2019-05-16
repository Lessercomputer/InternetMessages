//
//  ATBodyTextRepresentation.m
//  ATMail
//
//  Created by 高田　明史 on 07/07/15.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATBodyTextRepresentation.h"
#import "ATHeaderField.h"
#import "ATContentTypeFieldBody.h"
#import "ATContentTransferEncodingFieldBody.h"
#import "ATQuotedPrintableDecoder.h"
#import "ATBase64Decoder.h"
#import "ATMessageEntity.h"

@implementation ATBodyTextRepresentation

+ (id)textRepresentationWithTextData:(NSData *)aTextData parentEntity:(ATMessageEntity *)anEntity
{
	return [self textRepresentationWithTextData:aTextData contentType:[anEntity contentType] contentTransferEncoding:[anEntity contentTransferEncoding]];
}

+ (id)textRepresentationWithTextData:(NSData *)aTextData contentType:(ATHeaderField *)aContentType contentTransferEncoding:(ATHeaderField *)aContentTransferEncoding
{
	return [[[self alloc] initWithTextData:aTextData contentType:aContentType contentTransferEncoding:aContentTransferEncoding] autorelease];
}

- (id)initWithTextData:(NSData *)aTextData contentType:(ATHeaderField *)aContentType contentTransferEncoding:(ATHeaderField *)aContentTransferEncoding;
{
	[super init];
	
	textData = [aTextData retain];
	text = @"";
	
	contentType = [aContentType retain];
	contentTransferEncoding = [aContentTransferEncoding retain];
	
	[self interpret];
	
	return self;
}

- (void)dealloc
{
	[contentType release];
	[contentTransferEncoding release];
	[textData release];
	[text release];
	[attributedString release];
	
	[super dealloc];
}

- (void)interpret
{
	if ([contentType typeIs:@"text"] && textData)
	{
		NSString *aCharset = [contentType charset];
		CFStringEncoding aCFEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)aCharset);
		
		if (aCFEncoding != kCFStringEncodingInvalidId)
		{
			NSStringEncoding aNSEncoding = CFStringConvertEncodingToNSStringEncoding(aCFEncoding);
			NSString *aText = [[NSString alloc] initWithData:textData encoding:aNSEncoding];
			
			if (aText)
				text = aText;
			else if ([aCharset isEqualToString:@"Shift_JIS"])
			{
				aText = [[NSString alloc] initWithData:textData encoding:NSShiftJISStringEncoding];
				
				if (aText)
					text = aText;
			}
		}
	}
}

- (NSString *)text
{
	return text;
}

- (NSString *)stringValue
{
	return [self text];
}

- (void)addAttributesToURIsInText
{
	NSMutableAttributedString *anAttrStr = [[NSMutableAttributedString alloc] initWithString:[self text]];
	NSScanner *aScanner = [NSScanner scannerWithString:[self text]];
	BOOL aScannerIsAtEnd = NO;
	NSArray *aSchemeNames = [NSArray arrayWithObjects:@"http", @"https", @"mailto", nil];
	
	[aScanner setCharactersToBeSkipped:nil];

	while (!(aScannerIsAtEnd = [aScanner isAtEnd]))
	{
		unsigned aSchemeStatingLocation = 0;
		NSString *aURIString = nil;
		NSURL *aURL = nil;
		NSEnumerator *anEnumerator = [aSchemeNames objectEnumerator];
		NSString *aSchemeName = nil;
		BOOL aSchemeNameFound = NO;
				
		[aScanner scanCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
		
		aSchemeStatingLocation = [aScanner scanLocation];
		anEnumerator = [aSchemeNames objectEnumerator];
		
		while ((aSchemeName = [anEnumerator nextObject]) && !(aSchemeNameFound = [aScanner scanString:[aSchemeName stringByAppendingString:@":"] intoString:nil]))
			;
			
		if (aSchemeNameFound)
		{
			[aScanner setScanLocation:aSchemeStatingLocation];
			[aScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&aURIString];
						
			if (aURIString && (aURL = [NSURL URLWithString:aURIString]))
			{
				NSRange aRange = NSMakeRange(aSchemeStatingLocation, [aURIString length]);
				
				[anAttrStr addAttribute:NSLinkAttributeName value:aURL  range:aRange];
				[anAttrStr addAttribute:NSCursorAttributeName value:[NSCursor pointingHandCursor] range:aRange];
			}
		}
		else
			[aScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:nil];
	}
		
	attributedString = anAttrStr;
}

- (NSMutableAttributedString *)attributedString
{
	if (!attributedString)
		[self addAttributesToURIsInText];
		
	return attributedString;
}

- (BOOL)saveTo:(NSString *)aFilePath
{
	return [textData writeToFile:aFilePath atomically:YES];
}

@end
