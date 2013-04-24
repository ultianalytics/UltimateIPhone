//
//  Game.m
//  Ultimate
//
//  Created by james on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Game.h"
#import "UPoint.h"
#import "OffenseEvent.h"
#import "DefenseEvent.h"
#import "CessationEvent.h"
#import "Event.h"
#import "Team.h"
#import "Preferences.h"
#import "Tweeter.h"
#import "UPoint.h" 
#import "Wind.h"
#import "Player.h"
#import "Scrubber.h"
#import "LeaguevineGame.h"
#import "LeaguevineTournament.h"
#import "PlayerSubstitution.h"
#import "TimeoutDetails.h"

#define kGameFileNamePrefixKey  @"game-"
#define kGameKey                @"game"
#define kGameIdKey              @"gameId"
#define kStartDateTimeKey       @"timestamp"
#define kOpponentNameKey        @"opponentName"
#define kTournamentNameKey      @"tournamentName"
#define kPointsKey              @"points"
#define kPointsAsJsonKey        @"pointsJson"
#define kCurrentLineKey         @"currentLine"
#define kLastOLineKey           @"lastOLine"
#define kLastDLineKey           @"lastDLine"
#define kIsFirstPointOlineKey   @"firstPointOline"
#define kWindKey                @"wind"
#define kGamePointKey           @"gamePoint"
#define kLeagueVineGameKey      @"leaguevineGame"
#define kLeagueVineGameAsJsonKey      @"leaguevineJson"
#define kLeagueVineScoresPublishKey   @"pubToLeaguevine"
#define kLeagueVineStatsPublishKey   @"pubStatsToLeaguevine"
#define kJsonDateFormat         @"yyyy-MM-dd HH:mm"
#define kTimeoutDetailsJsonKey      @"timeoutDetailsJson"

static Game* currentGame = nil;

@interface Game()

@property (nonatomic, strong) NSString* timeoutJson;
@property (nonatomic, strong) CessationEvent* lastPeriodEnd; // transient

@end

@implementation Game
@synthesize gameId, points,isFirstPointOline, lastOLine, lastDLine, startDateTime,wind,gamePoint,firstEventTweeted;
@synthesize timeoutDetails=_timeoutDetails;
@synthesize periodsComplete=_periodsComplete;

+(Game*) fromDictionary:(NSDictionary*) dict {
    Game* game = [[Game alloc] init];
    game.gameId = [dict objectForKey:kGameIdKey];
    game.opponentName = [dict objectForKey:kOpponentNameKey];
    game.tournamentName = [dict objectForKey:kTournamentNameKey];
    NSNumber* gamePoint = [dict objectForKey:kGamePointKey];
    if (gamePoint) {
        game.gamePoint = [gamePoint intValue];
    }
    NSNumber* isFirstPointOline = [dict objectForKey:kIsFirstPointOlineKey];
    if (isFirstPointOline) {
        game.isFirstPointOline = [isFirstPointOline boolValue];
    }    
    NSString* startDateAsString = [dict objectForKey:kStartDateTimeKey];
    if (startDateAsString) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:kJsonDateFormat];
        game.startDateTime = [dateFormat dateFromString:startDateAsString];
    }
    NSString* pointsArrayJson = [dict objectForKey:kPointsAsJsonKey];
    if (pointsArrayJson) {
        NSError* marshallError;
        NSData* jsonData = [pointsArrayJson dataUsingEncoding:NSUTF8StringEncoding];
        NSArray* arrayOfPointDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&marshallError];
        if (marshallError) {
            NSLog(@"Error parsing points JSON");
        } else {
            NSMutableArray* points = [[NSMutableArray alloc] init];
            for (NSDictionary* pointDict in arrayOfPointDict) {
                [points addObject:[UPoint fromDictionary:pointDict]];
            }
            game.points = points;
        }
    }
    NSString* leaguevineJson = [dict objectForKey:kLeagueVineGameAsJsonKey];
    if (leaguevineJson) {
        NSError* marshallError;
        NSData* jsonData = [leaguevineJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* leaguevineGameDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&marshallError];
        if (marshallError) {
            NSLog(@"Error parsing leaguevine JSON");
        } else {
            game.leaguevineGame = [LeaguevineGame fromDictionary: leaguevineGameDict];
        }
    }
    game.timeoutJson = [dict objectForKey:kTimeoutDetailsJsonKey];
//    NSDictionary* windDict = [dict objectForKey:kPointsAsJsonKey];
//    if (windDict) {
//        game.wind = [Wind fromDictionary:windDict];
//    }
    return game;
}

-(NSString*)opponentName {
    if (self.leaguevineGame) {
        return [self.leaguevineGame opponentDescription];
    }
    return _opponentName;
}

-(NSString*)tournamentName {
    if (self.leaguevineGame) {
        return self.leaguevineGame.tournament.name;
    }
    return _tournamentName;
}

-(NSMutableDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub {
    [self updatePointSummaries];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
    [dict setValue: self.gameId forKey:kGameIdKey];
    NSString *oppName = shouldScrub ? [[Scrubber currentScrubber] substituteOpponentName:self.opponentName] : self.opponentName;
    [dict setValue: oppName forKey:kOpponentNameKey];
    [dict setValue: [NSNumber numberWithInt:self.gamePoint] forKey:kGamePointKey];
    [dict setValue: [NSNumber numberWithBool:self.isFirstPointOline] forKey:kIsFirstPointOlineKey];
    if (self.tournamentName) {
        NSString *tourneyName = shouldScrub ? [[Scrubber currentScrubber] substituteTournamentName:self.tournamentName] : self.tournamentName;
        [dict setValue: tourneyName forKey:kTournamentNameKey];
    }
    if (self.startDateTime) {
        NSDate *startDate = shouldScrub ? [[Scrubber currentScrubber] scrubGameDate:self.startDateTime] : self.startDateTime;
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:kJsonDateFormat];
        [dict setValue: [dateFormat stringFromDate:startDate] forKey:kStartDateTimeKey];
    }
    Score score;
    if (self.points && [self.points count] > 0) {
        NSMutableArray* pointDicts = [[NSMutableArray alloc] init];
        for (UPoint* point in self.points) {
            [pointDicts addObject:[point asDictionaryWithScrubbing:shouldScrub]];
            score = point.summary.score;
        }
        NSError* marshallError;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:pointDicts options:0 error:&marshallError];
        if (marshallError) {
            NSLog(@"Error creating JSON of points");
        } else {
            [dict setValue: [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:kPointsAsJsonKey];
        }
    } else {
        score.ours = 0;
        score.theirs = 0;
    }
    if (self.leaguevineGame) {
        NSDictionary* leaguevineGameDict = [self.leaguevineGame asDictionary];
        NSError* marshallError;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:leaguevineGameDict options:0 error:&marshallError];
        if (marshallError) {
            NSLog(@"Error creating JSON of leaguevine");
        } else {
            [dict setValue: [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] forKey:kLeagueVineGameAsJsonKey];
        }
    }
    [dict setValue: [NSNumber numberWithInt:score.ours] forKey:kScoreOursProperty];
    [dict setValue: [NSNumber numberWithInt:score.theirs] forKey:kScoreTheirsProperty];
    [dict setValue: [wind asDictionary] forKey: kWindKey];
    [dict setValue: self.timeoutJson forKey: kTimeoutDetailsJsonKey];
    
    return dict;
}

// return nil if no current game
+(Game*)getCurrentGame {
    @synchronized(self) {
        if (! currentGame) {
            NSString* currentGameFileName = [Preferences getCurrentPreferences].currentGameFileName;
            currentGame = [self readGame: currentGameFileName];    
        }
        return currentGame;
    }
}

+(NSString*)getCurrentGameId {
    return currentGame == nil ? nil : currentGame.gameId;
}

+(BOOL)isCurrentGame: (NSString*) gameId {
    return gameId == nil ? NO : [gameId isEqualToString:[self getCurrentGameId]];
}

+(BOOL)hasCurrentGame {
    @synchronized(self) {
        return currentGame != nil;
    }
}

+(void)setCurrentGame: (NSString*) gameId {
    currentGame = [Game readGame:gameId];
    [Preferences getCurrentPreferences].currentGameFileName = currentGame.gameId;
    [[Preferences getCurrentPreferences] save];
}

+(Game*)readGame: (NSString*) gameId {
    return [self readGame:gameId forTeam:[Team getCurrentTeam].teamId];
}

+(Game*)readGame: (NSString*) gameId forTeam: (NSString *) teamId {
    if (gameId == nil) {
        return nil;
    }
    NSString* filePath = [Game getFilePath: gameId team:teamId]; 
    
    NSData* data = [[NSData alloc] initWithContentsOfFile: filePath]; 
    if (data == nil) {
        return nil;
    } 
    NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data]; 
    Game* loadedGame = [unarchiver decodeObjectForKey:kGameKey]; 
    return loadedGame;
}

+(void)startNewGame {
    @synchronized(self) {
        Game* newGame = [[Game alloc] init]; 
        newGame.startDateTime = [NSDate date];
        [newGame save];
        [Game setCurrentGame:newGame.gameId];
    }
}

+(NSArray*)getAllGameFileNames: (NSString*) teamId {
    NSString* gamesDirectory = [Game getDirectoryPath: teamId];
    NSArray* directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:gamesDirectory error:NULL];
    
    NSMutableArray* fileNames = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int)[directoryContent count]; i++)
    {
        NSString* fileName = [directoryContent objectAtIndex:i];
        if ([fileName hasPrefix:kGameFileNamePrefixKey]) {
            [fileNames addObject:fileName];
        }
    }
    return fileNames;
}

+(NSString*)generateUniqueFileName {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    return [NSString stringWithFormat:@"%@%@", kGameFileNamePrefixKey, (__bridge NSString*)CFUUIDCreateString(nil, uuidObj)];
}

+ (NSString*)getFilePath: (NSString*) gameId team: (NSString *) teamId { 
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", [Game getDirectoryPath: teamId], gameId];
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
                NSLog(@"Create directory error: %@", error);
            }
		}
	}
    return gamesFolderPath;
}

+(void)deleteAllGamesForTeam: (NSString*) teamId {
    NSArray* fileNames = [Game getAllGameFileNames: teamId];
    for (NSString* fileName in fileNames) {
        [Game delete: fileName];
    }
    
    // delete the folder
    NSString *gamesFolder =  [Game getDirectoryPath: teamId];
    NSError *error;	
	if ([[NSFileManager defaultManager] fileExistsAtPath:gamesFolder]) {
		if (![[NSFileManager defaultManager] removeItemAtPath:gamesFolder error:&error]) {
			NSLog(@"Delete directory error: %@", error);
		}
	}
}

+(void)delete: (NSString*) aGameId {
    if ([[Preferences getCurrentPreferences].currentGameFileName isEqualToString:aGameId]) {
        [Preferences getCurrentPreferences].currentGameFileName = nil;
        [[Preferences getCurrentPreferences] save];
        [Game setCurrentGame:nil];
    }
    NSString *path = [Game getFilePath:aGameId team:[Team getCurrentTeam].teamId];
	NSError *error;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])		//Does file exist?
	{
		if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	//Delete it
		{
            if (error) {
                NSLog(@"Delete file error: %@", error);
            }
		}
	}
}

-(id) init  {
    self = [super init];
    if (self) {
        self.gameId = [Game generateUniqueFileName];
        self.points = [[NSMutableArray alloc] init];
        self.lastDLine = [[NSArray alloc] init];
        self.lastOLine = [[NSArray alloc] init];
        self.wind = [[Wind alloc] init];
        self.gamePoint = [Preferences getCurrentPreferences].gamePoint;
        arePointSummariesValid = NO;
        self.currentLine = [[Team getCurrentTeam] defaultLine];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.gameId = [decoder decodeObjectForKey:kGameIdKey];
        self.startDateTime = [decoder decodeObjectForKey:kStartDateTimeKey];
        self.opponentName = [decoder decodeObjectForKey:kOpponentNameKey]; 
        self.tournamentName = [decoder decodeObjectForKey:kTournamentNameKey];
        self.points = [decoder decodeObjectForKey:kPointsKey]; 
        self.currentLine = [decoder decodeObjectForKey:kCurrentLineKey];
        self.lastOLine = [decoder decodeObjectForKey:kLastOLineKey]; 
        self.lastDLine = [decoder decodeObjectForKey:kLastDLineKey];
        self.isFirstPointOline = [decoder decodeBoolForKey:kIsFirstPointOlineKey]; 
        self.gamePoint = [decoder decodeIntForKey:kGamePointKey];
        self.wind = [decoder decodeObjectForKey:kWindKey]; 
        if (self.wind == nil) {  // handle old data
            self.wind = [[Wind alloc] init];
        }
        arePointSummariesValid = NO;
        self.leaguevineGame = [decoder decodeObjectForKey:kLeagueVineGameKey];
        self.publishScoreToLeaguevine = [decoder decodeBoolForKey:kLeagueVineScoresPublishKey];
        self.publishStatsToLeaguevine = [decoder decodeBoolForKey:kLeagueVineStatsPublishKey];
        self.timeoutJson = [decoder decodeObjectForKey:kTimeoutDetailsJsonKey];
    } 
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeObject:self.gameId forKey:kGameIdKey]; 
    [encoder encodeObject:self.startDateTime forKey:kStartDateTimeKey]; 
    [encoder encodeObject:self.opponentName forKey:kOpponentNameKey];
    [encoder encodeObject:self.tournamentName forKey:kTournamentNameKey]; 
    [encoder encodeObject:self.points forKey:kPointsKey]; 
    [encoder encodeObject:self.currentLine forKey:kCurrentLineKey];     
    [encoder encodeObject:self.lastOLine forKey:kLastOLineKey]; 
    [encoder encodeObject:self.lastDLine forKey:kLastDLineKey]; 
    [encoder encodeBool:self.isFirstPointOline forKey:kIsFirstPointOlineKey]; 
    [encoder encodeInt:self.gamePoint forKey:kGamePointKey]; 
    [encoder encodeObject:self.wind forKey:kWindKey];
    [encoder encodeObject:self.leaguevineGame forKey: kLeagueVineGameKey];
    [encoder encodeBool:self.publishScoreToLeaguevine forKey:kLeagueVineScoresPublishKey];
    [encoder encodeBool:self.publishStatsToLeaguevine forKey:kLeagueVineStatsPublishKey];
    [encoder encodeObject:self.timeoutJson forKey:kTimeoutDetailsJsonKey];
} 


- (id)awakeAfterUsingCoder:(NSCoder*)decoder {
    for (UPoint* point in points) {
        for (Event* event in point.events) {
            [event useSharedPlayers];
        }
    }
    self.currentLine = [Player replaceAllWithSharedPlayer: self.currentLine];
    self.lastDLine = [Player replaceAllWithSharedPlayer: self.lastDLine];
    self.lastOLine = [Player replaceAllWithSharedPlayer: self.lastOLine];
    return self;
}

-(void)save {
    NSMutableData *data = [[NSMutableData alloc] init]; 
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] 
                                 initForWritingWithMutableData:data]; 
    [archiver encodeObject: self forKey:kGameKey]; 
    [archiver finishEncoding]; 
    BOOL success = [data writeToFile:[Game getFilePath:self.gameId team: [Team getCurrentTeam].teamId]atomically:YES]; 
    if (!success) {
        [NSException raise:@"Failed trying to save game" format:@"failed saving game"];
    }
}

-(BOOL)hasBeenSaved {
    NSString* filePath = [Game getFilePath: gameId team:[Team getCurrentTeam].teamId]; 
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

-(void)delete {
    [Game delete: self.gameId];
}

-(void)addEvent: (Event*) event{
    if ([self getCurrentPoint] == nil || [[self getCurrentPoint] isFinished]) {
        UPoint* newPoint = [[UPoint alloc] init];
        [self addPoint: newPoint];
    }
    [[self getCurrentPoint] addEvent:event];
    [self getCurrentPoint].line = self.currentLine;
    [self updateLastLine: event];
    [self clearPointSummaries];
    [self tweetEvent: event point: [self getCurrentPoint] isUndo: NO];
}

-(BOOL)hasEvents {
    return [self.points count] > 1 || [[self getCurrentPoint] getNumberOfEvents] > 0;
}

-(BOOL)hasOneEvent {
    return [self.points count] == 1 || [[self getCurrentPoint] getNumberOfEvents] == 1;
}

-(void)removeLastEvent {
    if ([self getCurrentPoint] != nil) {
        Event* lastEvent = [self getLastEvent];
        [self tweetEvent: lastEvent point: [self getCurrentPoint] isUndo: YES];
        [[self getCurrentPoint] removeLastEvent]; 
        if ([[self getCurrentPoint] getNumberOfEvents] == 0)  {
            [self.points removeLastObject];
        }
        if ([lastEvent isGoal] && [self getCurrentPoint] != nil && [self getCurrentPoint].line != nil) {
            self.currentLine = [NSMutableArray arrayWithArray:[self getCurrentPoint].line];
        }
        [self clearPointSummaries];
    }
}

-(Event*)getLastEvent {
    if ([self getCurrentPoint] != nil) {
        return [[self getCurrentPoint] getLastEvent]; 
    }
    return nil;
}

-(NSArray*)getLastEvents: (int) numberToRetrieve {
    NSMutableArray* list = [[NSMutableArray alloc] init];
    NSEnumerator* enumerator = [points reverseObjectEnumerator];
    UPoint* point;
    while ((point = [enumerator nextObject]) && [list count] < numberToRetrieve) {
        NSEnumerator* enumerator = [point getLastEvents: numberToRetrieve - [list count]];
        id event;
        while ((event = [enumerator nextObject])) {
            [list addObject:event];
        }
    }
    return list;
}

-(void)addPoint: (UPoint*) point {
    [self.points addObject: point];
    [self clearPointSummaries];
}

-(void)updateLastLine:(Event*) event {
    if ([event isFinalEventOfPoint]) {
        if ([self isPointOline:[self getCurrentPoint]]) {
            self.lastOLine = [[NSArray alloc] initWithArray:self.currentLine];
        } else {
            self.lastDLine = [[NSArray alloc] initWithArray:self.currentLine];
        }
    }
}

-(int)getNumberOfPoints {
    return [[self points] count];
}

-(NSString*)getPointNameAtMostRecentIndex: (int) index {
    [self updatePointSummaries];
    Score score = [self getScoreAtMostRecentIndex:index];
    return [self getPointNameForScore: score isMostRecent: (index == 0)];
} 

-(NSString*)getPointNameForScore: (Score) score isMostRecent: (BOOL) isMostRecent {
    if (isMostRecent && !([(UPoint*)[self.points lastObject] isFinished])) {
        return @"Current";
    } else {
        return [NSString stringWithFormat:@"%d-%d", score.ours, score.theirs];
    }
}

-(UPoint*)getPointAtMostRecentIndex: (int) index {
    // points are stored in ascending order but we are being asked for an index in descending order
    int count = [self.points count];
    if (count > 0) {
        return [self.points objectAtIndex:(count - index - 1)];
    } else {
        return nil;
    }
}

-(Score)getScoreAtMostRecentIndex: (int) index {
    [self updatePointSummaries];
    UPoint* point = [self getPointAtMostRecentIndex:index];
    return point.summary.score;
}

-(NSArray*)getPointNamesInMostRecentOrder {
    [self updatePointSummaries];
    NSMutableArray* names = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.points count]; i++) {
        UPoint* point = [self.points objectAtIndex:i];
        NSString* pointName = [self getPointNameForScore: point.summary.score isMostRecent: (i == [self.points count]-1)];
        [names insertObject:pointName atIndex:0]; // prepends value to the array
    }
    return names;
}

-(UPoint*)getCurrentPoint {
    if (self.points.count == 0) {
        return nil;
    } else {
        return [self.points lastObject];
    }
}

-(BOOL)arePlayingOffense {
    [self updatePointSummaries];
    if ([self getCurrentPoint] == nil) {
        return isFirstPointOline;
    } else {
        Event* lastEvent = [[self getCurrentPoint] getLastEvent];
        if ([self isNextEventImmediatelyAfterHalftime] || [lastEvent isPeriodEnd]) {
            return [self isNextPointAfterPeriodEndOline];
        } else {
            return [lastEvent isNextEventOffense];
        }
    }
}

-(BOOL)isPointOline: (UPoint*) point {
    [self updatePointSummaries];
    return [point.summary isOline];
}

-(BOOL)isFirstPoint: (UPoint*) point {
    return [self.points count] > 0 && [self.points objectAtIndex:0] == point;
}

-(BOOL)isCurrentlyOline {
    [self updatePointSummaries];
    if ([self getCurrentPoint] == nil) {
        return isFirstPointOline;
    } else if ([self isNextEventImmediatelyAfterHalftime] || [[self getLastEvent] isPeriodEnd]) {
        return [self isNextPointAfterPeriodEndOline];
    } else if ([[self getCurrentPoint] isFinished]) {
        return ![[self getCurrentPoint] isOurPoint];
    }
    return [self isPointOline:[self getCurrentPoint]];
}

-(UPoint*)findPreviousPoint: (UPoint*) pointParam {
    [self updatePointSummaries];
    return pointParam.summary.previousPoint;
}

-(Score)getScore {
    [self updatePointSummaries];
    if ([self getCurrentPoint] == nil) {
        return [self createScoreForOurs: 0 theirs: 0];
    }
    return [self getCurrentPoint].summary.score;
}

-(NSMutableArray*)currentLineSorted {
    if ([Team getCurrentTeam].isDiplayingPlayerNumber ) {
        [self.currentLine sortUsingComparator:^(id a, id b) {
            int first = ((Player*)a).number.intValue;
            int second = ((Player*)b).number.intValue;
            return first == second ? NSOrderedSame : first < second ? NSOrderedAscending : NSOrderedDescending;
        }];
    } else {
        [self.currentLine sortUsingComparator:^(id a, id b) {
            NSString *first = ((Player*)a).name;
            NSString *second = ((Player*)b).name;
            return [first caseInsensitiveCompare:second];
        }];
    }
    return self.currentLine;
}

-(void)clearCurrentLine {
    if (self.currentLine != nil) {
        [self.currentLine removeAllObjects];
    }
}

-(void)resetCurrentLine {
    if (self.currentLine) {
        self.currentLine = [NSMutableArray arrayWithArray:self.currentLine];
    }
}

-(void)makeCurrentLineLastLine: (BOOL) useOline {
    self.currentLine = [[NSMutableArray alloc] initWithArray: useOline ? 
        self.lastOLine : self.lastDLine];
}

-(BOOL)canNextPointBePull {
    Event* lastEvent = [self getLastEvent];
    if (lastEvent == nil) {
        return !self.isFirstPointOline;
    }
    if ([self isTimeBasedEnd]) {
        if ([lastEvent isOurGoal]) {
            return YES;
        } else if ([lastEvent isPeriodEnd]) {
            BOOL isNextPointOline = [self isNextPointAfterPeriodEndOline];
            return !isNextPointOline;
        } else {
            return NO;
        }
    } else {
        return [lastEvent isOurGoal] || ([lastEvent isTheirGoal] && [self isNextEventImmediatelyAfterHalftime] && self.isFirstPointOline);
    }
}

-(BOOL)isNextPointAfterPeriodEndOline {
    int periodsFinished = [self isTimeBasedEnd] ? self.periodsComplete : [self isAfterHalftime];
    if (periodsFinished >= 4) {
        return [[self lastPeriodEnd] isNextOvertimePeriodStartingOline];
    } else {
        return [self isNextPointOlineAfterPeriodsFinished: periodsFinished];
    }
}

-(BOOL)isNextPointOlineAfterPeriodsFinished: (int)periodsFinished {
    return ((self.isFirstPointOline + periodsFinished) % 2);
}

-(BOOL)isPointInProgress {
    Event* lastEvent = self.getLastEvent;
    return lastEvent && ![lastEvent isGoal] && ![lastEvent isPeriodEnd];
}

-(NSSet*)getPlayers {
    NSMutableSet* players = [[NSMutableSet alloc] init];
    for (UPoint* point in self.points) {
        for (Event* event in point.events) {
            [players addObjectsFromArray: [event getPlayers]];
        }
    }
    [players addObjectsFromArray:self.lastOLine];
    [players addObjectsFromArray:self.lastDLine];
    [players addObjectsFromArray:self.currentLine];
    return players;
}

-(BOOL)isNextEventImmediatelyAfterHalftime {
    if (self.isTimeBasedEnd) {
        return [self isHalftime];
    } else {
        [self updatePointSummaries];
        if ([self getCurrentPoint] != nil && [[self getCurrentPoint] isFinished] && (![self getCurrentPoint].summary.isAfterHalftime)) {
            return [self getLeadingScore] == [self getHalftimePoint];
        }
        return false;
    }
}

-(BOOL)isHalftime {
    if ([self isTimeBasedEnd]) {
        Event* evt = [self getLastEvent];
        return [evt isCessationEvent] && [((CessationEvent*)evt) isHalftime];
    } else {
        return [self isNextEventImmediatelyAfterHalftime];
    }
}

-(BOOL)isAfterHalftime {
    if ([self isTimeBasedEnd]) {
        return self.periodsComplete >= 2;
    } else {
        return [self isAfterHalftimeStarted] || [self isNextEventImmediatelyAfterHalftime];
    }
}

-(BOOL)isAfterHalftimeStarted {
    if ([self isTimeBasedEnd]) {
        return self.periodsComplete >= 2 && ![self isHalftime];
    } else {
        [self updatePointSummaries];
        return ([self getCurrentPoint] != nil && ([self getCurrentPoint].summary.isAfterHalftime));
    }
}

-(int)getHalftimePoint {
    return ((self.gamePoint == 0 ? kDefaultGamePoint : self.gamePoint) + 1) / 2;
}

-(Action)nextPeriodEnd {
    int lastPeriodEnded = [Game getCurrentGame].periodsComplete;
    switch (lastPeriodEnded) {
        case 0:
            return EndOfFirstQuarter;
            break;
        case 1:
            return Halftime;
            break;
        case 2:
            return EndOfThirdQuarter;
            break;
        case 3: {
            if ([self isTie]) {
                return EndOfFourthQuarter;
            } else {
                return GameOver;
            }
            break;
        }
        default: {
            if ([self isTie]) {
                return EndOfOvertime;
            } else {
                return GameOver;
            }
            break;
        }
    }
}

-(int)getLeadingScore {
    Score score = [self getScore];
    return MAX(score.ours, score.theirs);
}

-(Score)createScoreForOurs: (int) ours theirs: (int) theirs {
    Score score;
    score.ours = ours;
    score.theirs = theirs;
    return score;
}

-(BOOL)isTie {
    Score score = [self getScore];
    return score.ours == score.theirs;
}

-(void)setGamePoint:(int)newGamePoint {
    [self clearPointSummaries];
    gamePoint = newGamePoint;
}

-(void)tweetEvent: (Event*) event point: (UPoint*) point isUndo: (BOOL) isUndo {
    if ([[point getEvents] count] == 1) {
        [[Tweeter getCurrent] tweetFirstEventOfPoint:event forGame:self point:point isUndo:isUndo];
    } else {
        [[Tweeter getCurrent] tweetEvent:event forGame:self point:point isUndo:isUndo];
    }
}

-(void)updatePointSummaries {
    if (!arePointSummariesValid) {
        int periodEndCount = 0;
        Score score;
        score.ours = 0;
        score.theirs = 0;
        UPoint* lastPoint = nil;
        for (int i = 0; i < [self.points count]; i++) {
            UPoint* point = [self.points objectAtIndex:i];
            point.summary = [[PointSummary alloc] init];
            point.summary.isFinished = point.isFinished;
            if ([point isPeriodEnd]) {
                self.lastPeriodEnd = [point getPeriodEnd];
            }
            if (point.summary.isFinished) {
                if ([point isOurPoint]) {
                    score.ours++;
                } else if ([point isTheirPoint]) {
                    score.theirs++;
                }
            } 
            point.summary.score = [self createScoreForOurs:score.ours theirs:score.theirs];
            if (self.isTimeBasedEnd) {
                point.summary.isAfterHalftime = periodEndCount > 2;
                if (!lastPoint || [lastPoint isPeriodEnd]) {
                    point.summary.isOline = [self isNextPointOlineAfterPeriodsFinished: periodEndCount];
                } else {
                    point.summary.isOline = ![lastPoint isOurPoint];
                }
            } else {
                point.summary.isAfterHalftime = lastPoint != nil && [self getHalftimePoint] <= MAX(lastPoint.summary.score.ours, lastPoint.summary.score.theirs);
                BOOL isFirstPointAfterHalftime = lastPoint != nil && point.summary.isAfterHalftime && !lastPoint.summary.isAfterHalftime;
                point.summary.isOline = lastPoint == nil ? self.isFirstPointOline : isFirstPointAfterHalftime ? !self.isFirstPointOline : ![lastPoint isOurPoint];
            }
            point.summary.elapsedSeconds = point.timeEndedSeconds - point.timeStartedSeconds;
            point.summary.previousPoint = lastPoint;
            
            if ([point isPeriodEnd]) {
                periodEndCount++;
            }
            
            lastPoint = point;
        }
        _periodsComplete = periodEndCount;
        arePointSummariesValid = YES;
    }
}

-(void)clearPointSummaries {
    arePointSummariesValid = NO;
}

-(BOOL)isTimeBasedEnd {
    return gamePoint == kTimeBasedGame;
}

-(BOOL)doesGameAppearDone {
    if (self.isTimeBasedEnd) {
        return [self getLastEvent].action == GameOver;
    // have we reached the end point and leader has >= 2 lead?        
    } else {
        [self updatePointSummaries];
        Score score = [self getScore];
        int highScore = MAX(score.ours, score.theirs);
        int lowScore = MIN(score.ours, score.theirs);
        return (highScore >= self.gamePoint) && (highScore >= lowScore + 2);
    }
}

-(NSString*)shortOpponentName {
    if ([self.opponentName length] > 20) {
        return [NSString stringWithFormat: @"%@...", [self.opponentName substringToIndex: 17]];
    } else {
        return self.opponentName;
    }
}

-(int)periodsComplete {
    [self updatePointSummaries];
    return _periodsComplete;
}

-(CessationEvent*)lastPeriodEnd {
    [self updatePointSummaries];
    return _lastPeriodEnd;
}

#pragma mark - Leaguevine

-(BOOL)isLeaguevineGame {
    return self.leaguevineGame != nil;
}

-(void)setLeaguevineGame:(LeaguevineGame *)leaguevineGame {
    _leaguevineGame = leaguevineGame;
    self.publishScoreToLeaguevine = NO;  // reset publish
}

#pragma mark - Substitutions

-(void)addSubstitution: (PlayerSubstitution*)substitution {
    UPoint* currentPoint = [self getCurrentPoint];
    [currentPoint.substitutions addObject: substitution];
    [self adjustLineForSubstitution: substitution];
}

// answer YES if line could be readjusted correctly
-(BOOL)removeLastSubstitutionForCurrentPoint {
    UPoint* currentPoint = [self getCurrentPoint];
    PlayerSubstitution* lastSub = [currentPoint.substitutions lastObject];
    if (lastSub) {
        [currentPoint.substitutions removeLastObject];
        return [self adjustLineForSubstitutionUndo:lastSub];
    }
    return YES;
}

-(NSArray*)substitutionsForCurrentPoint {
    UPoint* currentPoint = [self getCurrentPoint];
    return currentPoint && ![currentPoint isFinished] ? [[currentPoint.substitutions reverseObjectEnumerator] allObjects] : [NSArray array];
}

-(void)adjustLineForSubstitution:(PlayerSubstitution*)sub {
    [self.currentLine removeObject:sub.fromPlayer];
    if ([self.currentLine count] < 7) {
        [self.currentLine addObject:sub.toPlayer];
    }
}

-(BOOL)adjustLineForSubstitutionUndo:(PlayerSubstitution*)sub {
    if (![self.currentLine containsObject:sub.toPlayer] || [self.currentLine containsObject:sub.fromPlayer]) {
        return NO;
    }
    [self.currentLine removeObject:sub.toPlayer];
    if ([self.currentLine count] < 7) {
        [self.currentLine addObject:sub.fromPlayer];
    }
    return YES;
}

-(BOOL)publishStatsToLeaguevine {
    return (self.leaguevineGame) && _publishStatsToLeaguevine;
}

-(BOOL)publishScoresToLeaguevine {
    return (self.leaguevineGame) && _publishScoreToLeaguevine;
}

#pragma mark - Timeouts 

-(void)setTimeoutDetails:(TimeoutDetails *)timeoutDetails {
    _timeoutDetails = timeoutDetails;
    if (timeoutDetails) {
        NSDictionary* timeoutDetailsDict = [timeoutDetails asDictionary];
        NSError* marshallError;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:timeoutDetailsDict options:0 error:&marshallError];
        if (marshallError) {
            NSLog(@"Error creating JSON of timeout details");
        } else {
            self.timeoutJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else {
        self.timeoutJson = nil;
    }
}

-(TimeoutDetails*)timeoutDetails {
    if (_timeoutDetails == nil) {
        if (self.timeoutJson) {
            NSError* marshallError;
            NSData* jsonData = [self.timeoutJson dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary* timeoutDetailsDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&marshallError];
            if (marshallError) {
                NSLog(@"Error parsing leaguevine JSON");
            } else {
                _timeoutDetails = [TimeoutDetails fromDictionary: timeoutDetailsDict];
            }
        } else {
            TimeoutDetails* timeoutDetails = [[TimeoutDetails alloc] init];
            timeoutDetails.quotaPerHalf = [Preferences getCurrentPreferences].timeoutsPerHalf;
            timeoutDetails.quotaFloaters = [Preferences getCurrentPreferences].timeoutFloaters;
            self.timeoutDetails = timeoutDetails;
        }
    }
    return _timeoutDetails;
}

-(int)availableTimeouts {
    if (!self.timeoutDetails) {
        return 0;
    }
    int totalAvailableFirstHalf = self.timeoutDetails.quotaPerHalf + self.timeoutDetails.quotaFloaters;
    if ([self isAfterHalftime]) {
        int floatersAvailableAfterFirstHalf = MIN(totalAvailableFirstHalf - self.timeoutDetails.takenFirstHalf, self.timeoutDetails.quotaFloaters);
        int totalAvailableSecondHalf = self.timeoutDetails.quotaPerHalf + floatersAvailableAfterFirstHalf;
        return totalAvailableSecondHalf - self.timeoutDetails.takenSecondHalf;
    } else {
        return totalAvailableFirstHalf - self.timeoutDetails.takenFirstHalf;
    }
}

@end
