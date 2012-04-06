//
//  Team.m
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Team.h"
#import "Preferences.h"
#import "TeamDescription.h"

#define kArchiveFileName        @"team"
#define kTeamKey                @"team"
#define kTeamIdKey              @"id"
#define kPlayersKey             @"players"
#define kNameKey                @"name"
#define kIsMixedKey             @"mixed"
#define kDisplayPlayerNumberKey @"displayPlayerNumber"
#define kTeamFileNamePrefixKey  @"team-"

static Team* currentTeam = nil;

@implementation Team
@synthesize teamId, players, name, isMixed, isDiplayingPlayerNumber, cloudId;

+(NSArray*)retrieveTeamDescriptions {
    NSMutableArray* descriptions = [[NSMutableArray alloc] init];
    NSArray* fileNames = [Team getAllTeamFileNames];
    for (NSString* idOfTeam in fileNames) {
        Team* team = [Team readTeam:idOfTeam];
        TeamDescription* teamDesc = [[TeamDescription alloc] initWithId:team.teamId name:team.name];
        [descriptions addObject:teamDesc];
    }
    return descriptions;
}

+(Team*)getCurrentTeam {
    @synchronized(self) {
        if (currentTeam == nil) {
            NSString* currentTeamFileName = [Preferences getCurrentPreferences].currentTeamFileName;
            currentTeam = [self readTeam: currentTeamFileName];    
            if (currentTeam == nil) {
                Team* team = [[Team alloc] init];
                [team save];
                [Preferences getCurrentPreferences].currentTeamFileName = team.teamId;
                [[Preferences getCurrentPreferences] save];
                currentTeam = team;
            }
        }
        return currentTeam;
    }
}

+(BOOL)isCurrentTeam: (NSString*) teamId {
    return [teamId isEqualToString:[Preferences getCurrentPreferences].currentTeamFileName];
}

+(void)setCurrentTeam: (NSString*) teamId {
    currentTeam = [Team readTeam:teamId];
    [Preferences getCurrentPreferences].currentTeamFileName = currentTeam.teamId;
    [[Preferences getCurrentPreferences] save];
}

+(Team*)readTeam: (NSString*) teamId {
    if (teamId == nil) {
        return nil;
    }
    NSString* filePath = [Team getFilePath: teamId]; 
    
    NSData* data = [[NSData alloc] initWithContentsOfFile: filePath]; 
    if (data == nil) {
        return nil;
    } 
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] 
                                     initForReadingWithData:data]; 
    Team* loadedTeam = [unarchiver decodeObjectForKey:kTeamKey]; 
    return loadedTeam;
}

+(NSArray*)getAllTeamFileNames {
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* documentsDirectory = [paths objectAtIndex:0];
    NSArray* directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:NULL];
    
    NSMutableArray* fileNames = [[NSMutableArray alloc] init];
    for (int i = 0; i < (int)[directoryContent count]; i++)
    {
        NSString* fileName = [directoryContent objectAtIndex:i];
        if ([fileName hasPrefix:kTeamFileNamePrefixKey]) {
            [fileNames addObject:fileName];
        }
    }
    return fileNames;
}

+(NSString*)getFilePath: (NSString*) teamdId { 
    NSArray* paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES); 
    NSString* documentsDirectory = [paths objectAtIndex:0]; 
    return [documentsDirectory stringByAppendingPathComponent:teamdId]; 
}

-(NSString*)generateUniqueFileName {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    return [NSString stringWithFormat:@"%@%@", kTeamFileNamePrefixKey, (__bridge NSString*)CFUUIDCreateString(nil, uuidObj)];
}

-(id) init  {
    self = [super init];
    if (self) {
        self.teamId = [self generateUniqueFileName];
        self.players = [[NSMutableArray alloc] init];
        self.name = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder { 
    if (self = [super init]) { 
        self.teamId = [decoder decodeObjectForKey:kTeamIdKey];
        self.players = [decoder decodeObjectForKey:kPlayersKey]; 
        self.name = [decoder decodeObjectForKey:kNameKey];
        self.isMixed = [decoder decodeBoolForKey:kIsMixedKey];
        self.isDiplayingPlayerNumber = [decoder decodeBoolForKey:kDisplayPlayerNumberKey];
        self.cloudId = [decoder decodeObjectForKey:kCloudIdKey];
    } 
    return self; 
} 

- (void)encodeWithCoder:(NSCoder *)encoder { 
    [encoder encodeObject:self.teamId forKey:kTeamIdKey]; 
    [encoder encodeObject:self.players forKey:kPlayersKey]; 
    [encoder encodeObject:self.name forKey:kNameKey]; 
    [encoder encodeBool:self.isMixed forKey:kIsMixedKey];
    [encoder encodeBool:self.isDiplayingPlayerNumber forKey:kDisplayPlayerNumberKey];     
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

-(void)save {
    NSMutableData *data = [[NSMutableData alloc] init]; 
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] 
                                 initForWritingWithMutableData:data]; 
    [archiver encodeObject: self forKey:kTeamKey]; 
    [archiver finishEncoding]; 
    BOOL success = [data writeToFile:[Team getFilePath:self.teamId]atomically:YES]; 
    if (!success) {
        [NSException raise:@"Failed trying to save team" format:@"failed saving team"];
    }
}

-(BOOL)hasBeenSaved {
    NSString* filePath = [Team getFilePath: teamId]; 
	return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

-(void)delete {
    if ([Team isCurrentTeam:self.teamId]) {
        // move "current" to another team
        for (TeamDescription* teamDesc in [Team retrieveTeamDescriptions]) {
            if (teamDesc.teamId != self.teamId) {
                [Team setCurrentTeam:teamDesc.teamId];
                break;
            }
        }
    }
    NSString *path = [Team getFilePath:self.teamId];
	NSError *error;
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])		//Does file exist?
	{
		if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error])	//Delete it
		{
            if (error) {
                NSLog(@"Delete team file error: %@", error);
            }
		}
	}
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
