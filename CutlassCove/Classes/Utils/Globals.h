//
//  Globals.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ElementExpiredEvent.h"
#import "SPUtils.h"

//#define RANDOM_SEED() srand(time(NULL))
//#define RANDOM_INT(min,max) ((min) + rand() % (((max) + 1) - (min)))
#define RANDOM_SEED()
#define RANDOM_INT(min,max) ([SPUtils randomIntBetweenMin:(min) andMax:(max)+1]) // +1 to max to make it inclusive
#define SCREEN_WIDTH 480.0f
#define SCREEN_HEIGHT 285.0f // 320.0f - railing height

// Crowd-control Ashes
#define ASH_SPELL_ACID_POOL (1UL<<0)
#define ASH_SPELL_MAGMA_POOL (1UL<<1)

// Crowd-control Ash Proc durations
#define ASH_DURATION_ACID_POOL (20.0f + VOODOO_DESPAWN_DURATION)
#define ASH_DURATION_MAGMA_POOL (20.0f + VOODOO_DESPAWN_DURATION)

// ---- Sprite Layer Categories ----

// These categories are arranged as a flat array of children. They are not X layers deep. So no matter how many categories in any enum, we are only using
// a single layer of the display list's tree depth (SP_MAX_DISPLAY_TREE_DEPTH), which is defined as 16 in "SPMacros.h".
typedef enum {
	CAT_PF_SEA = 0,  // Submerged, water
    CAT_PF_WAKES,
	CAT_PF_WAVES,
	CAT_PF_SURFACE,
	CAT_PF_LAND,			// Combine with Waves
	CAT_PF_SHOREBREAK,		// Combine with Waves
	CAT_PF_BUILDINGS,		// Combine with Waves
	CAT_PF_PICKUPS,			// Combine with Waves
	CAT_PF_POINT_MOVIES,	
	CAT_PF_SHIPS,
	CAT_PF_EXPLOSIONS,
	CAT_PF_DIALOGS,
	CAT_PF_CLOUD_SHADOWS,
	CAT_PF_CLOUDS,			// Can combine with shadows if we have a pool of clouds already added to the scene but just invisible and ready to go
    CAT_PF_COMBAT_TEXT,
	CAT_PF_DECK,
	CAT_PF_HUD
} PlayfieldCategory;

typedef enum {
	CAT_COVE_BACKGROUND = 0,
	CAT_COVE_BASE,
	CAT_COVE_UI,
	CAT_COVE_BOTTLES,
	CAT_COVE_MUSKETS,
	CAT_COVE_OVERLAY,
	CAT_COVE_HELP,
	CAT_COVE_ACHIEVEMENTS,
	CAT_COVE_BLINDS
} CoveCategory;

typedef enum {
	CAT_TITLE_BASE = 0,
	CAT_TITLE_LEVEL_1,
	CAT_TITLE_LEVEL_2
} TitleCategory;

typedef enum {
	CAT_LOADING_ALL = 0
} LoadingCategory;

// ---- End Sprite Layer Categories ----

// ------- Collision Group/Category Indexes -------

// Must fit within an int16 datatype
#define CGI_PLAYER_EXCLUDED -1
#define CGI_ENEMY_EXCLUDED -2
#define CGI_CANNONBALLS -3

// Must fit within a uint16 datatype
#define COL_BIT_DEFAULT 0x0001
#define COL_BIT_PLAYER_SHIP_HULL 0x0002
#define COL_BIT_NPC_SHIP_HULL 0x0004
#define COL_BIT_NPC_SHIP_FEELER 0x0008
#define COL_BIT_NPC_SHIP_DEFENDER 0x0010
#define COL_BIT_CANNONBALL_CORE 0x0020
#define COL_BIT_CANNONBALL_CONE 0x0040
#define COL_BIT_VOODOO 0x0080
#define COL_BIT_OVERBOARD 0x0100
#define COL_BIT_SHARK 0x0200
#define COL_BIT_PLAYER_BUFF 0x0400
#define COL_BIT_NPC_SHIP_STERN 0x0800

// ------- End Collision Group/Category Indexes -------

// ------ Misc -------
typedef enum {
	PortSide = 0,
	StarboardSide
} ShipSides;
// ------ End Misc -------

@interface Globals : NSObject {
	NSMutableDictionary *mPlists;
}

+ (NSDictionary *)voodooAudioForKeys:(uint)keys sceneName:(NSString *)sceneName;
- (id)plistForKey:(NSString *)key;
- (void)setPlist:(id)plist forKey:(NSString *)key;

+ (Globals *)sharedGlobals;
+ (float)angleBetweenAngle:(float)src toAngle:(float)dest;
+ (SPPoint *)centerPoint:(SPRectangle *)bounds;
+ (void)rotatePoint:(SPPoint *)point throughAngle:(float)angle;
+ (NSDictionary *)loadPlist:(NSString *)fileName;
+ (NSArray *)loadPlistArray:(NSString *)fileName;
+ (float)vecLengthX:(float)x y:(float)y;
+ (float)vecLengthSquaredX:(float)x y:(float)y;
+ (float)normalize:(SPPoint *)vec;
+ (double)diminishedReturnsForValue:(double)value scale:(double)scale;
+ (BOOL)isWithinScreenBounds:(float)x y:(float)y;
+ (NSString *)commaSeparatedInteger:(int)value showSign:(BOOL)showSign;
+ (NSString *)commaSeparatedValue:(uint)value;
+ (NSString *)commaSeparatedScore:(int64_t)value;
+ (NSString *)formatElapsedTime:(double)time;

+ (SPTexture *)foldoutTexture:(SPTexture *)texture settings:(uint)settings;
+ (SPTexture *)wholeTextureFromQuarter:(SPTexture *)texture;
+ (SPTexture *)wholeTextureFromHalfHoriz:(SPTexture *)texture;
+ (SPTexture *)wholeTextureFromHalfVert:(SPTexture *)texture;
+ (SPTexture *)repeatedTexture:(SPTexture *)texture width:(float)width height:(float)height;
+ (SPTexture *)repeatedTexture:(SPTexture *)texture width:(float)width height:(float)height boldness:(int)boldness;
+ (SPTexture *)debugTexture;

@end
