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

#define kLineChangePlayerIdsSeparator @"|"

@interface LeaguevinePostingLog()

@property (nonatomic, strong) NSString* currentLogFilePath;
@property (nonatomic, strong) NSString* logAPath;
@property (nonatomic, strong) NSString* logBPath;
@property (nonatomic, strong) NSString* logsDirectory;

@end

@implementation LeaguevinePostingLog


-(void)logLeaguevineEvent: (LeaguevineEvent*)event {
    // format: {event-type}/{log-record-version}/{timestamp}/{leaguevine-id}/{game-id}/{UNUSED}/{array-of-LV-player-ids-for-line-change-event}/{description}
    [self appendToLog:[NSString stringWithFormat:@"%d/%@/%f/%lu/%d/%@/%@/%@\n",
                       event.leaguevineEventType,
                       @"V1",
                       event.iUltimateTimestamp,
                       (unsigned long)event.leaguevineEventId,
                       event.leaguevineGameId,
                       @"",  // unused
                       [self lineChangePlayersAsString:event],
                       [event crudDescription]]];
}

-(NSUInteger)leaguevineEventIdForTimestamp: (NSTimeInterval)eventTimestamp eventType: (NSUInteger)eventType {
    NSUInteger eventId = 0;
    eventId = [self leaguevineEventIdForTimestamp:eventTimestamp eventType:eventType inFile:self.currentLogFilePath];
    if (eventId == 0) {
        NSString* otherLogFilePath = [self.currentLogFilePath isEqualToString:self.logAPath] ? self.logBPath : self.logAPath;
        eventId = [self leaguevineEventIdForTimestamp:eventTimestamp eventType:eventType inFile:otherLogFilePath];
    }
    return eventId;
}

-(NSUInteger)leaguevineEventIdForTimestamp: (NSTimeInterval)eventTimestamp {
    return [self leaguevineEventIdForTimestamp:eventTimestamp eventType:0];
}

-(NSArray*)lastLinePostedForGameId: (NSUInteger)gameId {
    NSArray* lastLineChangePlayerIds = [self lastLinePostedForGameId:gameId inFile:self.currentLogFilePath];
    if (!lastLineChangePlayerIds) {
        lastLineChangePlayerIds = [self lastLinePostedForGameId:gameId inFile:self.currentLogFilePath == self.logAPath ? self.logBPath : self.logAPath];
    }
    return lastLineChangePlayerIds;
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
            SHSLog(@"error writing to log: %@", error);
        }
    }
}

-(NSUInteger)leaguevineEventIdForTimestamp: (NSTimeInterval)eventTimestamp eventType: (NSUInteger)eventType inFile: (NSString*)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:filePath];
        NSString * line = nil;
        while ((line = [reader readLine])) {
            NSArray* fields = [line pathComponents];
            NSTimeInterval recordEventType = [[fields objectAtIndex:0] doubleValue];
            NSTimeInterval recordTimestamp = [[fields objectAtIndex:2] doubleValue];
            if ((eventType == 0 || (recordEventType == eventType)) && recordTimestamp == eventTimestamp) {
                return [[fields objectAtIndex:3] intValue];
            }
        }
    }
    return 0;
}

-(NSArray*)lastLinePostedForGameId: (NSUInteger)gameId inFile: (NSString*)filePath{
    NSString* lineChangeEventTypeRecordPrefix = [NSString stringWithFormat:@"%d/", kLineChangeEventType];
    NSString* lastLineChangeEventTypeRecord;
    // find last logged line record for this game in the file
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        DDFileReader * reader = [[DDFileReader alloc] initWithFilePath:filePath];
        NSString * line = nil;
        while ((line = [reader readLine])) {
            if ([line hasPrefix:lineChangeEventTypeRecordPrefix]) {  // is it a line change event?
                NSArray* fields = [line pathComponents];
                NSTimeInterval recordGameId = [[fields objectAtIndex:4] intValue];
                if (gameId == recordGameId) {
                    lastLineChangeEventTypeRecord = line;
                }
            }
        }
    }
    // if we found one, return the players in the line change
    if (lastLineChangeEventTypeRecord) {
        NSArray* fields = [lastLineChangeEventTypeRecord pathComponents];
        NSString* lineChangePlayerArrayAsString = [fields objectAtIndex:5];
        return [self lineChangePlayersAsArray: lineChangePlayerArrayAsString];
    } else {
        return nil;
    }
}

-(void)initFilePaths {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cacheDir = [paths objectAtIndex:0];
    self.logsDirectory = [cacheDir stringByAppendingPathComponent:  @"LeaguevineSubmitLog"];
    NSError *error;
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.logsDirectory]) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:self.logsDirectory withIntermediateDirectories:NO attributes:nil error:&error]) {
			SHSLog(@"Error creating leaguevine event submit log: %@", error);
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
			SHSLog(@"Delete file error: %@", error);
		}
    }
}

-(NSString*)lineChangePlayersAsString: (LeaguevineEvent*)event {
    NSString* lineChangePlayerIdsAsString = @"";
    if (event.leaguevineEventType == kLineChangeEventType && event.latestLine) {
        NSMutableArray* playerIdStrings = [NSMutableArray array];
        for (NSNumber* playerId in event.latestLine) {
            [playerIdStrings addObject:[NSString stringWithFormat:@"%d", playerId.intValue]];
        }
        lineChangePlayerIdsAsString = [playerIdStrings componentsJoinedByString: kLineChangePlayerIdsSeparator];
    }
    return lineChangePlayerIdsAsString;
}

-(NSArray*)lineChangePlayersAsArray: (NSString*)lineChangePlayerArrayAsString {
    if ([lineChangePlayerArrayAsString isNotEmpty]) {
        NSArray* playerIdStrings = [lineChangePlayerArrayAsString componentsSeparatedByString: kLineChangePlayerIdsSeparator];
        NSMutableArray* playerIds = [NSMutableArray arrayWithCapacity:[playerIdStrings count]];
        for (NSString* playerIdString in playerIdStrings) {
            [playerIds addObject: [NSNumber numberWithInt:[playerIdString intValue]]];
        }
        return playerIds;
    } else {
        return [NSArray array];
    }
}

-(void)writeErrorMessage: (NSString*) message overwrite: (BOOL)overwrite {
    NSString* path = [self errorMessageFilePath];
    if (overwrite || ![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData* data = [message asData];
        [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
    }
}

-(NSString*)readErrorMessage {
    NSData* data = [[NSData alloc] initWithContentsOfFile:[self errorMessageFilePath]];
    return data ? [NSString stringWithData: data] : nil;
}

-(void)deleteErrorMessage {
    NSString* path = [self errorMessageFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}
}

-(NSString*)errorMessageFilePath {
     return [self.logsDirectory stringByAppendingPathComponent:@"LeaguevineErrorMessage"];
}

@end
