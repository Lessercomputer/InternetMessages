//
//  ATFieldBody.m
//  ATMail
//
//  Created by 高田　明史 on 06/03/11.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATFieldBody.h"
#import "ATTokenScanner.h"
#import "ATUnstructuredFieldBody.h"
#import "ATMailboxListFieldBody.h"
#import "ATAddressListFieldBody.h"
#import "ATKeywordsFieldBody.h"
#import "ATMailboxFieldBody.h"
#import "ATBccFieldBody.h"
#import "ATMsgIDFieldBody.h"
#import "ATPathFieldBody.h"
#import "ATReceivedFieldBody.h"
#import "ATMIMEVersionFieldBody.h"
#import "ATContentTypeFieldBody.h"
#import "ATContentTransferEncodingFieldBody.h"
#import "ATContentIDFieldBody.h"
#import "ATContentDescriptionFieldBody.h"
#import "ATMIMETokenScanner.h"
#import "ATDateTimeFieldBody.h"
#import "ATContentDispositionFieldBody.h"

static NSMutableDictionary *fieldBodyClassDictionary;

@implementation ATFieldBody

+ (void)initialize
{
	fieldBodyClassDictionary = [NSMutableDictionary new];
	
	[self setFieldBody:[ATDateTimeFieldBody class] forName:@"date"];
	[self setFieldBody:[ATMailboxListFieldBody class] forName:@"from"];
	[self setFieldBody:[ATAddressListFieldBody class] forName:@"to"];
	[self setFieldBody:[ATKeywordsFieldBody class] forName:@"keywords"];
	[self setFieldBody:[ATMailboxFieldBody class] forName:@"sender"];
	[self setFieldBody:[ATAddressListFieldBody class] forName:@"reply-to"];
	[self setFieldBody:[ATAddressListFieldBody class] forName:@"cc"];
	[self setFieldBody:[ATBccFieldBody class] forName:@"bcc"];
	[self setFieldBody:[ATMsgIDFieldBody class] forName:@"message-id"];
	[self setFieldBody:[ATMsgIDFieldBody class] forName:@"in-reply-to"];
	[self setFieldBody:[ATMsgIDFieldBody class] forName:@"references"];
	
	[self setFieldBody:[ATDateTimeFieldBody class] forName:@"resent-date"];
	[self setFieldBody:[ATMailboxListFieldBody class] forName:@"resent-from"];
	[self setFieldBody:[ATMailboxFieldBody class] forName:@"resent-sender"];
	[self setFieldBody:[ATAddressListFieldBody class] forName:@"resent-to"];
	[self setFieldBody:[ATBccFieldBody class] forName:@"resent-bcc"];
	[self setFieldBody:[ATMsgIDFieldBody class] forName:@"resent-msg-id"];
	
	[self setFieldBody:[ATPathFieldBody class] forName:@"return-path"];
	[self setFieldBody:[ATReceivedFieldBody class] forName:@"received"];
	
	[self setFieldBody:[ATMIMEVersionFieldBody class] forName:@"MIME-Version"];
	[self setFieldBody:[ATContentTypeFieldBody class] forName:@"Content-Type"];
	[self setFieldBody:[ATContentTransferEncodingFieldBody class] forName:@"Content-Transfer-Encoding"];
	[self setFieldBody:[ATContentIDFieldBody class] forName:@"Content-ID"];
	[self setFieldBody:[ATContentDescriptionFieldBody class] forName:@"Content-Description"];
	
	[self setFieldBody:[ATContentDispositionFieldBody class] forName:@"Content-Disposition"];
}

+ (void)setFieldBody:(Class)aFieldBodyClass forName:(NSString *)aName
{
	[fieldBodyClassDictionary setObject:aFieldBodyClass forKey:[aName lowercaseString]];
}

+ (Class)fieldBodyForName:(NSString *)aName
{
	if (aName)
	{		
		Class aFieldBodyClass = [fieldBodyClassDictionary objectForKey:[aName lowercaseString]];
	
		return aFieldBodyClass ? aFieldBodyClass : [ATUnstructuredFieldBody class];
	}
	else
		return [ATFieldBody class];
}

@end

@implementation ATFieldBody (Initializing)

- (id)init
{
	return [self initWithFoldedLine:[NSMutableString string]];;
}

- (id)initWith:(NSString *)aString
{
	return [self initWithFoldedLine:aString];
}

- (id)initWithFoldedLine:(NSString *)aString
{
	[super init];
	
	[self setValue:[[aString mutableCopy] autorelease]];
	
	return self;
}

- (void)dealloc
{
	[self setValue:nil];
	
	[super dealloc];
}

@end

@implementation ATFieldBody (Accessing)

- (void)setValue:(NSMutableString *)aString
{
	[value release];
	value = [aString retain];
}

- (NSMutableString *)value
{
	return value;
}

- (NSString *)stringValue
{
	return [self value];
}

- (NSAttributedString *)attributedString
{
	return [[[NSAttributedString alloc] initWithString:[self stringValue] attributes:[NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSForegroundColorAttributeName]] autorelease];
}

- (void)addLine:(NSString *)aLine
{
	[[self value] appendString:aLine];
}

@end
