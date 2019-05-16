//
//  ATMailDocument.m
//  ATMail
//
//  Created by ????? on 06/02/12.
//  Copyright __MyCompanyName__ 2006 . All rights reserved.
//

#import "ATMailDocument.h"
#import "ATMailSpool.h"
#import "ATInternetMessageLineScanner.h"
#import "ATInternetMessage.h"
#import "ATTokenScanner.h"
#import "ATMailAccount.h"
#import "ATMailAccountWindowController.h"
#import "ATPop3Core.h"
#import "ATPop3MessageDownloader.h"
#import "ATMessageDownloaderWindowController.h"
#import "ATMailDocumentWindowController.h"
#import "ATFilterEditor.h"
#import "ATFilter.h"
#import "ATFilterEditorWindowController.h"

NSString *ATMaillDocumentType = @"mailDocument";

@implementation ATMailDocument

- (id)init
{
    self = [super init];
	
    if (self)
	{
		[self setMailSpool:[[ATMailSpool new] autorelease]];
    }
	
    return self;
}

- (void)dealloc
{
	[self setMailSpool:nil];
	
	[super dealloc];
}

- (void)makeWindowControllers
{
	if (initialPresentationSettings)
	{
		NSEnumerator *anEnumerator = [initialPresentationSettings objectEnumerator];
		id aPlist = nil;
		
		while (aPlist = [anEnumerator nextObject])
		{
			ATMailDocumentWindowController *aWindowController = [ATMailDocumentWindowController windowControllerWithMailSpoolModel:[ATMailSpoolModel modelWithMailSpool:[self mailSpool]]];
		
			[self addWindowController:aWindowController];
			[aWindowController setPropertyListRepresentation:aPlist];
		}
		
		[initialPresentationSettings release];
		initialPresentationSettings = nil;
	}
	else
	{
		ATMailDocumentWindowController *aWindowController = [ATMailDocumentWindowController windowControllerWithMailSpoolModel:[ATMailSpoolModel modelWithMailSpool:[self mailSpool]]];
		
		[self addWindowController:aWindowController];
		//[self addWindowController:[[ATMailDocumentWindowController new] autorelease]];
	}
}

- (void)setFileURL:(NSURL *)absoluteURL
{
	[super setFileURL:absoluteURL];
	
	[[self mailSpool] setMailDocumentPath:[absoluteURL path]];
}

- (BOOL)writeSafelyToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation error:(NSError **)outError
{
	return [self writeToURL:absoluteURL ofType:typeName error:outError];
}

- (BOOL)writeToURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	BOOL aTargetIsDir;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:[absoluteURL path] isDirectory:&aTargetIsDir] && aTargetIsDir)
	{
		if ([[self mailSpool] saveWithin:absoluteURL] && [self savePresentationSetting])
			return YES;
		else
		{
			*outError = [NSError errorWithDomain:@"ATMailErrorDomain" code:0 userInfo:nil];
			return NO;
		}
	}
	else
	{
		BOOL aMailDocumentFolderIsCreated = [[NSFileManager defaultManager] createDirectoryAtPath:[absoluteURL path] attributes:nil];
		BOOL aMailSpoolIsSaved;
		
		if (aMailDocumentFolderIsCreated)
		{
			aMailSpoolIsSaved = [[self mailSpool] saveWithin:absoluteURL];
		}

		return aMailDocumentFolderIsCreated && aMailSpoolIsSaved;
	}
}

/*
	メールスプール名（ドキュメントファイル（パッケージ））
		idPool（プロパティリスト）
		mailAccount（プロパティリスト）
		messages（メッセージフォルダ）
			...メッセージファイル
		headers（ヘッダーフォルダ）
			...ヘダーファイル
*/
- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{		
	BOOL aReadingSucceed;
	
	inReading = YES;
	aReadingSucceed = [[self mailSpool] loadWithin:absoluteURL] && [self loadPresentationSetting];
	inReading = NO;
	
	return aReadingSucceed;
}

- (void)openPanelDidEnd:(NSOpenPanel *)panel returnCode:(int)returnCode  contextInfo:(void  *)contextInfo
{
	if (returnCode == NSOKButton)
	{
		[[self mailSpool] importMessages:[panel filenames]];
		[self updateChangeCount:NSChangeDone];
	}
}

- (void)mailSpoolDidChange:(NSNotification *)aNotification
{
	if (!inReading)
		[self updateChangeCount:NSChangeDone];
}

- (void)shouldCloseWindowController:(NSWindowController *)windowController delegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
	NSArray *aMailDocumentWindowControllers = [self mailDocumentWindowControllers];
	
	if (([[self windowControllers] count] != 1) && ([aMailDocumentWindowControllers count] == 1) && [aMailDocumentWindowControllers containsObject:windowController])
	{
		NSInvocation *anInvocation = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:shouldCloseSelector]];
		BOOL aFlag = NO;
		
		[anInvocation setSelector:shouldCloseSelector];
		[anInvocation setArgument:&self atIndex:2];
		[anInvocation setArgument:&aFlag atIndex:3];
		[anInvocation setArgument:&contextInfo atIndex:4];
		
		[anInvocation invokeWithTarget:delegate];
	}
	else
		[super shouldCloseWindowController:windowController delegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}

/*- (void)canCloseDocumentWithDelegate:(id)delegate shouldCloseSelector:(SEL)shouldCloseSelector contextInfo:(void *)contextInfo
{
	if (YES)
		objc_msgSend(delegate, shouldCloseSelector, self, NO, contextInfo);
	else
		[super canCloseDocumentWithDelegate:delegate shouldCloseSelector:shouldCloseSelector contextInfo:contextInfo];
}*/

@end

@implementation ATMailDocument (Accessing)

- (ATMailSpool *)mailSpool
{
	return mailSpool;
}

- (void)setMailSpool:(ATMailSpool *)aMailSpool
{
	if (mailSpool != aMailSpool)
	{
		if (mailSpool)
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self];
		}
		
		[mailSpool autorelease];
		mailSpool = [aMailSpool retain];
		
		if (mailSpool)
		{
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSpoolDidChange:) name:ATMessageReadStatusDidChangeNotification object:mailSpool];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSpoolDidChange:) name:ATMailboxesDidChangeNotification object:mailSpool];
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mailSpoolDidChange:) name:ATFilterEditorDidChangeNotification object:mailSpool];
		}
	}
}

- (NSArray *)mailDocumentWindowControllers
{
	NSMutableArray *aWindowControllers = [NSMutableArray array];
	id aWindowController = nil;
	NSEnumerator *aWindowControllerEnumerator = [[self windowControllers] objectEnumerator];
	
	while (aWindowController = [aWindowControllerEnumerator nextObject])
	{
		if ([aWindowController isKindOfClass:[ATMailDocumentWindowController class]])
			[aWindowControllers addObject:aWindowController];
	}
	
	return aWindowControllers;
}

@end

@implementation ATMailDocument (Actions)

- (IBAction)showMailAccount:(id)sender
{
	NSEnumerator *enumerator = [[self windowControllers] objectEnumerator];
	id aWinCtrl = nil;
	
	while ((aWinCtrl = [enumerator nextObject]) && ![aWinCtrl isKindOfClass:[ATMailAccountWindowController class]]) 
		;
	
	if (!aWinCtrl)
	{
		aWinCtrl = [[ATMailAccountWindowController new] autorelease];
		[self addWindowController:aWinCtrl];
	}
		
	[aWinCtrl showWindow:nil];
}

- (IBAction)importMessages:(id)sender
{
	NSOpenPanel *anOPanel = [NSOpenPanel openPanel];
	
	[anOPanel setAllowsMultipleSelection:YES];
	[anOPanel beginSheetForDirectory:nil file:nil types:[NSArray arrayWithObject:@"txt"] modalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction)rebuildCacheHeader:(id)sender
{
	[[self mailSpool] rebuildCacheHeader];
}

- (IBAction)showFilterEditor:(id)sender
{
	ATFilterEditorWindowController *aWindowController = [ATFilterEditorWindowController filterEditorWindowControllerWith:[[self mailSpool] filterEditor]];
	
	[self addWindowController:aWindowController];
	[aWindowController showWindow:nil];
}

- (IBAction)addIsolatedMessagesToInbox:(id)sender
{
	[[self mailSpool] addIsolatedMessagesToInbox];
}

@end

@implementation ATMailDocument (DownloadingMessage)

- (IBAction)download:(id)sender
{
	ATMessageDownloaderWindowController *aWinCtrl = [[[ATMessageDownloaderWindowController alloc] initWith:[[self mailSpool] messageDownloader]] autorelease];
	
	[self addWindowController:aWinCtrl];
	[aWinCtrl showWindow:nil];
	
	[[self mailSpool] download];
}

- (IBAction)cancel:(id)sender
{
	[[[self mailSpool] messageDownloader] cancel];
}

- (BOOL)isDownloading
{
	return [[self mailSpool] isDownloading];
}

@end

@implementation ATMailDocument (SavingAndLoading)

- (NSString *)presentationSettingsFilePath
{
	return [[[self fileURL] path] stringByAppendingPathComponent:@"presentationSettings.plist"];
}

- (BOOL)savePresentationSetting
{
	NSEnumerator *anEnumerator = [[self windowControllers] objectEnumerator];
	id aWindowController = nil;
	NSMutableArray *aPresentationSettings = [NSMutableArray array];
	NSString *anErrorDescription = nil;
	NSData *aData = nil;
	
	while (aWindowController = [anEnumerator nextObject])
		[aPresentationSettings addObject:[aWindowController propertyListRepresentation]];
	
	aData = [NSPropertyListSerialization dataFromPropertyList:aPresentationSettings format:NSPropertyListXMLFormat_v1_0 errorDescription:&anErrorDescription];
	
	if (anErrorDescription)
	{
		[anErrorDescription release];
		anErrorDescription = nil;
		
		return NO;
	}
	else
		return [aData writeToFile:[self presentationSettingsFilePath] atomically:YES];
}

- (BOOL)loadPresentationSetting
{
	initialPresentationSettings = [[NSPropertyListSerialization propertyListFromData:[NSData dataWithContentsOfFile:[self presentationSettingsFilePath]] mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:nil] retain];
	
	return YES;
}	

@end