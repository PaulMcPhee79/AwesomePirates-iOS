//
//  Game.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 4/09/10.
//  Copyright Cheeky Mammoth 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CutlassCoveViewController,CCOFManager;

@interface Game : SPStage

- (void)setupWithViewController:(CutlassCoveViewController *)viewController ofDelegate:(CCOFManager *)ofDelegate;
- (void)pausePirates;
- (void)propagateMemoryWarning;
- (void)applicationWillTerminate;

@end
