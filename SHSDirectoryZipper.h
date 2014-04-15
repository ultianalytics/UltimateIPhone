//
//  SHSDirectoryZipper.h
//  UltimateIPhone
//
//  Created by james on 4/14/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHSDirectoryZipper : NSObject

// answer the file path (will be in tmp directory) of the zipped files found in the path.
// this is a recursive zip
+(NSString*)zipDirectory: (NSString*)path toFileName: (NSString*)fileName;

@end
