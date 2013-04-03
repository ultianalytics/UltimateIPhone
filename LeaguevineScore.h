//
//  LeaguevineScore.h
//  UltimateIPhone
//
//  Created by james on 4/2/13.
//  Copyright (c) 2013 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeaguevineScore : NSObject

@property (nonatomic) NSUInteger team1Score;
@property (nonatomic) NSUInteger team2Score;
@property (nonatomic) NSUInteger gameId;
@property (nonatomic) BOOL final;

+(LeaguevineScore*)leaguevineScoreWithGameId: (NSUInteger)gameId;
+(LeaguevineScore*)restoreFrom: (NSString*)filePath;
-(void)save: (NSString*)filePath;

@end
