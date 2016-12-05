//
//  GCAiKnob.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 31/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameController.h"

@interface GCAiKnob : NSObject <NSCoding> {
	AiKnob aiKnob;
}

@property (nonatomic,assign) AiKnob aiKnob;

+ (GCAiKnob *)gcAiKnob;

@end
