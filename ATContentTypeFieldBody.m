//
//  ATContentTypeFieldBody.m
//  ATMail
//
//  Created by 高田　明史 on 06/09/23.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATContentTypeFieldBody.h"
#import "ATMIMETokenScanner.h"


@implementation ATContentTypeFieldBody

+ (id)defaultContentType
{
	return [[[self alloc] initWithType:@"text" subtype:@"plain" parameters:[NSDictionary dictionaryWithObject:@"us-ascii" forKey:@"charset"]] autorelease];
}

- (id)initWith:(NSString *)aString
{
	return [self initWithUnfoldedLine:aString];
}

- (id)initWithUnfoldedLine:(NSString *)aString
{
	ATMIMETokenScanner *aTokenScanner = [[[ATMIMETokenScanner alloc] initWith:aString] autorelease];
	
	[super init];
	
	if ([aTokenScanner scanContentTypeFieldValueInto:&type into:&subtype into:&parameters])
	{
		[type retain];
		[subtype retain];
		[parameters retain];
		
		return self;
	}
	else
	{
		[self release];
		
		return nil;
	}
}

- (id)initWithType:(NSString *)aType subtype:(NSString *)aSubtype parameters:(NSDictionary *)aParameters
{
	[super init];
	
	type = [aType copy];
	subtype = [aSubtype copy];
	parameters = [aParameters copy];
	
	return self;
}

- (void)dealloc
{
	[type release];
	[subtype release];
	[parameters release];
	
	[super dealloc];
}

- (NSString *)type
{
	return type;
}

- (NSString *)subtype
{
	return subtype;
}

- (NSString *)stringValue
{
	return [NSString stringWithFormat:@"%@/%@ %@", type, subtype, [parameters description]];
}

- (NSString *)charset
{
	NSString *aCharset = [parameters objectForKey:@"charset"];
	return aCharset ? aCharset : @"us-ascii";
}

- (NSString *)boundary
{
	return [parameters objectForKey:@"boundary"];
}

- (BOOL)typeIs:(NSString *)aType
{
	return [[[self type] lowercaseString] isEqualToString:[aType lowercaseString]];
}

- (BOOL)subtypeIs:(NSString *)aSubtype
{
	return [[[self subtype] lowercaseString] isEqualToString:[aSubtype lowercaseString]];
}

- (BOOL)charsetIs:(NSString *)aCharset
{
	return [[[self charset] lowercaseString] isEqualToString:[aCharset lowercaseString]];
}

@end
