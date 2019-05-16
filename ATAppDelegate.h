/* ATAppDelegate */

#import <Cocoa/Cocoa.h>

@interface ATAppDelegate : NSObject
{
	IBOutlet id window;
	NSString *mailSpoolName;
	NSString *savingPath;
}
- (IBAction)newMailSpool:(id)sender;
- (IBAction)selectSavingFolder:(id)sender;
- (IBAction)openNewMailSpool:(id)sender;
@end
