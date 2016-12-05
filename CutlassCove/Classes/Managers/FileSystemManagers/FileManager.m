//
//  FileManager.m
//  PiratesOfCutlassCove
//
//  Created by Paul McPhee on 9/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileManager.h"


@implementation FileManager

+ (NSString *)pathForFilename:(NSString *)filename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath:path]) {
		NSString *bundle = [[NSBundle mainBundle] pathForResource:filename ofType:@"plist"];
		
		if ([fileManager copyItemAtPath:bundle toPath:path error:NULL] == NO)
			path = nil;
	}
	return path;
}

+ (NSDictionary *)loadPlistDictionaryWithFilename:(NSString *)filename {
	NSDictionary *plistDict = nil;
	NSString *path = [FileManager pathForFilename:filename];
	
	if (path != nil)
		plistDict = [NSDictionary dictionaryWithContentsOfFile:path];
	return plistDict;
}

+ (NSArray *)loadPlistArrayWithFilename:(NSString *)filename {
	NSArray	*plistArray = nil;
	NSString *path = [FileManager pathForFilename:filename];
	
	if (path != nil)
		plistArray = [NSArray arrayWithContentsOfFile:path];
	return plistArray;
}

+ (BOOL)savePlistDictionary:(NSDictionary *)data withFilename:(NSString *)filename {
	BOOL result = NO;
	NSString *path = [FileManager pathForFilename:filename];
	
	if (path != nil)
		result = [data writeToFile:path atomically:YES];
	return result;
}

+ (BOOL)savePlistArray:(NSArray *)data withFilename:(NSString *)filename {
	BOOL result = NO;
	NSString *path = [FileManager pathForFilename:filename];
	
	if (path != nil)
		result = [data writeToFile:path atomically:YES];
	return result;
}

+ (BOOL)deletePlistFile:(NSString *)filename {
	BOOL result = YES;
	NSString *path = [FileManager pathForFilename:filename];
	
	if (path != nil) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		result = [fileManager removeItemAtPath:path error:nil];
	}
	return result;
}

+ (NSString *)dataPathForFileName:(NSString *)filename {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
	return path;
}

+ (NSData *)loadNSDataWithFilename:(NSString *)filename {
	NSData *data = nil;
	NSString *path = [FileManager dataPathForFileName:filename];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (path != nil && [fileManager fileExistsAtPath:path])
		data = [NSData dataWithContentsOfFile:path];
	return data;
}

+ (BOOL)saveNSData:(NSData *)data withFilename:(NSString *)filename {
	if (data == nil)
		return NO;
	NSString *path = [FileManager dataPathForFileName:filename];
	return [data writeToFile:path atomically:YES];
}

+ (BOOL)deleteNSDataFile:(NSString *)filename {
	BOOL result = YES;
	NSString *path = [FileManager dataPathForFileName:filename];
	
	if (path != nil) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		result = [fileManager removeItemAtPath:path error:nil];
	}
	return result;
}

+ (NSData *)loadFromUserDefaults:(NSString *)key {
    if (key == nil)
        return nil;
    
    NSData* data = nil;
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	if (prefs) {
        data = [[(NSData *)[prefs objectForKey:key] retain] autorelease];
        
        if (data)
            NSLog(@"Progress loaded from NSUserDefaults for %@ was %@ bytes in length.", key, [NSString stringWithFormat:@"%u", [data length]]);
        else
            NSLog(@"No progress to load from NSUserDefaults for %@", key);
	} else {
        NSLog(@"Error: NSUserDefaults unavailable for loading progress for %@", key);
    }
    
    return data;
}

+ (BOOL)saveToUserDefaults:(NSData *)data key:(NSString *)key {
    if (data == nil || key == nil)
        return NO;
    
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if (prefs) {
        [prefs setObject:data forKey:key];
        [prefs synchronize];
        return YES;
	} else {
		NSLog(@"Error: NSUserDefaults unavailable for saving progress for %@", key);
        return NO;
	}
}

@end
