//
//  Team.m
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Team.h"

#define kArchiveFileName    @"team"
#define kTeamKey            @"team"
#define kPlayersKey         @"players"
#define kNameKey            @"name"
#define kIsMixedKey         @"mixed"

static Team* currentTeam = nil;

@implementation Team
@synthesize players, filePath, name, isMixed,cloudId;

-(id) init  {
    self = [super init];
    if (self) {
        self.players = [[NSMutableArray alloc] init];
        self.filePath = [Team getFilePath];
        self.name = @"Us";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.filePath = [Team getFilePath];
        self.players = [decoder decodeObjectForKey:kPlayersKey]; 
        self.name = [decoder decodeObjectForKey:kNameKey];
        self.isMixed = [decoder decodeBoolForKey:kIsMixedKey];
        self.cloudId = [decoder decodeObjectForKey:kCloudIdKey];
    } 
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeObject:self.players forKey:kPlayersKey]; 
    [encoder encodeObject:self.name forKey:kNameKey]; 
    [encoder encodeBool:self.isMixed forKey:kIsMixedKey]; 
    [encoder encodeObject:self.cloudId forKey:kCloudIdKey]; 
} 

-(NSDictionary*) asDictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue: self.name forKey:kNameKey];
    [dict setValue: self.cloudId forKey:kCloudIdKey];
    [dict setValue: [NSNumber numberWithBool:self.isMixed ] forKey:kIsMixedKey];
    NSMutableArray* arrayOfPlayers = [[NSMutableArray alloc] init];
    for (Player* player in self.players) {
        [arrayOfPlayers addObject:[player asDictionary]];
    }
    [dict setValue: arrayOfPlayers forKey:kPlayersKey];
    return dict;
}

+(Team*)getCurrentTeam {
    @synchronized(self) {
        if (! currentTeam) {
            currentTeam = [[Team alloc] init];    
            
            NSData *data = [[NSData alloc] initWithContentsOfFile: [Team getFilePath]]; 
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] 
                                             initForReadingWithData:data]; 
            Team* loadedTeam = [unarchiver decodeObjectForKey:kTeamKey]; 
            currentTeam = loadedTeam ? loadedTeam : [[Team alloc] init]; 
        }
        return currentTeam;
    }
}

-(void)save {
    NSMutableData *data = [[NSMutableData alloc] init]; 
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] 
                                 initForWritingWithMutableData:data]; 
    [archiver encodeObject: self forKey:kTeamKey]; 
    [archiver finishEncoding]; 
    BOOL success = [data writeToFile:self.filePath atomically:YES]; 
    if (!success) {
        [NSException raise:@"Failed trying to save team" format:@"failed saving team"];
    }
}

+ (NSString*)getFilePath { 
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* documentsDirectory = [paths objectAtIndex:0]; 
    return [documentsDirectory stringByAppendingPathComponent:kArchiveFileName]; 
}

-(NSArray*) getAllPlayers {
    return self.players;
}

-(void) addPlayer: (Player*) player {
    if ([self.players containsObject:player]) {
        [self removePlayer:player]; // don't allow dupes
    }
    [self.players addObject:player];
    
}
-(void) removePlayer: (Player*) player {
    [self.players removeObject:player];
}

-(NSArray*)getInitialOLine {
    return [self.players subarrayWithRange:NSMakeRange(0, MIN([self.players count], 7))];
}

-(NSArray*)getInitialDLine {
    return [self.players subarrayWithRange:NSMakeRange(0, MIN([self.players count], 7))];
}

-(void)sortPlayers {
    [self.players sortUsingComparator:^(id a, id b) {
        NSString* playerNameA = ((Player*)a).name;
        NSString* playerNameB = ((Player*)b).name;
        return [playerNameA caseInsensitiveCompare:playerNameB];
    }];
}

@end
