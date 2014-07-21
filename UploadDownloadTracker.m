//
//  UploadDownloadTracker.m
//  UltimateIPhone
//
//  Created by Jim Geppert on 7/21/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import "UploadDownloadTracker.h"

#define kUploadDownloadTrackerKey   @"uploadDownloadTracker"
#define kUploadDownloadLookupKey    @"uploadDownloadLookup"
#define kUploadDownloadTeamIdKey    @"teamId"

@interface UploadDownloadTracker ()

@property (nonatomic, strong) NSMutableDictionary* uploadDownloadLookup;
@property (nonatomic, strong) NSString* teamId;

@end

@implementation UploadDownloadTracker

- (id)initWithTeamId:(NSString*)teamId {
    if (self = [super init]) {
        self.teamId = teamId;
    }
    return self;
}

#pragma mark - Upload/Download tracking - public

+(void)updateLastUploadOrDownloadTime: (NSTimeInterval)timestamp forGameId: (NSString*)gameId inTeamId: (NSString*)teamId {
    UploadDownloadTracker* tracker = [self readTeamTracker:teamId];
    [tracker updateLastUploadOrDownloadTime:timestamp ForGameId:gameId];
    [tracker save];
}

+(NSTimeInterval)lastUploadOrDownloadForGameId: (NSString*)gameId inTeamId: (NSString*)teamId {
    UploadDownloadTracker* tracker = [self readTeamTracker:teamId];
    return [tracker lastUploadOrDownloadForGameId:gameId];
}

#pragma mark - Upload/Download tracking - private

-(NSTimeInterval)lastUploadOrDownloadForGameId: (NSString*)gameId {
    NSNumber* timestampAsNSNumber = [self.uploadDownloadLookup objectForKey:gameId];
    return timestampAsNSNumber ? [timestampAsNSNumber doubleValue] : -1;
}

-(void)updateLastUploadOrDownloadTime: (NSTimeInterval)timestamp ForGameId: (NSString*)gameId {
    [self.uploadDownloadLookup setObject:[NSNumber numberWithDouble:timestamp] forKey:gameId];
}

#pragma mark - Persistence

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.uploadDownloadLookup = [decoder decodeObjectForKey:kUploadDownloadLookupKey];
        self.teamId = [decoder decodeObjectForKey:kUploadDownloadTeamIdKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.uploadDownloadLookup forKey:kUploadDownloadLookupKey];
    [encoder encodeObject:self.teamId forKey:kUploadDownloadTeamIdKey];
}

-(NSMutableDictionary*)uploadDownloadLookup {
    if (_uploadDownloadLookup == nil) {
        _uploadDownloadLookup = [[NSMutableDictionary alloc] init];
    }
    return _uploadDownloadLookup;
}

-(void)save {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                 initForWritingWithMutableData:data];
    [archiver encodeObject: self forKey:kUploadDownloadTrackerKey];
    [archiver finishEncoding];
    BOOL success = [data writeToFile:[[self class] getFilePath: self.teamId] atomically:YES];
    if (!success) {
        [NSException raise:@"Failed trying to save upload download tracker" format:@"failed saving team"];
    }
}

+(UploadDownloadTracker*)readTeamTracker: (NSString*) teamId {
    if (teamId == nil) {
        return nil;
    }
    NSString* filePath = [self getFilePath: teamId];
    NSData* data = [[NSData alloc] initWithContentsOfFile: filePath];
    if (data == nil) {
        return [[UploadDownloadTracker alloc] initWithTeamId:teamId];
    }
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    return [unarchiver decodeObjectForKey:kUploadDownloadTrackerKey];
}

+ (NSString*)getFilePath: (NSString *) teamId {
    NSString* filePath = [NSString stringWithFormat:@"%@/upload-download", [self getDirectoryPath: teamId]];
    return filePath;
}

+ (NSString*)getDirectoryPath: (NSString*) teamId {
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSString* gamesFolderPath = [NSString stringWithFormat:@"%@/games-%@", documentsDirectory, teamId];
    if (![[NSFileManager defaultManager] fileExistsAtPath:gamesFolderPath]) {	//Does directory already exist?
        NSError* error;
		if (![[NSFileManager defaultManager] createDirectoryAtPath:gamesFolderPath withIntermediateDirectories:NO attributes:nil error:&error]) {
            if (error) {
                SHSLog(@"Create directory error: %@", error);
            }
		}
	}
    return gamesFolderPath;
}

@end
