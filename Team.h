//
//  Team.h
//  Ultimate
//
//  Created by Jim Geppert
//  Copyright (c) 2012 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;
@class LeaguevineTeam;

#define kTeamIdKey          @"teamId"
#define kCloudIdKey         @"cloudId"

@interface Team : NSObject 

@property (nonatomic, strong) NSString* teamId;
@property (nonatomic, strong) NSMutableArray* players;
@property (nonatomic, strong) NSString* name;
@property (nonatomic) BOOL isMixed;
@property (nonatomic) BOOL isDiplayingPlayerNumber;
@property (nonatomic, strong) NSString* cloudId;
@property (nonatomic, strong) LeaguevineTeam* leaguevineTeam;

+(Team*)getCurrentTeam;
+(Team*)readTeam: (NSString*) teamId;
+(void)setCurrentTeam: (NSString*) teamId;
+(BOOL)isCurrentTeam: (NSString*) teamId;
+(NSArray*)getAllTeamFileNames;
+(NSArray*)retrieveTeamDescriptions;
+(Team*)fromDictionary:(NSDictionary*) dict;
+(Player*) getPlayerNamed: (NSString*) playerName;
+(NSString*) getTeamIdForCloudId: (NSString*)  cloudId;
+(BOOL) isDuplicateTeamName: (NSString*) newTeamName notIncluding: (Team*) team;

-(void)save;
-(void)delete;
-(BOOL)hasBeenSaved;
-(NSArray*) getAllPlayers;
-(void) addPlayer: (Player*) player;
-(Player*) getPlayer: (NSString*) playerName;
-(void) removePlayer: (Player*) player;
-(NSMutableArray*)defaultLine;
-(void)sortPlayers;
-(BOOL)isLeaguevineTeam;
-(NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub;

// private
+(NSString*)getFilePath: (NSString*) teamdId;
+(NSString*)generateUniqueFileName;

@end




