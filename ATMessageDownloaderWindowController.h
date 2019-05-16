/* ATMessageDownloaderWindowController */

#import <Cocoa/Cocoa.h>

@class ATPop3MessageDownloader;

@interface ATMessageDownloaderWindowController : NSWindowController
{
    IBOutlet id controller;
	ATPop3MessageDownloader *downloader;
}
@end
