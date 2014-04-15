//
//  SHSDirectoryZipper.m
//  UltimateIPhone
//
//  Created by james on 4/14/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "SHSDirectoryZipper.h"
#import <zipzap/zipzap.h>

@implementation SHSDirectoryZipper

// answer the file path (will be in tmp directory) of the zipped files found in the path.
// this is a recursive zip
+(NSString*)zipDirectory: (NSString*)path toFileName: (NSString*)fileName {
    
    // zip file path
    NSString *zipFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent: fileName];

    // collect all of the entries to zip
    ZZMutableArchive* newArchive = [ZZMutableArchive archiveWithContentsOfURL:[NSURL fileURLWithPath:zipFilePath]];
    NSMutableArray* zipEntries = [NSMutableArray array];
    [self addEntriesForDirectory:path toZipEntries:zipEntries];
    
    // zip
    NSError* error;
    [newArchive updateEntries: zipEntries error:&error];
    if (error) {
        SHSLog(@"Unable to create zip");
        return nil;
    } else {
        return zipFilePath;
    }
    
}

+(void)addEntriesForDirectory: (NSString*)directory  toZipEntries: (NSMutableArray*) zipEntries {
    NSError* error;
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directory error:&error];
    if (error) {
        SHSLog(@"Error adding dir entry to zip: %@", error);
    } else {
        BOOL isDir;
        for (NSString* name in directoryContent) {
            NSString* fileOrDir = [directory stringByAppendingPathComponent:name];
            if ([[NSFileManager defaultManager] fileExistsAtPath:fileOrDir isDirectory:&isDir]) {
                if (isDir) {
                    [self addEntriesForDirectory:fileOrDir toZipEntries:zipEntries];
                } else {
                    error = nil;
                    ZZArchiveEntry* zipEntry = [ZZArchiveEntry archiveEntryWithFileName: fileOrDir compress:YES dataBlock:^NSData *(NSError **error) {
                        NSData *fileContents = [[NSData alloc] initWithContentsOfFile:fileOrDir];
                        return fileContents;
                    }];
                    [zipEntries addObject: zipEntry];
                }
            }
        }
    }
}

@end
