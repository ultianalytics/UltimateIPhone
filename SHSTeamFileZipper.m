//
//  SHSTeamFileZipper.m
//  UltimateIPhone
//
//  Created by james on 4/14/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "SHSTeamFileZipper.h"
//#import <zipzap/zipzap.h>

#define kZipFileNamePrefixKey  @"ultimate-files-"

@implementation SHSTeamFileZipper

// answer the file path of the zipped files
+(NSString*)zipTeamAndGameFiles {
    NSString* teamsDirectory = [self teamFilesDirectory];
    NSString *zipFilePath = [self generateZipFilePath];
//    ZZMutableArchive* newArchive = [ZZMutableArchive archiveWithContentsOfURL:[NSURL fileURLWithPath:zipFilePath]];
//    NSError* error;
//    [newArchive updateEntries: @[[ZZArchiveEntry archiveEntryWithDirectoryName:teamsDirectory]] error:&error];
//    if (error) {
//        NSLog(@"Unable to create zip");
//        return nil;
//    } else {
//        return zipFilePath;
//    }
    return nil;
}

+(NSString*)teamFilesDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* teamsDirectoryPath = documentsDirectory;
    return teamsDirectoryPath;
}

+(NSString*)generateZipFilePath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:[self generateUniqueFileName]];
}

+(NSString*)generateUniqueFileName {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    return [NSString stringWithFormat:@"%@%@", kZipFileNamePrefixKey, (__bridge NSString*)CFUUIDCreateString(nil, uuidObj)];
}

@end
