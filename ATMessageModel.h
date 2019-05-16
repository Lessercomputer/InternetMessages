//
//  ATMessageModel.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/11/19.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATInternetMessage;
@class ATMailSpoolModel;
@class ATMessageEntity;

extern NSString *ATMessageModelEntitySelectionDidChangeNotification;
extern NSString *ATSelectedEntityKey;

@interface ATMessageModel : NSObject
{
	ATInternetMessage *message;
	ATMessageEntity *selectedEntity;
}

- (ATInternetMessage *)message;
- (void)setMessage:(ATInternetMessage *)aMessage;

- (ATMessageEntity *)selectedEntity;
- (void)setSelectedEntity:(ATMessageEntity *)anEntity;

- (NSString *)filename;
- (BOOL)saveBodyOfSelectedEntityTo:(NSString *)aFilePath;

- (NSSet *)headerNamesToBeShow;

@end
