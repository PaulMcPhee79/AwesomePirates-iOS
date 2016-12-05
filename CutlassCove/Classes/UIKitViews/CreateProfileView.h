//
//  CreateProfileView.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 29/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CreateProfileView : UIView {
	UITextField	*mProfileNameTextfield;
}

@property (nonatomic,readonly) NSString *profileName;

- (void)setupView;

@end
