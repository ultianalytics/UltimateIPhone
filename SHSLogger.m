//
//  SHSLogger.m
//  UltimateIPhone
//
//  Created by james on 3/31/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "SHSLogger.h"
#import "DDFileReader.h"
#import "NSString+manipulations.h"

#define kLogFolder @"IUltimateLogs"
#define kLogPrefix @"IUltimate-%@"
#define kLogSuffix @"log"
#define kLogFileSize 500000

@interface SHSLogger()

@property (nonatomic, strong) NSString* currentLogFilePath;
@property (nonatomic, strong) NSString* logAPath;
@property (nonatomic, strong) NSString* logBPath;
@property (nonatomic, strong) NSString* logsDirectory;

@end

@implementation SHSLogger

static SHSLogger *sharedInstance = nil;

+ (SHSLogger *)sharedLogger {
    if (nil != sharedInstance) {
        return sharedInstance;
    }
    
    static dispatch_once_t pred;        
    dispatch_once(&pred, ^{             
        sharedInstance = [[SHSLogger alloc] init];
    });
    
    return sharedInstance;
}

-(void)log: (NSString*)message {
    [self appendToLog: [NSString stringWithFormat:@"%@: %@\n", [NSDate date], message]];
}

-(NSArray*)filesInDateAscendingOrder {
    NSMutableArray* filePaths = [NSMutableArray array];
    NSString* lastFilePath = [self lastLogWrittenToFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:lastFilePath]) {
        [filePaths addObject:lastFilePath];
    }
    NSString* otherFile = [lastFilePath isEqualToString:self.logAPath] ? self.logBPath : self.logAPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:otherFile]) {
        [filePaths addObject:otherFile];
    }
    return [[filePaths reverseObjectEnumerator] allObjects];
}

#pragma mark Private

- (id)init
{
    self = [super init];
    if (self) {
        [self initFilePaths];
    }
    return self;
}

-(void)appendToLog: (NSString*)record {
    NSData* recordAsData = [record dataUsingEncoding:NSUTF8StringEncoding];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentLogFilePath]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.currentLogFilePath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:recordAsData];
        [fileHandle closeFile];
        [self switchLogsIfNeeded];
    } else {
        NSError* error;
        [recordAsData writeToFile:self.currentLogFilePath options:NSDataWritingAtomic error:&error];
        if(error != nil) {
            NSLog(@"error writing to log: %@", error);
        }
    }
}

-(void)initFilePaths {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    self.logsDirectory = [cacheDir stringByAppendingPathComponent: kLogFolder];
    NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.logsDirectory]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:self.logsDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
			NSLog(@"Error creating leaguevine event submit log: %@", error);
		}
	}
    self.logAPath = [self getFilePathForLog: @"A"];
    self.logBPath = [self getFilePathForLog: @"B"];
}

-(NSString*)getFilePathForLog: (NSString*)logSuffix {
    return [[self.logsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:kLogPrefix, logSuffix]] stringByAppendingPathExtension:kLogSuffix];
}

-(NSString*)currentLogFilePath {
    if (!_currentLogFilePath) {
        _currentLogFilePath = [self lastLogWrittenToFilePath];
    }
    return _currentLogFilePath;
}

-(NSString*)lastLogWrittenToFilePath {
    NSDate* logADate;
    NSDate* logBDate;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.logAPath]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.logAPath error:nil];
        logADate = [attributes fileModificationDate];
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.logBPath]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.logBPath error:nil];
        logBDate = [attributes fileModificationDate];
    }
    if (!logBDate) {
        return self.logAPath;
    } else if (!logADate) {
        return self.logBPath;
    } else {
        return [logADate compare:logBDate] == NSOrderedAscending ? self.logBPath : self.logAPath;
    }
}

-(void)switchLogsIfNeeded {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentLogFilePath]) {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.currentLogFilePath error:nil];
        unsigned long long size = [attributes fileSize];
        if (size > kLogFileSize) {
            [self switchLogs];
        }
    }
}

-(void)switchLogs {
    self.currentLogFilePath = [self.currentLogFilePath isEqualToString:self.logAPath] ? self.logBPath : self.logAPath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.currentLogFilePath]) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtPath:self.currentLogFilePath error:&error]) {
			NSLog(@"Delete file error: %@", error);
		}
    }
}

@end
