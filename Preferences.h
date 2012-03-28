//
//  Preferences.h
//  Ultimate
//
//  Created by james on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Preferences : NSObject 
    
@property (nonatomic, strong) NSString* tournamentName;
@property (nonatomic, strong) NSString* currentGameFileName;
@property (nonatomic, strong) NSString* filePath;
@property (nonatomic) BOOL isDiplayingPlayerNumber;
@property (nonatomic) int gamePoint;
@property (nonatomic, strong) NSString* userid;
@property (nonatomic) BOOL isTweetingEvents;
@property (nonatomic, strong) NSString* twitterAccountDescription;

+(Preferences*)getCurrentPreferences;
+(NSString*)getFilePath;
-(void)save;

@end




