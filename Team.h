//
//  Team.h
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Player.h"
#define kCloudIdKey         @"cloudId"

@interface Team : NSObject 
    
@property (nonatomic, strong) NSMutableArray* players;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic) BOOL isMixed;
@property (nonatomic, strong) NSString* cloudId;

+(Team*)getCurrentTeam;
-(void)save;
-(NSArray*) getAllPlayers;
-(void) addPlayer: (Player*) player;
-(void) removePlayer: (Player*) player;
+(NSString*)getFilePath;
-(NSMutableArray*)getInitialOLine;
-(NSMutableArray*)getInitialDLine;
-(void)sortPlayers;
-(NSDictionary*) asDictionary;
@end




