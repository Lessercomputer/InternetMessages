//
//  ATMailboxesOutlineDataSource.h
//  ATMail
//
//  Created by 高田 明史 on 08/02/01.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATMailSpool;
@class ATMailSpoolModel;

@interface ATMailboxesOutlineDataSource : NSObject
{
	ATMailSpoolModel *mailSpoolModel;
}

- (ATMailSpool *)mailSpool;
- (ATMailSpoolModel *)mailSpoolModel;
- (void)setMailSpoolModel:(ATMailSpoolModel *)aMailSpoolModel;

@end
