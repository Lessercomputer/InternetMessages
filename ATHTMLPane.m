//
//  ATHTMLPane.m
//  ATMail
//
//  Created by çÇìc ñæéj on 07/12/24.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "ATHTMLPane.h"


@implementation ATHTMLPane

- (NSString *)paneNibName
{
	return @"ATHTMLPane";
}

- (void)setEntity:(ATMessageEntity *)anEntity
{
	if (anEntity)
	{
		[[[self view] mainFrame] loadHTMLString:[[anEntity body] text] baseURL:nil];
	}
}

@end
