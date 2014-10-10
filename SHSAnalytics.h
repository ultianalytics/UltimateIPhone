//
//  SHSAnalytics.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 10/10/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kAnalyticsGameStart @"GameStart"
#define kAnalyticsGameFirstUpload @"GameFirstUpload"
#define kAnalyticsGameAutoTweeted @"GameAutoTweeted"
#define kAnalyticsGameScorePostedToLeaguevine @"GameScorePostedToLeaguevine"
#define kAnalyticsGameStatsPostedToLeaguevine @"GameStatsPostedToLeaguevine"

@interface SHSAnalytics : NSObject

+ (SHSAnalytics*)sharedAnalytics;

-(void)initializeAnalytics;

-(void)logGameStart;
-(void)logEvent: (NSString*)eventName ifFirstForGame: (BOOL)onlyLogIfFirstForCurrentGame;
-(void)logEvent: (NSString*)eventName;
-(void)logEvent: (NSString*)eventName withParameters: (NSDictionary*)eventParameters;

@end
