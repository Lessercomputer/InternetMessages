//
//  ATOctetStreamRepresentation.h
//  ATMail
//
//  Created by 高田　明史 on 07/11/04.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ATOctetStreamRepresentation : NSObject
{
	NSData *data;
}

+ (id)representationWithOctets:(NSData *)anOctets;

- (id)initWithData:(NSData *)aData;

- (NSData *)data;

- (NSMutableAttributedString *)attributedString;

@end
