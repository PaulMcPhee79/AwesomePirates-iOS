//
//  StaticFactory.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 7/09/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>

class ActorDef;

@interface StaticFactory : NSObject {

}

+ (StaticFactory *)staticFactory;
- (ActorDef *)createBeachActorDef;
- (ActorDef *)createTownActorDef;

@end
