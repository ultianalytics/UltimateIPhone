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
#define kCurrentGameFileKey     @"currentGameFileName"
#define kDisplayPlayerNumberKey @"displayPlayerNumber"
#define kGamePointKey           @"gamePoint"
#define kTweetEventsKey         @"tweetEvents"
#define kUseridKey              @"userid"
#define kDefaultGamePoint       13
#define kMinGamePoint           9
#define kMaxGamePoint           17
static Preferences* currentPreferences= nil;

@implementation Preferences
@synthesize filePath, tournamentName,currentGameFileName, isDiplayingPlayerNumber,gamePoint,userid,isTweetingEvents,twitterAccountDescription;

-(id) init  {
    self = [super init];
    if (self) {
        self.filePath = [Preferences getFilePath];
        self.gamePoint = kDefaultGamePoint;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.filePath = [Preferences getFilePath];
        self.tournamentName = [decoder decodeObjectForKey:kTournamentKey];
        self.currentGameFileName = [decoder decodeObjectForKey:kCurrentGameFileKey];
        self.isDiplayingPlayerNumber = [decoder decodeBoolForKey:kDisplayPlayerNumberKey];
        self.gamePoint = [decoder decodeBoolForKey:kGamePointKey];
        if (self.gamePoint < kMinGamePoint || self.gamePoint > kMaxGamePoint) {
            self.gamePoint = kDefaultGamePoint;
        }
        self.userid = [decoder decodeObjectForKey:kUseridKey];
        self.isTweetingEvents = [decoder decodeBoolForKey:kTweetEventsKey];
    } 
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeObject:self.tournamentName forKey:kTournamentKey]; 
    [encoder encodeObject:self.currentGameFileName forKey:kCurrentGameFileKey]; 
    [encoder encodeBool:self.isDiplayingPlayerNumber forKey:kDisplayPlayerNumberKey]; 
    [encoder encodeBool:self.gamePoint forKey:kGamePointKey];
    [encoder encodeObject:self.userid forKey:kUseridKey];
    [encoder encodeBool:self.isTweetingEvents forKey:kTweetEventsKey];
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
        [NSException raise:@"Failed trying to save team" format:@"failed saving team"];
    }
}

+ (NSString*)getFilePath { 
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* documentsDirectory = [paths objectAtIndex:0]; 
    return [documentsDirectory stringByAppendingPathComponent:kPreferencesFileName]; 
}

@end
