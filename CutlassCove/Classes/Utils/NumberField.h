//
//  NumberField.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 25/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPTextField.h"

@interface NumberField : SPTextField {
	uint mValue;
}

@property (nonatomic,assign) uint value;

@end
