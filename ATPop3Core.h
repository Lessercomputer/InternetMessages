//
//  ATPop3Core.h
//  ATMail
//
//  Created by 高田　明史 on 06/09/10.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATMailAccount;

@interface ATPop3Core : NSObject
{
	ATMailAccount *account;
	NSString *lineFragment;
	SEL selectorToInterpret;
	NSOutputStream *outputStream;
	NSInputStream *inputStream;
	id delegate;
	NSString *command;
	NSMutableDictionary *uidDic;
	BOOL isCanceled;
	BOOL logging;
	BOOL isRunning;
	NSLock *cancelLock;
	NSLock *runLock;
}

- (id)initWith:(ATMailAccount *)anAccount with:(id)aDelegate;

- (BOOL)logging;
- (void)setLogging:(BOOL)aFlag;

- (BOOL)isCanceled;
- (BOOL)isRunning;

@end

@interface ATPop3Core (Controlling)

- (void)start;
- (void)cancel;

- (void)prepareRetrFor:(NSString *)aUID;
- (void)prepareQuit;

@end

@interface ATPop3Core (StreamHandling)

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode;
- (void)handleInputStreamEvent:(NSStreamEvent)eventCode;
- (void)handleOutputStreamEvent:(NSStreamEvent)eventCode;

- (void)openStreams;
- (void)closeStreams;

- (NSString *)readResponse;
- (void)receive:(NSString *)aResponse;
- (void)logResponse:(NSArray *)aLines;

@end

@interface ATPop3Core (CommandSending)

- (void)authorize;
- (void)uidl;
- (void)retrFor:(NSString *)aUID;
- (void)quit;

- (void)prepareCommand:(NSString *)aCommand;
- (void)send:(NSString *)aCommand;
- (void)writeCommandIfPossible;

- (NSString *)command;
- (void)setCommand:(NSString *)aString;
- (NSString *)lineFragment;
- (void)setLineFragment:(NSString *)aString;
- (NSString *)decodeByteStuff:(NSString *)aString;
- (NSArray *)divideLines:(NSString *)aString;

@end

@interface ATPop3Core (Interpreting)

- (void)interpretGreeting:(NSArray *)aLines;
- (void)interpretUser:(NSArray *)aLines;
- (void)interpretPass:(NSArray *)aLines;
- (void)interpretUIDLStatusIndicator:(NSArray *)aLines;
- (void)interpretUIDL:(NSArray *)aLines;
- (void)interpretRetrStatusIndicator:(NSArray *)aLines;
- (void)interpretRetr:(NSArray *)aLines;
- (void)interpretQuit:(NSArray *)aLines;

@end
