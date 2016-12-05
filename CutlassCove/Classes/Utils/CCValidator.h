//
//  CCValidator.h
//  CutlassCove
//
//  Created by Paul McPhee on 29/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCValidator : NSObject

+ (BOOL)isDataValidForDictionary:(NSDictionary *)data validators:(NSDictionary *)validators;
+ (void)printValidatorsForDictionary:(NSDictionary *)data categoryName:(NSString *)categoryName;

+ (BOOL)isDataValidForArray:(NSArray *)data validators:(NSArray *)validators;
+ (void)printValidatorsForArray:(NSArray *)data categoryName:(NSString *)categoryName;

+ (void)reportInvalidData;

@end
