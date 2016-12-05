//
//  NSMutableData_Extension.h
//  xyzCCTestingxyz
//
//  Created by Paul McPhee on 19/01/11.
//  Copyright 2011 Cheeky Mammoth. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSMutableData (Extension)

+ (id)mutableDataWithData:(NSData *)data;
- (void)maskWithOffset:(unsigned char)offset;
- (void)unmaskWithOffset:(unsigned char)offset;

@end
