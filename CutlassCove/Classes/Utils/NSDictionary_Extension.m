//
//  NSDictionary_Extension.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 9/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import "NSDictionary_Extension.h"


@implementation NSDictionary (Extension)

- (NSComparisonResult)compare_CHEEKY:(NSDictionary *)aDictionary {
	NSComparisonResult result;
	NSString *key = @"sort";
	
	int price = [(NSNumber *)[self objectForKey:key] intValue];
	int aPrice = [(NSNumber *)[aDictionary objectForKey:key] intValue];
	
	if (price < aPrice)
		result = NSOrderedAscending;
	else if (price > aPrice)
		result = NSOrderedDescending;
	else
		result = NSOrderedSame;
	return result;
}

- (NSDictionary *)dictionaryByMerging_CHEEKY:(NSDictionary *)dict1 with:(NSDictionary *)dict2 {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dict1];
	
	for (NSString *key in dict2) {
		id objDict1 = [dict1 objectForKey:key];
		id obj = [dict2 objectForKey:key];
		
		if ([obj isKindOfClass:[NSDictionary class]] && objDict1) {
			if ([objDict1 isKindOfClass:[NSDictionary class]]) {
				NSDictionary *newVal = [(NSDictionary *)objDict1 dictionaryByMerging_CHEEKY:objDict1 with:(NSDictionary *)obj];
				[result setObject:newVal forKey:key];
			}
		} else if (objDict1 == nil) {
			[result setObject:obj forKey:key];
		}
	}
	
	return (NSDictionary *)[[result mutableCopy] autorelease];
}

/*
+ (NSDictionary *)dictionaryByMerging_CHEEKY:(NSDictionary *)dict1 with:(NSDictionary *)dict2 {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:dict1];
	
	[dict2 enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		id objDict1 = [dict1 objectForKey:key];
		
		if ([obj isKindOfClass:[NSDictionary class]] && objDict1) {
			if ([objDict1 isKindOfClass:[NSDictionary class]]) {
				NSDictionary *newVal = [(NSDictionary *)objDict1 dictionaryByMergingWith_CHEEKY:(NSDictionary *)obj];
				[result setObject:newVal forKey:key];
			}
		} else if (objDict1 == nil) {
			[result setObject:obj forKey:key];
		}
	}];
	
	return (NSDictionary *)[[result mutableCopy] autorelease];
}

- (NSDictionary *)dictionaryByMergingWith_CHEEKY:(NSDictionary *)dict {
	return [[self class] dictionaryByMerging_CHEEKY:self with:dict];
}
*/

@end
