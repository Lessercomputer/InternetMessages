//
//  ATMailboxesOutlinePane.h
//  ATMail
//
//  Created by 高田 明史 on 08/02/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "ATMessagesPane.h"

@class ATMailboxesOutlineDataSource;

@interface ATMailboxesOutlinePane : ATItemsPane
{
	IBOutlet ATMailboxesOutlineDataSource *dataSource;
}

- (void)mailboxesDidChange:(NSNotification *)aNotification;
- (void)mailboxesDidMove:(NSNotification *)aNotification;

- (IBAction)makeNewMailbox:(id)sender;
- (void)selectedMailboxesDidChange:(NSNotification *)aNotification;

@end
