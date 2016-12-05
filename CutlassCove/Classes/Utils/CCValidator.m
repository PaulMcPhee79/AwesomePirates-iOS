//
//  CCValidator.m
//  CutlassCove
//
//  Created by Paul McPhee on 29/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CCValidator.h"
#import "GameController.h"

@interface CCValidator ()

+ (int)validityScoreForSingularObject:(NSObject *)obj;
+ (int)validityScoreForArray:(NSArray *)array;
+ (int)validityScoreForDictionary:(NSDictionary *)dict;

@end


@implementation CCValidator

+ (int)validityScoreForSingularObject:(NSObject *)obj {
    int score = 0;
    
    if ([obj isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)obj;
        score += [str length];
    } else if ([obj isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)obj;
        score += (int)(1000 *[number floatValue]);
        
        /*
        CFNumberType type = CFNumberGetType((CFNumberRef)number);
        
        if (type == kCFNumberFloat32Type || type == kCFNumberFloat64Type || type == kCFNumberFloatType || type == kCFNumberDoubleType || type == kCFNumberCGFloatType)
            score += (int)(1000 * [number floatValue]);
        else
            score += (int)(1000 * [number intValue]);
         */
    }
    
    return score;
}

+ (int)validityScoreForArray:(NSArray *)array {
    int score = 0;
    
    for (NSObject *obj in array) {
        if ([obj isKindOfClass:[NSDictionary class]])
            score += [CCValidator validityScoreForDictionary:(NSDictionary *)obj];
        else if ([obj isKindOfClass:[NSArray class]])
            score += [CCValidator validityScoreForArray:(NSArray *)obj];
        else
            score += [CCValidator validityScoreForSingularObject:obj];
    }
    
    return score;
}

+ (int)validityScoreForDictionary:(NSDictionary *)dict {
    int score = 0;
    
    for (NSString *key in dict) {
        NSObject *obj = (NSObject *)[dict objectForKey:key];
        
        if ([obj isKindOfClass:[NSDictionary class]])
            score += [CCValidator validityScoreForDictionary:(NSDictionary *)obj];
        else if ([obj isKindOfClass:[NSArray class]])
            score += [CCValidator validityScoreForArray:(NSArray *)obj];
        else
            score += [CCValidator validityScoreForSingularObject:obj];
    }
    
    return score;
}

+ (BOOL)isValidScore:(int)score validators:(NSArray *)validators {
    BOOL isValid = NO;
    
    for (NSNumber *number in validators) {
        if ([number intValue] == score) {
            isValid = YES;
            break;
        }
    }
        
    return isValid;
}

+ (BOOL)isDataValidForDictionary:(NSDictionary *)data validators:(NSDictionary *)validators {
    BOOL isValid = (data.count == validators.count);
    
    for (NSString *key in data) {
        if (isValid == NO)
            break;
        
        int score = 0;
        NSObject *obj = (NSObject *)[data objectForKey:key];
        
        if ([obj isKindOfClass:[NSDictionary class]])
            score = [CCValidator validityScoreForDictionary:(NSDictionary *)obj];
        else if ([obj isKindOfClass:[NSArray class]])
            score = [CCValidator validityScoreForArray:(NSArray *)obj];
        else
            score = [CCValidator validityScoreForSingularObject:obj];
        
        NSNumber *validator = (NSNumber *)[validators objectForKey:key]; 
        isValid = (validator && [validator intValue] == score);
    }
    
    return isValid;
}

+ (void)printValidatorsForDictionary:(NSDictionary *)data categoryName:(NSString *)categoryName {
    NSLog(@" ");
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    NSLog(@"Validators for %@", categoryName);
    
    for (NSString *key in data) {
        int score = 0;
        NSObject *obj = (NSObject *)[data objectForKey:key];
        
        if ([obj isKindOfClass:[NSDictionary class]])
            score = [CCValidator validityScoreForDictionary:(NSDictionary *)obj];
        else if ([obj isKindOfClass:[NSArray class]])
            score = [CCValidator validityScoreForArray:(NSArray *)obj];
        else
            score = [CCValidator validityScoreForSingularObject:obj];
        
        NSLog(@"%u, %@", score, key);
    }
    
    NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
}

+ (BOOL)isDataValidForArray:(NSArray *)data validators:(NSArray *)validators {
    BOOL isValid = (data.count == validators.count);
    int index = 0;
    
    for (NSObject *obj in data) {
        if (isValid == NO)
            break;
        
        int score = 0;
        
        if ([obj isKindOfClass:[NSDictionary class]])
            score = [CCValidator validityScoreForDictionary:(NSDictionary *)obj];
        else if ([obj isKindOfClass:[NSArray class]])
            score = [CCValidator validityScoreForArray:(NSArray *)obj];
        else
            score = [CCValidator validityScoreForSingularObject:obj];
        
        isValid = (score == [[validators objectAtIndex:index] intValue]);
        ++index;
    }
    
    return isValid;
}

+ (void)printValidatorsForArray:(NSArray *)data categoryName:(NSString *)categoryName {
    NSLog(@" ");
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    NSLog(@"Validators for %@", categoryName);
    
    for (NSObject *obj in data) {
        int score = 0;
        
        if ([obj isKindOfClass:[NSDictionary class]])
            score = [CCValidator validityScoreForDictionary:(NSDictionary *)obj];
        else if ([obj isKindOfClass:[NSArray class]])
            score = [CCValidator validityScoreForArray:(NSArray *)obj];
        else
            score = [CCValidator validityScoreForSingularObject:obj];
        
        NSLog(@"%u", score);
    }
    
    NSLog(@"<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
}

+ (void)reportInvalidData {
    [GCTRL invalidGameDataWasFound];
}

@end
