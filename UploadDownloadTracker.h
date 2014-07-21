//
//  UploadDownloadTracker.h
//  UltimateIPhone
//
//  Created by Jim Geppert on 7/21/14.
//  Copyright (c) 2014 Summit Hill Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadDownloadTracker : NSObject

+(void)updateLastUploadOrDownloadTime: (NSTimeInterval)timestamp forGameId: (NSString*)gameId inTeamId: (NSString*)teamId;
+(NSTimeInterval)lastUploadOrDownloadForGameId: (NSString*)gameId  inTeamId: (NSString*)teamId;

@end
