//
//  Team.h
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Player;
#define kTeamIdKey          @"teamId"
#define kCloudIdKey         @"cloudId"

@interface Team : NSObject 

@property (nonatomic, strong) NSString* teamId;
@property (nonatomic, strong) NSMutableArray* players;
@property (nonatomic, strong) NSString* name;
@property (nonatomic) BOOL isMixed;
@property (nonatomic) BOOL isDiplayingPlayerNumber;
@property (nonatomic, strong) NSString* cloudId;

+(Team*)getCurrentTeam;
+(Team*)readTeam: (NSString*) teamId;
+(void)setCurrentTeam: (NSString*) teamId;
+(BOOL)isCurrentTeam: (NSString*) teamId;
+(NSArray*)getAllTeamFileNames;
+(NSArray*)retrieveTeamDescriptions;
+(Team*)fromDictionary:(NSDictionary*) dict;
+(Player*) getPlayerNamed: (NSString*) playerName;
+(NSString*) getTeamIdForCloudId: (NSString*)  cloudId;

-(void)save;
-(void)delete;
-(BOOL)hasBeenSaved;
-(NSArray*) getAllPlayers;
-(void) addPlayer: (Player*) player;
-(Player*) getPlayer: (NSString*) playerName;
-(void) removePlayer: (Player*) player;
-(NSMutableArray*)getInitialOLine;
-(NSMutableArray*)getInitialDLine;
-(void)sortPlayers;
-(NSDictionary*) asDictionary;

// private
+(NSString*)getFilePath: (NSString*) teamdId;
+(NSString*)generateUniqueFileName;

@end




