//
//  GCShipDetails.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 30/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prisoner.h"

@interface GCShipDetails : NSObject <NSCoding> {
	int condition;
	NSMutableDictionary *prisoners;
}

+ (GCShipDetails *)gcShipDetails;

@property (nonatomic,assign) int condition;
@property (nonatomic,readonly) NSDictionary *prisoners;

- (void)addPrisoner:(Prisoner *)aPrisoner;
- (void)setPrisoners:(NSDictionary *)prisonerDict;

@end
