//
//  Game.h
//  Ultimate
//
//  Created by james on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PointSummary.h"
@class Event;
@class UPoint;
@class Wind;
@class LeaguevineGame;

#define kDefaultGamePoint 15
#define kTimeBasedGame    1000

@interface Game : NSObject {
    BOOL arePointSummariesValid;
}
@property (nonatomic, strong) NSString* gameId;
@property (nonatomic, strong) NSDate* startDateTime;
@property (nonatomic, strong) NSString* opponentName;
@property (nonatomic, strong) NSString* tournamentName;
@property (nonatomic, strong) NSMutableArray* points;
@property (nonatomic, strong) NSMutableArray* currentLine;
@property (nonatomic, strong) NSArray* lastOLine;
@property (nonatomic, strong) NSArray* lastDLine;
@property (nonatomic) BOOL isFirstPointOline;
@property (nonatomic, strong) Wind* wind;
@property (nonatomic) int gamePoint;
@property (nonatomic, strong) LeaguevineGame* leaguevineGame;
@property (nonatomic) BOOL publishScoreToLeaguevine;
@property (nonatomic, weak) Event* firstEventTweeted; // transient

+(Game*)getCurrentGame;
+(NSString*)getCurrentGameId;
+(BOOL)isCurrentGame: (NSString*) gameId;
+(BOOL)hasCurrentGame;
+(void)setCurrentGame: (NSString*) gameId;
+(void)startNewGame;
+(Game*)readGame: (NSString*) gameId;
+(Game*)readGame: (NSString*) gameId forTeam: (NSString *) teamId;
+(NSArray*)getAllGameFileNames: (NSString*) teamId;
+(NSString*)getFilePath: (NSString*) gameId team: (NSString *) teamId;
+(NSString*)generateUniqueFileName;
+(void)deleteAllGamesForTeam: (NSString*) teamId;
+(Game*) fromDictionary:(NSDictionary*) dict;

-(void)save;
-(BOOL)hasBeenSaved;
-(void)delete;
-(void)addEvent: (Event*) event;
-(BOOL)hasEvents;
-(void)removeLastEvent;
-(Event*)getLastEvent;
-(NSArray*)getLastEvents: (int) numberToRetrieve;
-(UPoint*)getCurrentPoint;
-(int)getNumberOfPoints;
-(NSArray*)getPointNamesInMostRecentOrder;
-(NSString*)getPointNameForScore: (Score) score isMostRecent: (BOOL) isMostRecent;
-(UPoint*)getPointAtMostRecentIndex: (int) index;
-(Score)getScore;
-(Score)getScoreAtMostRecentIndex: (int) index;
-(NSString*)getPointNameAtMostRecentIndex: (int) index;
-(NSMutableArray*)getCurrentLine;
-(NSMutableArray*)getCurrentLineSorted;
-(void)clearCurrentLine;
-(BOOL)arePlayingOffense;
-(BOOL)isPointOline: (UPoint*) point;
-(BOOL)isFirstPoint: (UPoint*) point;
-(BOOL)isCurrentlyOline;
-(UPoint*)findPreviousPoint: (UPoint*) point;
-(void)makeCurrentLineLastLine: (BOOL) useOline; 
-(BOOL)canNextPointBePull;
-(NSArray*)getPlayers;
-(BOOL)isAfterHalftime;
-(BOOL)isNextEventImmediatelyAfterHalftime;
-(int)getLeadingScore;
-(NSMutableDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub;
-(BOOL)isTimeBasedEnd;
-(void)clearPointSummaries;
-(BOOL)doesGameAppearDone;
-(BOOL)isLeaguevineGame;

@end
