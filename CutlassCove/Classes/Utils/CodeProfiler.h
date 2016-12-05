//
//  CodeProfiler.h
//  Cutlass Cove
//
//  Created by Paul McPhee on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CodeSection : NSObject {
    NSString *key;
    
    BOOL paused;
    BOOL didBreach;
    
    uint numTimesRun;
    uint numCeilingBreaches;
    
    NSTimeInterval currentDuration;
    NSTimeInterval totalDuration;
    NSTimeInterval worst;
    NSTimeInterval ceiling;
    
    NSDate *date;
}

@property (nonatomic,readonly) BOOL didBreach;
@property (nonatomic,readonly) NSTimeInterval totalDuration;
@property (nonatomic,readonly) NSTimeInterval currentDuration;
@property (nonatomic,readonly) NSTimeInterval average;
@property (nonatomic,readonly) NSTimeInterval worst;
@property (nonatomic,copy) NSDate *date;
@property (nonatomic,readonly) NSString *reportString;

+ (CodeSection *)codeSectionWithName:(NSString *)name startDate:(NSDate *)startDate intervalCeiling:(NSTimeInterval)intervalCeiling;
- (id)initWithName:(NSString *)name startDate:(NSDate *)startDate intervalCeiling:(NSTimeInterval)intervalCeiling;
- (void)start;
- (void)pause;
- (void)stop;
- (void)reset;

@end


@interface CodeProfiler : NSObject {
    uint mNumFrames;
    NSMutableDictionary *mCodeSections;
}

@property (nonatomic,readonly) uint numFrames;

- (void)addCodeSectionForKey:(NSString *)key ceiling:(NSTimeInterval)ceiling;
- (void)removeCodeSectionForKey:(NSString *)key;

- (void)startProfilerForKey:(NSString *)key;
- (void)pauseProfilerForKey:(NSString *)key;
- (void)stopProfilerForKey:(NSString *)key;
- (BOOL)didProfilerBreachForKey:(NSString *)key;
- (NSTimeInterval)codeSectionDurationForKey:(NSString *)key;
- (void)resetProfilers;

- (NSString *)reportForKey:(NSString *)key;
- (NSArray *)reportAll;

- (void)resetFrameCount;
- (void)markEndOfFrame;

@end
