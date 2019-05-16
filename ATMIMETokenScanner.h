//
//  ATMIMETokenScanner.h
//  ATMail
//
//  Created by çÇìcÅ@ñæéj on 06/09/21.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "ATTokenScanner.h"

@class ATHeaderField;

@interface ATMIMETokenScanner : ATTokenScanner
{
}

+ (NSArray *)ianaToken;

@end

@interface ATMIMETokenScanner (ScaningTokens)

- (BOOL)scanParametersInto:(NSDictionary **)aParameters;
- (BOOL)scanParameterInto:(NSString **)anAttribute into:(NSString **)aValue;
- (BOOL)scanAttributeInto:(NSString **)anAttribute;
- (BOOL)scanValueInto:(NSString **)aValue;
- (BOOL)scanTokenInto:(NSString **)aToken;
- (BOOL)scanTypeInto:(NSString **)aType;
- (BOOL)scanSubtypeInto:(NSString **)aType;
- (BOOL)scanIetfTokenInto:(NSString **)anIetfToken;
- (BOOL)scanIANATokenInto:(NSString **)aType;
- (BOOL)scanStringListedIn:(NSArray *)aStringList into:(NSString **)aString;
- (BOOL)scanDiscreteTypeInto:(NSString **)aType;
- (BOOL)scanCompositeTypeInto:(NSString **)aType;
- (BOOL)scanExtensionTokenInto:(NSString **)aType;
- (BOOL)scanXTokenInto:(NSString **)aType;

@end

@interface ATMIMETokenScanner (ScaningFields)

- (BOOL)scanMIMEVersionFieldValueInto:(NSString **)aVersion1 into:(NSString **)aVersion2;
- (BOOL)scanContentTypeFieldValueInto:(NSString **)aType into:(NSString **)aSubtype into:(NSDictionary **)aParameters;
- (BOOL)scanContentTransferEncodingFieldValueInto:(NSString *)aMechanism;
- (BOOL)scanContentIDFieldValueInto:(ATMsgID **)aContentID;
- (BOOL)scanContentDescriptionFieldValueInto:(NSString **)aContentDescription;

@end
