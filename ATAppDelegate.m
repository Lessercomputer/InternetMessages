#import "ATAppDelegate.h"
#import "ATMailDocument.h"

@implementation ATAppDelegate

- (IBAction)newMailSpool:(id)sender
{
	[window makeKeyAndOrderFront:nil];
}

- (IBAction)selectSavingFolder:(id)sender
{
	NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	[oPanel setCanChooseDirectories:YES];
	[oPanel beginSheetForDirectory:nil file:nil types:nil modalForWindow:window modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		NSString *aPath = [[sheet directory] stringByAppendingPathComponent:mailSpoolName];
		aPath = [aPath stringByAppendingPathExtension:ATMaillDocumentType];
		[self setValue:aPath  forKey:@"savingPath"];
	}
}

- (IBAction)openNewMailSpool:(id)sender
{
	NSError *anError = nil;
	ATMailDocument *aDocument = [[NSDocumentController sharedDocumentController] openUntitledDocumentAndDisplay:NO error:&anError];
	[aDocument writeToURL:[NSURL fileURLWithPath:savingPath] ofType:ATMaillDocumentType error:&anError];
	[aDocument close];
	[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:savingPath] display:YES error:&anError];
	[window orderOut:nil];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	return [[NSDocumentController sharedDocumentController] hasMessageDownloadingDocument] ? NSTerminateCancel : NSTerminateNow;
}

@end
