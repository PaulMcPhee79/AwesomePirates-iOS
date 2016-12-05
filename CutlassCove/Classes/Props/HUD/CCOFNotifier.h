//
//  CCOFNotifier.h
//  CutlassCove
//
//  Created by Paul McPhee on 14/02/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface CCOFNotification : NSObject {
    double mDelay;
    double mDuration;
    NSString *mNotification;
}

@property (nonatomic,readonly) double delay;
@property (nonatomic,readonly) double duration;
@property (nonatomic,readonly) NSString *notification;

- (id)initWithNotification:(NSString *)notification delay:(double)delay duration:(double)duration;

@end


@interface CCOFNotifier : Prop {
    BOOL mIsBusy;
    float mNotificationDuration;
    
    SPImage *mIcon;
    SPTextField *mNotice;
    SPSprite *mCanvas;
    
    NSMutableArray *mNoticeQueue;
}

- (id)initWithCategory:(int)category notificationDuration:(float)notificationDuration;
- (void)setIconTexture:(SPTexture *)texture;
- (void)addNotification:(NSString *)notification;
- (void)addNotification:(NSString *)notification delay:(double)delay duration:(double)duration;
- (void)pumpNotificationQueue;
- (void)clearNotificationQueue;

@end
