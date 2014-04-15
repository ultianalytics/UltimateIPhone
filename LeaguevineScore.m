//
//  LeaguevineScore.m
//  UltimateIPhone
//
//  Created by james on 4/2/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import "LeaguevineScore.h"

#define kLeaguevineScore @"LeaguevineScore"
#define kGameId @"gameId"
#define kTeam1Score @"team1Score"
#define kTeam2Score @"team2Score"
#define kFinal @"final"

@implementation LeaguevineScore

+(LeaguevineScore*)leaguevineScoreWithGameId: (NSUInteger)gameId  {
    LeaguevineScore* score = [[LeaguevineScore alloc] init];
    score.gameId = gameId;
    return score;
}

+(LeaguevineScore*)restoreFrom: (NSString*)filePath {
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSData *data = [[NSData alloc] initWithContentsOfFile: filePath];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        LeaguevineScore* lvEvent = [unarchiver decodeObjectForKey:kLeaguevineScore];
        return lvEvent;
    } else {
        return nil;
    }
}

-(void)save: (NSString*)filePath {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]
                                 initForWritingWithMutableData:data];
    [archiver encodeObject: self forKey:kLeaguevineScore];
    [archiver finishEncoding];
    
    NSError* error;
    [data writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if(error != nil) {
        SHSLog(@"Failed trying to save leaguevine score: %@", error);
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.team1Score = [decoder decodeIntForKey:kTeam1Score];
        self.team2Score = [decoder decodeIntForKey:kTeam2Score];
        self.gameId = [decoder decodeIntForKey:kGameId];
        self.final = [decoder decodeBoolForKey:kFinal];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:(int)self.team1Score forKey:kTeam1Score];
    [encoder encodeInt:(int)self.team2Score forKey:kTeam2Score];
    [encoder encodeBool:self.final forKey:kFinal];
    [encoder encodeInt:(int)self.gameId forKey:kGameId];
}

-(NSString*)description {
    return [NSString stringWithFormat: @"LeaguevineScore gameId=%lu,final=%@, team1Score=%lu, team2Score=%lu", (unsigned long)self.gameId, self.final ? @"YES" : @"NO", (unsigned long)self.team1Score, (unsigned long)self.team2Score];
}


@end
