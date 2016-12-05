//
//  FileManager.h
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 9/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileManager : NSObject

+ (NSString *)pathForFilename:(NSString *)filename;
+ (NSDictionary *)loadPlistDictionaryWithFilename:(NSString *)filename;
+ (NSArray *)loadPlistArrayWithFilename:(NSString *)filename;
+ (BOOL)savePlistDictionary:(NSDictionary *)data withFilename:(NSString *)filename;
+ (BOOL)savePlistArray:(NSArray *)data withFilename:(NSString *)filename;
+ (BOOL)deletePlistFile:(NSString *)filename;

+ (NSString *)dataPathForFileName:(NSString *)filename;
+ (NSData *)loadNSDataWithFilename:(NSString *)filename;
+ (BOOL)saveNSData:(NSData *)data withFilename:(NSString *)filename;
+ (BOOL)deleteNSDataFile:(NSString *)filename;

+ (NSData *)loadFromUserDefaults:(NSString *)key;
+ (BOOL)saveToUserDefaults:(NSData *)data key:(NSString *)key;

@end
