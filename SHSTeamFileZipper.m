//
//  SHSTeamFileZipper.m
//  UltimateIPhone
//
//  Created by james on 4/14/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "SHSTeamFileZipper.h"
#import "SHSDirectoryZipper.h"
#import "NSString+manipulations.h"

#define kZipFileNamePrefixKey  @"ultimate-files-"

@implementation SHSTeamFileZipper

// answer the file path of the zipped files
+(NSString*)zipTeamAndGameFiles {
    
    // from/to directories
    NSString* teamsDirectory = [self teamFilesDirectory];
    NSString *zipFilePath = [self generateUniqueFileName];
    
    // zip
    return [SHSDirectoryZipper zipDirectory:teamsDirectory toFileName:zipFilePath];
}

+(NSString*)teamFilesDirectory {
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* teamsDirectoryPath = documentsDirectory;
    return teamsDirectoryPath;
}

+(NSString*)generateUniqueFileName {
    return [NSString stringWithFormat:@"%@%@.zip", kZipFileNamePrefixKey, [NSString stringWithGuid]];
}

@end
