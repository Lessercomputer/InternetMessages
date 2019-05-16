//
//  ATMailDocument.h
//  ATMail
//
//  Created by ????? on 06/02/12.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

extern NSString *ATMaillDocumentType;

@class ATMailSpool;
@class ATInternetMessage;
@class ATMailAccount;
@class ATPop3MessageDownloader;

@interface ATMailDocument : NSDocument
{
	ATMailSpool *mailSpool;
	BOOL inReading;
	NSArray *initialPresentationSettings;
}

@end

@interface ATMailDocument (Accessing)

- (ATMailSpool *)mailSpool;
- (void)setMailSpool:(ATMailSpool *)aMailSpool;

- (NSArray *)mailDocumentWindowControllers;

@end

@interface ATMailDocument (Actions)

- (IBAction)showFilterEditor:(id)sender;
- (IBAction)showMailAccount:(id)sender;

- (IBAction)importMessages:(id)sender;
- (IBAction)rebuildCacheHeader:(id)sender;

- (IBAction)addIsolatedMessagesToInbox:(id)sender;

@end

@interface ATMailDocument (DownloadingMessage)

- (IBAction)download:(id)sender;
- (IBAction)cancel:(id)sender;

@end

@interface ATMailDocument (SavingAndLoading)

- (NSString *)presentationSettingsFilePath;

- (BOOL)savePresentationSetting;
- (BOOL)loadPresentationSetting;

@end