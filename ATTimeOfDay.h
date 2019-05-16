//
//  ATTimeOfDay.h
//  ATMail
//
//  Created by 高田　明史 on 06/04/11.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ATTimeOfDay : NSObject
{
	int hour;
	int minute;
	int second;
}

- (id)initWith:(int)anHour with:(int)aMinute with:(int)aSecond;

- (int)hour;
- (int)minute;
- (int)second;

@end
