//
//  NSDictionary_Extension.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 9/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (Extension)

- (NSComparisonResult)compare_CHEEKY:(NSDictionary *)aDictionary;
- (NSDictionary *)dictionaryByMerging_CHEEKY:(NSDictionary *)dict1 with:(NSDictionary *)dict2;

/*
+ (NSDictionary *)dictionaryByMerging_CHEEKY:(NSDictionary *)dict1 with:(NSDictionary *)dict2;
- (NSDictionary *)dictionaryByMergingWith_CHEEKY:(NSDictionary *)dict;
*/

@end
