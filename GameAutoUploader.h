//
//  GameAutoUploader.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 9/4/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Game, Team;

@interface GameAutoUploader : NSObject

+ (GameAutoUploader*)sharedUploader;

-(void)submitGameForUpload: (Game*) game ofTeam:(Team*)team;
-(void)flush;

@end
