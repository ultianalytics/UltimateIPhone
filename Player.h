//
//  Player.h
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LeaguevinePlayer;

typedef enum {
    Any,
    Handler,
    Cutter
} Position;

@interface Player : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* number;
@property (nonatomic) Position position;
@property (nonatomic) BOOL isMale;
@property (nonatomic) BOOL isAbsent;
@property (nonatomic, strong) LeaguevinePlayer* leaguevinePlayer;

+(Player*)getAnonymous;
+(Player*)replaceWithSharedPlayer: (Player*) player;
+(NSMutableArray*)replaceAllWithSharedPlayer: (NSArray*) playersArray;
+(Player*)fromDictionary:(NSDictionary*) dict;

-(id) initName:  (NSString*) aName;
-(id) initName:  (NSString*) aName position: (Position) aPosition isMale: (BOOL) isPlayerMale;
-(BOOL) isAnonymous;
-(id)getId;
-(NSString*)getDisplayName;
-(NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub;
-(BOOL)isPlayerNamed: (NSString*)playerName;
-(BOOL)isLeaguevinePlayer;
-(NSComparisonResult)compareUsingNumber:(Player*)anotherPlayer;

@end
