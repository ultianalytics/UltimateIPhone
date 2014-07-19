//
//  Player.m
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Player.h"
#import "AnonymousPlayer.h"
#import "Preferences.h"
#import "Team.h"
#import "Scrubber.h"
#import "LeaguevinePlayer.h"
#import "NSDictionary+JSON.h"

#define kNameKey        @"name"
#define kPositionKey    @"position"
#define kSexKey         @"sex"
#define kIsMaleKey      @"male"
#define kIsAbsentKey    @"absent"
#define kNumberKey      @"number"
#define kLeagueVinePlayerJsonKey      @"leaguevinePlayer"

static AnonymousPlayer* singleAnonymous = nil;

@interface Player()

@property (nonatomic, strong) NSString* leaguevinePlayerJson;

@end

@implementation Player
@synthesize leaguevinePlayer=_leaguevinePlayer;

+ (void)initialize
{
    singleAnonymous = [[AnonymousPlayer alloc] init];  
}

+(Player*)getAnonymous {
    return singleAnonymous;
}

+(Player*)replaceWithSharedPlayer: (Player*) player {
    if (player == nil ) {
        return nil;
    }
    if ([player isAnonymous]) {
        return [Player getAnonymous];
    }
    // If the player is in the current team then use that instance.
    if ([[Team getCurrentTeam].players containsObject:player]) {
        Player* sharedPlayer = [[Team getCurrentTeam].players objectAtIndex: [[Team getCurrentTeam].players indexOfObject: player]];
        return sharedPlayer == player ? player : sharedPlayer;
    // Otherwise, add the player to the current team           
    } else {
        [[Team getCurrentTeam] addPlayer:player];
        return player;
    }
}

+(NSMutableArray*)replaceAllWithSharedPlayer: (NSArray*) playersArray {
    NSMutableArray* replacementArray = [[NSMutableArray alloc] init];
    for (Player* player in playersArray) {
        Player* replacementPlayer = [Player replaceWithSharedPlayer: player];
        [replacementArray addObject:replacementPlayer];
    }
    return replacementArray;
}

+(Player*)fromDictionary:(NSDictionary*) dict {
    Player* player = [[Player alloc] initName:[dict valueForKey:kNameKey]];
    NSString* positionString = [dict valueForKey:kPositionKey];
    player.position = [positionString isEqualToString:@"Cutter"] ? Cutter : [positionString isEqualToString:@"Handler"] ? Handler : Any;
    NSNumber* isMaleNumber = [dict valueForKey:kIsMaleKey];
    player.isMale = [isMaleNumber boolValue];
    player.isAbsent = [dict boolForJsonProperty:kIsAbsentKey defaultValue:NO];
    player.number = [dict valueForKey:kNumberKey];
    player.leaguevinePlayerJson = [dict valueForKey:kLeagueVinePlayerJsonKey];
    
    return player;
}

-(id) initName:  (NSString*) aName {
    self = [super init];
    if (self) {
        self.name = aName;
        self.number = @"";
        self.position = Any;
        self.isMale = YES;
    }
    return self;
}


-(BOOL) isAnonymous {
    return [self.name isEqualToString:[Player getAnonymous].name];
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.name = [decoder decodeObjectForKey:kNameKey]; 
        self.position = [decoder decodeIntForKey:kPositionKey]; 
        self.isMale = [decoder decodeBoolForKey:kSexKey];
        self.isAbsent = [decoder decodeBoolForKey:kIsAbsentKey];
        self.number = [decoder decodeObjectForKey:kNumberKey];
        self.leaguevinePlayerJson = [decoder decodeObjectForKey:kLeagueVinePlayerJsonKey];
    } 
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeObject:self.name forKey:kNameKey]; 
    [encoder encodeInt:self.position forKey:kPositionKey]; 
    [encoder encodeBool:self.isMale forKey:kSexKey];
    [encoder encodeBool:self.isAbsent forKey:kIsAbsentKey];
    [encoder encodeObject:self.number forKey:kNumberKey];
    [encoder encodeObject:self.leaguevinePlayerJson forKey:kLeagueVinePlayerJsonKey];
} 

-(NSDictionary*) asDictionaryWithScrubbing: (BOOL) shouldScrub {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    NSString *playerName = shouldScrub ? [[Scrubber currentScrubber] substitutePlayerName:self.name isMale:self.isMale] : self.name;
    [dict setValue: playerName forKey:kNameKey];
    [dict setValue: (self.position == Any ? @"Any" : self.position == Cutter ? @"Cutter" : @"Handler") forKey:kPositionKey];
    [dict setValue: [NSNumber numberWithBool:self.isMale ] forKey:kIsMaleKey];
    [dict setValue: [NSNumber numberWithBool:self.isAbsent ] forKey:kIsAbsentKey];
    [dict setValue: self.number forKey:kNumberKey];
    [dict setValue: self.leaguevinePlayerJson forKey:kLeagueVinePlayerJsonKey];
    
    return dict;
}

-(id) initName:  (NSString*) aName position: (Position) aPosition isMale: (BOOL) isPlayerMale {
    self = [super init];
    if (self) {
        self.name = aName;
        self.position = aPosition;
        self.isMale = isPlayerMale;
    }
    return self;
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    Player* otherPlayer = (Player*) other;
    return [self isPlayerNamed:otherPlayer.name];
}

- (NSUInteger)hash {
    NSUInteger hash = 0;
    hash += [self.name hash];
    return hash;
}

- (NSString* )description {
    return [NSString stringWithFormat:@"Player %@", self.name];
}

-(id)getId {
    return self.name;
}

- (NSComparisonResult)compare:(Player*)anotherPlayer {
    return [self.name caseInsensitiveCompare:anotherPlayer.name];
}

-(NSString*)getDisplayName {
    return [[Team getCurrentTeam]isDiplayingPlayerNumber] && self.number !=  nil && (![self.number isEqualToString: @""]) ? self.number : self.name;
}

-(BOOL)isPlayerNamed: (NSString*)playerName {
    return [self.name caseInsensitiveCompare: playerName] == NSOrderedSame;
}

-(BOOL)isLeaguevinePlayer {
    return self.leaguevinePlayerJson != nil;
}

-(void)setLeaguevinePlayer:(LeaguevinePlayer *)leaguevinePlayer {
    _leaguevinePlayer = leaguevinePlayer;
    if (leaguevinePlayer) {
        NSDictionary* leaguevinePlayerDict = [leaguevinePlayer asDictionary];
        NSError* marshallError;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:leaguevinePlayerDict options:0 error:&marshallError];
        if (marshallError) {
            SHSLog(@"Error creating JSON of leaguevine");
        } else {
            self.leaguevinePlayerJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else {
        self.leaguevinePlayerJson = nil;
    }
}

-(LeaguevinePlayer*)leaguevinePlayer {
    if (_leaguevinePlayer == nil && self.leaguevinePlayerJson) {
        NSError* marshallError;
        NSData* jsonData = [self.leaguevinePlayerJson dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* leaguevinePlayerDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&marshallError];
        if (marshallError) {
            SHSLog(@"Error parsing leaguevine JSON");
        } else {
            _leaguevinePlayer = [LeaguevinePlayer fromDictionary: leaguevinePlayerDict];
        }
    }
    return _leaguevinePlayer;
}

@end

