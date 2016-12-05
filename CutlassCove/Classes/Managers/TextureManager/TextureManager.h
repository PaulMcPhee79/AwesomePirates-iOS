//
//  TextureManager.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 10/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define TM_EXC_INVALID_ATLAS_RELEASE @"AtlasInUse"
#define TM_EXC_ATLAS_CHECKIN_EXCEEDED @"AtlasCheckinExceeded"

#define TM_CACHE_ALL_TEX_GROUP_NAME @"__TM_Reserved_Tex__"
#define TM_CACHE_ALL_ANIM_GROUP_NAME @"__TM_Reserved_Anim__"

#define TM_FLAG_CACHE_ALL_TEX 0x1UL
#define TM_FLAG_CACHE_ALL_ANIM 0x2UL
#define TM_FLAG_PERSISTENT_ATLAS 0x4UL
#define TM_FLAG_PERMANENT_ATLAS 0x8UL

#define TM_CACHE_CANNONBALLS @"Cannonballs"
#define TM_CACHE_PF_SHIPS @"PfShips"
#define TM_CACHE_POINT_MOVIES @"PointMovie"
#define TM_CACHE_SHIP_WAKES @"ShipWakes"
#define TM_CACHE_LOOT_PROPS @"LootProps"
#define TM_CACHE_BLAST_PROPS @"BlastProps"
#define TM_CACHE_SHARK @"Shark"
#define TM_CACHE_ENVIRONMENT @"Enviro"
#define TM_CACHE_VOODOO @"Voodoo"

typedef enum 
{
	TMMemModeConservative,
	TMMemModeLiberal
} TMMemMode;

@interface AtlasCheckout : NSObject
{
	NSString *mCategory;
	NSString *mName;
	int mFlags;
	uint mCheckoutCount;
	SPTextureAtlas *mAtlas;
	NSMutableDictionary *mTextureCacheGroups;
	NSMutableDictionary *mAnimCacheGroups;
}

@property (nonatomic,readonly) NSString *category;
@property (nonatomic,readonly) NSString *name;
@property (nonatomic,assign) int flags;
@property (nonatomic,readonly) uint checkoutCount;
@property (nonatomic,readonly) SPTextureAtlas *atlas;

- (id)initWithCategory:(NSString *)category name:(NSString *)name path:(NSString *)path;
- (void)checkout;
- (void)checkin;
- (void)clearTextureCacheGroup:(NSString *)groupName;
- (void)clearAnimCacheGroup:(NSString *)groupName;
- (SPTexture *)textureByName:(NSString *)name;
- (SPTexture *)textureByName:(NSString *)name cacheGroup:(NSString *)groupName;
- (NSArray *)texturesStartingWith:(NSString *)name;
- (NSArray *)texturesStartingWith:(NSString *)name cacheGroup:(NSString *)groupName;

@end



@interface TextureManager : NSObject
{
	TMMemMode mMemoryMode;
	BOOL mDebugEnabled;
	NSMutableDictionary *mCheckouts; // Dictionary of dictionaries of AtlasCheckouts. (Keychain: Category->AtlasName->[CacheGroup]->TextureName)
	NSMutableDictionary *mTextureCache;
	NSMutableSet *mQueuedCheckouts;
	NSMutableSet *mPersistentCheckouts;
	NSMutableSet *mPermanentCheckouts;
	SPView *mView;
}

@property (nonatomic,assign) TMMemMode memoryMode;
@property (nonatomic,assign) BOOL debugEnabled;

- (id)initWithView:(SPView *)view;
- (id)initWithView:(SPView *)view memoryMode:(TMMemMode)mode;

// Texture Cache
- (SPTexture *)cachedTextureByName:(NSString *)name;
- (void)cacheTexture:(SPTexture *)texture byName:(NSString *)name;
- (void)emptyTextureCache;


// Textures ("_TMShared_" is a reserved category that is included in all lookups)
- (SPTexture *)textureByName:(NSString *)name category:(NSString *)category;
- (SPTexture *)textureByName:(NSString *)name atlasName:(NSString *)atlasName category:(NSString *)category;
- (SPTexture *)textureByName:(NSString *)name cacheGroup:(NSString *)groupName category:(NSString *)category;
- (SPTexture *)textureByName:(NSString *)name atlasName:(NSString *)atlasName cacheGroup:(NSString *)groupName category:(NSString *)category;
- (NSArray *)texturesStartingWith:(NSString *)name category:(NSString *)category;
- (NSArray *)texturesStartingWith:(NSString *)name atlasName:(NSString *)atlasName category:(NSString *)category;
- (NSArray *)texturesStartingWith:(NSString *)name cacheGroup:(NSString *)groupName category:(NSString *)category;
- (NSArray *)texturesStartingWith:(NSString *)name atlasName:(NSString *)atlasName cacheGroup:(NSString *)groupName category:(NSString *)category;

// Atlases
- (SPTextureAtlas *)atlasByName:(NSString *)name category:(NSString *)category;
- (void)setFlags:(int)flags forAtlasNamed:(NSString *)name inCategory:(NSString *)category;

// Sync
- (void)checkoutAtlasByName:(NSString *)name category:(NSString *)category;
- (void)checkoutAtlasByName:(NSString *)name path:(NSString *)path category:(NSString *)category;

// Async
// Example callback selector form: (void)onAtlasLoaded:(NSString *)atlasName errorMsg:(NSString *)errorMsg;
- (void)checkoutAtlasByName:(NSString *)name category:(NSString *)category caller:(id)caller callback:(NSString *)callback;
- (void)checkoutAtlasByName:(NSString *)name path:(NSString *)path category:(NSString *)category caller:(id)caller callback:(NSString *)callback;

// Sync
- (void)checkinAtlasByName:(NSString *)name category:(NSString *)category;
- (void)purgeAtlasNamed:(NSString *)name category:(NSString *)category;
- (void)purgeAtlases;
- (void)purgeUnusedAtlases;
- (void)purgePersistentAtlases;

@end
