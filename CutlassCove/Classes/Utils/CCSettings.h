/*
 *  CCSettings.h
 *  xyzCCTestingxyz
 *
 *  Created by Paul McPhee on 27/10/11.
 *  Copyright 2011 Cheeky Mammoth. All rights reserved.
 *
 */

//#define DISABLE_MEMORY_POOLING

// Game Modes
#ifdef CHEEKY_LITE_VERSION
    #define CC_GAME_MODE_DEFAULT @"CCLBID.HallOfInfamyLite"
#else
    #define CC_GAME_MODE_DEFAULT @"CCLBID.HallOfInfamy"
#endif 

#define CC_GAME_MODE_SPEED_DEMONS @"CCLBID.SpeedDemons"

// Default user-visible strings
#define CC_ALIAS_DEFAULT @"DefaultPlayer"
