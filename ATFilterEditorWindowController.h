/* ATFilterEditorWindowController */

#import <Cocoa/Cocoa.h>

@class ATFilterEditor;

@interface ATFilterEditorWindowController : NSWindowController
{
    IBOutlet id filterEditor;
    IBOutlet id filtersPresentation;
    IBOutlet id mailboxesPresentation;
}

+ (id)filterEditorWindowControllerWith:(ATFilterEditor *)anEditor;
- (id)initWithFilterEditor:(ATFilterEditor *)anEditor;

@end
