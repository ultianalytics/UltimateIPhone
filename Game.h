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

#define kDefaultGamePoint 15

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

+(Game*)getCurrentGame;
+(NSString*)getCurrentGameId;
+(BOOL)isCurrentGame: (NSString*) gameId;
+(BOOL)hasCurrentGame;
+(void)setCurrentGame: (NSString*) gameId;
+(void)startNewGame;
+(Game*)readGame: (NSString*) gameId;
+(NSArray*)getAllGameFileNames: (NSString*) teamId;
+(NSString*)getFilePath: (NSString*) gameId;
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
-(BOOL)isNextEventImmediatelyAfterHalftime;
-(int)getHalftimePoint;
-(int)getLeadingScore;
-(NSMutableDictionary*) asDictionary;

// private
+(NSString*)getDirectoryPath: (NSString*) teamId;
-(void)updateLastLine: (Event*) event;
-(void)addPoint: (UPoint*) point;
+(void)delete: (NSString*) aGameId;
-(void)updatePointSummaries;
-(void)clearPointSummaries;
-(Score)createScoreForOurs: (int) ours theirs: (int) theirs;
-(void)tweetEvent: (Event*) event point: (UPoint*) point isUndo: (BOOL) isUndo;


@end
