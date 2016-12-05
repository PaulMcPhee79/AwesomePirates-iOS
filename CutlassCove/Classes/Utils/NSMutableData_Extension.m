//
//  NSMutableData_Extension.m
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 19/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import "NSMutableData_Extension.h"

@implementation NSMutableData (Extension)

+ (id)mutableDataWithData:(NSData *)data {
    if (data == nil || data.length == 0)
        return nil;
    
    NSMutableData *mutableData = [NSMutableData dataWithLength:data.length];
    [mutableData setData:data];
    return mutableData;
}

- (void)maskUnmaskWithOffset:(unsigned char)offset {
    unsigned char mask = offset;
    unsigned char *buffer = (unsigned char *)[self mutableBytes];
    
    for (NSUInteger i = 0; i < [self length]; ++i) {
        buffer[i] = buffer[i] ^ mask;
        mask += i&7;
    }
}

- (void)maskWithOffset:(unsigned char)offset {
    [self maskUnmaskWithOffset:offset];
}

- (void)unmaskWithOffset:(unsigned char)offset {
    [self maskUnmaskWithOffset:offset];
}

@end
