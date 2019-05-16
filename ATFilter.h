//
//  ATFilter.h
//  ATMail
//
//  Created by 高田 明史 on 08/03/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATMailbox;
@class ATMailSpool;

@interface ATFilter : NSObject
{
	NSString *name;
	NSString *predicateString;
	ATMailbox *targetMailbox;
}

@end

@interface ATFilter (Initializing)

+ (id)filterWithPropertyListRepresentation:(NSDictionary *)aPlist mailSpool:(ATMailSpool *)aMailSpool;

- (id)initWithName:(NSString *)aName predicateString:(NSString *)aPredicateString targetMailbox:(ATMailbox *)aMailbox;
- (id)initWithPropertyListRepresentation:(NSDictionary *)aPlist mailSpool:(ATMailSpool *)aMailSpool;

@end

@interface ATFilter (Accessing)

- (NSString *)name;
- (void)setName:(NSString *)aName;

- (NSString *)predicateString;
- (void)setPredicateString:(NSString *)aString;

- (NSPredicate *)predicate;

- (ATMailbox *)targetMailbox;
- (void)setTargetMailbox:(ATMailbox *)aMailbox;

- (NSArray *)editableKeys;

@end

@interface ATFilter (Converting)

- (NSDictionary *)propertyListRepresentation;

@end

@interface ATFilter (Filtering)

- (NSArray *)filter:(NSArray *)aMessages;
- (void)filterAndMove:(NSMutableArray *)aMessages;

@end