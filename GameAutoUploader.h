//
//  GameAutoUploader.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/4/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Game, Team, CloudRequestStatus;

@interface GameAutoUploader : NSObject

@property (nonatomic, readonly) CloudRequestStatus* lastUploadStatus;

+ (GameAutoUploader*)sharedUploader;

-(BOOL)isAutoUploading;
-(void)submitGameForUpload: (Game*) game ofTeam:(Team*)team;
-(void)flush;
-(void)resetRecentErrors;
-(BOOL)recentUploadsFailing;

@end
