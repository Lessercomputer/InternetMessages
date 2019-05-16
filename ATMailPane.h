//
//  ATMailPane.h
//  ATMail
//
//  Created by 高田 明史 on 07/12/23.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATMailPane : NSResponder
{
    IBOutlet id contentView;
    IBOutlet id view;
}

- (NSString *)paneNibName;
- (BOOL)loadContentView;

- (NSView *)contentView;
- (NSView *)view;

- (void)setupResponderChain;
- (void)restoreResponderChain;

- (id)propertyListRepresentation;
- (void)setPropertyListRepresentation:(id)aPlist;

@end
