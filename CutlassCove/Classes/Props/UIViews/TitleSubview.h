//
//  TitleSubview.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 23/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuDetailView.h"


@interface TitleSubview : MenuDetailView {
	SPPoint *mClosePosition;
	NSString *mCloseSelectorName;
}

@property (nonatomic,retain) SPPoint *closePosition;
@property (nonatomic,copy) NSString *closeSelectorName;

+ (TitleSubview *)titleSubviewWtihCategory:(int)category;

@end
