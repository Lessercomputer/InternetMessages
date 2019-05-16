//
//  ATFilterEditor.h
//  ATMail
//
//  Created by 高田 明史 on 08/03/20.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATFilter;
@class ATMailSpool;

extern NSString *ATFilterEditorDidChangeNotification;

@interface ATFilterEditor : NSObject
{
	NSMutableArray *filters;
}

@end

@interface ATFilterEditor (Initializing)

+ (id)filterEditor;
+ (id)filterEditorWithContentsOfFile:(NSString *)aPath mailSpool:(ATMailSpool *)aMailSpool;

- (id)initWithFilters:(NSMutableArray *)aFilters;
- (id)initWithContentsOfFile:(NSString *)aPath mailSpool:(ATMailSpool *)aMailSpool;

@end

@interface ATFilterEditor (Accessing)

- (NSMutableArray *)filters;
- (void)setFilters:(NSMutableArray *)aFilters;

- (void)insertObject:(ATFilter *)aFilter inFiltersAtIndex:(unsigned)anIndex;
- (void)removeObjectFromFiltersAtIndex:(unsigned)anIndex;

@end

@interface ATFilterEditor (Saving)

- (BOOL)writeToFile:(NSString *)aPath;

@end

@interface ATFilterEditor (Filtering)

- (NSArray *)filterAndMove:(NSArray *)aMessages;

@end

@interface ATFilterEditor (Observing)

- (void)addObservingOf:(NSArray *)aFilters;
- (void)removeObservingOf:(NSArray *)aFilters;

- (void)addObservingOfFilter:(ATFilter *)aFilter;
- (void)removeObservingOfFilter:(ATFilter *)aFilter;

@end