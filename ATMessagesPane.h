//
//  ATMessagesPane.h
//  ATMail
//
//  Created by 高田 明史 on 07/12/23.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATItemsPane.h"
@class ATMailSpoolModel;

@interface ATMessagesPane : ATItemsPane
{
}


- (void)messageReadStatusDidChange:(NSNotification *)aNotification;

//- (void)setSortDescriptors:(NSArray *)aSortDescriptors;

@end

@interface ATMessagesPane (ColumnSupport)

- (void)setupColumnsFromColumnsPropertyListRepresentation:(NSArray *)aColumns;
- (NSArray *)collectViewTableColumnsForColumnsPropertyListRepresentation:(NSArray *)aColumns;
- (void)setTableColumns:(NSArray *)aTableColumns;

- (NSArray *)columnsPropertyListRepresentation;

- (void)storeColumns;

@end
