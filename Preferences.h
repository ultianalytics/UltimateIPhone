//
//  Preferences.h
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweeter.h"

@interface Preferences : NSObject 
    
@property (nonatomic, strong) NSString* tournamentName;
@property (nonatomic, strong) NSString* currentTeamFileName;
@property (nonatomic, strong) NSString* currentGameFileName;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic) int gamePoint;
@property (nonatomic) int timeoutsPerHalf;
@property (nonatomic) int timeoutFloaters;
@property (nonatomic, strong) NSString* userid;
@property (nonatomic) AutoTweetLevel autoTweetLevel;
@property (nonatomic, strong) NSString* twitterAccountDescription;
@property (nonatomic, strong) NSString* leaguevineToken;

+(Preferences*)getCurrentPreferences;
+(NSString*)getFilePath;
-(void)save;

@end




