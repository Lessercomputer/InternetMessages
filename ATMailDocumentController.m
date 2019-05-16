#import "ATMailDocumentController.h"

@implementation ATMailDocumentController

- (BOOL)hasMessageDownloadingDocument
{
	NSEnumerator *aDocumentEnumerator = [[self documents] objectEnumerator];
	id aDocument = nil;
	BOOL aDocumentInDownload = NO;
	
	while (!aDocumentInDownload && (aDocument = [aDocumentEnumerator nextObject]))
	{
		if ([aDocument isDownloading])
			aDocumentInDownload = YES;
	}
	
	return aDocumentInDownload;
}

@end
