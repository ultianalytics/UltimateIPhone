//
//  LeaguevinePostingLog.m
//  UltimateIPhone
//
//  Created by james on 3/31/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevinePostingLog.h"
#import "Event.h"
#import "LeaguevineEvent.h"
#import "DDFileReader.h"
#import "NSString+manipulations.h"

@interface LeaguevinePostingLog()

@property (nonatomic, strong) NSString* currentLogFilePath;
@property (nonatomic, strong) NSString* logAPath;
@property (nonatomic, strong) NSString* logBPath;
@property (nonatomic, strong) NSString* logsDirectory;

@end

@implementation LeaguevinePostingLog


-(void)logLeaguevineEvent: (LeaguevineEvent*)event {
    // format: {timestamp}/{leavuevine-id}
    [self appendToLog:[NSString stringWithFormat:@"%f/%lu/%@\n", event.iUltimateTimestamp, (unsigned long)event.leaguevineEventId, [event crudDescription]]];
}

-(NSUInteger)leaguevineEventIdForTimestamp: (NSTimeInterval)eventTimestamp {
    NSUInteger eventId = 0;
    eventId = [self leaguevineEventIdForTimestamp:eventTimestamp inFile:self.currentLogFilePath];
    if (eventId == 0) {
        NSString* otherLogFilePath = [self.currentLogFilePath isEqualToString:self.logAPath] ? self.logBPath : self.logAPath;
        eventId = [self leaguevineEventIdForTimestamp:eventTimestamp inFile:otherLogFilePath];
    }
    return eventId;
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

-(NSUInteger)leaguevineEventIdForTimestamp: (NSTimeInterval)eventTimestamp inFile: (NSString*)filePath{
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:filePath];
        NSString * line = nil;
        while ((line = [reader readLine])) {
            NSArray* fields = [line pathComponents];
            NSTimeInterval recordTimestamp = [[fields objectAtIndex:0] doubleValue];
            if (recordTimestamp == eventTimestamp) {
                return [[fields objectAtIndex:1] intValue];
            }
        }
    }
    return 0;
}

-(void)initFilePaths {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    self.logsDirectory = [cacheDir stringByAppendingPathComponent:  @"LeaguevineSubmitLog"];
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
    return [self.logsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"LeaguevineSubmitLog-%@", logSuffix]];
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
        long size = [attributes fileSize];
        if (size > 500000) {
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
