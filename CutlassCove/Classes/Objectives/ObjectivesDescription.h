//
//  ObjectivesDescription.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 6/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SHIP_TYPE_PLAYER_SHIP 0x1UL
#define SHIP_TYPE_PIRATE_SHIP 0x2UL
#define SHIP_TYPE_NAVY_SHIP 0x4UL
#define SHIP_TYPE_MERCHANT_SHIP 0x8UL
//#define SHIP_TYPE_VILLAIN_SHIP 0x10UL
//#define SHIP_TYPE_PINK_PEARL_SHIP 0x20UL
#define SHIP_TYPE_ESCORT_SHIP 0x40UL
#define SHIP_TYPE_TREASURE_FLEET 0x80UL
#define SHIP_TYPE_SILVER_TRAIN 0x100UL

@interface ObjectivesDescription : NSObject <NSCoding> {
    uint mKey;
    uint mCount;
    
    BOOL mFailed;
}

@property (nonatomic,assign) uint count;
@property (nonatomic,readonly) uint quota;
@property (nonatomic,readonly) uint key;
@property (nonatomic,assign) BOOL isFailed;
@property (nonatomic,readonly) BOOL isCumulative;
@property (nonatomic,readonly) BOOL isCompleted;
@property (nonatomic,readonly) NSString *description;
@property (nonatomic,readonly) NSString *logbookDescription;

- (id)initWithKey:(uint)key count:(uint)count;
- (id)initWithKey:(uint)key;

- (void)forceCompletion;
- (void)reset;

+ (ObjectivesDescription *)objectivesDescriptionWithKey:(uint)key count:(uint)count;
+ (ObjectivesDescription *)objectivesDescriptionWithKey:(uint)key;
+ (NSString *)descriptionTextForKey:(uint)key;
+ (NSString *)logbookDescriptionTextForKey:(uint)key;
+ (uint)quotaForKey:(uint)key;
+ (uint)valueForKey:(uint)key;
+ (BOOL)isCumulativeForKey:(uint)key;
+ (uint)requiredNpcShipTypeForKey:(uint)key;
+ (uint)requiredAshTypeForKey:(uint)key;

@end
