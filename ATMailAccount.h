//
//  ATMailAccount.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/08/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATPop3MessageDownloader;

@interface ATMailAccount : NSObject
{
	NSString *hostName;
	NSString *userName;
	NSString *password;
	
	NSArray *messageUIDLToBeSkipped;
}

- (id)initWithHostName:(NSString *)aHostName userName:(NSString *)aUserName password:(NSString *)aPassword messageUIDLToBeSkipped:(NSArray *)aMessageUIDLToBeSkipped;

- (id)initWithPropertyListReprensentation:(NSDictionary *)aPlistRep;
- (id)initWithSerializedPropertyListReprensentation:(NSData *)aSerializedPlistRep;

- (NSString *)hostName;
- (void)setHostName:(NSString *)aName;

- (NSString *)userName;
- (void)setUserName:(NSString *)aName;

- (NSString *)password;
- (void)setPassword:(NSString *)aPassword;

- (NSArray *)messageUIDLToBeSkipped;
- (void)setMessageUIDLToBeSkipped:(NSArray *)aUIDL;

- (BOOL)updateMessageUIDLToBeSkipped:(ATPop3MessageDownloader *)aDownloader;

- (NSDictionary *)propertyListRepresentation;
- (NSData *)serializedPropertyListRepresentation;

@end
