//
//  CodeProfiler.m
//  Cutlass Cove
//
//  Created by Paul McPhee on 30/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CodeProfiler.h"

@implementation CodeProfiler

@synthesize numFrames = mNumFrames;

- (id)init {
    if (self = [super init]) {
        mNumFrames = 0;
        mCodeSections = [[NSMutableDictionary alloc] initWithCapacity:20];
    }
    
    return self;
}

- (void)dealloc {
    [mCodeSections release]; mCodeSections = nil;
    [super dealloc];
}

- (void)addCodeSectionForKey:(NSString *)key ceiling:(NSTimeInterval)ceiling {
    [mCodeSections setObject:[CodeSection codeSectionWithName:key startDate:[NSDate date] intervalCeiling:ceiling] forKey:key];
}

- (void)removeCodeSectionForKey:(NSString *)key {
    [mCodeSections removeObjectForKey:key];
}

- (void)startProfilerForKey:(NSString *)key {
    CodeSection *codeSection = (CodeSection *)[mCodeSections objectForKey:key];
    [codeSection start];
}

- (void)pauseProfilerForKey:(NSString *)key {
    CodeSection *codeSection = (CodeSection *)[mCodeSections objectForKey:key];
    [codeSection pause];
}

- (void)stopProfilerForKey:(NSString *)key {
    CodeSection *codeSection = (CodeSection *)[mCodeSections objectForKey:key];
    [codeSection stop];
}

- (BOOL)didProfilerBreachForKey:(NSString *)key {
    CodeSection *codeSection = (CodeSection *)[mCodeSections objectForKey:key];
    return codeSection.didBreach;
}

- (NSTimeInterval)codeSectionDurationForKey:(NSString *)key {
    CodeSection *codeSection = (CodeSection *)[mCodeSections objectForKey:key];
    return codeSection.currentDuration;
}

- (void)resetProfilers {
    for (NSString *key in mCodeSections) {
        CodeSection *codeSection = (CodeSection *)[mCodeSections objectForKey:key];
        [codeSection reset];
    }
}

- (NSString *)reportForKey:(NSString *)key {
    CodeSection *codeSection = (CodeSection *)[mCodeSections objectForKey:key];
    return codeSection.reportString;
}

- (NSArray *)reportAll {
    NSMutableArray *reports = [NSMutableArray arrayWithCapacity:mCodeSections.count];
    
    for (NSString *key in mCodeSections) {
        CodeSection *codeSection = (CodeSection *)[mCodeSections objectForKey:key];
        [reports addObject:codeSection.reportString];
    }
    
    return reports;
}

- (void)resetFrameCount {
    mNumFrames = 0;
}

- (void)markEndOfFrame {
    ++mNumFrames;
}

@end


@implementation CodeSection

@synthesize didBreach,currentDuration,totalDuration,worst,date;
@dynamic average,reportString;

+ (CodeSection *)codeSectionWithName:(NSString *)name startDate:(NSDate *)startDate intervalCeiling:(NSTimeInterval)intervalCeiling {
    return [[[CodeSection alloc] initWithName:name startDate:startDate intervalCeiling:intervalCeiling] autorelease];
}

- (id)initWithName:(NSString *)name startDate:(NSDate *)startDate intervalCeiling:(NSTimeInterval)intervalCeiling {
    if (self = [super init]) {
        key = [name copy];
        ceiling = intervalCeiling;
        paused = NO;
        didBreach = NO;
        numCeilingBreaches = 0;
        numTimesRun = 0;
        currentDuration = 0;
        totalDuration = 0;
        worst = 0;
        date = [startDate copy];
    }
    
    return self;
}

- (void)dealloc {
    [date release]; date = nil;
    [super dealloc];
}

- (NSTimeInterval)average {
    return (NSTimeInterval)(totalDuration / MAX(1,numTimesRun));
}

- (NSString *)reportString {
    return [NSString stringWithFormat:@"\n+++ CODE SECTION: %@\n+++ AVG: %.5f\n+++ WORST: %.5f\n+++ TOTAL: %.5f\n+++ BREACHES: %u\n+++ RUNS: %u\n", key, self.average, worst, totalDuration, numCeilingBreaches, numTimesRun];
}

- (void)start {
    paused = NO;
    didBreach = NO;
    self.date = [NSDate date];
}

- (void)pause {
    paused = YES;
    NSDate *nowDate = [NSDate date];
    currentDuration = currentDuration + [nowDate timeIntervalSinceDate:self.date];
    self.date = nowDate;
}

- (void)stop {
    NSDate *nowDate = [NSDate date];
    currentDuration = currentDuration + [nowDate timeIntervalSinceDate:self.date];
    totalDuration = totalDuration + currentDuration;
    
    if (currentDuration > worst)
        worst = currentDuration;
    if (currentDuration > ceiling) {
        ++numCeilingBreaches;
        didBreach = YES;
    }
    
    currentDuration = 0;
    paused = NO;
    ++numTimesRun;
}

- (void)reset {
    numCeilingBreaches = 0;
    numTimesRun = 0;
    currentDuration = 0;
    totalDuration = 0;
    worst = 0;
    self.date = [NSDate date];
}

@end
