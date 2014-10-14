//
//  Team.m
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Preferences.h"
#define kPreferencesFileName    @"preferences"
#define kPreferencesKey         @"preferences"
#define kTournamentKey          @"tournament"
#define kCurrentTeamFileKey     @"currentTeamFileName"
#define kCurrentGameFileKey     @"currentGameFileName"
#define kGamePointKey           @"gamePoint"
#define kAutoTweetLevelKey      @"autoTweetLevel"
#define kUseridKey              @"userid"
#define kAccessTokenKey         @"accessToken"
#define kLeaguevineTokenKey     @"leagevineToken"
#define kTimeoutPerHalfKey      @"timeoutPerHalf"
#define kTimeoutFloaterKey      @"timeoutFloater"
#define kFieldDimensionsKey     @"fieldDimensions"
#define kDefaultGamePoint       13
#define kDefaultTimeoutsPerHalf 2
#define kMinGamePoint           9
#define kMaxGamePoint           17
static Preferences* currentPreferences= nil;

@implementation Preferences

-(id) init  {
    self = [super init];
    if (self) {
        self.filePath = [Preferences getFilePath];
        self.gamePoint = kDefaultGamePoint;
        self.timeoutsPerHalf = kDefaultTimeoutsPerHalf;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.filePath = [Preferences getFilePath];
        self.tournamentName = [decoder decodeObjectForKey:kTournamentKey];
        self.currentTeamFileName = [decoder decodeObjectForKey:kCurrentTeamFileKey];
        self.currentGameFileName = [decoder decodeObjectForKey:kCurrentGameFileKey];
        self.gamePoint = [decoder decodeBoolForKey:kGamePointKey];
        if (self.gamePoint < kMinGamePoint || self.gamePoint > kMaxGamePoint) {
            self.gamePoint = kDefaultGamePoint;
        }
        self.userid = [decoder decodeObjectForKey:kUseridKey];
        self.accessToken = [decoder decodeObjectForKey:kAccessTokenKey];
        self.autoTweetLevel = [decoder decodeIntForKey:kAutoTweetLevelKey];
        self.leaguevineToken = [decoder decodeObjectForKey:kLeaguevineTokenKey];
        self.timeoutsPerHalf = [decoder decodeIntForKey:kTimeoutPerHalfKey];
        self.timeoutFloaters = [decoder decodeIntForKey:kTimeoutFloaterKey];
        self.fieldDimensions = [decoder decodeObjectForKey:kFieldDimensionsKey];
    }
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeObject:self.tournamentName forKey:kTournamentKey]; 
    [encoder encodeObject:self.currentTeamFileName forKey:kCurrentTeamFileKey]; 
    [encoder encodeObject:self.currentGameFileName forKey:kCurrentGameFileKey];
    [encoder encodeBool:self.gamePoint forKey:kGamePointKey];
    [encoder encodeObject:self.userid forKey:kUseridKey];
    [encoder encodeObject:self.accessToken forKey:kAccessTokenKey];
    [encoder encodeInt:self.autoTweetLevel forKey:kAutoTweetLevelKey];
    [encoder encodeObject:self.leaguevineToken forKey:kLeaguevineTokenKey];
    [encoder encodeInt:self.timeoutsPerHalf forKey:kTimeoutPerHalfKey];
    [encoder encodeInt:self.timeoutFloaters forKey:kTimeoutFloaterKey];
    [encoder encodeObject:self.fieldDimensions forKey:kFieldDimensionsKey];
}

+(Preferences*)getCurrentPreferences {
    @synchronized(self) {
        if (! currentPreferences) {
            currentPreferences = [[Preferences alloc] init];    
            
            NSData *data = [[NSData alloc] initWithContentsOfFile: [Preferences getFilePath]]; 
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] 
                                             initForReadingWithData:data]; 
            Preferences* loadedPreferences = [unarchiver decodeObjectForKey:kPreferencesKey]; 
            currentPreferences = loadedPreferences ? loadedPreferences : [[Preferences alloc] init]; 
        }
        return currentPreferences;
    }
}

-(void)save {
    NSMutableData *data = [[NSMutableData alloc] init]; 
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] 
                                 initForWritingWithMutableData:data]; 
    [archiver encodeObject: self forKey:kPreferencesKey]; 
    [archiver finishEncoding]; 
    BOOL success = [data writeToFile:self.filePath atomically:YES]; 
    if (!success) {
        [NSException raise:@"Failed trying to save preferences" format:@"failed saving preferences"];
    }
}

+ (NSString*)getFilePath { 
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* documentsDirectory = [paths objectAtIndex:0]; 
    return [documentsDirectory stringByAppendingPathComponent:kPreferencesFileName]; 
}

-(FieldDimensions*)fieldDimensions {
    if (!_fieldDimensions) {
        _fieldDimensions = [[FieldDimensions alloc] init];
    }
    return _fieldDimensions;
}

@end
