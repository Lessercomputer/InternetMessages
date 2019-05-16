//
//  ATTokenScanner.h
//  ATMail
//
//  Created by 高田　明史 on 06/03/18.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ATCFWS;
@class ATFWS;
@class ATComment;
@class ATCtext;
@class ATTimeOfDay;
@class ATGroup;
@class ATAddrSpec;
@class ATNameAddr;
@class ATAngleAddr;
@class ATMsgID;
@class ATEncodedWord;

@interface ATTokenScanner : NSObject
{
	NSScanner *scanner;
}

+ (NSCharacterSet *)wspSet;
+ (NSCharacterSet *)crSet;
+ (NSCharacterSet *)lfSet;
+ (NSCharacterSet *)textSet;
+ (NSCharacterSet *)utextSet;
+ (NSCharacterSet *)obsCharSet;
+ (NSCharacterSet *)obsCharSetExceptingWSP;
+ (NSCharacterSet *)atextSet;
+ (NSCharacterSet *)qtextSet;
+ (NSCharacterSet *)lfcrSet;
+ (NSCharacterSet *)dtextSet;
+ (NSCharacterSet *)alphaSet;
+ (NSCharacterSet *)ftextSet;
+ (NSCharacterSet *)ctextSet;

+ (BOOL)isUnstructured:(NSString *)aString;

+ (id)scannerWith:(NSString *)aString;
- (id)initWith:(NSString *)aString;

- (NSScanner *)scanner;
- (BOOL)isAtEnd;
- (NSString *)string;
- (unsigned)scanLocation;
- (void)setScanLocation:(unsigned)aLocation;

- (BOOL)scanString:(NSString *)aString intoString:(NSString **)aValue;
- (BOOL)scanCharactersFromSet:(NSCharacterSet *)aCharSet intoString:(NSString **)aString;

@end

@interface ATTokenScanner (PrimitiveTokens)

- (BOOL)scanTextInto:(NSString **)aText;
- (BOOL)scanObsTextInto:(NSString **)aText;
- (BOOL)scanObsTextInto:(NSString **)aText obsCharSet:(NSCharacterSet *)anObsCharSet;

@end

@interface ATTokenScanner (FoldingWhiteSpaceAndComments)

- (BOOL)skipFWS;
- (BOOL)scanFWSInto:(NSString **)aFWS;
- (BOOL)skipWSP;
- (BOOL)skipCRLF;
- (BOOL)peekCRLF;
- (BOOL)skipCtext;
- (BOOL)skipCcontent;
- (BOOL)skipComment;
- (BOOL)skipCFWS;
- (BOOL)scanCFWSInto:(ATCFWS **)aCFWS;
- (BOOL)scanFWSTokenInto:(ATFWS **)aFWS;
- (BOOL)scanCommentInto:(ATComment **)aComment;
- (BOOL)scanCtextInto:(ATCtext **)aCtext;
- (BOOL)scanCtextIntoToken:(id)aToken;
- (BOOL)scanFWSIntoToken:(id)aToken;
- (BOOL)scanCommentIntoToken:(id)aToken;
- (BOOL)scanCcontentIntoToken:(ATComment *)aComment;

@end

@interface ATTokenScanner (Atom)

- (BOOL)scanAtomInto:(NSString **)aWord;
- (BOOL)scanAtomExceptingCFWSInto:(NSString *)anAtom;
- (BOOL)scanDotAtomInto:(NSString **)aDotAtom;
- (BOOL)scanDotAtomTextInto:(NSString **)aDotAtom;

@end

@interface ATTokenScanner (QuotedStrings)

- (BOOL)scanQcontentInto:(NSString **)aQcontent;
- (BOOL)scanQtextInto:(NSString **)aQText;
- (BOOL)skipQuotedPair;
- (BOOL)scanQuotedPairInto:(NSString **)aText;
- (BOOL)scanQuotedStringInto:(NSString **)aQuotedString;
- (BOOL)scanQuotedStringExceptingCFWSInto:(NSString **)aQuotedString;
- (BOOL)scanQuotedPairIntoToken:(id)aToken;

@end

@interface ATTokenScanner (MiscellaneousTokens)

- (BOOL)scanWordInto:(NSString **)aWord;
- (BOOL)scanWordExceptingCFWSInto:(NSString **)aWord;
- (BOOL)scanPhraseInto:(NSString **)aPhrase;
- (BOOL)scanEncodedWordTokenInto:(id *)anEncodedWord;
- (BOOL)scanEncodedWordTokenIncludingCFWSInto:(ATEncodedWord **)anEncodedWord;
- (BOOL)scanEncodedWordTokenIncludingFWSInto:(ATEncodedWord **)anEncodedWord;
- (BOOL)scanEncodedWordTokenInto:(ATEncodedWord **)anEncodedWord enclosingSelector:(SEL)anEnclosingSelector terminatingSelector:(SEL)aTerminatingSelector;
- (BOOL)scanEncodedWordInto:(NSString **)aCharset into:(NSString **)anEncoding into:(NSString **)anEncodedText;
- (BOOL)scanCharsetInto:(NSString **)aCharset;
- (BOOL)scanEncodingInto:(NSString **)anEncoding;
- (BOOL)scanEncodedTextInto:(NSString **)anEncodedText;
- (BOOL)scanTokenOfEncodedWordInto:(NSString **)anEncodedWordToken;
- (BOOL)scanNoEmptyUnstructuredInto:(NSString **)aNoEmptyUnstructured;
- (BOOL)scanUnstructuredInto:(NSString **)anUnstructured;
- (BOOL)scanUtextInto:(NSString **)aUtext;
- (BOOL)scanObsUtextInto:(NSString **)aUtext;
//encoded-word用
- (BOOL)scanUTextExceptingFWSInto:(NSString **)aUTextExceptingFWS;
- (BOOL)scanObsUtextExceptingFWSInto:(NSString **)aUTextExceptingFWS;
- (BOOL)wordContinue;
- (BOOL)utextContinue;

@end

@interface ATTokenScanner (DateAndTimeSpecification)

- (BOOL)scanDateTimeInto:(NSCalendarDate **)aDateTime;
- (NSCalendarDate *)dateByYear:(NSString *)aYear month:(NSString *)aMonth day:(NSString *)aDay timeOfDay:(ATTimeOfDay *)aTimeOfDay timeZone:(NSString *)aZone;
- (int)secondsOfZone:(NSString *)aZone isValid:(BOOL *)aValid;
- (int)secondsOfObsZone:(NSString *)aZone isValid:(BOOL *)aValid;
- (unsigned)numberOfMonth:(NSString *)aMonth;
- (BOOL)scanTimeInto:(ATTimeOfDay **)aTimeOfDay into:(NSString **)aZone;
- (BOOL)scanZoneInto:(NSString **)aZone;
- (BOOL)scanObsZoneInto:(NSString **)aZone;
- (BOOL)scanTimeOfDayInto:(ATTimeOfDay **)aTimeOfDay ;
- (BOOL)scanHourInto:(int *)anHour;
- (BOOL)scanMinuteInto:(int *)aMinute;
- (BOOL)scanSecondInto:(int *)aSecond;
- (BOOL)scanTwoDigitInto:(NSString **)aTwoDigit;
- (BOOL)scanDigitInto:(NSString **)aDigit length:(unsigned)aLength;
- (BOOL)scanObsTwoDigitInto:(int *)aTwoDigit;
- (BOOL)scanDateInto:(NSString **)aDay into:(NSString **)aMonth into:(NSString **)aYear;
- (BOOL)scanDayInto:(NSString **)aDay;
- (BOOL)scanOneOrTwoDIGITInto:(NSString **)aDigit;
- (BOOL)scanYearInto:(NSString **)aYear;
- (BOOL)scanObsYearInto:(NSString **)aYear;
- (BOOL)scanMonthInto:(NSString **)aMonth;
- (BOOL)scanMonthNameInto:(NSString **)aMonth;
- (BOOL)scanObsMonthInto:(NSString **)aMonth;
- (BOOL)scanObsDayInto:(NSString **)aDay;
- (BOOL)scanDayOfWeekInto:(NSString **)aDayOfWeek;
- (BOOL)scanObsDayOfWeekInto:(NSString **)aDayOfWeek;
- (BOOL)scanDayNameInto:(NSString **)aDayOfWeek;

@end

@interface ATTokenScanner (AddressSpecification)

- (BOOL)scanAddressInto:(id *)anAddress;
- (BOOL)scanAddressListInto:(NSArray **)anAddressList;
- (BOOL)scanObsAddrListInto:(NSArray **)anAddressList;
- (BOOL)scanGroupInto:(ATGroup **)aGroup;
- (BOOL)scanGroupInto:(NSString **)aDisplayName into:(NSArray **)aMailboxList;
- (BOOL)scanMailboxListInto:(NSArray **)aMailboxList;
- (BOOL)scanObsMboxListInto:(NSArray **)aMailboxList;
- (BOOL)scanMailboxInto:(id *)aMailbox;
- (BOOL)scanAddrSpecInto:(ATAddrSpec **)anAddrSpec;
- (BOOL)scanAddrSpecInto:(NSString **)aLocalPart into:(NSString **)aDomain;
- (BOOL)scanNameAddrInto:(ATNameAddr **)aNameAddr;
- (BOOL)scanDisplayNameInto:(NSString **)aDisplayName ;
- (BOOL)scanAngleAddrInto:(ATAngleAddr **)anAngleAddr;
- (BOOL)scanObsAngleAddrInto:(ATAngleAddr **)anAngleAddr;
- (BOOL)skipObsRoute;
- (BOOL)skipObsDomainList;
- (BOOL)scanDomainInto:(NSString **)aDomain;
- (BOOL)scanDomainLiteralInto:(NSString **)aDomainLiteral;
- (BOOL)scanDcontentInto:(NSString **)aDcontent;
- (BOOL)scanDtextInto:(NSString **)aDtext;
- (BOOL)scanLocalPartInto:(NSString **)aLocalPart;
- (BOOL)scanObsLocalPartInto:(NSString **)aLocalPart;
- (BOOL)scanObsDomainInto:(NSString **)aDomain;

@end

@interface ATTokenScanner (IdentificationFields)

- (BOOL)scanMsgIDInto:(ATMsgID **)aMsgID;
- (BOOL)scanMsgIDInto:(NSString **)anIDLeft into:(NSString **)anIDRight;
- (BOOL)scanIDLeftInto:(NSString **)anIDLeft;
- (BOOL)scanNoFoldQuoteInto:(NSString **)aNoFoldQuote;
- (BOOL)scanObsIDLeftInto:(NSString **)anIDLeft;
- (BOOL)scanIDRightInto:(NSString **)anIDRight;
- (BOOL)scanNoFoldLiteralInto:(NSString **)aNoFoldLiteral;
- (BOOL)scanObsIDRightInto:(NSString **)anIDRight;

@end

@interface ATTokenScanner (ResentFields)

- (BOOL)scanPathInto:(id *)aPath;
- (BOOL)scanNameValListInto:(NSDictionary **)aNameValList;
- (BOOL)scanNameValPairInto:(NSString **)anItemName into:(id *)anItemValue;
- (BOOL)scanItemNameInto:(NSString **)anItemName;
- (BOOL)scanItemValueInto:(id *)anItemValue;

@end