//
//  ATTimeOfDay.m
//  ATMail
//
//  Created by ‚“c@–¾j on 06/04/11.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATTimeOfDay.h"


@implementation ATTimeOfDay

- (id)initWith:(int)anHour with:(int)aMinute with:(int)aSecond
{
	[super init];
	
	hour = anHour;
	minute = aMinute;
	second = aSecond;
	
	return self;
}

/*- (void)dealloc
{
	[hour release];
	[minute release];
	[second release];
	
	[super dealloc];
}*/

- (int)hour
{
	return hour;
}

- (int)minute
{
	return minute;
}

- (int)second
{
	return second;
}

@end
