//
//  MenuDetailsView.h
//  Pirates
//
//  Created by Paul McPhee on 24/08/10.
//  Copyright 2010 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prop.h"

@interface MenuDetailView : Prop {
	NSMutableDictionary *mMutableLabels;
	NSMutableDictionary *mLabelArrays;
	NSMutableDictionary *mMutableImages;
	NSMutableDictionary *mButtons;
	NSMutableDictionary *mMutableSprites;
	NSMutableArray *mMiscProps;
    NSMutableArray *mFlipProps;
    NSMutableArray *mLoopingTweens;
}

@property (nonatomic,readonly) NSMutableDictionary *mutableLabels;
@property (nonatomic,readonly) NSMutableDictionary *labelArrays;
@property (nonatomic,readonly) NSMutableDictionary *mutableImages;
@property (nonatomic,readonly) NSMutableDictionary *buttons;
@property (nonatomic,readonly) NSMutableDictionary *mutableSprites;
@property (nonatomic,readonly) NSMutableArray *miscProps;
@property (nonatomic,readonly) NSMutableArray *loopingTweens;

- (void)deconstruct;
- (SPDisplayObject *)controlForKey:(NSString *)key;
- (NSArray *)controlArrayForKey:(NSString *)key;
- (void)setControl:(SPDisplayObject *)control forKey:(NSString *)key;
- (void)removeControl:(SPDisplayObject *)control forKey:(NSString *)key;
- (void)setControlArray:(NSArray *)array forKey:(NSString *)key;
- (void)removeControlArrayForKey:(NSString *)key;
- (void)setTexture:(NSString *)textureName forKey:(NSString *)key;
- (void)setText:(NSString *)text forKey:(NSString *)key;
- (void)setTextIndex:(int)index forKey:(NSString *)key;
- (void)setRepeatingTexture:(NSString *)textureName repeats:(int)repeats forKey:(NSString *)key;
- (void)addMiscProp:(Prop *)prop;
- (void)removeMiscProp:(Prop *)prop;
- (void)addFlipProp:(Prop *)prop;
- (void)removeFlipProp:(Prop *)prop;
- (void)addLoopingTween:(SPTween *)tween;
- (void)removeLoopingTween:(SPTween *)tween;
- (void)enableButton:(BOOL)enable forKey:(NSString *)key;
- (void)setVisible:(BOOL)value forKey:(NSString *)key;

@end
