//
//  ViewParser.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 20/05/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuDetailView.h"
#import "TitleSubview.h"

@class SceneController,ResOffsetStack;

@interface ViewParser : NSObject {
	int mCategory;
	NSString *mFont;
	NSDictionary *mViewData;
	id mEventListener; // Weak reference
	SceneController *mScene; // Weak reference
}

@property (nonatomic,assign) int category;
@property (nonatomic,copy) NSString *fontKey;

- (id)initWithScene:(SceneController *)scene eventListener:(id)eventListener plistPath:(NSString *)path;
- (void)changePlistPath:(NSString *)path;

- (MenuDetailView *)parseSubviewByName:(NSString *)name forViewName:(NSString *)viewName;
- (MenuDetailView *)parseSubviewByName:(NSString *)name forViewName:(NSString *)viewName index:(int)index;

- (TitleSubview *)parseTitleSubviewByName:(NSString *)name forViewName:(NSString *)viewName;
- (TitleSubview *)parseTitleSubviewByName:(NSString *)name forViewName:(NSString *)viewName index:(int)index;

- (NSDictionary *)parseSubviewsByViewName:(NSString *)viewName;
- (NSDictionary *)parseTitleSubviewsByViewName:(NSString *)viewName;

- (void)parseLabels:(NSArray *)labels view:(MenuDetailView *)view;
- (void)parseImages:(NSArray *)images view:(MenuDetailView *)view;
- (void)parseButtons:(NSArray *)buttons view:(MenuDetailView *)view;
- (void)parseQuarterFoldouts:(NSArray *)foldouts view:(MenuDetailView *)view;

@end
