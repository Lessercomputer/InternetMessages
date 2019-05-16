#import "ATMessageDownloaderWindowController.h"
#import "ATPop3MessageDownloader.h"

@implementation ATMessageDownloaderWindowController

- (id)initWith:(ATPop3MessageDownloader *)aDownloader
{
	[super initWithWindowNibName:@"ATMessageDownloaderWindow"];
	
	downloader = [aDownloader retain];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFinished:) name:ATPop3MessageDownloaderDidFinishDownload object:downloader];
	
	return self;
}

- (void)dealloc
{
	NSLog(@"ATMessageDownloaderWindowController #dealloc");
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[downloader release];
	[controller setContent:nil];
	
	[super dealloc];
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	[controller setContent:downloader];
}

- (void)downloadFinished:(NSNotification *)aNotification
{
	[self close];
}

@end
