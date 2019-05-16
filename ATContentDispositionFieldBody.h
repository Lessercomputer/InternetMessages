//
//  ATContentDispositionFieldBody.h
//  ATMail
//
//  Created by 高田　明史 on 07/11/10.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATMIMETokenScanner;

@interface ATContentDispositionFieldBody : NSObject
{
	NSString *dispositionType;
	NSMutableDictionary *parameters;
}

- (id)initWith:(NSString *)aString;

- (NSString *)dispositionType;
- (NSMutableDictionary *)parameters;
- (NSString *)filename;
- (NSString *)stringValue;

- (NSString *)scanDispositionTypeFrom:(ATMIMETokenScanner *)aScanner;
- (NSMutableDictionary *)scanDispositionParametersFrom:(ATMIMETokenScanner *)aScanner;
- (BOOL)scanDispositionParmNameInto:(NSString **)aName valueInto:(NSString **)aValue from:(ATMIMETokenScanner *)aScanner;
- (BOOL)scanFilenameParmNameInto:(NSString **)aName valueInto:(NSString **)aValue from:(ATMIMETokenScanner *)aScanner;

@end
