//
//  MessageCloud.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 5/10/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

#define CUST_EVENT_TYPE_MSG_CLOUD_NEXT @"msgCloudNextEvent"
#define CUST_EVENT_TYPE_MSG_CLOUD_CHOICE @"msgCloudChoiceEvent"
#define CUST_EVENT_TYPE_MSG_CLOUD_DISMISSED @"msgCloudDismissedEvent"

#define kMsgCloudStateNull 0
#define kMsgCloudStateNext 1
#define kMsgCloudStateAye 2
#define kMsgCloudStateChoice 3
#define kMsgCloudStateClosing 4


@interface MessageCloud : Prop {
	int mState;
	int mDir;
	BOOL mChoice;
	SPTextField *mText;
	SPButton *mButtonLeft;
	SPButton *mButtonRight;
}

@property (nonatomic,assign) int state;
@property (nonatomic,readonly) BOOL choice;

- (id)initWithCategory:(int)category x:(float)x y:(float)y dir:(int)dir;
- (id)initWithCategory:(int)category dir:(int)dir;
- (void)setMessageText:(NSString *)text;
- (void)dismissOverTime:(float)time;
- (void)dismissInstantly;

@end
