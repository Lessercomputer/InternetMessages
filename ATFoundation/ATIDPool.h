//
//  ATIDPool.h
//  ATBookmarks
//
//  Created by –¾Žj on 05/10/11.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import <Nursery/Nursery.h>

@interface ATIDPool : NSObject
{
//    NUBell *bell;
    UInt64 nextID;
    NSMutableIndexSet *freeIDs;
}

@end

@interface ATIDPool (Initializing)

+ (id)idPool;

+ (id)newWith:(NSDictionary *)aPropertyList;

- (id)initWith:(NSDictionary *)aPropertyList;
@end

//@interface ATIDPool (Coding) <NUCoding>
//@end

@interface ATIDPool (Accessing)
- (UInt64)newID;

- (UInt64)newIDWith:(UInt64)anID;

- (void)releaseID:(UInt64)anID;
@end


@interface ATIDPool (Testing)
- (BOOL)isUsing:(UInt64)anID;
@end

@interface ATIDPool (Converting)
- (NSDictionary   *)propertyListRepresentation;
@end
