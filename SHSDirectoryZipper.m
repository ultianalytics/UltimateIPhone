//
//  SHSDirectoryZipper.m
//  UltimateIPhone
//
//  Created by james on 4/14/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "SHSDirectoryZipper.h"
#import "SSZipArchive.h"

@implementation SHSDirectoryZipper

// answer the file path (will be in tmp directory) of the zipped files found in the path.
// this is a recursive zip
+(NSString*)zipDirectory: (NSString*)path toFileName: (NSString*)fileName {
    
    // zip file path
    NSString *zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: fileName];

    // zip
    [SSZipArchive createZipFileAtPath:zipFilePath withContentsOfDirectory:path];
	if ([[NSFileManager defaultManager] fileExistsAtPath:zipFilePath]) {
        return zipFilePath;
	} else {
        SHSLog(@"Failed to create zip file at %@ for directory %@", zipFilePath, path);
        return nil;
    }
}

@end
